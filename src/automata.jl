# Interface for manipulating automaton

abstract type AbstractAutomata end 

struct SpotAutomata <: AbstractAutomata
    a::CxxWrap.StdLib.SharedPtrAllocated{Spot.TWAGraph}
end

"""
    split_edges(aut::SpotAutomata)
add dummy edges
"""
function split_edges(aut::SpotAutomata)
    return SpotAutomata(Spot.split_edges(aut.a))
end

"""
    num_states(aut::SpotAutomata)
number of states in the automata
"""
function num_states(aut::SpotAutomata)
    return convert(Int64, Spot.num_states(aut.a[]))
end

"""
    get_init_state_number(aut::SpotAutomata)
number of the initial state in the automata (0-indexed!!)
"""
function get_init_state_number(aut::SpotAutomata)
    return convert(Int64, Spot.get_init_state_number(aut.a[]) + 1)
end

"""
    num_edges(aut::SpotAutomata)
number of edges in the automata
"""
function num_edges(aut::SpotAutomata)
    return convert(Int64, Spot.num_edges(aut.a[]))
end

"""
    atomic_propositions(aut::SpotAutomata)
return a list of atomic propositions used in the automata, as Symbols
"""
function atomic_propositions(aut::SpotAutomata)
    aps = Spot.atomic_propositions(aut.a[])
    return @. Symbol(SpotFormula(copy(aps)))
end

"""
    to_generalized_rabin(aut::SpotAutomata, split=true)
convert the automata to a generalized rabin automata 
if split=true, it adds dummy edges to simplify the labels conditions
"""
function to_generalized_rabin(aut::SpotAutomata, split=true)
    gra = SpotAutomata(Spot.to_generalized_rabin(aut.a))
    if split
        return split_edges(gra)
    end
    return gra
end

"""
    is_deterministic(aut::SpotAutomata)
returns true if the automata is deterministic
"""
function is_deterministic(aut::SpotAutomata)
    return Spot.is_deterministic(aut.a)
end

"""
    edges(aut::SpotAutomata)
returns a list of edges as pairs (src, dest)
"""
function get_edges(aut::SpotAutomata)
    cpp_edges = Spot.get_edges(aut.a[])
    edge_list = Vector{Int64}[convert.(Int64, copy.(c)) .+ 1 for c in copy.(cpp_edges)]
    return Tuple{Int64,Int64}[tuple(c...) for c in edge_list]
end

"""
    get_edges_labels(aut::SpotAutomata)
returns a list of all the edges labels as a SpotFormula.
The edges are labeled by a conjunction of all the atomic proposition.
See spot.split_edges documentation for more information. 
This is inspired from https://spot.lrde.epita.fr/tut24.html
"""
function get_labels(aut::SpotAutomata)
    cpp_labs = Spot.get_labels(aut.a[])
    return @. SpotFormula(copy(cpp_labs))
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
        if Spot.is_tt(lab.f)
            push!(positive_ap, TRUE_CONSTANT)
        elseif !( Spot.is(lab.f, Spot.Not) )
            push!(positive_ap, Symbol(lab))
        else
            return positive_ap
        end
    end
    cpp_aps = Spot.positive_atomic_propositions(lab.f)
    return @. Symbol(SpotFormula(copy(cpp_aps)))
end

"""
    get_rabin_acceptance(aut::SpotAutomata)
Return a Rabin acceptance condition as a list of pairs (Fin, Inf)
where Fin is a set of states to be visited finitely often and Inf inifinitely often 
"""
function get_rabin_acceptance(aut::SpotAutomata)
    fin_inf_sets_cpp = Spot.get_rabin_acceptance(aut.a[])
    fin_inf_sets = Tuple{Set{Int64}, Set{Int64}}[]
    for c in fin_inf_sets_cpp
        state_inf_set = Set{Int64}()
        state_fin_set = Set{Int64}() 
        @assert length(c) == 2
        for (i, cc) in enumerate(c)
            if i == 1
                # add 1 since cpp is 0 indexed
                push!.(Ref(state_fin_set), copy.(cc) .+ 1)
            elseif i == 2 
                # add 1 since cpp is 0 indexed
                push!.(Ref(state_inf_set), copy.(cc) .+ 1)
            end
        end 
        push!(fin_inf_sets, (state_fin_set, state_inf_set))
    end
    return fin_inf_sets
end

## Rendering

function plot_automata(aut::SpotAutomata)
    texstr = mktempdir() do path
        dotfile = joinpath(path, "graph.dot")
        open(dotfile, "w") do f
            redirect_stdout(f) do 
                    Spot.print_dot(aut.a)
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
