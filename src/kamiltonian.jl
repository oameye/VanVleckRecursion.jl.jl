"""
Kamiltonian and Generator calculations with caching.
"""

# Kamiltonian implementation using a global cache
const KAMILTONIAN_CACHE = Dict{Tuple{Int,Int}, Terms}()

"""
    kamiltonian_get(n::Int, k::Int)

Get Kamiltonian K(n)_[k] according to the recursive formula.

The Kamiltonian K(n)_[k] represents the k-th order contribution to the
n-th order effective Hamiltonian in the Van Vleck transformation.

# Arguments
- `n::Int`: Order of the transformation
- `k::Int`: Sub-order index

# Returns
`Terms`: The Kamiltonian terms

# Examples
```julia
# Set base Hamiltonian first
H = Terms([Term(rotating=0), Term(rotating=1)])
set_hamiltonian!(H)

# Get specific Kamiltonian
k11 = kamiltonian_get(1, 1)
```
"""
function kamiltonian_get(n::Int, k::Int)
    key = (n, k)
    haskey(KAMILTONIAN_CACHE, key) && return KAMILTONIAN_CACHE[key]

    if n == 0 && k == 0
        error("Base case of recursion not specified. Use set_hamiltonian! first.")
    elseif n == 0 && k == 1
        KAMILTONIAN_CACHE[key] = dot(generator_get(1), 1)
    elseif n != 0 && k == 1
        term1 = dot(generator_get(n + 1), 1)
        term2 = bracket(generator_get(n), kamiltonian_get(0, 0))
        KAMILTONIAN_CACHE[key] = term1 + term2
    elseif 1 < k <= n + 1
        terms = Terms()
        for m in 0:n-1
            terms = terms + bracket(generator_get(n - m), kamiltonian_get(m, k - 1), 1//k)
        end
        KAMILTONIAN_CACHE[key] = terms
    else
        return Terms()
    end

    simplify!(KAMILTONIAN_CACHE[key])
    return KAMILTONIAN_CACHE[key]
end

# Generator implementation using a global cache
const GENERATOR_CACHE = Dict{Int, Terms}()

"""
    generator_get(n::Int)

Get generator S(n) according to the recursive formula.

The generator S(n) is the n-th order transformation function in the
Van Vleck canonical transformation.

# Arguments
- `n::Int`: Order of the generator

# Returns
`Terms`: The generator terms

# Examples
```julia
# Set base Hamiltonian first
H = Terms([Term(rotating=0), Term(rotating=1)])
set_hamiltonian!(H)

# Get first-order generator
s1 = generator_get(1)
```
"""
function generator_get(n::Int)
    haskey(GENERATOR_CACHE, n) && return GENERATOR_CACHE[n]

    terms = Terms()

    if n == 0
        return Terms()
    elseif n == 1
        terms = terms + (-1 * kamiltonian_get(0, 0))
    elseif n > 1
        terms = terms + bracket(generator_get(n - 1), kamiltonian_get(0, 0), -1)
    end

    for k in 2:n
        terms = terms + (-1 * kamiltonian_get(n - 1, k))
    end

    terms = integrate(rot(terms))
    simplify!(terms)
    GENERATOR_CACHE[n] = terms

    return GENERATOR_CACHE[n]
end

"""
    K(n::Int, k::Int=-1)

Convenience function for Kamiltonian access.

If k is specified, returns K(n)_[k]. If k=-1 (default), returns the sum
of all K(n)_[ki] for ki = 0, 1, ..., n+1.

# Arguments
- `n::Int`: Order of the Kamiltonian
- `k::Int`: Sub-order (default -1 for sum of all orders)

# Returns
`Terms`: The requested Kamiltonian

# Examples
```julia
k11 = K(1, 1)     # Specific sub-order
k1_total = K(1)   # Sum of all sub-orders
```
"""
function K(n::Int, k::Int=-1)
    if k != -1
        return kamiltonian_get(n, k)
    end

    kn = Terms()
    for ki in 0:n+1
        kn = kn + kamiltonian_get(n, ki)
    end
    simplify!(kn)
    return kn
end

"""
    S(n::Int)

Convenience function for Generator access.

# Arguments
- `n::Int`: Order of the generator

# Returns
`Terms`: The n-th order generator

# Examples
```julia
s1 = S(1)  # First-order generator
s2 = S(2)  # Second-order generator
```
"""
S(n::Int) = generator_get(n)

"""
    set_hamiltonian!(H::Terms)

Set the base Hamiltonian H for the calculation.

This function initializes the calculation by setting the base Hamiltonian
H = K(0)_[0]. All subsequent generator and Kamiltonian calculations
will use this as the starting point.

# Arguments
- `H::Terms`: The base Hamiltonian

# Examples
```julia
# Typical setup with static and rotating terms
H = Terms([Term(rotating=0), Term(rotating=1)])
set_hamiltonian!(H)

# Now you can calculate generators and Kamiltonians
s1 = S(1)
k1 = K(1)
```
"""
function set_hamiltonian!(H::Terms)
    KAMILTONIAN_CACHE[(0, 0)] = H
end

"""
    clear_caches!()

Clear all cached Kamiltonian and Generator calculations.

Useful when starting a new calculation or when memory usage becomes a concern.

# Examples
```julia
clear_caches!()
# Now set a new Hamiltonian and start fresh calculations
```
"""
function clear_caches!()
    empty!(KAMILTONIAN_CACHE)
    empty!(GENERATOR_CACHE)
end
