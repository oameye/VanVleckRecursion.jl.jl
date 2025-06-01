"""
Van Vleck recursive formulas for effective Hamiltonians and canonical transformation generators.

Core functions for computing static effective Hamiltonians of driven systems:
- `K(n, k)`: Kamiltonian contributions
- `S(n)`: Canonical transformation generators
- `set_hamiltonian!()`: Initialize base Hamiltonian
- `clear_caches!()`: Reset computation caches

Recursive formulas:
- K(0,0) = H₀, K(0,1) = Ṡ(1)
- K(n,1) = Ṡ(n+1) + {S(n), H₀} for n≠0
- K(n,k) = (1/k) Σₘ {S(n-m), K(m,k-1)} for 1 < k ≤ n+1
- S(n) = ∫ rot([oscillating terms]) dt

Reference: Venkatraman et al., Phys. Rev. Lett. 129, 100601 (2022)
"""

# Global caches for memoization of expensive calculations
const KAMILTONIAN_CACHE = Dict{Tuple{Int,Int},Terms}()
const GENERATOR_CACHE = Dict{Int,Terms}()

"""
    kamiltonian_get(n::Int, k::Int)

Compute Kamiltonian K(n)_[k] using Van Vleck recursive formulas.

Implements recursive computation of effective Hamiltonian contributions:
- K(0,0) = H₀ (base case, set by `set_hamiltonian!`)
- K(0,1) = Ṡ(1)
- K(n,1) = Ṡ(n+1) + {S(n), H₀} for n≠0
- K(n,k) = (1/k) Σₘ₌₀ⁿ⁻¹ {S(n-m), K(m,k-1)} for 1 < k ≤ n+1
- K(n,k) = 0 for k > n+1

## Arguments
- `n::Int`: Perturbative order (n ≥ 0)
- `k::Int`: Sub-order index (k ≥ 0)

## Returns
`Terms`: Kamiltonian contribution K(n)_[k]

## Example
```julia
H = Terms([Term(rotating=0), Term(rotating=1)])
set_hamiltonian!(H)
k00 = kamiltonian_get(0, 0)  # Base Hamiltonian
k01 = kamiltonian_get(0, 1)  # First correction
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
        for m in 0:(n - 1)
            terms = terms + bracket(generator_get(n - m), kamiltonian_get(m, k - 1), 1//k)
        end
        KAMILTONIAN_CACHE[key] = terms
    else
        return Terms()
    end

    simplify!(KAMILTONIAN_CACHE[key])
    return KAMILTONIAN_CACHE[key]
end

"""
    generator_get(n::Int)

Compute generator S(n) using Van Vleck recursive construction.

Generators eliminate oscillating terms through canonical transformations:
- S(0) = 0 (no zeroth-order generator)
- S(1) = ∫ rot([-H₀]) dt
- S(n) = ∫ rot([-{S(n-1), H₀} - Σₖ₌₂ⁿ K(n-1,k)]) dt for n > 1

## Arguments
- `n::Int`: Generator order (n ≥ 0)

## Returns
`Terms`: The nth-order generator S(n)

## Example
```julia
H = Terms([Term(rotating=0), Term(rotating=1)])
set_hamiltonian!(H)
s1 = generator_get(1)  # First-order generator
s2 = generator_get(2)  # Second-order generator
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

Compute Kamiltonian contributions to effective Hamiltonian.

- `K(n, k)`: Returns specific sub-contribution K(n)_[k]
- `K(n)`: Returns complete nth-order sum Σₖ K(n)_[k]

Effective Hamiltonian: H_eff = K(0) + K(1) + K(2) + ...

## Arguments
- `n::Int`: Perturbative order (0, 1, 2, ...)
- `k::Int`: Sub-order index (default -1 for sum over all k)

## Returns
`Terms`: Kamiltonian contribution(s)

## Example
```julia
set_hamiltonian!(H)
k00 = K(0, 0)     # Base Hamiltonian
k1_total = K(1)   # All first-order terms
H_eff = K(0) + K(1) + K(2)  # Effective Hamiltonian
```
"""
function K(n::Int, k::Int=-1)
    if k != -1
        return kamiltonian_get(n, k)
    end

    kn = Terms()
    for ki in 0:(n + 1)
        kn = kn + kamiltonian_get(n, ki)
    end
    simplify!(kn)
    return kn
end

"""
    S(n::Int)

Convenience function for accessing Van Vleck generators.

Generators S(n) are canonical transformation functions that eliminate
time-dependent terms from driven Hamiltonians. Each S(n) removes
oscillating terms at order n.

## Arguments
- `n::Int`: Generator order (1, 2, 3, ...)

## Returns
`Terms`: The nth-order generator S(n)

## Example
```julia
set_hamiltonian!(H)
s1 = S(1)    # First-order generator
s2 = S(2)    # Second-order generator
```

Note: S(0) = 0 by convention.
"""
S(n::Int) = generator_get(n)

"""
    set_hamiltonian!(H::Terms)

Initialize Van Vleck calculation by setting the base Hamiltonian.

Sets K(0,0) = H₀ as the foundation for Van Vleck recursion.
Input should contain static terms (rotating=0) and oscillating
terms (rotating=1,2,...) for driven systems.

## Arguments
- `H::Terms`: Complete driven Hamiltonian (static + oscillating parts)

## Example
```julia
H = Terms([
    Term(rotating=0, factor=1),      # H₀ (static)
    Term(rotating=1, factor=1//4)    # H₁cos(ωt) (drive)
])
set_hamiltonian!(H)
```

Must be called before computing any S(n) or K(n,k).
"""
function set_hamiltonian!(H::Terms)
    KAMILTONIAN_CACHE[(0, 0)] = H
end

"""
    clear_caches!()

Clear all cached Van Vleck calculations for fresh computations.

Clears KAMILTONIAN_CACHE and GENERATOR_CACHE. Useful for:
- Starting new problems with different Hamiltonians
- Memory management for large calculations
- Parameter studies

Must call `set_hamiltonian!` again after clearing caches.

## Example
```julia
clear_caches!()
set_hamiltonian!(H_new)
s1 = S(1)  # Fresh computation
```
"""
function clear_caches!()
    empty!(KAMILTONIAN_CACHE)
    empty!(GENERATOR_CACHE)
end
