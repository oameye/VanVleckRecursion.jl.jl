"""
Arithmetic operations for Term and Terms objects.
"""

# Arithmetic operations for Terms collections
"""
    +(terms1::Terms, terms2::Terms)

Add two Terms collections by concatenating their terms.

# Examples
```julia
terms1 = Terms([Term(rotating=0)])
terms2 = Terms([Term(rotating=1)])
combined = terms1 + terms2  # Contains both terms
```
"""
Base.:+(terms1::Terms, terms2::Terms) = Terms(vcat(terms1.terms, terms2.terms))

# Multiplication for Term objects
"""
    *(term::Term, factor)

Scale a term by multiplying its factor.

# Examples
```julia
term = Term(rotating=1, factor=2)
scaled = term * 3  # New term with factor=6
```
"""
function Base.:*(term::Term, factor)
    Term(
        term.rotating,
        term.factor * factor,
        term.freq_denom,
        term.term1,
        term.term2,
        term.footprint,
        term.term_count,
    )
end

"""
    *(factor, term::Term)

Scale a term by multiplying its factor (commutative).
"""
Base.:*(factor, term::Term) = term * factor

# Multiplication for Terms objects
"""
    *(terms::Terms, factor)

Scale all terms in a collection by multiplying their factors.

# Examples
```julia
terms = Terms([Term(rotating=1, factor=2)])
scaled = terms * 3  # All terms scaled by 3
```
"""
function Base.:*(terms::Terms, factor)
    Terms([
        Term(
            t.rotating,
            t.factor * factor,
            t.freq_denom,
            t.term1,
            t.term2,
            t.footprint,
            t.term_count,
        ) for t in terms.terms
    ])
end

"""
    *(factor, terms::Terms)

Scale all terms in a collection by multiplying their factors (commutative).
"""
Base.:*(factor, terms::Terms) = terms * factor
