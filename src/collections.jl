"""
Operations on Terms collections and simplification functions.
"""

# Operations on Terms collections
"""
    bracket(terms1::Terms, terms2::Terms, factor=1)

Compute Poisson brackets between all pairs of terms.

This function computes the bracket operation between every term in the first
collection and every term in the second collection.

# Arguments
- `terms1::Terms`: First collection of terms
- `terms2::Terms`: Second collection of terms
- `factor`: Scaling factor (default 1)

# Returns
`Terms`: Collection containing all bracket results
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
    dot(terms::Terms, factor=1)

Apply dot operation to all terms.

# Arguments
- `terms::Terms`: Collection of terms to differentiate
- `factor`: Scaling factor (default 1)

# Returns
`Terms`: Collection containing all differentiated terms
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
    rot(terms::Terms, factor=1)

Apply rotation operation to all terms.

# Arguments
- `terms::Terms`: Collection of terms to rotate
- `factor`: Rotation factor (default 1)

# Returns
`Terms`: Collection containing all rotated terms
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
    integrate(terms::Terms, factor=1)

Integrate all terms.

# Arguments
- `terms::Terms`: Collection of terms to integrate
- `factor`: Scaling factor (default 1)

# Returns
`Terms`: Collection containing all integrated terms
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
    simplify!(terms::Terms)

Simplify terms by combining like terms (modifies in place).

This function combines terms with the same structure by adding their factors.
Terms with zero factors are removed. The operation modifies the input collection.

# Arguments
- `terms::Terms`: Collection to simplify (modified in place)

# Returns
`Terms`: The same collection (for chaining)

# Examples
```julia
terms = Terms([Term(rotating=1, factor=2), Term(rotating=1, factor=3)])
simplify!(terms)  # Now contains one term with factor=5
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
    simplify(terms::Terms)

Return a simplified copy of terms.

This function creates a new simplified collection without modifying the input.

# Arguments
- `terms::Terms`: Collection to simplify

# Returns
`Terms`: New simplified collection
"""
function simplify(terms::Terms)
    new_terms = deepcopy(terms)
    simplify!(new_terms)
    return new_terms
end
