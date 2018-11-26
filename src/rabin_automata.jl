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
    states::AbstractVector{Int64}
    transition::MetaDiGraph{Int64}
    APs::Vector{Symbol}
    acc_sets::Vector{Tuple{Set{Int64}, Set{Int64}}}
end

# extract a Rabin Automata from an LTL formula using Spot.jl
function DeterministicRabinAutomata(ltl::SpotFormula, 
                                    translator::LTLTranslator = LTLTranslator(deterministic=true, buchi=true, state_based_acceptance=true))
    aut = SpotAutomata(translate(translator, ltl))
    dra = to_generalized_rabin(aut)
    @assert is_deterministic(dra)
    states = 1:num_states(dra)
    initial_state = get_init_state_number(dra) 
    APs = atomic_propositions(dra)
    edgelist, labels = get_edges_labels(dra)
    sdg = SimpleDiGraph(num_states(dra))
    for e in edgelist
        add_edge!(sdg, e)
    end
    transition = MetaDiGraph(sdg)
    conditions = label_to_array.(labels)
    conditions = broadcast(x -> tuple(x...), conditions)
    for (e, l) in zip(edgelist, conditions)
        if haskey(props(transition, Edge(e...)), :cond)
            push!(props(transition, Edge(e...))[:cond], l)
        else
            set_prop!(transition, Edge(e...), :cond, Set{Tuple{Vararg{Symbol,N} where N}}([l]))
        end
    end
    acc_sets = get_rabin_acceptance(dra)
    return DeterministicRabinAutomata(initial_state, states, transition, APs, acc_sets)
end

num_states(aut::DeterministicRabinAutomata) = length(aut.states)

get_init_state_number(aut::DeterministicRabinAutomata) = aut.initial_state

get_rabin_acceptance(aut::DeterministicRabinAutomata) = aut.acc_sets

function nextstate(dra::DeterministicRabinAutomata, q::Int64, lab::NTuple{N,Symbol}) where N
    next_states = neighbors(dra.transition, q)
    edge_it = filter_edges(dra.transition, (g, e) -> (src(e) == q) && (lab ∈ props(g, e)[:cond]))
    edge_list = collect(edge_it)
    if isempty(edge_list)
        return nothing
    else
        @assert length(edge_list) == 1 "from state $q with label $lab"
        return dst(first(edge_list))
    end 
end
