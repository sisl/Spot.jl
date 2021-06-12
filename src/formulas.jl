struct SpotFormula
    f::Spot.FormulaAllocated
end

macro ltl_str(l) 
    SpotFormula(l)
end

function SpotFormula(f::AbstractString)
    return SpotFormula(Spot.parse_formula(f))
end

"""
    is_ltl_formula(f::SpotFormula)
return true if the formula is a Linear Temporal Logic formula
"""
is_ltl_formula(f::SpotFormula) = Spot.is_ltl_formula(f.f)

"""
    is_eventual(f::SpotFormula)
Whether the formula is purely eventual.
"""
is_eventual(f::SpotFormula) = Spot.is_eventual(f.f)

"""
    is_sugar_free_ltl(f::SpotFormula)
Whether the formula avoids the F and G operators.
"""
is_sugar_free_ltl(f::SpotFormula) = Spot.is_sugar_free_ltl(f.f)

"""
    is_literal()
Whether the formula is an atomic proposition or its negation.
"""
is_literal(f::SpotFormula) = Spot.is_literal(f.f)

"""
    is_boolean()
Whether the formula is boolean 
"""
is_boolean(f::SpotFormula) = Spot.is_boolean(f.f)

"""
    is_reachability(f::SpotFormula)
returns true if a formula is of type `F a`
"""
is_reachability(f::SpotFormula) = Spot.is_reachability(f.f)

"""
    is_constrained_reachability(f::SpotFormula)
returns true if a formula is of type `a U b`
"""
is_constrained_reachability(f::SpotFormula) = Spot.is_constrained_reachability(f.f)

"""
    atomic_prop_collect(f::SpotFormula)
returns the list of atomic propositions in f
"""
function atomic_prop_collect(f::SpotFormula)
    ap_vec = copy.(Spot.atomic_prop_collect(f.f))
    return [Symbol(SpotFormula(ap)) for ap in ap_vec]
end

"""
    Base.length(f::SpotFormula)
    
Returns the number of children in the formula AST
"""
function Base.length(f::SpotFormula)
    return convert(Int64, Spot.size(f.f))
end

# ## Rendering and conversion

Base.string(f::SpotFormula) = String(Spot.str_psl(f.f, false))
Base.Symbol(f::SpotFormula) = Symbol(string(f))

function Base.show(io::IO, m::MIME{Symbol("text/latex")}, f::SpotFormula)
    show(io, m, latexstring(String(Spot.str_latex_psl(f.f, false))))
end

function Base.show(io::IO, mime::MIME"text/plain", f::SpotFormula)
    show(io, mime, string(f))
end
