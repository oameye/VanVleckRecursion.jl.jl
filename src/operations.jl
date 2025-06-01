"""
Basic operations on individual terms: bracket, dot, rot, integrate.
"""

"""
    bracket(term1::Term, term2::Term, factor=1)

Compute the Poisson bracket {{term1, term2}}/factor.

This creates a new term representing the bracket operation between two terms.
The result depends on the rotating properties of the input terms.

# Arguments
- `term1::Term`: First term in the bracket
- `term2::Term`: Second term in the bracket
- `factor`: Scaling factor (default 1)

# Returns
`Terms`: Collection containing the result of the bracket operation

# Examples
```julia
term1 = Term(rotating=0)
term2 = Term(rotating=1)
result = bracket(term1, term2)
```
"""
function bracket(term1::Term, term2::Term, factor=1)
    term_r = Term(
        rotating = 1,
        term1 = term1,
        term2 = term2,
        factor = factor * term1.factor * term2.factor,
        footprint = "[$(term1.footprint),$(term2.footprint)]",
        term_count = term1.term_count + term2.term_count
    )

    term_s = deepcopy(term_r)
    term_s.rotating = 0
    term_s.footprint *= "0"

    if term1.rotating != term2.rotating
        return Terms([term_r])
    elseif term1.rotating == 0
        return Terms([term_s])
    else
        return Terms([term_s, term_r])
    end
end

"""
    dot(term::Term, factor=1)

Apply the dot operation (time derivative) to a term.

This operation represents taking the time derivative of a term.
Static terms (rotating=0) yield empty results.

# Arguments
- `term::Term`: The term to differentiate
- `factor`: Scaling factor (default 1)

# Returns
`Terms`: Collection containing the differentiated term
"""
function dot(term::Term, factor=1)
    term.rotating == 0 && return Terms(Term[])

    new_term = deepcopy(term)
    new_term.factor *= factor
    new_term.freq_denom -= 1

    if new_term.freq_denom == 0
        # Cancels out the frequency prefactor from the integration
        new_term.footprint = new_term.footprint[1:end-2]
    else
        # Add the frequency denominator to the footprint
        # Generally this shouldn't happen
        @warn "Unexpected derivative over an unintegrated term"
        new_term.footprint *= "/$(new_term.freq_denom)"
    end

    return Terms([new_term])
end

"""
    rot(term::Term, factor=1)

Apply rotation operation to a term.

This operation applies a rotation transformation with the given factor.
Static terms yield empty results.

# Arguments
- `term::Term`: The term to rotate
- `factor`: Rotation factor (default 1)

# Returns
`Terms`: Collection containing the rotated term
"""
function rot(term::Term, factor=1)
    term.rotating == 0 && return Terms(Term[])
    factor == 1 && return Terms([term])

    new_term = deepcopy(term)
    new_term.factor *= factor
    return Terms([new_term])
end

"""
    integrate(term::Term, factor=1)

Integrate a term with respect to time.

This operation performs time integration on a term.
Static terms cannot be integrated and will throw an error.

# Arguments
- `term::Term`: The term to integrate
- `factor`: Scaling factor (default 1)

# Returns
`Terms`: Collection containing the integrated term

# Throws
`ErrorException`: If attempting to integrate a static term
"""
function integrate(term::Term, factor=1)
    if term.rotating == 0
        error("Secular term generated from time integration")
    end

    new_term = deepcopy(term)
    new_term.factor *= factor
    new_term.freq_denom += 1

    if new_term.freq_denom == 0
        # Cancels out the frequency prefactor from the integration
        # Generally this shouldn't happen
        @warn "Unexpected integration over a dot term directly"
        new_term.footprint = new_term.footprint[1:end-3]
    else
        # Add the frequency denominator to the footprint
        new_term.footprint *= "/$(new_term.freq_denom)"
    end

    return Terms([new_term])
end
