abstract type Automata{Q, A} end

# interface for automata:

struct BuchiAutomata{Q, A} <: Automata{Q, A}
    states::Vector{Q}
    alphabet::Vector{A}
    transition::Dict{Tuple{Int64, Set{A}}, Int64} # use custom struct for transitions?
    initialstate::Q
    acceptance::Set{Q}
    property::String
end

struct RabinAutomata{Q, A} <: Automata{Q, A}
    states::Vector{Q}
    alphabet::Vector{A}
    transition::Dict{Tuple{Int64, Set{A}}, Int64} # use custom struct for transitions?
    initialstate::Q
    inf::Set{Q} # states that must be visited infinitely often 
    fin::Set{Q} # states that must be visited finitely often
    property::String
end

function acceptance_condition(automata::BuchiAutomata{Q, A}) where {Q, A}
    return automata.acceptance, Q[]
end

function acceptance_condition(automata::RabinAutomata)
    return automata.inf, automata.fin
end

function POMDPs.stateindex(autom::B, q::Int64) where B <: Automata
    return q 
end

function POMDPs.n_states(autom::Union{BuchiAutomata, RabinAutomata})
    return length(autom.states)
end

#  return true if there is a  transitions q, l, q' given q and l 
function has_transition(automata::Automata{Q, String}, q::Q, word::Vector{String}) where Q
    set_word = Set(word)
    if haskey(automata.transition, (q, set_word))
        return true 
    else
        for w in word
            if haskey(automata.transition, (q, w))
                return true
            end
        end
    end
    return false
end

# will return a key error if no transition exists! 
function POMDPs.transition(automata::Automata{Q, String}, q::Q, word::Vector{String}) where Q
        set_word = Set(word)
    if haskey(automata.transition, (q, set_word))
        return automata.transition[(q, set_word)]
    else
        for w in word
            if haskey(automata.transition, (q, w))
                return automata.transition[(q,w)]
            end
        end
    end
    return throw("AutomataTransitionError: No transition for state $q, input word $word")
end

# FILE PARSER 

# convert LTL formula to automata
function ltl2tgba(property::String, automata_file::String="automata.hoa")
    run(`ltl2tgba -G -D -S -H -f $property -o $automata_file`)
end


# parse a .hoa file to return a BuchiAutomata
# only support Buchi!
function hoa2buchi(file_name::String)
    # initialize properties
    property = ""
    n_states = 0
    states = Vector{Int64}()
    initialstate = 0
    alphabet = Vector{String}()
    n_inputs = 0
    transition = Dict{Tuple{Int64, Set{String}}, Int64}()
    acceptance = Set{Int64}()

    open(file_name, "r") do f
        # parse header first 
        ln = 1
        l = readline(f) 
        while l != "--BODY--"
            # parse header
            if occursin("acc-name", l)
                if !occursin("Buchi", l)
                    autom_type = l[length("acc-name: ")+1:end]
                    throw("HOAParsingError: this function only supports Buchi automata, the file you provided was for a $autom_type")   
                end
            elseif occursin("States", l)
                n_states = parse(Int64, match(r"\d+", l).match)
                states = 1:n_states
            elseif occursin("Start", l)
                initialstate = parse(Int64, match(r"\d+", l).match) + 1
            elseif occursin(l, "name")
                name = match(r"\"(.*?)\"", l).match
                property = name[2:end-1] # remove quotes
            elseif occursin("AP", l)
                alphabet = parse_alphabet(l)
            elseif occursin("Acceptance", l)
            
            end
            l = readline(f)
            ln += 1
        end
        # parse body
        l = readline(f)
        ln += 1
        cur_state = 0
        while l != "--END--"
            if occursin("State", l)
                # set current state 
                cur_state = parse(Int64, match(r"\d+", l).match) + 1
                # check if it is accepting 
                acc = match(r"\{(.*?)\}", l)
                if acc != nothing
                    push!(acceptance, cur_state)
                end
            else
                # set edge 
                input = match(r"\[(.*?)\]", l).match[2:end-1]
                inputs = split(input, "&")
                for i=1:length(inputs)
                    inputs[i] = replace(inputs[i], r"\d+" => x->alphabet[parse(Int64, x)+1])
                end
                inputs = Set(inputs)
                succ = parse(Int64, match(r"\s(.*?)($|\s)", l).match) + 1
                transition[(cur_state, inputs)] = succ
            end
            l = readline(f)
            ln += 1            
        end
    end
    return BuchiAutomata{Int64, String}(states, alphabet, transition, initialstate, acceptance, property)
