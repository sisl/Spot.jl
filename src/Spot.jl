__precompile__(false)
module Spot

using Cxx
using Libdl
using Parameters
using TikzPictures
using LightGraphs
using MetaGraphs


const depfile = joinpath(@__DIR__, "..", "deps", "deps.jl")
if isfile(depfile)
    include(depfile)
else
    error("libspot not properly installed. Please run Pkg.build(\"Spot\")")
end

const path_to_header = joinpath(@__DIR__, "..", "deps", "usr", "include")

function __init__()
    addHeaderDir(path_to_header, kind=C_System)
    Libdl.dlopen(libspot, Libdl.RTLD_GLOBAL)
    
    cxx"#include <iostream>"
    cxx"#include <vector>"
    cxx"#include <tuple>"

    # formula
    cxx"#include <spot/tl/formula.hh>"
    cxx"#include <spot/tl/parse.hh>"
    cxx"#include <spot/tl/print.hh>"
    cxx"#include <spot/tl/apcollect.hh>"

    # automata
    cxx"#include <spot/twa/formula2bdd.hh>"
    cxx"#include <spot/twa/acc.hh>"
    cxx"#include <spot/twaalgos/translate.hh>"
    cxx"#include <spot/twaalgos/dot.hh>"
    cxx"#include <spot/twaalgos/isdet.hh>"
    cxx"#include <spot/twaalgos/split.hh>"
    cxx"#include <spot/twaalgos/totgba.hh>"
end

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
    AbstractAutomata,
    SpotAutomata,
    num_states,
    num_edges,
    get_init_state_number,
    is_deterministic,
    to_generalized_rabin,
    split_edges,
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

end # module spot