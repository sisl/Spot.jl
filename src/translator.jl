## LTL to automata 
"""

    LTLTranslator 

Translates a Linear Temporal Logic formula to an automata 

# Fields 
- tgba::Bool = true  outputs Transition-based Generalized Büchi Automata
- buchi::Bool = false outputs state-based Büchi automata
- monitor::Bool = false outputs monitors
- deterministic::Bool = true combined with generic, will do whatever it takes to produce a deterministic automaton, and may use any acceptance condition
- generic::Bool = true 
- parity::Bool = true combined with deterministic, will produce a deterministic automaton with parity acceptance
- state_based_acceptance::Bool = true define the acceptance using states
"""
@with_kw struct LTLTranslator
    tgba::Bool = true
    buchi::Bool = false
    monitor::Bool = false
    deterministic::Bool = false
    generic::Bool = false
    parity::Bool = false 
    state_based_acceptance::Bool = false 
end


"""
    translate(translator::LTLTranslator, ltl::string)

translate an LTL formula into an automata
Options are set using the translator object. More options can be passed as strings.
See https://spot.lrde.epita.fr/ltl2tgba.html for extra options that are not in LTLTranslator
"""
function translate(translator::LTLTranslator, ltl::AbstractString, args...)
    options = String[]
    translator.buchi ? push!(options, "BA") : nothing
    translator.monitor ? push!(options, "monitor") : nothing
    translator.deterministic ? push!(options, "deterministic") : nothing 
    translator.generic ? push!(options, "generic") : nothing 
    translator.parity ? push!(options, "parity") : nothing 
    translator.state_based_acceptance ? push!(options, "sbacc") : nothing 
    return spot.translate(ltl, options..., args...)
end