using Spot
using Test

@testset "LTL Parsing" begin
    f = spot.formula("p1 U p2 R (p3 & !p4)")
    # convert formula to string
    @test f[:to_str]() == "p1 U (p2 R (p3 & !p4))"
    # check properties
    @test f[:is_ltl_formula]()
    f = ltl"p1 U p2 R (p3 & !p4)" # check constructor
    @test is_ltl_formula(f)
    @test is_eventual(ltl"F a")
    @test is_sugar_free_ltl(ltl"a & b | c")
    @test is_literal(ltl"a")
    @test is_literal(ltl"!a")
    @test !is_literal(ltl"a & b")
    @test is_boolean(ltl"a & b | c")
    @test is_reachability(ltl"F reach")
    @test is_constrained_reachability(ltl"!avoid U reach")
    @test atomic_prop_collect(ltl"a & b & c & d") == [:a,:b,:c,:d]
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
    @test sa == SpotAutomata(a, false)
    @test num_states(sa) == 2
    @test get_init_state_number(sa) == 1
    @test num_edges(sa) == 6
    @test atomic_propositions(sa) == [:a, :b, :c, :d]
end

@testset "DRA" begin 
    dra = DeterministicRabinAutomata(ltl"!a U b")
    @test num_states(dra) == 2
    @test get_init_state_number(dra) == 2
    @test nextstate(dra, 2, (:a, :b)) == 1
    @test nextstate(dra, 2, ()) == 2
    @test dra.acc_sets == [(Set([]), Set([1]))]
end