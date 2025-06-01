
# Generator class (inherits from Terms)
mutable struct Generator
    terms::Vector{Term}

    function Generator(terms::Vector{Term})
        new(terms)
    end
end

# Class variables for Generator
const Ss = Dict{Int, Terms}()

function get_generator(n::Int)
    """
    get generator S(n) according to the recursive formula.
    """
    if haskey(Ss, n)
        return Ss[n]
    end

    terms = Terms(Term[])
    if n == 0
        return Terms(Term[])
    end
    if n == 1
        terms = terms + (Sym(-1) * K(0, 0))
    end
    if n > 1
        terms = terms + bracket(S(n-1), K(0, 0), Sym(-1))
    end
    for k in 2:n
        terms = terms + (Sym(-1) * K(n-1, k))
    end
    terms = integrate(rot(terms))

    simplify!(terms)
    Ss[n] = terms
    return Ss[n]
end
