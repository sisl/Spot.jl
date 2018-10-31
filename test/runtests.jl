using Revise
using Spot
using Test

@testset "LTL Parsing" begin
    f = spot.formula("p1 U p2 R (p3 & !p4)")
    # convert formula to string
    @test f[:to_str]() == "p1 U (p2 R (p3 & !p4))"
    # check properties
    @test f[:is_ltl_formula]()
end

@testset "LTL To Automata" begin 
    ltl = "(a U b) & GFc & GFd"
    translator = LTLTranslator(deterministic=true, generic=true, state_based_acceptance=true)
    a = translate(translator, ltl)
end

@testset "SpotAutomata" begin
    ltl = "(a U b) & GFc & GFd"
    a = translate(LTLTranslator(), ltl)
    sa = SpotAutomata(a)
    @test num_states(sa) == 2
    @test get_init_state_number(sa) == 0 # 0 indexed!
    @test num_edges(sa) == 6
    @test atomic_propositions(sa) == [:a, :b, :c, :d]
end

ltl = "(a U b) & GFc & GFd"
sa = SpotAutomata(translate(LTLTranslator(deterministic=true, generic=true, state_based_acceptance=true), ltl))
edges, labels = get_edges_labels(sa)
ns = num_states(sa)

APs = atomic_propositions(sa)

conditions = label_to_function.(Ref(APs), labels)


using LightGraphs
using MetaGraphs

sdg = SimpleDiGraph(ns)
for e in edges
    add_edge!(sdg, e)
end

mg = MetaGraph(sdg)

for (e, l) in zip(edges, conditions)
    set_prop!(mg, Edge(e[1], e[2]), :cond, l)
end

inf_set, fin_set = parse_inf_fin_sets(sa)

next_states = outneighbors(mg, 5)

# label
l = [:a, :c]




props(mg, Edge(1,2))[:cond](false, true, true, true)

l = sa.a[:get_acceptance]()[:__str__]()

fin_str = match(r"Fin\(\d+\)", l).match
fin_idx = parse(Int64, match(r"\d+", fin_str).match)
inf_str = match(r"Inf\(\d+\)", l).match
inf_idx = parse(Int64, match(r"\d+", inf_str).match) 

inf_set = Set{Int64}()
for m in eachmatch(r"Inf\(\d+\)", l)
    push!(inf_set, parse(Int64, match(r"\d+",m.match).match))
end

## Get number of states and edges 
n_states = a[:num_states]()
n_edges = a[:num_edges]()

## Check if a is deterministic 
a[:is_deterministic]()

## get initial state


