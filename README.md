# VanVleckRecursion.jl

A Julia package for quantum harmonic balance calculations using Van Vleck recursion.

## Overview

This package implements the Van Vleck canonical transformation for quantum systems, providing efficient tools for computing generators and effective Hamiltonians (Kamiltonians) in the rotating wave approximation. The implementation uses idiomatic Julia features including multiple dispatch, efficient memory management, and rational arithmetic.

## Features

- **Term Algebra**: Flexible representation of quantum terms with rotation properties
- **Bracket Operations**: Efficient computation of Poisson brackets
- **Time Evolution**: Time derivatives, integration, and rotation operations
- **Automatic Simplification**: Combines like terms and removes zero contributions
- **Caching System**: Memoization of expensive calculations for performance
- **LaTeX Output**: Generate publication-ready mathematical expressions

## Installation

```julia
# From the Julia REPL, navigate to the package directory and activate
using Pkg
Pkg.activate("path/to/VanVleckRecursion")
Pkg.instantiate()

# Then use the package
using VanVleckRecursion
```

## Quick Start

```julia
using VanVleckRecursion

# Define a Hamiltonian with static and rotating terms
H = Terms([
    Term(rotating=0, factor=1),      # Static term
    Term(rotating=1, factor=1//2)    # Rotating term
])

# Set as the base Hamiltonian
set_hamiltonian!(H)

# Calculate first-order generator and Kamiltonian
s1 = S(1)          # First-order generator
k1 = K(1)          # First-order Kamiltonian (sum of all sub-orders)
k11 = K(1, 1)      # Specific sub-order

# Display results
println("First-order generator:")
println(s1)

println("\\nFirst-order Kamiltonian:")
println(k1)
```

## Core Types

### `Term`
Represents a single term in the quantum expression:
```julia
# Basic term construction
term = Term(rotating=1, factor=2//3)

# Terms can represent bracket operations
bracket_term = bracket(term1, term2)
```

### `Terms`
Collection of `Term` objects with algebraic operations:
```julia
# Create from individual terms
terms = Terms([term1, term2, term3])

# Arithmetic operations
combined = terms1 + terms2
scaled = terms * (1//2)
```

## Main Operations

### Bracket Operations
Compute Poisson brackets between terms:
```julia
result = bracket(term1, term2, factor)
```

### Time Evolution
- `dot(term)`: Time derivative
- `integrate(term)`: Time integration  
- `rot(term, factor)`: Rotation transformation

### Simplification
```julia
# In-place simplification
simplify!(terms)

# Return simplified copy
simplified = simplify(terms)
```

## Van Vleck Transformation

The package computes the Van Vleck canonical transformation:

- **Generators** `S(n)`: Transform functions for nth-order
- **Kamiltonians** `K(n,k)`: Effective Hamiltonian contributions

```julia
# Set base Hamiltonian
set_hamiltonian!(H)

# Compute generators
s1 = S(1)    # First-order
s2 = S(2)    # Second-order

# Compute Kamiltonians
k10 = K(1, 0)   # Specific contribution
k1_total = K(1) # Sum of all contributions
```

## Performance Features

- **Rational Arithmetic**: Exact computation using Julia's `Rational` type
- **Caching**: Automatic memoization of expensive calculations
- **Memory Efficiency**: In-place operations where possible
- **Type Stability**: Leverages Julia's type system for performance

## Caching

The package automatically caches computed values:
```julia
# Clear caches when starting new calculations
clear_caches!()

# Caches are automatically populated
s1 = S(1)  # Computed and cached
s1_again = S(1)  # Retrieved from cache
```

## LaTeX Output

Generate publication-ready output:
```julia
term = Term(rotating=1, factor=2)
latex_str = latex(term)  # "2*1e^{i\\omega t}"

terms = Terms([term1, term2])
latex_collection = latex(terms)  # Multi-line LaTeX
```

## Mathematical Background

This implementation follows the Van Vleck recursion for canonical transformations in quantum mechanics. The transformation eliminates time-dependent terms through successive canonical transformations, resulting in an effective time-independent Hamiltonian suitable for rotating wave approximation.

## Translation from Python

This package is a complete Julia translation of the original Python implementation by xiaoxu (2021). Key improvements include:

- **Multiple Dispatch**: Replaced object-oriented design with Julia's multiple dispatch
- **Type System**: Leveraged Julia's type system for better performance and clarity
- **Native Arithmetic**: Used Julia's built-in rational arithmetic instead of symbolic math
- **Memory Management**: Efficient memory usage with proper immutable/mutable design
- **Error Handling**: Proper Julia exception handling with `@warn` and `error()`

## Examples

See the test suite in `test/runtests.jl` for comprehensive examples of all functionality.

## Contributing

This package follows standard Julia package development practices. To contribute:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

[Specify your license here]

## Citation

If you use this package in research, please cite:

[Add appropriate citation information]

Based on the original Python implementation by xiaoxu (2021), translated to Julia with significant enhancements for performance and usability.
