# Spot

[![Build status](https://github.com/sisl/Spot.jl/workflows/CI/badge.svg)](https://github.com/sisl/Spot.jl/actions)
[![CodeCov](https://codecov.io/gh/sisl/Spot.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/sisl/Spot.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://sisl.github.io/Spot.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://sisl.github.io/Spot.jl/dev)

This package provides Julia bindings to the [Spot](https://spot.lrde.epita.fr/index.html) library for LTL and automata manipulation. It relies on [CxxWrap.jl](https://github.com/JuliaInterop/CxxWrap.jl) to interface julia with the Spot c++ library. You can find the c++ code with the wrapped functions in [spot_julia](https://github.com/MaximeBouton/spot_julia/), and the build script for the `jll` file in [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil/blob/master/S/Spot_julia/build_tarballs.jl).

## Installation 

```julia
using Pkg; Pkg.add("Spot.jl")
```

For the rendering, Spot requires [GraphViz](https://graphviz.gitlab.io/) and [dot2tex](https://dot2tex.readthedocs.io/en/latest/index.html) to be installed. 

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

Thanks to Alexandre Duretz-Lutz and Mosé Giordano for all the help provided in cross compiling Spot.
