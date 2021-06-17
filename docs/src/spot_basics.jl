# # Basics of Spot.jl

# For more extensive tutorials see the original [Spot documentation](https://spot.lrde.epita.fr/tut.html).

# ## Parsing LTL Formulas

# Spot.jl provides a string macro to write ltl formulas: `ltl" ... "`, which will create a `SpotFormula` object.

using Spot

safety = ltl"!crash U goal" 
surveillance = ltl"G (F (a & (F (b & Fc))))"

# ## Conversion to Automata

# Use the `LTLtranslator` constructor to specify the translation options, then use the `translate` method to convert the LTL formula into an automata.

# `LTLTranslator`:
# - `tgba::Bool = true` outputs Transition-based Generalized Büchi Automata
# - `buchi::Bool = false` outputs state-based Büchi automata
# - `monitor::Bool = false` outputs monitors
# - `deterministic::Bool = true` combined with generic, will do whatever it takes to produce a deterministic automaton, and may use any acceptance condition
# - `generic::Bool = true`
# - `parity::Bool = true` combined with deterministic, will produce a deterministic automaton with parity acceptance
# - `state_based_acceptance::Bool = true` define the acceptance using states

translator = LTLTranslator()
safety_aut = translate(translator, safety)

translator = LTLTranslator(buchi=true, deterministic=true, state_based_acceptance=true)
surveillance_aut = translate(translator, surveillance)

# ## Display Automata 

# In environment like the vscode julia IDE or in jupyer notebooks, automata will be automatically displayed as a tikz picture.
# In non interactive environment, you can get a tikzpicture object by calling `plot_automata`. This object can then be saved to a file and visualized. 
using TikzPictures
pic = plot_automata(surveillance_aut)
save(PDF("test"), pic)


# ## Deterministic Rabin Automata
# Spot.jl provides a Deterministic Rabin Automata structure which is pure Julia. It can be constructed directly from a LTL formula.

dra = DeterministicRabinAutomata(surveillance)
nextstate(dra, 4, (:a,:b,:c))
