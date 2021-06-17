# Basics of Spot.jl

For more extensive tutorials see the original [Spot documentation](https://spot.lrde.epita.fr/tut.html).

## Parsing LTL Formulas

Spot.jl provides a string macro to write ltl formulas: `ltl" ... "`, which will create a `SpotFormula` object.

```jldoctest basics
using Spot

safety = ltl"!crash U goal" 
surveillance = ltl"G (F (a & (F (b & Fc))))"

# output

"GF(a & F(b & Fc))"
```

## Conversion to Automata

Use the `LTLtranslator` constructor to specify the translation options, then use the `translate` method to convert the LTL formula into an automata.

`LTLTranslator`:
- `tgba::Bool = true` outputs Transition-based Generalized Büchi Automata
- `buchi::Bool = false` outputs state-based Büchi automata
- `monitor::Bool = false` outputs monitors
- `deterministic::Bool = true` combined with generic, will do whatever it takes to produce a deterministic automaton, and may use any acceptance condition
- `generic::Bool = true`
- `parity::Bool = true` combined with deterministic, will produce a deterministic automaton with parity acceptance
- `state_based_acceptance::Bool = true` define the acceptance using states
