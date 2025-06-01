"""
# VanVleckRecursion.jl

A Julia package for quantum harmonic balance calculations using Van Vleck recursion.

This package implements the Van Vleck transformation for quantum systems,
providing tools for computing generators and Kamiltonians in the rotating wave approximation.

## Main Features

- Term and Terms types for representing quantum expressions
- Bracket operations (Poisson brackets)
- Time derivatives and integration
- Rotation operations
- Kamiltonian and Generator calculations
- Caching for efficient repeated calculations

## Example Usage

```julia
using VanVleckRecursion

# Set up Hamiltonian
H = Terms([Term(rotating=0), Term(rotating=1)])
set_hamiltonian!(H)

# Calculate generators
s1 = S(1)  # First-order generator
k1 = K(1)  # First-order Kamiltonian
```

Translated from Python code by xiaoxu (2021) into idiomatic Julia.
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
