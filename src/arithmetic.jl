"""
Arithmetic operations for Van Vleck recursion Term and Terms objects.

Implements arithmetic operations preserving mathematical structure and exact rational arithmetic:
- Addition: Term collection concatenation (K⁽ⁿ⁾ + K⁽ᵐ⁾)
- Scalar multiplication: Scaling by rational/integer factors
- Structure preservation: Maintains rotating/static properties and nested structure

Compatible with Van Vleck recursive structure and symbolic computation.
"""

# Arithmetic operations for Terms collections

"""
    +(terms1::Terms, terms2::Terms) -> Terms

Add two Van Vleck term collections by concatenating terms.

Combines collections preserving all individual terms. Essential for
building complete K⁽ⁿ⁾ = Σₖ K⁽ⁿ,ₖ⁾ expressions.

## Example
```julia
k10_terms = K(1, 0)  # Static contribution
k11_terms = K(1, 1)  # Rotating contribution
k1_total = k10_terms + k11_terms  # Complete K⁽¹⁾
```

Terms concatenated without simplification.
"""
Base.:+(terms1::Terms, terms2::Terms) = Terms(vcat(terms1.terms, terms2.terms))

# Scalar multiplication for individual Terms

"""
    *(term::Term, factor) -> Term

Scale Van Vleck term by multiplying coefficient factor.

Preserves all term properties (rotating, nested structure, frequency dependencies)
while scaling the coefficient. Used for applying recursive coefficients and
normalization factors.

## Example
```julia
term = Term(rotating=1, factor=1//2)
scaled = term * 3  # factor becomes 3//2
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
    *(factor, term::Term) -> Term

Scale Van Vleck term by coefficient factor (commutative form).

Equivalent to `term * factor` with reversed argument order.

## Example
```julia
term = Term(rotating=1, factor=2)
scaled = 3 * term  # factor becomes 6
```
"""
Base.:*(factor, term::Term) = term * factor

# Scalar multiplication for Terms collections

"""
    *(terms::Terms, factor) -> Terms

Scale all terms in Van Vleck collection by multiplying their factors.

Applies scalar to every term coefficient, preserving structure.
Used for series normalization and perturbation scaling.

## Example
```julia
k2_terms = K(2)
normalized = k2_terms * (1//factorial(2))  # Apply 1/2!
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
    *(factor, terms::Terms) -> Terms

Scale all terms in Van Vleck collection (commutative form).

Equivalent to `terms * factor` with reversed argument order.

## Example
```julia
terms = K(2)
scaled = 3 * terms  # All factors multiplied by 3
```
"""
Base.:*(factor, terms::Terms) = terms * factor
