module Spot

# Package code goes here.
using PyCall
using Parameters
using LightGraphs
using MetaGraphs

function __init__()
    pushfirst!(PyVector(pyimport("sys")["path"]),joinpath(dirname(@__FILE__), "../deps/spot/lib/python3.6/site-packages/spot"))
    global spot = pywrap(pyimport("spot"))
    spot.setup() # for display style
end

export 
    spot

export
    SpotFormula,
    is_ltl_formula,
    to_str,
    is_eventual,
    is_sugar_free_ltl,
    is_literal,
    atomic_prop_collect,
    is_constrained_reachability,
    @ltl_str

include("formulas.jl")

export
    LTLTranslator,
    translate,
    AbstractAutomata,
    SpotAutomata,
    num_states,
    num_edges,
    get_init_state_number,
    get_edges_labels,
    atomic_propositions,
    label_to_function,
    label_to_array,
    get_fin_inf_sets,
    to_generalized_rabin,
    is_deterministic,
    DeterministicRabinAutomata

include("translator.jl")
include("automata.jl")
include("rabin_automata.jl")

end # module spot