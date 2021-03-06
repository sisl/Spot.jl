using Revise
using Spot 

# using Cxx

f = ltl"!a U b"

translator = LTLTranslator(deterministic=true, buchi=true, state_based_acceptance=true)

aut = translate(translator, f)

dra = DeterministicRabinAutomata(f)

f = ltl"(a U b) & GFc & GFd"

translator = LTLTranslator(deterministic=true, generic=true, state_based_acceptance=true)

a = translate(LTLTranslator(), f)

edges(a)

labs = get_labels(a)

label_to_array(labs[end])

const TRUE_CONSTANT = :true_constant

function label_to_array(lab::SpotFormula)
    @assert is_boolean(lab)
    positive_ap = Symbol[]
    if length(lab) <= 1
        if @cxx lab.f->is_tt()
            push!(positive_ap, TRUE_CONSTANT)
        elseif !( @cxx lab.f->is(spot::op::Not) )
            push!(positive_ap, Symbol(lab))
        else
            return positive_ap
        end
    end
    cpp_aps = icxx""" 
    std::vector<spot::formula> positive_aps;
    for (auto ap: $(f.f)) {
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

function plot(aut)


icxx"""$(a.a)->get_dict();"""


function get_edges_labels(aut::SpotAutomata)
    cpp_edges, cpp_labs = icxx"""
        std::vector<spot::formula> labs_list;
        auto bdict = $(aut.a)->get_dict();
        std::vector<std::vector<unsigned int>> edge_list;
        for (auto& e: $(aut.a)->edges())
            {
                labs_list.push_back(spot::bdd_to_formula(e.cond, bdict));
                std::vector<unsigned int> edge;
                edge.push_back(e.src);
                edge.push_back(e.dst);
            }
    """
    return cpp_edges, cpp_labs
end

cl = get_edges_labels(a)

cxx"#include <typeinfo>"

edge_it = icxx"""$(a.a)->edges();"""

cpp_edges = icxx"""
    std::vector<std::vector<unsigned int>> edge_list;
    for (auto& e: $edge_it)
        {
            std::vector<unsigned int> edge;
            edge.push_back(e.src);
            edge.push_back(e.dst);
            edge_list.push_back(edge);
            std::cout << " edge(" << e.src << "-> " << e.dst << ")\n";
        }
    edge_list;
"""

edges = Vector{Tuple{Int64, Int64}}(undef, length(cpp_edges))
for (i, e) in enumerate(cpp_edges)
    edges[i] = (e[0], e[1])) # this is a cpp vector!
end



is_reachability(ltl"F reach")

atomic_prop_collect(f)

function isreachability(f::SpotFormula)
    icxx"""
        spot::formula ff = $(f.f);
        ff.is(spot::op::F) && ff[0].is_boolean();
    """
end

## Get dot string 
translator = LTLTranslator(state_based_acceptance=true)
aut = translate(translator, ltl"! c U a & !c U b");

autdot = aut.to_str(format="dot");


texstr = mktempdir() do path
    dotfile = joinpath(path, "graph.dot")
    open(dotfile, "w") do f
        write(f, autdot)
    end
    xdotfile = joinpath(path, "graph.xdot")
    run(pipeline(`dot -Txdot $dotfile`, stdout=xdotfile))
    texstr = read(run(`dot2tex $xdotfile`), String)
end

using TikzPictures

run(`dot -Txdot test.dot | dot2tex > test.tex`)


surveillance = ltl"G (F (a & (F (b & Fc))))" 
safety = ltl"!a U b"

surveillance = ltl"G F a"

dra = DeterministicRabinAutomata(surveillance)

translator = LTLTranslator(deterministic=true, buchi=true, state_based_acceptance=true)
aut = SpotAutomata(translate(translator, safety))
dra = to_generalized_rabin(aut)

avoid = ltl"F!c"

dra = DeterministicRabinAutomata(avoid)
aut = spot.split_edges(spot.to_generalized_rabin(translate(translator, avoid)))


for e in edges(dra.transition)
    println(e)
end

props(dra.transition, Edge(2,2))[:cond]

nextstate(dra, 2, ())



edgelist, labels = get_edges_labels(SpotAutomata(aut))

conditions = label_to_array.(labels)

lab = labels[end]



label_to_array(lab)

lab.f[:ap_name]()

collect(ap for ap in lab.f)

for ap in lab.f
    println(ap)
end

lab.f[:_is](spot.op_Not)

length(lab.f)

labs = ltl"!a & !c"

length(labs.f)

dra 

acc = aut.a[:acc]()
israbin, acc_sets = acc[:is_rabin_like]()

s = acc_sets[1]

q0 = get_init_state_number(dra)

q0 = 2

nextstate(dra, q0, (:a,:b))

mg = dra.transition

q = 2
lab = (:a,:b)

src(Edge(2, 1)) == q &&  (lab ∈ props(dra.transition, Edge(2,1))[:cond])

collect(edges(dra.transition))

has_edge(dra.transition, 2, 1)

props(mg, Edge(2,1))[:cond]

translator = LTLTranslator()
safety_aut = translate(translator, safety)
ra  = to_generalized_rabin(SpotAutomata(safety_aut))
is_deterministic(ra)

edge_list, labels = get_edges_labels(ra)

sdg = SimpleDiGraph(2)
add_edge!(sdg, 1, 1)
add_edge!(sdg, 2, 1)
add_edge!(sdg, 2, 2)
collect(edges(sdg))

mg = MetaDiGraph(sdg)
collect(edges(mg))