end

function hoa2rabin(file_name::String)
    # initialize properties
    property = ""
    n_states = 0
    states = Vector{Int64}()
    initialstate = 0
    alphabet = Vector{String}()
    n_inputs = 0
    transition = Dict{Tuple{Int64, Set{String}}, Int64}()
    fin = Set{Int64}()
    inf = Set{Int64}()
    fin_idx = 1
    inf_idx = 0

    open(file_name, "r") do f
        # parse header first 
        ln = 1
        l = readline(f) 
        while l != "--BODY--"
            # parse header
            if occursin("acc-name", l)
                if !occursin("Rabin", l)
                    autom_type = l[length("acc-name: ")+1:end]
                    throw("HOAParsingError: this function only supports Rabin automata, the file you provided was for a $autom_type")   
                end
            elseif occursin("States", l)
                n_states = parse(Int64, match(r"\d+", l).match)
                states = 1:n_states
            elseif occursin("Start", l)
                initialstate = parse(Int64, match(r"\d+", l).match) + 1
            elseif occursin("name", l)
                name = match(r"\"(.*?)\"", l).match
                property = name[2:end-1] # remove quotes
            elseif occursin("AP", l)
                alphabet = parse_alphabet(l)
            elseif occursin("Acceptance", l)
                n_sets = parse(Int64, match(r"\d+", l).match) 
                @assert n_sets == 2
                fin_str = match(r"Fin\(\d+\)", l).match
                fin_idx = parse(Int64, match(r"\d+", fin_str).match)
                inf_str = match(r"Inf\(\d+\)", l).match
                inf_idx = parse(Int64, match(r"\d+", inf_str).match) 
            end
            l = readline(f)
            ln += 1
        end
        # parse body
        l = readline(f)
        ln += 1
        cur_state = 0
        while l != "--END--"
            if occursin("State", l)
                # set current state 
                cur_state = parse(Int64, match(r"\d+", l).match) + 1
                # check if it is accepting 
                acc = match(r"\{(.*?)\}", l)
                if acc != nothing
                    acc_idx = parse(Int64, acc.match[2:end-1])
                    if acc_idx == fin_idx 
                        push!(fin, cur_state)
                    elseif acc_idx == inf_idx 
                        push!(inf, cur_state)
                    else
                        throw("HOAParsingError: failed to assign acceptance condition")
                    end
                end
            else
                # set edge 
                input = match(r"\[(.*?)\]", l).match[2:end-1]
                inputs = split(input, "&")
                for i=1:length(inputs)
                    inputs[i] = replace(inputs[i], r"\d+" => x->alphabet[parse(Int64, x)+1])
                end
                inputs = Set(inputs)
                succ = parse(Int64, match(r"\s(.*?)($|\s)", l).match) + 1
                transition[(cur_state, inputs)] = succ
            end
            l = readline(f)
            ln += 1            
        end
    end
    return RabinAutomata{Int64, String}(states, alphabet, transition, initialstate, inf, fin, property)
end
        
function parse_alphabet(l::String)
    n_inputs = parse(Int64, match(r"\d+", l).match)
    alphabet = Vector{String}(undef, n_inputs)
    for (i,a) in enumerate(split(l)[3:end])
        # remove quotes
        alphabet[i] = a[2:end-1]
    end
    return alphabet
end

function automata_type(hoa_file::String)
    autom_type = ""
    open(hoa_file, "r") do f
        l = ""
        while autom_type == "" && !eof(f)
            l = readline(f)
            if occursin("acc-name", l)
                if occursin("Rabin", l)
                    autom_type = "Rabin"
                elseif occursin("Buchi", l)
                    autom_type = "Buchi"
                else
                    throw("HOAParsingError: Automata type not supported, only DFA with Rabin or Buchi acceptance conditions are supported")                    
                end
            end
        end
    end
    if autom_type == ""
        throw("HOAParsingError: Automata type not found")
    end
    return autom_type
end