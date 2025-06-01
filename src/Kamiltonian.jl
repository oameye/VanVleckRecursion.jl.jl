
# Kamiltonian class (inherits from Terms)
mutable struct Kamiltonian
    terms::Vector{Term}

    function Kamiltonian(terms::Vector{Term})
        new(terms)
    end
end

# Class variables for Kamiltonian
const Ks = Dict{String, Terms}()

function get_kamiltonian(n::Int, k::Int)
    """
    get Kamiltonian K(n)_[k] according to the recursive formula.
    """
    key = string([n, k])

    if haskey(Ks, key)
        return Ks[key]
    end

    if n == 0 && k == 0  # base case
        throw(ArgumentError("Base case of recursion not specified"))
    elseif n == 0 && k == 1
        Ks[key] = dot(S(1), Sym(1))
    elseif n != 0 && k == 1
        term1 = dot(S(n+1), Sym(1))
        term2 = bracket(S(n), K(0, 0))
        Ks[key] = term1 + term2
        # this can be alternatively expressed as static of term2 - rotating
        # parts of other K(n,k'!=k)
    elseif k > 1 && k <= n+1
        terms = Terms(Term[])
        for m in 0:(n-1)
            terms = terms + bracket(S(n-m), K(m, k-1), 1/Sym(k))
        end
        Ks[key] = terms
    else
        return Terms(Term[])
    end

    simplify!(Ks[key])
    return Ks[key]
end

function set_H!(H::Terms)
    Ks[string([0, 0])] = H
end
