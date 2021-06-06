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
    cpptrans = Spot.Translator()
    if translator.tgba
        Spot.set_type(cpptrans, Spot.TGBA)
    end
    if translator.buchi 
        Spot.set_type(cpptrans, Spot.BA)
    end
    if translator.monitor
        Spot.set_type(cpptrans, Spot.Monitor)
    end
    if translator.generic
        Spot.set_type(cpptrans, Spot.Generic)
    end
    if translator.parity
        Spot.set_type(cpptrans, Spot.Parity)
    end
    if translator.state_based_acceptance
        Spot.set_pref(cpptrans, Spot.SBAcc)
    end
    aut = Spot.run_translator(cpptrans, ltl.f)
    return SpotAutomata(aut)
end
