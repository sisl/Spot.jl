#= 
From the spot documentation: 
"An ω-automaton can be defined as a labeled directed graph, plus an initial state and an acceptance condition. "
=#

"""
    DeterministicRabinAutomata
Datastructure representing a deterministic Rabin Automata. It is parameterized by the state type Q.
"""
struct DeterministicRabinAutomata <: AbstractAutomata
    initial_state::Int64
    states::Vector{Int64}
    transition
    fin_set::Set{Int64}
    inf_set::Set{Int64}
end

# extract a Rabin Automata from an LTL formula using Spot.jl
function DeterministicRabinAutomata(ltl::AbstractString, 
                                    translator::LTLTranslator = LTLTranslator(deterministic=true, generic=true, state_based_acceptance=true))
    aut = SpotAutomata(translate(ltl, translator))
    states = 1:num_states(aut)
    initial_state = initialstate(aut) + 1 # python is 0 indexed
end


