# Interface for manipulating automaton

abstract type AbstractAutomata end 

struct SpotAutomata <: AbstractAutomata
    a::Cxx.CxxCore.CppValue
end

"""
    split_edges(aut::SpotAutomata)
add dummy edges
"""
function split_edges(aut::SpotAutomata)
    return SpotAutomata(@cxx spot::split_edges(aut.a))
end

function num_states(aut::SpotAutomata)
    return convert(Int64, icxx"""$(aut.a)->num_states();""")
end

function get_init_state_number(aut::SpotAutomata)
    return convert(Int64, icxx"""$(aut.a)->get_init_state_number();""") + 1
end

function num_edges(aut::SpotAutomata)
    return convert(Int64, icxx"""$(aut.a)->num_edges();""")
end

function atomic_propositions(aut::SpotAutomata)
    aps = icxx"""$(aut.a)->ap();"""
    return [Symbol(SpotFormula(ap)) for ap in aps]
end

function to_generalized_rabin(aut::SpotAutomata, split=true)
    gra = SpotAutomata(@cxx spot::to_generalized_rabin(aut.a))
    if split
        return split_edges(gra)
    end
    return gra
end

function is_deterministic(aut::SpotAutomata)
    return icxx"""spot::is_deterministic($(aut.a));"""
end

"""
    edges(aut::SpotAutomata)

returns a list of edges as pairs (src, dest)
"""
function get_edges(aut::SpotAutomata)
    cpp_edges = icxx"""
        std::vector<std::vector<unsigned int>> edge_list;
        for (auto& e: $(aut.a)->edges())
            {
                std::vector<unsigned int> edge;
                edge.push_back(e.src);
                edge.push_back(e.dst);
                edge_list.push_back(edge);
            }
        edge_list;
    """

    edges = Vector{Tuple{Int64, Int64}}(undef, length(cpp_edges))
    for (i, e) in enumerate(cpp_edges)
        edges[i] = (e[0] + 1, e[1] + 1) # this is a cpp vector, so it is 0 index!
    end
    return edges
end

"""
    get_edges_labels(aut::SpotAutomata)
returns a list of all the edges labels as a SpotFormula.
The edges are labeled by a conjunction of all the atomic proposition.
See spot.split_edges documentation for more information. 
This is inspired from https://spot.lrde.epita.fr/tut24.html
"""
function get_labels(aut::SpotAutomata)
    cpp_labs = icxx"""
        std::vector<spot::formula> labs_list;
        auto bdict = $(aut.a)->get_dict();
        for (auto& e: $(aut.a)->edges())
            {
                spot::formula f = spot::bdd_to_formula(e.cond, bdict);
                labs_list.push_back(f);
            }
        labs_list;
    """
    return [SpotFormula(f) for f in cpp_labs]
end

const TRUE_CONSTANT = :true_constant

"""
    label_to_array(lab::SpotFormula)
convert a conjunction into an array of symbols. 
The outputs is the list of AP that are true in the input formula
"""
function label_to_array(lab::SpotFormula)
    @assert is_boolean(lab)
    positive_ap = Symbol[]
    if length(lab) <= 1
        if @cxx lab.f->is_tt()
            push!(positive_ap, TRUE_CONSTANT)
        elseif !( @cxx lab.f->is(@cxx spot::op::Not) )
            push!(positive_ap, Symbol(lab))
        else
            return positive_ap
        end
    end
    cpp_aps = icxx""" 
    std::vector<spot::formula> positive_aps;
    for (auto ap: $(lab.f)) {
        if ( !ap.is(spot::op::Not) ){
            positive_aps.push_back(ap);
        }
    }
    positive_aps;
    """
    for ap in cpp_aps
        push!(positive_ap, Symbol(SpotFormula(ap)))
    end
    return positive_ap
end

"""
    get_rabin_acceptance(aut::SpotAutomata)
Return a Rabin acceptance condition as a list of pairs (Fin, Inf)
where Fin is a set of states to be visited finitely often and Inf inifinitely often 
"""
function get_rabin_acceptance(aut::SpotAutomata)
    acc = icxx"$(aut.a)->acc();"
    rabin_pairs = icxx"""
                std::vector<spot::acc_cond::rs_pair> pairs;
                $acc.is_rabin_like(pairs);
                pairs;
                """
    @assert !isempty(rabin_pairs) "SpotError: automata is not Rabin like"
    fin_inf_sets = Vector{Tuple{Set{Int64}, Set{Int64}}}(undef, length(rabin_pairs))
    for (i,s) in enumerate(rabin_pairs)
        stateinfset = Set{Int64}()
        statefinset = Set{Int64}()
        infset = convert(Set{Int64}, icxx"$s.inf.sets();")
        finset = convert(Set{Int64}, icxx"$s.fin.sets();")


        for state in 1:num_states(aut)
            stateset = convert(Set{Int64}, icxx"$(aut.a)->state_acc_sets($state - 1).sets();")
            if !isempty(intersect(infset,stateset))
                push!(stateinfset, state)
            elseif !isempty(intersect(finset, stateset))
                push!(statefinset, state)
            end
        end
        fin_inf_sets[i] = (statefinset, stateinfset)
    end
    return fin_inf_sets
end

const AccCond = Cxx.CxxCore.CppRef{Cxx.CxxCore.CppBaseType{Symbol("spot::acc_cond")},(false, false, false)}

function is_rabin_like(acc::AccCond)
    rabin = icxx"""
    std::vector<spot::acc_cond::rs_pair> pairs;
    $acc.is_rabin_like(pairs);
    """
    return convert(Bool, rabin)
end

const MarkContainer = Cxx.CxxCore.CppValue{Cxx.CxxCore.CxxQualType{Cxx.CxxCore.CppBaseType{Symbol("spot::internal::mark_container")},(false, false, false)},4}

function Base.convert(::typeof(Set{Int64}), mc::MarkContainer)
    v = icxx"""
        std::vector<unsigned int> vec;
        for (unsigned int s: $mc){
            vec.push_back(s);
        }
        vec;
    """
    return Set(collect(Int64, v))
end

## Rendering

function plot_automata(aut::SpotAutomata)
    texstr = mktempdir() do path
        dotfile = joinpath(path, "graph.dot")
        open(dotfile, "w") do f
            redirect_stdout(f) do 
                    icxx"spot::print_dot(std::cout, $(aut.a));"
            end
        end
        xdotfile = joinpath(path, "graph.xdot")
        run(pipeline(`dot -Txdot $dotfile `, stdout=xdotfile))
        texfile = joinpath(path, "graph.tex")
        run(`dot2tex -tmath --figonly $xdotfile -o $texfile`)

        # a bit hacky, replace the logical characters by latex command
        texstr = open(texfile) do f
            texstr = read(f, String)
            texstr = replace(texstr, "&" => " \\land ")
            texstr = replace(texstr, "!" => " \\lnot ")
            texstr = replace(texstr, "|" => "\\lor")
    #         texstr = replace(texstr, "\$[Büchi]\$" => "[B\\\"uchi]")
        end

        return texstr
    end
    return TikzPicture(texstr, preamble="\n\\usepackage{amsmath,amsfonts,amssymb}\n\\usetikzlibrary{snakes,arrows,shapes}")
end

function Base.show(f::IO, a::MIME"image/svg+xml", aut::SpotAutomata)
 	show(f, a, plot_automata(aut))
end
