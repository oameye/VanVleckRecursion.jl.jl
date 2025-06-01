module VanVleckRecursion

using SymPy
using Base: deepcopy

export Term, Terms, Kamiltonian, Generator
export bracket, dot, rot, integrate, simplify!
export get_kamiltonian, get_generator, set_H!, K, S
export latex


function K(n::Int, k::Int = -1)
    if k != -1
        return get_kamiltonian(n, k)
    end
    Kn = Terms(Term[])
    for ki in 0:(n+1)
        Kn = Kn + get_kamiltonian(n, ki)
    end
    simplify!(Kn)
    return Kn
end

function S(n::Int)
    return get_generator(n)
end

end # module
