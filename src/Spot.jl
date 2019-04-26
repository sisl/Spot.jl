module Spot

# Package code goes here.
using PyCall
using Parameters
using LightGraphs
using MetaGraphs

const spot = PyNULL()

function __init__()
    pyversion = PyCall.pyversion
    pythonspot = "../deps/spot/lib/python"*string(pyversion.major)*"."*string(pyversion.minor)*"/site-packages/"
    pushfirst!(PyVector(pyimport("sys").path),joinpath(dirname(@__FILE__), pythonspot))
    # global spot = pyimport("spot")
    copy!(spot, pyimport("spot"))
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
    is_boolean,
    atomic_prop_collect,
    is_reachability,
    is_constrained_reachability,
    @ltl_str

include("formulas.jl")

export
    LTLTranslator,
    translate

include("translator.jl")

export
    AbstractAutomata,
    SpotAutomata,
    num_states,
    num_edges,
    get_init_state_number,
    get_edges_labels,
    atomic_propositions,
    label_to_function,
    label_to_array,
    get_rabin_acceptance,
    to_generalized_rabin,
    is_deterministic,
    DeterministicRabinAutomata,
    nextstate

include("automata.jl")
include("rabin_automata.jl")

end # module spot