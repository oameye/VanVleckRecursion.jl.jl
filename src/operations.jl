# filepath: /home/oameye/Documents/vanVleck-recursion/src/operations.jl
"""
Core operations for Van Vleck canonical transformation.
"""

"""
    bracket(term1::Term, term2::Term, factor=1)

Compute Poisson bracket {term1, term2} or commutator [term1, term2].

# Rules
- {static, oscillating} → oscillating
- {static, static} → static
- {oscillating, oscillating} → static + oscillating
"""
function bracket(term1::Term, term2::Term, factor=1)
    term_r = Term(;
        rotating=1,
        term1=term1,
        term2=term2,
        factor=factor * term1.factor * term2.factor,
        footprint="[$(term1.footprint),$(term2.footprint)]",
        term_count=(term1.term_count + term2.term_count),
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

Apply time derivative ∂/∂t. Oscillating terms get frequency factor,
static terms vanish.
"""
function dot(term::Term, factor=1)
    term.rotating == 0 && return Terms(Term[])

    new_term = deepcopy(term)
    new_term.factor *= factor
    new_term.freq_denom -= 1

    if new_term.freq_denom == 0
        # Cancels out the frequency prefactor from the integration
        new_term.footprint = new_term.footprint[1:(end - 2)]
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

Extract oscillating parts. Static terms → empty, oscillating terms → scaled.
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

Time integration. Oscillating terms → frequency denominator,
static terms → empty (no secular growth).
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
        new_term.footprint = new_term.footprint[1:(end - 3)]
    else
        # Add the frequency denominator to the footprint
        new_term.footprint *= "/$(new_term.freq_denom)"
    end

    return Terms([new_term])
end
