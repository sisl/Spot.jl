# Spot

[![Build Status](https://travis-ci.org/sisl/Spot.jl.svg?branch=master)](https://travis-ci.org/sisl/Spot.jl)
[![CodeCov](https://codecov.io/gh/sisl/Spot.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/sisl/Spot.jl)
[![Coveralls](https://coveralls.io/repos/github/sisl/Spot.jl/badge.svg?branch=master)](https://coveralls.io/github/sisl/Spot.jl?branch=master)

This package provides Julia bindings to the [Spot](https://spot.lrde.epita.fr/index.html) library for LTL and automata manipulation. It relies on [Cxx.jl](https://github.com/JuliaInterop/Cxx.jl) to interface julia with the Spot c++ library. 

## Installation 

For the rendering, Spot requires [GraphViz](https://graphviz.gitlab.io/) and [dot2tex](https://dot2tex.readthedocs.io/en/latest/index.html) to be installed.

```julia
using Pkg; Pkg.add("https://github.com/sisl/Spot.jl")
```

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

### Notes

Right now, the wrapping of all the c++ functions present in `libspot` is not automatic. 
Every function can be called using the Cxx interface. 
If you need to wrap a function that has not been wrapped yet, feel free to submit a Pull Request.

## Acknowledgement 

Thanks to Alexandre Duretz-Lutz for all the help provided.
