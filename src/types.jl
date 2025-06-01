# filepath: /home/oameye/Documents/vanVleck-recursion/src/types.jl
"""
Core data structures for Van Vleck recursion calculations.
"""

const SymbolicNum = Union{Int,Float64,Rational{Int64}}

abstract type AbstractTerm end
abstract type AbstractTerms end

"""
    Term

Single term in Van Vleck expansion. Either fundamental Hamiltonian (H₀, H₁)
or result of bracket operations {{·,·}}.

# Fields
- `rotating::Int`: 0=static (H₀), 1=oscillating (H₁e^{iωt})
- `factor::SymbolicNum`: Numerical coefficient
- `freq_denom::Int`: Frequency powers from time integration
- `term1, term2`: Sub-terms for {{term1, term2}} brackets
- `footprint::String`: Unique identifier
- `term_count::Int`: Complexity measure
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

Collection of Term objects representing complete expressions like K⁽ⁿ⁾ or S⁽ⁿ⁾.
Supports algebraic operations and simplification.
"""
struct Terms <: AbstractTerms
    terms::Vector{Term}

    function Terms(terms::Vector{T}) where {T}
        filtered_terms = filter(!isnothing, terms)
        new(filtered_terms)
    end
end

# Convenience constructors
Terms() = Terms(Term[])
Terms(term::Term) = Terms([term])
