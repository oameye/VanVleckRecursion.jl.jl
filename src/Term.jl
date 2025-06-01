# Define Term struct
mutable struct Term
    rotating::Int
    factor::Sym
    freq_denom::Int
    term1::Union{Term, Nothing}
    term2::Union{Term, Nothing}
    footprint::String
    term_count::Int

    function Term(rotating::Int = 1)
        new(rotating, Sym(1), 0, nothing, nothing, string(rotating), 1)
    end
end

"""
compute {{self, term}}/factor

Parameters
----------
term : Term
    DESCRIPTION.
factor : Sym, optional
    DESCRIPTION. The default is Sym(1).

Returns
-------
Terms
"""
function bracket(self::Term, term::Term, factor::Sym = Sym(1))
    term_r = Term(1)
    term_r.term1 = self
    term_r.term2 = term
    term_r.factor = factor * self.factor * term.factor
    term_r.footprint = "[$(self.footprint),$(term.footprint)]"
    term_r.term_count = self.term_count + term.term_count

    term_s = deepcopy(term_r)
    term_s.rotating = 0
    term_s.footprint *= "0"

    if self.rotating != term.rotating
        return Terms([term_r])
    end
    if self.rotating == 0
        return Terms([term_s])
    end
    return Terms([term_s, term_r])
end

function dot(self::Term, factor::Sym = Sym(1))
    if self.rotating == 0
        return Terms(Term[])
    end
    new_term = deepcopy(self)
    new_term.factor = new_term.factor * factor
    new_term.freq_denom -= 1

    if new_term.freq_denom == 0
        # cancels out the frequency prefactor from the integration
        new_term.footprint = new_term.footprint[1:end-2]
    else
        # add the frequency denominator to the footprint
        # generally this shouldn't happen
        @warn "Unexpected derivative over an unintegrated term"
        new_term.footprint *= "/" * string(new_term.freq_denom)
    end
    return Terms([new_term])
end

function rot(self::Term, factor::Sym = Sym(1))
    if self.rotating == 0
        return Terms(Term[])
    end
    if factor == 1
        return Terms([self])
    end
    new_term = deepcopy(self)
    new_term.factor = new_term.factor * factor
    return Terms([new_term])
end

function integrate(self::Term, factor::Sym = Sym(1))
    if self.rotating == 0
        throw(ArgumentError("secular term generated from time integration"))
    end
    new_term = deepcopy(self)
    new_term.factor = new_term.factor * factor
    new_term.freq_denom += 1

    if new_term.freq_denom == 0
        # cancels out the frequency prefactor from the integration
        # generally this shouldn't happen
        @warn "Unexpected integration over a dot term directly"
        new_term.footprint = new_term.footprint[1:end-3]
    else
        # add the frequency denominator to the footprint
        new_term.footprint *= "/" * string(new_term.freq_denom)
    end

    return Terms([new_term])
end

function is_same(self::Term, term::Term)
    if typeof(term) != typeof(self)
        return 0
    end
    if self.term_count != term.term_count
        return 0  # base case 1
    end
    if self.rotating != term.rotating
        return 0  # base case 2
    end
    if self.freq_denom != term.freq_denom
        return 0  # base case 3
    end
    if self.term1 === nothing && term.term1 === nothing  # base case 4
        if self.rotating == term.rotating
            return 1
        else
            return 0
        end
    end

    a1, a2 = self.term1, self.term2
    b1, b2 = term.term1, term.term2

    # next we compare if {{a1, a2}} is the same as {{b1, b2}}
    a1b1 = is_same(a1, b1)
    if a1b1 != 0
        a2b2 = is_same(a2, b2)
        if a2b2 != 0
            return a1b1 * a2b2
        end
    end

    a1b2 = is_same(a1, b2)
    if a1b2 != 0
        a2b1 = is_same(a2, b1)
        if a2b1 != 0
            return -1 * a1b2 * a2b1
        end
    end

    if self.rotating == 0
        # special case. denominator can be swapped between b1 and b2
        b1 = deepcopy(b1)
        b2 = deepcopy(b2)
        if b1.freq_denom != b2.freq_denom
            temp = b1.freq_denom
            b1.freq_denom = b2.freq_denom
            b2.freq_denom = temp
        end

        a1b1 = is_same(a1, b1)
        if a1b1 != 0
            a2b2 = is_same(a2, b2)
            if a2b2 != 0
                return -1 * a1b1 * a2b2
            end
        end

        a1b2 = is_same(a1, b2)
        if a1b2 != 0
            a2b1 = is_same(a2, b1)
            if a2b1 != 0
                return a1b2 * a2b1
            end
        end
    end

    return 0
end

# Add these method definitions before the existing is_same method
function is_same(::Nothing, ::Nothing)
    return 1  # Both are nothing, so they're the same
end

function is_same(::Term, ::Nothing)
    return 0  # Term and nothing are different
end

function is_same(::Nothing, ::Term)
    return 0  # Nothing and term are different
end

function combine_if_same(self::Term, term::Term)
    same = is_same(self, term)
    if same == 0
        return self, false
    end
    combined = deepcopy(self)
    combined.factor += same * term.factor
    return combined, true
end

function latex(self::Term)
    freq_id = 1
    if self.rotating == 0
        freq = Sym("0")
    else
        freq = symbols("m_1")
    end
    # if the term is itself rotating, m_1 is reserved for the overall freq
    s, freq_id, freqs = _latex(self, freq_id, freq = freq, freqs = Sym[])
    denom = Sym(1)
    for freq in freqs
        denom *= freq
    end
    sign = self.factor > 0

    if length(free_symbols(-denom)) < length(free_symbols(denom))
        # if denom has a negative sign, move it to the overall sign
        sign = !sign
        denom *= -1
    end

    # Handle rational numbers properly
    factor_val = self.factor
    p, q = 1, 1
    try
        if hasmethod(numerator, (typeof(factor_val),))
            p = abs(numerator(factor_val))
            q = abs(denominator(factor_val))
        else
            p = abs(factor_val)
            q = 1
        end
    catch
        p = abs(factor_val)
        q = 1
    end

    sall = sign ? "+" : "-"
    sall *= "\\frac{"
    if p != 1
        sall *= string(p)
    end
    sall *= s * "}{"
    if q != 1
        sall *= string(q)
    end
    sall *= replace(replace(string(denom), "**" => "^"), "*" => "") *
            "(i\\omega)^$(length(freqs))}"
    if self.rotating == 1
        sall *= "e^{im_1\\omega t}"
    end
    return sall
end

function Base.string(self::Term)
    return string(self.factor) * "*" * self.footprint
end

function Base.show(io::IO, self::Term)
    print(io, "Term($(string(self)))")
end

function Base.:*(self::Term, other)
    new_term = deepcopy(self)
    new_term.factor *= other
    return new_term
end

function Base.:*(other, self::Term)
    new_term = deepcopy(self)
    new_term.factor *= other
    return new_term
end
