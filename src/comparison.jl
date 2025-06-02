"""
Functions for comparing and combining Van Vleck recursion terms.

Provides structural comparison and combination of terms for simplification.
Handles anti-commutativity of Poisson brackets: {A,B} = -{B,A}.

Key functions:
- `is_same()`: Check structural equivalence with sign tracking
- `combine_if_same()`: Merge terms with identical structure
"""

"""
    is_same(term1::Term, term2::Term) -> Int

Check if two terms are structurally equivalent.

Returns similarity factor accounting for anti-commutativity:
- `0`: Different structure (cannot combine)
- `+1`: Identical structure (same sign)
- `-1`: Equivalent but opposite sign ({A,B} = -{B,A})

# Arguments
- `term1::Term`: First term to compare
- `term2::Term`: Second term to compare

# Example
```jldoctest
using VanVleckRecursion: is_same
term1 = Term(rotating=1, factor=2)
term2 = Term(rotating=1, factor=3)
is_same(term1, term2)  # Returns 1 (combinable; same sign)

# output

1
```
"""
function is_same(term1::Term, term2::Term)
    # Type check
    typeof(term1) != typeof(term2) && return 0

    # Base cases
    term1.term_count != term2.term_count && return 0
    term1.rotating != term2.rotating && return 0
    term1.freq_denom != term2.freq_denom && return 0

    # Both are leaf nodes
    if isnothing(term1.term1) && isnothing(term2.term1)
        return term1.rotating == term2.rotating ? 1 : 0
    end

    a1, a2 = term1.term1, term1.term2
    b1, b2 = term2.term1, term2.term2

    # Compare if {{a1, a2}} is the same as {{b1, b2}}
    a1b1 = is_same(a1, b1)
    if a1b1 != 0
        a2b2 = is_same(a2, b2)
        a2b2 != 0 && return a1b1 * a2b2
    end

    a1b2 = is_same(a1, b2)
    if a1b2 != 0
        a2b1 = is_same(a2, b1)
        a2b1 != 0 && return -a1b2 * a2b1
    end

    # Special case for non-rotating terms
    if term1.rotating == 0
        # Denominator can be swapped between b1 and b2
        b1_copy = deepcopy(b1)
        b2_copy = deepcopy(b2)

        if b1_copy.freq_denom != b2_copy.freq_denom
            b1_copy.freq_denom, b2_copy.freq_denom = b2_copy.freq_denom, b1_copy.freq_denom
        end

        a1b1_swap = is_same(a1, b1_copy)
        if a1b1_swap != 0
            a2b2_swap = is_same(a2, b2_copy)
            a2b2_swap != 0 && return -a1b1_swap * a2b2_swap
        end

        a1b2_swap = is_same(a1, b2_copy)
        if a1b2_swap != 0
            a2b1_swap = is_same(a2, b1_copy)
            a2b1_swap != 0 && return a1b2_swap * a2b1_swap
        end
    end

    return 0
end

"""
    combine_if_same(term1::Term, term2::Term) -> Tuple{Term, Bool}

Combine two terms if they are structurally equivalent.

Merges terms by adding coefficients when structure matches, handling sign
relationship from anti-commutativity. Preserves exact rational arithmetic.

# Arguments
- `term1::Term`: First term to combine
- `term2::Term`: Second term to combine

# Returns
- `Tuple{Term, Bool}`: (combined_term, was_combined)

# Example
```jldoctest
using VanVleckRecursion: combine_if_same
term1 = Term(rotating=1, factor=1//2)
term2 = Term(rotating=1, factor=1//3)
combined, success = combine_if_same(term1, term2)

# output
(5//6*1, true)
```
"""
function combine_if_same(term1::Term, term2::Term)
    same = is_same(term1, term2)
    same == 0 && return term1, false

    combined = deepcopy(term1)
    combined.factor += same * term2.factor
    return combined, true
end

# Handle Nothing cases for robust recursive comparison
# These ensure the recursive algorithm handles missing terms gracefully
is_same(::Nothing, ::Nothing) = 1     # Two missing terms are equivalent
is_same(::Term, ::Nothing) = 0        # Term vs missing: not equivalent
is_same(::Nothing, ::Term) = 0        # Missing vs term: not equivalent
