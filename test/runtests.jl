using Spot
using Test
using NBInclude
using TikzPictures

@testset "LTL Parsing" begin
    f = SpotFormula("p1 U p2 R (p3 & !p4)")
    # convert formula to string
    @test string(f) == "p1 U (p2 R (p3 & !p4))"
    # check properties
    @test is_ltl_formula(f)
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
    f1 = ltl"(a U b) & GFc & GFd"
    translator = LTLTranslator(deterministic=true, generic=true, state_based_acceptance=true)
    a = translate(translator, f1)
    translator = LTLTranslator(buchi=true)    
    b = translate(translator, f1)
    translator = LTLTranslator(parity=true)    
    c = translate(translator, f1)
end

@testset "SpotAutomata" begin
    ltl = ltl"(a U b) & GFc & GFd"
    a = translate(LTLTranslator(), ltl)
    @test num_states(a) == 2
    @test get_init_state_number(a) == 1
    @test num_edges(a) == 6
    @test atomic_propositions(a) == [:a, :b, :c, :d]
    sa = split_edges(a)
    @test num_states(sa) == num_states(a)
    @test num_edges(sa) > num_edges(a)
    length(get_edges(a)) == num_edges(a)
    length(get_labels(a)) == num_edges(a)
    ga = to_generalized_rabin(a) 
    @test num_states(ga) == num_states(a) # TODO find better test
    f = ltl"!a"
    b = translate(LTLTranslator(), f)
    b = to_generalized_rabin(b)
    b = split_edges(b)
    labs = get_labels(b)
    @test length(labs) == 1
    aps = label_to_array.(labs)
    @test length(aps) == 1 
    @test isempty(aps[1])
end


@testset "save plot" begin
    ltl = ltl"(a U b) & GFc & GFd"
    a = translate(LTLTranslator(), ltl)
    p = plot_automata(a)
    save(PDF("test"), p)
end

@testset "DRA" begin 
    dra = DeterministicRabinAutomata(ltl"!a U b")
    @test num_states(dra) == 2
    @test get_init_state_number(dra) == 1
    @test nextstate(dra, 1, ()) == 1
    @test nextstate(dra, 1,  (:b,)) == 2
    @test nextstate(dra, 2, (:a,:b)) == 2
    @test dra.acc_sets == [(Set([]), Set([2]))]
end

@testset "doc" begin 
    @nbinclude(joinpath(@__DIR__, "..", "docs", "spot_basic_tutorial.ipynb"))
end
