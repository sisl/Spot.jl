using Spot
using Test
using LightGraphs
using MetaGraphs

@testset "LTL Parsing" begin
    f = spot.formula("p1 U p2 R (p3 & !p4)")
    # convert formula to string
    @test f[:to_str]() == "p1 U (p2 R (p3 & !p4))"
    # check properties
    @test f[:is_ltl_formula]()
    f = ltl"p1 U p2 R (p3 & !p4)" # check constructor
end

@testset "LTL To Automata" begin 
    ltl = ltl"(a U b) & GFc & GFd"
    translator = LTLTranslator(deterministic=true, generic=true, state_based_acceptance=true)
    a = translate(translator, ltl)
end

@testset "SpotAutomata" begin
    ltl = ltl"(a U b) & GFc & GFd"
    a = translate(LTLTranslator(), ltl)
    sa = SpotAutomata(a)
    @test num_states(sa) == 2
    @test get_init_state_number(sa) == 0 # 0 indexed!
    @test num_edges(sa) == 6
    @test atomic_propositions(sa) == [:a, :b, :c, :d]
end

@testset "DRA" begin 
    dra = DeterministicRabinAutomata(ltl"(a U b) & GFc & GFd")
end