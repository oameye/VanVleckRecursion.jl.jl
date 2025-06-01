"""
Operations on Van Vleck recursion term collections and simplification functions.

Extends core operations to collections, enabling bulk processing of K⁽ⁿ⁾ and S⁽ⁿ⁾ expressions.
Provides simplification to manage exponential term growth in higher-order recursions.

Key operations:
- `bracket()`: Distribute Poisson brackets over collections
- `dot()`: Apply time derivatives to all terms
- `rot()`: Extract oscillating components
- `integrate()`: Time-average for secular elimination
- `simplify()`: Combine like terms and eliminate zeros
"""

# Operations on Terms collections

"""
    bracket(terms1::Terms, terms2::Terms, factor=1) -> Terms

Compute Poisson brackets between all pairs of terms from two collections.

Implements distributive property: {A + B, C + D} = {A,C} + {A,D} + {B,C} + {B,D}.
Essential for building K⁽ⁿ,ₖ⁾ expressions from lower-order terms.

# Arguments
- `terms1::Terms`: First collection
- `terms2::Terms`: Second collection
- `factor`: Global scaling factor (default 1)

# Example
```julia
k0_terms = K(0)
k1_terms = K(1)
k21_terms = bracket(k0_terms, k1_terms)  # All pairwise brackets
```
"""
function bracket(terms1::Terms, terms2::Terms, factor=1)
    new_terms = Term[]
    for t1 in terms1.terms
        for t2 in terms2.terms
            result = bracket(t1, t2, factor)
            append!(new_terms, result.terms)
        end
    end
    return Terms(new_terms)
end

"""
    dot(terms::Terms, factor=1) -> Terms

Apply time differentiation to all terms in a collection.

Computes ∂/∂t with frequency-dependent scaling: ∂/∂t H_m e^{imωt} = (imω) H_m e^{imωt}.
Used for generator construction and secular elimination.

# Arguments
- `terms::Terms`: Collection to differentiate
- `factor`: Global scaling factor (default 1)

# Example
```julia
k1_terms = K(1)
k1_dot = dot(k1_terms)  # Time derivatives of all terms
```
"""
function dot(terms::Terms, factor=1)
    new_terms = Term[]
    for term in terms.terms
        result = dot(term, factor)
        append!(new_terms, result.terms)
    end
    return Terms(new_terms)
end

"""
    rot(terms::Terms, factor=1) -> Terms

Extract oscillating (rotating) components from all terms.

Separates time-dependent parts H_rot(t) = Σₘ≠₀ H_m e^{imωt} from static components.
Static terms (rotating=0) are filtered out.

# Arguments
- `terms::Terms`: Collection to process
- `factor`: Rotation scaling factor (default 1)

# Example
```julia
k1_terms = K(1)
k1_rotating = rot(k1_terms)  # Only oscillating parts
```
"""
function rot(terms::Terms, factor=1)
    new_terms = Term[]
    for term in terms.terms
        result = rot(term, factor)
        append!(new_terms, result.terms)
    end
    return Terms(new_terms)
end

"""
    integrate(terms::Terms, factor=1) -> Terms

Perform time integration on all terms for secular elimination.

Applies ∫₀^T dt to eliminate oscillating terms: ∫₀^T H_m e^{imωt} dt = 0 for m≠0.
Only secular (time-averaged) terms survive.

# Arguments
- `terms::Terms`: Collection to integrate
- `factor`: Global scaling factor (default 1)

# Example
```julia
k1_terms = K(1)
k1_secular = integrate(k1_terms)  # Only static parts survive
```
"""
function integrate(terms::Terms, factor=1)
    new_terms = Term[]
    for term in terms.terms
        result = integrate(term, factor)
        append!(new_terms, result.terms)
    end
    return Terms(new_terms)
end

"""
    simplify!(terms::Terms) -> Terms

Simplify collection by combining like terms and removing zeros (in-place).

Combines terms with identical structure, removes zero coefficients.
Essential for managing exponential growth in higher-order recursions.

# Arguments
- `terms::Terms`: Collection to simplify (modified in place)

# Returns
Same collection reference for method chaining

# Example
```julia
k2_terms = K(2)
simplify!(k2_terms)  # Reduces from hundreds to dozens of terms
```
"""
function simplify!(terms::Terms)
    new_terms = Term[]
    marked_for_removal = Set{Int}()

    for (i, term_i) in enumerate(terms.terms)
        i in marked_for_removal && continue

        new_term = term_i
        for (j, term_j) in enumerate(terms.terms[(i + 1):end])
            actual_j = i + j
            actual_j in marked_for_removal && continue

            new_term, was_combined = combine_if_same(new_term, term_j)
            if was_combined
                push!(marked_for_removal, actual_j)
            end
        end

        if new_term.factor != 0
            push!(new_terms, new_term)
        end
    end

    # Replace the terms vector content
    empty!(terms.terms)
    append!(terms.terms, new_terms)
    return terms
end

"""
    simplify(terms::Terms) -> Terms

Return simplified copy without modifying original.

Functional version of `simplify!()` that preserves the original collection.
Preferred for immutability, debugging, and thread safety.

# Arguments
- `terms::Terms`: Collection to simplify (unchanged)

# Returns
New simplified collection

# Example
```julia
original = K(2)
simplified = simplify(original)  # original unchanged
```
"""
function simplify(terms::Terms)
    new_terms = deepcopy(terms)
    simplify!(new_terms)
    return new_terms
end
