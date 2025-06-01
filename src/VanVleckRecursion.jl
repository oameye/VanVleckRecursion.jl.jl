"""
    VanVleckRecursion.jl

Van Vleck canonical transformation for rapidly driven quantum systems.

Implements recursive formulas from Venkatraman et al. (2022) arXiv:2108.02861
to compute static effective Hamiltonians H_eff from time-periodic H(t).

# Key Functions
- `set_hamiltonian!(H0, H_dict)`: Define H(t) = H₀ + Σₘ Hₘ e^{imωt}
- `K(n, k=nothing)`: Compute K⁽ⁿ,ₖ⁾ or K⁽ⁿ⁾ (nested commutators)
- `S(n)`: Compute generator S⁽ⁿ⁾ (anti-Hermitian)
- `clear_caches!()`: Reset memoization

# Example
```julia
H0 = [1 0; 0 -1]  # σz
H_drive = Dict(1 => [0 1; 1 0])  # σx at frequency ω
set_hamiltonian!(H0, H_drive)
H_eff = integrate(K(0) + K(2))  # 2nd order effective Hamiltonian
```
"""
module VanVleckRecursion

using Printf, LaTeXStrings

# Export main types
export AbstractTerm, AbstractTerms, Term, Terms, SymbolicNum

# Export main operations
export bracket, dot, rot, integrate
export is_same, combine_if_same, simplify, simplify!
export latex, latex_simple, latex_advanced

# Export Kamiltonian and Generator functions
export K, S, kamiltonian_get, generator_get, set_hamiltonian!, clear_caches!

# Export caches (for advanced users)
export KAMILTONIAN_CACHE, GENERATOR_CACHE

include("types.jl")
include("operations.jl")
include("comparison.jl")
include("collections.jl")
include("arithmetic.jl")
include("display.jl")
include("kamiltonian.jl")

end # module VanVleckRecursion
