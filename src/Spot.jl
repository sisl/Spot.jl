module Spot

using CxxWrap
using Parameters
using TikzPictures
using Graphs
using MetaGraphs
using Spot_julia_jll
@wrapmodule(Spot_julia_jll.get_libspot_julia_path)

function __init__()
    @initcxx
end

export
    SpotFormula,
    @ltl_str,
    is_ltl_formula,
    is_eventual,
    is_sugar_free_ltl,
    is_literal,
    is_boolean,
    is_reachability,
    is_constrained_reachability,
    atomic_prop_collect

include("formulas.jl")


export
    AbstractAutomata,
    SpotAutomata,
    split_edges,
    num_states,
    num_edges,
    get_init_state_number,
    is_deterministic,
    to_generalized_rabin,
    atomic_propositions,
    get_edges,
    get_labels,
    label_to_array,
    get_rabin_acceptance,
    plot_automata

include("automata.jl")


export
    LTLTranslator,
    translate

include("translator.jl")

export
    DeterministicRabinAutomata,
    nextstate

include("rabin_automata.jl")

end
