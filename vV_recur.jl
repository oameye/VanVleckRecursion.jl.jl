#!/usr/bin/env julia
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 16 21:27:50 2021
Translated to Julia from Python

@author: xiaoxu
"""

using SymPy
using Base: deepcopy

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

function bracket(self::Term, term::Term, factor::Sym = Sym(1))
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

function _latex(self::Term, freq_id::Int = 1; freq::Sym = symbols(""), freqs::Vector{Sym} = Sym[])
    if self.freq_denom != 0
        # decide if add freq term to denominator and increase freq index
        push!(freqs, freq)
        if typeof(freq) == Sym && (self.term1 === nothing ||
                                   self.term1.rotating * self.term2.rotating != 0)
            # denominator is a symbol, and no static element in bracket
            freq_id += 1
        end
    end

    if self.term1 === nothing  # base case
        if self.rotating == 0
            return "H_0", freq_id, freqs
        end
        return "H_{$(freq)}", freq_id, freqs
    end

    if self.rotating == 0
        if self.term1.freq_denom != 0
            freq1 = symbols("m_$(freq_id)")
            freq2 = freq - freq1
        else
            freq2 = symbols("m_$(freq_id)")
            freq1 = freq - freq2
        end

        s1, freq_id, freqs = _latex(self.term1, freq_id, freq = freq1, freqs = freqs)
        s2, freq_id, freqs = _latex(self.term2, freq_id, freq = freq2, freqs = freqs)

    else
        if self.term1.rotating * self.term2.rotating != 0
            # for both terms in bracket are rotating, the one with
            # freq_denom have a single freq index
            if self.term1.freq_denom != 0
                freq1 = symbols("m_$(freq_id)")
                s1, freq_id, freqs = _latex(self.term1, freq_id, freq = freq1, freqs = freqs)
                s2, freq_id, freqs = _latex(self.term2, freq_id, freq = freq - 1*freq1, freqs = freqs)
            else
                freq2 = symbols("m_$(freq_id)")
                s1, freq_id, freqs = _latex(self.term1, freq_id, freq = freq - 1*freq2, freqs = freqs)
                s2, freq_id, freqs = _latex(self.term2, freq_id, freq = freq2, freqs = freqs)
            end
        else  # if one of the term in bracket is static
            # in this case, the freq index should be passed over to next level
            if self.term1.rotating == 0
                s1, freq_id, freqs = _latex(self.term1, freq_id, freq = Sym(0), freqs = freqs)
                s2, freq_id, freqs = _latex(self.term2, freq_id, freq = freq, freqs = freqs)
            else
                s1, freq_id, freqs = _latex(self.term1, freq_id, freq = freq, freqs = freqs)
                s2, freq_id, freqs = _latex(self.term2, freq_id, freq = Sym(0), freqs = freqs)
            end
        end
    end
    return "\\{\\!\\!\\{$(s1),$(s2)\\}\\!\\!\\}", freq_id, freqs
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

# Define Terms struct
mutable struct Terms
    terms::Vector{Term}

    function Terms(terms::Vector{Term})
        new(terms)
    end

    function Terms(terms::Vector{Union{Term, Nothing}})
        filtered_terms = Term[]
        for term in terms
            if term !== nothing
                push!(filtered_terms, term)
            end
        end
        new(filtered_terms)
    end
end

function bracket(self::Terms, terms::Terms, factor::Sym = Sym(1))
    new_terms = Terms(Term[])
    for ti in self.terms
        for tj in terms.terms
            new_terms = new_terms + bracket(ti, tj, factor)
        end
    end
    return new_terms
end

function dot(self::Terms, factor::Sym = Sym(1))
    new_terms = Terms(Term[])
    for ti in self.terms
        new_terms = new_terms + dot(ti, factor)
    end
    return new_terms
end

function rot(self::Terms, factor::Sym = Sym(1))
    new_terms = Terms(Term[])
    for ti in self.terms
        new_terms = new_terms + rot(ti, factor)
    end
    return new_terms
end

function integrate(self::Terms, factor::Sym = Sym(1))
    new_terms = Terms(Term[])
    for ti in self.terms
        new_terms = new_terms + integrate(ti, factor)
    end
    return new_terms
end

function simplify!(self::Terms)
    new_terms_list = Term[]
    terms_to_skip = Set{Int}()

    for (i, ti) in enumerate(self.terms)
        if i in terms_to_skip
            continue
        end
        new_t = ti
        for (j, tj) in enumerate(self.terms[i+1:end])
            idx = i + j
            if idx in terms_to_skip
                continue
            end
            new_t, same = combine_if_same(new_t, tj)
            if same
                push!(terms_to_skip, idx)
            end
        end
        if new_t.factor != 0
            push!(new_terms_list, new_t)
        end
    end
    self.terms = new_terms_list
end

function Base.:+(self::Terms, terms::Terms)
    return Terms(vcat(self.terms, terms.terms))
end

function Base.string(self::Terms)
    s = ""
    for ti in self.terms
        s *= string(ti) * "\n"
    end
    return s
end

function Base.show(io::IO, self::Terms)
    print(io, "Terms(\n$(string(self)))")
end

function Base.length(self::Terms)
    return length(self.terms)
end

function latex(self::Terms)
    s = "&"
    count = 0
    for ti in self.terms
        count += 1
        s *= latex(ti)
        if count % 2 == 0
            s *= "\\\\ \n&"
        end
    end
    return s
end

function Base.:*(self::Terms, other)
    new_terms = Term[]
    for term in self.terms
        push!(new_terms, term * other)
    end
    return Terms(new_terms)
end

function Base.:*(other, self::Terms)
    new_terms = Term[]
    for term in self.terms
        push!(new_terms, other * term)
    end
    return Terms(new_terms)
end

# Kamiltonian class (inherits from Terms)
mutable struct Kamiltonian
    terms::Vector{Term}

    function Kamiltonian(terms::Vector{Term})
        new(terms)
    end
end

# Class variables for Kamiltonian
const Ks = Dict{String, Terms}()

function get_kamiltonian(n::Int, k::Int)
    """
    get Kamiltonian K(n)_[k] according to the recursive formula.
    """
    key = string([n, k])

    if haskey(Ks, key)
        return Ks[key]
    end

    if n == 0 && k == 0  # base case
        throw(ArgumentError("Base case of recursion not specified"))
    elseif n == 0 && k == 1
        Ks[key] = dot(S(1), Sym(1))
    elseif n != 0 && k == 1
        term1 = dot(S(n+1), Sym(1))
        term2 = bracket(S(n), K(0, 0))
        Ks[key] = term1 + term2
        # this can be alternatively expressed as static of term2 - rotating
        # parts of other K(n,k'!=k)
    elseif k > 1 && k <= n+1
        terms = Terms(Term[])
        for m in 0:(n-1)
            terms = terms + bracket(S(n-m), K(m, k-1), 1/Sym(k))
        end
        Ks[key] = terms
    else
        return Terms(Term[])
    end

    simplify!(Ks[key])
    return Ks[key]
end

function set_H!(H::Terms)
    Ks[string([0, 0])] = H
end

# Generator class (inherits from Terms)
mutable struct Generator
    terms::Vector{Term}

    function Generator(terms::Vector{Term})
        new(terms)
    end
end

# Class variables for Generator
const Ss = Dict{Int, Terms}()

function get_generator(n::Int)
    """
    get generator S(n) according to the recursive formula.
    """
    if haskey(Ss, n)
        return Ss[n]
    end

    terms = Terms(Term[])
    if n == 0
        return Terms(Term[])
    end
    if n == 1
        terms = terms + (Sym(-1) * K(0, 0))
    end
    if n > 1
        terms = terms + bracket(S(n-1), K(0, 0), Sym(-1))
    end
    for k in 2:n
        terms = terms + (Sym(-1) * K(n-1, k))
    end
    terms = integrate(rot(terms))

    simplify!(terms)
    Ss[n] = terms
    return Ss[n]
end

function K(n::Int, k::Int = -1)
    if k != -1
        return get_kamiltonian(n, k)
    end
    Kn = Terms(Term[])
    for ki in 0:(n+1)
        Kn = Kn + get_kamiltonian(n, ki)
    end
    simplify!(Kn)
    return Kn
end

function S(n::Int)
    return get_generator(n)
end
