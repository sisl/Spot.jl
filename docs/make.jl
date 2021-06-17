using Documenter
using Literate
using Spot

Literate.markdown(
    joinpath(@__DIR__, "src", "spot_basics.jl"), 
    joinpath(@__DIR__, "src"), 
    documenter=true)

makedocs(sitename="Spot.jl Documentation",
    pages=[
        "index.md",
        "spot_basics.md"
    ])

deploydocs(
    repo = "github.com/sisl/Spot.jl.git",
)
