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
building complete K⁽ⁿ⁾ = Σₖ Kₖ⁽ⁿ⁾ expressions.

## Example
```jldoctest; output = false
H = Terms([Term(rotating=0), Term(rotating=1)])
set_hamiltonian!(H)

k10_terms = K(1, 0)  # Static contribution
k11_terms = K(1, 1)  # Rotating contribution
k1_total = k10_terms + k11_terms  # Complete K⁽¹⁾

# output

-1//2*[1/1,1]
-1*[1/1,1]0
```

Terms concatenated without simplification.
"""
Base.:+(terms1::Terms, terms2::Terms) = Terms(vcat(terms1.terms, terms2.terms))

# Scalar multiplication for individual Terms

"""
    *(term::Term, factor::Number) -> Term
    *(factor::Number, term::Term) -> Term

Scale Van Vleck term by multiplying coefficient factor.

Preserves all term properties (rotating, nested structure, frequency dependencies)
while scaling the coefficient. Used for applying recursive coefficients and
normalization factors.

## Example
```jldoctest; output = false
term = Term(rotating=1, factor=1//2)
scaled = term * 3  # factor becomes 3//2

# output

3//2*1
```
"""
function Base.:*(term::Term, factor::Number)
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
Base.:*(factor::Number, term::Term) = term * factor

# Scalar multiplication for Terms collections

"""
    *(terms::Terms, factor::Number) -> Terms

Scale all terms in Van Vleck collection by multiplying their factors.

Applies scalar to every term coefficient, preserving structure.
Used for series normalization and perturbation scaling.

## Example; output = false
```jldoctest
H = Terms([Term(rotating=0), Term(rotating=1)])
set_hamiltonian!(H)

k2_terms = K(2)
normalized = k2_terms * (1//factorial(2))  # Apply 1/2!

# output

1//4*[[1/1,0]/1,1]0
1//6*[[1/1,1]/1,1]0
```
"""
function Base.:*(terms::Terms, factor::Number)
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
Base.:*(factor, terms::Terms) = terms * factor
