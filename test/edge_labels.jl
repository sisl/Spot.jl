APs = ["a", "b"] # atomic propositions

l = "!a & b"

ex1 = Meta.parse(l)

function evaluate_transition(ex::Expr, a, b) 
    eval(ex)
end

evaluate_transition(ex1, true, true)

ex1.head
ex1.args

ex2=Meta.parse("(a, b) -> a | b")

function create_transition_formula(APs::Vector{Symbol}, formula::String)
end

function create_argument_list(APs::Vector{Symbol})
    
    return :($([a for a in APs]))
end
    
APs = [:a,:b]
parsed_formula = Meta.parse("!a & b")

fun_args = Expr(:tuple, APs...)
ex = Expr(:->, fun_args, parsed_formula)
f = eval(ex)


using Test
@code_warntype f(false, true)

ex = :($(APs[1]) -> a | !a)


## Acceptance conditions

l = "Inf(0)&Inf(1)"

l = replace(l, "Inf" => "inf")

ex = Meta.parse(l)

ex.args[2].args

inf_set=Set{Int64}()
fin_set =Set{Int64}()

function inf(x)
    push!(inf_set, x)
    return true
end

function Fin(x)
    push!(fin_set, x)
    return true
end

eval(ex)

inf_set

length(inf_set)


### DRA traversal

