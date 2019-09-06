struct SpotFormula
    f::Cxx.CxxCore.CppValue
end

macro ltl_str(l) 
    SpotFormula(l)
end

function SpotFormula(f::AbstractString)
    return SpotFormula(@cxx spot::parse_formula(pointer(f)))
end

"""
    is_ltl_formula(f::SpotFormula)
return true if the formula is a Linear Temporal Logic formula
"""
is_ltl_formula(f::SpotFormula) = @cxx f.f -> is_ltl_formula()

"""
    is_eventual(f::SpotFormula)
Whether the formula is purely eventual.
"""
is_eventual(f::SpotFormula) = @cxx f.f -> is_eventual()

"""
    is_sugar_free_ltl(f::SpotFormula)
Whether the formula avoids the F and G operators.
"""
is_sugar_free_ltl(f::SpotFormula) = @cxx f.f -> is_sugar_free_ltl()

"""
    is_literal()
Whether the formula is an atomic proposition or its negation.
"""
is_literal(f::SpotFormula) = @cxx f.f -> is_literal()

"""
    is_boolean()
Whether the formula is boolean 
"""
is_boolean(f::SpotFormula) = @cxx f.f -> is_boolean()

"""
    is_reachability(f::SpotFormula)
returns true if a formula is of type `F a`
"""
function is_reachability(f::SpotFormula)
    return icxx"""
        spot::formula ff = $(f.f);
        ff.is(spot::op::F) && ff[0].is_boolean();
    """
end

"""
    is_constrained_reachability(f::SpotFormula)
returns true if a formula is of type `a U b`
"""
function is_constrained_reachability(f::SpotFormula)
   return  icxx"""
        spot::formula ff = $(f.f);
        ff.is(spot::op::U) && ff[0].is_boolean() && ff[1].is_boolean();
    """
end

"""
    atomic_prop_collect(f::SpotFormula)
returns the list of atomic propositions in f
"""
function atomic_prop_collect(f::SpotFormula)
    sap = @cxx spot::atomic_prop_collect(f.f)
    vap = icxx"""
    std::vector<spot::formula> v($sap->begin(), $sap->end());
    v;
    """
    return [Symbol(SpotFormula(ap)) for ap in vap]
end

"""
    Base.length(f::SpotFormula)
    
Returns the number of children in the formula AST
"""
function Base.length(f::SpotFormula)
    return convert(Int64, @cxx f.f->size())
end

## Rendering and conversion

Base.string(f::SpotFormula) = String(@cxx spot::str_psl(f.f))
Base.Symbol(f::SpotFormula) = Symbol(string(f))

function Base.show(io::IO, m::MIME{Symbol("text/latex")}, f::SpotFormula)
    show(io, m, latexstring(String(@cxx spot::str_latex_psl(f.f))))
end

function Base.show(io::IO, mime::MIME"text/plain", f::SpotFormula)
    show(io, mime, string(f))
end