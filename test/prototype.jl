using Revise
using Spot 
using LightGraphs
using MetaGraphs

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