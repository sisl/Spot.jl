# Interface for manipulating automaton

abstract type AbstractAutomata end 

struct SpotAutomata <: AbstractAutomata
    a::PyObject
end

function num_states(aut::SpotAutomata)
    return aut.a[:num_states]()
end

function get_init_state_number(aut::SpotAutomata)
    return aut.a[:get_init_state_number]()
end

function num_edges(aut::SpotAutomata)
    return aut.a[:num_edges]()
end

function atomic_propositions(aut::SpotAutomata)
    return [Symbol(a[:to_str]()) for a in aut.a[:ap]()]
end

"""
    get_edges_labels(aut::SpotAutomata)
returns a list of edges as pairs (src, dest)
and their associated labels as strings representing boolean formula. 
this is inspired from https://spot.lrde.epita.fr/tut24.html
"""
function get_edges_labels(aut::SpotAutomata)
    bdict = aut.a[:get_dict]()
    edges = Tuple{Int64, Int64}[]
    labels = String[]
    for s=1:num_states(aut)
        for t in aut.a[:out](s - 1) 
            ud = aut.a[:is_univ_dest](t)
            if !ud 
                for dest in aut.a[:univ_dests](t)
                    push!(edges, (Int(t[:src]) + 1, Int(dest) + 1))
                    push!(labels, ((string(spot.bdd_format_formula(bdict, t[:cond])))))
                end
            end
        end
    end
    return edges, labels 
end

"""
    label_to_function(ap::Vector{Symbol}, label::String)
returns a functions with atomic propositions as arguments. 
The function evaluates the boolean expression represented in the label.
"""
function label_to_function(ap::Vector{Symbol}, label::String)
    parsed_formula = Meta.parse(label)
    fun_args = Expr(:tuple, ap...)
    ex = Expr(:->, fun_args, parsed_formula)
    return eval(ex)
end

"""
    parse_inf_fin_sets(aut::SpotAutomata)
Given a SpotAutomata, parse the accepting condition and returns
 the set of states that must be visited infinitely often (inf_set)
 and the set of states that must be visited finitely often (fin_set)
"""
function parse_inf_fin_sets(aut::SpotAutomata)
    inf_set=Set{Int64}()
    fin_set =Set{Int64}()
    l = aut.a[:get_acceptance]()[:__str__]() #XXX hack
    inf_set = Set{Int64}()
    for m in eachmatch(r"Inf\(\d+\)", l)
        push!(inf_set, parse(Int64, match(r"\d+",m.match).match))
    end
    fin_set = Set{Int64}()
    for m in eachmatch(r"Fin\(\d+\)", l)
        push!(fin_set, parse(Int64, match(r"\d+",m.match).match))
    end    
    return (inf_set, fin_set)
end
