module Spot

# Package code goes here.
using PyCall
using Parameters


function __init__()
    global spot = pywrap(pyimport("spot"))
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
    atomic_prop_collect

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
    parse_fin_inf_sets

include("translator.jl")
include("automata.jl")
include("rabin_automata.jl")

end # module spot