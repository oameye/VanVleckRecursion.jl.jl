"""
Type definitions for Van Vleck recursion calculations.
"""

# For this implementation, we use simple numeric types instead of symbolic ones
const SymbolicNum = Union{Int,Float64,Rational{Int64}}

# Abstract type hierarchy
abstract type AbstractTerm end
abstract type AbstractTerms end

"""
    Term

Represents a single term in the quantum harmonic balance calculation.

# Fields
- `rotating::Int`: Rotation flag (0 for static, 1 for rotating)
- `factor::SymbolicNum`: Numerical coefficient
- `freq_denom::Int`: Frequency denominator for integration/differentiation
- `term1::Union{Term, Nothing}`: First term in bracket operation
- `term2::Union{Term, Nothing}`: Second term in bracket operation
- `footprint::String`: String representation of the term structure
- `term_count::Int`: Number of operations in the term's history

# Examples
```julia
# Create a rotating term with factor 2
term = Term(rotating=1, factor=2)

# Create a static term
static_term = Term(rotating=0, factor=1//2)
```
"""
@kwdef mutable struct Term <: AbstractTerm
    rotating::Int              = 1
    factor::SymbolicNum        = 1
    freq_denom::Int            = 0
    term1::Union{Term,Nothing} = nothing
    term2::Union{Term,Nothing} = nothing
    footprint::String          = string(rotating)
    term_count::Int            = 1
end

"""
    Terms

A collection of Term objects with operations for quantum harmonic balance.

# Fields
- `terms::Vector{Term}`: Vector containing individual terms

# Examples
```julia
# Create from individual terms
term1 = Term(rotating=0)
term2 = Term(rotating=1)
terms = Terms([term1, term2])

# Create empty collection
empty_terms = Terms()
```
"""
struct Terms <: AbstractTerms
    terms::Vector{Term}

    function Terms(terms::Vector{T}) where {T}
        # Filter out nothing values
        filtered_terms = filter(!isnothing, terms)
        new(filtered_terms)
    end
end

# Constructor overloads for convenience
Terms() = Terms(Term[])
Terms(term::Term) = Terms([term])
