struct SpotFormula
    f::PyObject
end

macro ltl_str(l) 
    SpotFormula(l)
end

function SpotFormula(f::AbstractString)
    return SpotFormula(spot.formula(f))
end

"""
    is_ltl_formula(f::SpotFormula)
return true if the formula is a Linear Temporal Logic formula
"""
is_ltl_formula(f::SpotFormula) = f.f[:is_ltl_formula]()

to_str(f::SpotFormula) = f.f[:to_str]()
Base.string(f::SpotFormula) = f.f[:to_str]()

"""
    is_eventual(f::SpotFormula)
Whether the formula is purely eventual.
"""
is_eventual(f::SpotFormula) = f.f[:is_eventual]()

"""
    is_sugar_free_ltl(f::SpotFormula)
Whether the formula avoids the F and G operators.
"""
is_sugar_free_ltl(f::SpotFormula) = f.f[:is_sugar_free_ltl]()

"""
    is_literal()
Whether the formula is an atomic proposition or its negation.
"""
is_literal(f::SpotFormula) = f.f[:is_literal]()

"""
    is_boolean()
Whether the formula is boolean 
"""
is_boolean(f::SpotFormula) = f.f[:is_boolean]()

"""
    is_reachability(f::SpotFormula)
returns true if a formula is of type `F a`
"""
function is_reachability(f::SpotFormula)
    return f.f[:_is](spot.op_F) && f.f[1][:is_boolean]()
end

"""
    is_constrained_reachability(f::SpotFormula)
returns true if a formula is of type `a U b`
"""
function is_constrained_reachability(f::SpotFormula)
    return f.f[:_is](spot.op_U) && f.f[1][:is_boolean]() && f.f[2][:is_boolean]()
end

"""
    atomic_prop_collect(f::SpotFormula)
returns the list of atomic propositions in f
"""
atomic_prop_collect(f::SpotFormula) = [Symbol(ap[:to_str]()) for ap in spot.atomic_prop_collect(f.f)]
