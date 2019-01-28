# Spot

[![Build Status](https://travis-ci.org/sisl/Spot.jl.svg?branch=master)](https://travis-ci.org/sisl/Spot.jl)
[![CodeCov](https://codecov.io/gh/sisl/Spot.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/sisl/Spot.jl)
[![Coveralls](https://coveralls.io/repos/github/sisl/Spot.jl/badge.svg?branch=master)](https://coveralls.io/github/sisl/Spot.jl?branch=master)

This package provides Julia bindings to the [Spot](https://spot.lrde.epita.fr/index.html) library for LTL and automata manipulation. 
It requires the python bindings of spot to be correctly installed and accessible via [PyCall.jl](https://github.com/JuliaPy/PyCall.jl)

## Installation 

```julia
using Pkg; Pkg.add("https://github.com/sisl/Spot.jl")
```

Python dependencies:
    - IPython (for visualization in jupyter notebook)

## Usage 

### LTL Manipulation

Construct LTL formula using a non standard string literal:

```julia
f = ltl"FG a -> FG b"
``` 

The formula will be automatically parsed by Spot.

### LTL to Automata Translation

```julia
using Spot

ltl = "FG A"
translator = LTLTranslator(deterministic=true)

a = translate(translator, ltl)

```

### Tutorial 

A basic tutorial is available in [docs/spot_basic_tutorial.ipynb](https://github.com/sisl/Spot.jl/blob/master/docs/spot_basic_tutorial.ipynb) 


## TODOs

- [ ] Use CXXWrap.jl to avoid relying on a third language (python) and automatically import all the spot functions.
- [ ] Try using BinaryBuilder. A first experiment was not successful, the path to `libspot.so` in the python bindings is wrong.

## Acknowledgement 

Thanks to Alexandre Duretz-Lutz for all the help provided.
