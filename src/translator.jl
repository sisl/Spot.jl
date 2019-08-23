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
Options are set using the translator object.
See https://spot.lrde.epita.fr/ltl2tgba.html for extra options that are not in LTLTranslator
"""
function translate(translator::LTLTranslator, ltl::SpotFormula)
    trans = @cxx spot::translator()
    if translator.buchi 
        autom_type = @cxx spot::postprocessor::BA
        @cxx trans -> set_type(autom_type)
    end
    if translator.monitor
        autom_type = @cxx spot::postprocessor::Monitor
        @cxx trans -> set_type(autom_type)
    end
    if translator.deterministic
        autom_pref = @cxx spot::postprocessor::Deterministic
        @cxx trans -> set_pref(autom_pref)
    end
    if translator.generic
        autom_type = @cxx spot::postprocessor::Generic
        @cxx trans -> set_type(autom_type)
    end
    if translator.parity
        autom_type = @cxx spot::postprocessor::Parity
        @cxx trans -> set_type(autom_type)
    end
    if translator.state_based_acceptance
        autom_pref = @cxx spot::postprocessor::SBAcc
        @cxx trans -> set_pref(autom_pref) 
    end
    aut = @cxx trans -> run(ltl.f)
    return SpotAutomata(aut)
end