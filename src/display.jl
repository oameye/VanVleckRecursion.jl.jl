"""
Display methods and LaTeX generation for terms and collections.
"""

# Frequency symbol management for LaTeX
struct FreqSymbol
    name::String
    index::Int
end

Base.show(io::IO, fs::FreqSymbol) = print(io, fs.name)
Base.string(fs::FreqSymbol) = fs.name
Base.:*(fs::FreqSymbol, other) = "$(fs.name)*$(other)"
Base.:*(other, fs::FreqSymbol) = "$(other)*$(fs.name)"
Base.:-(fs1::FreqSymbol, fs2::FreqSymbol) = "$(fs1.name) - $(fs2.name)"
Base.:-(other, fs::FreqSymbol) = "$(other) - $(fs.name)"
Base.:-(fs::FreqSymbol, other) = "$(fs.name) - $(other)"

# Create frequency symbols like m_1, m_2, etc.
freq_symbol(i::Int) = FreqSymbol("m_$i", i)

"""
    format_frequency_denominator(freqs::Vector)

Format frequency symbols into a proper denominator string with exponents.
Groups identical frequencies and formats them as m_i^n.
"""
function format_frequency_denominator(freqs::Vector)
    if isempty(freqs)
        return ""
    end

    # Count occurrences of each frequency
    freq_counts = Dict{String, Int}()
    for f in freqs
        if f != 0 && f !== nothing
            freq_str = string(f)
            freq_counts[freq_str] = get(freq_counts, freq_str, 0) + 1
        end
    end

    # Build denominator string with exponents
    denom_parts = String[]
    for (freq_name, count) in freq_counts
        if count == 1
            push!(denom_parts, freq_name)
        else
            push!(denom_parts, "$(freq_name)^$(count)")
        end
    end

    return join(denom_parts, "")
end

"""
    _latex(term::Term, freq_id::Int=1, freq=nothing, freqs::Vector=[])

Internal LaTeX generation with frequency indexing.

# Arguments
- `term::Term`: The term to process
- `freq_id::Int`: Current frequency index counter
- `freq`: Current frequency symbol or value
- `freqs::Vector`: Accumulated frequency symbols for denominator

# Returns
`Tuple{String, Int, Vector}`: (latex_string, next_freq_id, updated_freqs)
"""
function _latex(term::Term, freq_id::Int=1, freq=nothing, freqs::Vector=[])
    new_freqs = copy(freqs)

    if term.freq_denom != 0
        # Add frequency term to denominator and possibly increase freq index
        push!(new_freqs, freq)
        if isa(freq, FreqSymbol) && (term.term1 === nothing ||
                                     term.term1.rotating * term.term2.rotating != 0)
            # Denominator is a symbol, and no static element in bracket
            freq_id += 1
        end
    end

    # Base case
    if term.term1 === nothing
        if term.rotating == 0
            return "H_0", freq_id, new_freqs
        end
        freq_str = freq === nothing ? "" : string(freq)
        return "H_{$freq_str}", freq_id, new_freqs
    end

    # Recursive case
    if term.rotating == 0
        # Static term
        if term.term1.freq_denom != 0
            freq1 = freq_symbol(freq_id)
            freq2 = freq === nothing ? freq_symbol(freq_id+1) : freq - freq1
        else
            freq2 = freq_symbol(freq_id)
            freq1 = freq === nothing ? freq_symbol(freq_id+1) : freq - freq2
        end

        s1, freq_id, new_freqs = _latex(term.term1, freq_id, freq1, new_freqs)
        s2, freq_id, new_freqs = _latex(term.term2, freq_id, freq2, new_freqs)
    else
        # Rotating term
        if term.term1.rotating * term.term2.rotating != 0
            # Both terms in bracket are rotating
            if term.term1.freq_denom != 0
                freq1 = freq_symbol(freq_id)
                s1, freq_id, new_freqs = _latex(term.term1, freq_id, freq1, new_freqs)
                freq2_expr = freq === nothing ? freq_symbol(freq_id) : freq - freq1
                s2, freq_id, new_freqs = _latex(term.term2, freq_id, freq2_expr, new_freqs)
            else
                freq2 = freq_symbol(freq_id)
                freq1_expr = freq === nothing ? freq_symbol(freq_id) : freq - freq2
                s1, freq_id, new_freqs = _latex(term.term1, freq_id, freq1_expr, new_freqs)
                s2, freq_id, new_freqs = _latex(term.term2, freq_id, freq2, new_freqs)
            end
        else
            # One term is static
            if term.term1.rotating == 0
                s1, freq_id, new_freqs = _latex(term.term1, freq_id, 0, new_freqs)
                s2, freq_id, new_freqs = _latex(term.term2, freq_id, freq, new_freqs)
            else
                s1, freq_id, new_freqs = _latex(term.term1, freq_id, freq, new_freqs)
                s2, freq_id, new_freqs = _latex(term.term2, freq_id, 0, new_freqs)
            end
        end
    end

    return "\\{\\!\\!\\{$s1,$s2\\}\\!\\!\\}", freq_id, new_freqs
end

# Handle Nothing cases for _latex function
_latex(::Nothing, freq_id::Int, freq, freqs::Vector) = ("", freq_id, freqs)

"""
    latex(term::Term; advanced::Bool=true)

Generate LaTeX representation of a term.

# Arguments
- `term::Term`: The term to represent
- `advanced::Bool`: If true, uses sophisticated LaTeX with fractions and frequency handling

# Returns
`String`: LaTeX string representation

# Examples
```julia
term = Term(rotating=1, factor=2)
advanced_latex = latex(term)  # Complex fraction notation (default)
simple_latex = latex(term, advanced=false)  # "2*1e^{i\\omega t}"
```
"""
function latex(term::Term; advanced::Bool=true)
    if !advanced
        # Simple LaTeX implementation for basic use
        s = "$(term.factor)*$(term.footprint)"
        if term.rotating == 1
            s *= "e^{i\\omega t}"
        end
        return latexstring(s)
    end

    # Advanced LaTeX implementation with sophisticated formatting
    freq_id = 1
    freq = nothing

    if term.rotating == 0
        freq = 0
    else
        freq = freq_symbol(1)
    end    # Generate the main LaTeX structure
    s, freq_id, freqs = _latex(term, freq_id, freq, [])

    # Build denominator from accumulated frequencies
    denom_str = format_frequency_denominator(freqs)

    # Handle factor sign and magnitude
    factor_val = term.factor
    sign = factor_val >= 0

    # For rational numbers, separate numerator and denominator
    if isa(factor_val, Rational)
        p, q = abs(numerator(factor_val)), abs(denominator(factor_val))
    else
        p, q = abs(factor_val), 1
    end

    # Build the final LaTeX string
    result = sign ? "+" : "-"
    result *= "\\frac{"

    # Add numerator factor if not 1
    if p != 1
        result *= string(p)
    end

    result *= s
    result *= "}{"

    # Add denominator factor if not 1
    if q != 1
        result *= string(q)
    end

    # Add frequency denominator
    if !isempty(denom_str)
        result *= denom_str
    end

    # Add (iω)^n factor
    if length(freqs) > 0
        result *= "(i\\omega)^$(length(freqs))"
    end

    result *= "}"

    # Add rotating exponential factor
    if term.rotating == 1
        result *= "e^{im_1\\omega t}"
    end

    return result
end

"""
    latex(terms::Terms; advanced::Bool=true)

Generate LaTeX representation of a collection of terms with proper alignment.

# Arguments
- `terms::Terms`: The collection to represent
- `advanced::Bool`: If true, uses sophisticated LaTeX formatting for individual terms

# Returns
`String`: LaTeX string representation with line breaks and alignment
"""
function latex(terms::Terms; advanced::Bool=true)
    s = L""
    count = 0
    for term in terms.terms
        count += 1
        s *= latex(term, advanced=advanced)
        if count % 2 == 0
            s *= "\\\\ \n"
        end
    end
    return latexstring(s)
end

"""
    latex_advanced(term::Term)
    latex_advanced(terms::Terms)

Generate sophisticated LaTeX representation with proper fractions and frequency handling.
This is equivalent to calling `latex(term, advanced=true)`.

# Examples
```julia
term = Term(rotating=1, factor=1//2)
advanced_str = latex_advanced(term)
```
"""
latex_advanced(term::Term) = latex(term, advanced=true)
latex_advanced(terms::Terms) = latex(terms, advanced=true)

"""
    latex_simple(term::Term)
    latex_simple(terms::Terms)

Generate simple LaTeX representation for basic use.
This is equivalent to calling `latex(term, advanced=false)`.

# Examples
```julia
term = Term(rotating=1, factor=2)
simple_str = latex_simple(term)  # "2*1e^{i\\omega t}"
```
"""
latex_simple(term::Term) = latex(term, advanced=false)
latex_simple(terms::Terms) = latex(terms, advanced=false)

# Display methods
"""
    show(io::IO, term::Term)

Display a term in a compact format.
"""
Base.show(io::IO, term::Term) = print(io, "$(term.factor)*$(term.footprint)")

"""
    show(io::IO, terms::Terms)

Display a collection of terms, one per line.
"""
Base.show(io::IO, terms::Terms) = print(io, join(string.(terms.terms), "\n"))

"""
    length(terms::Terms)

Get the number of terms in a collection.
"""
Base.length(terms::Terms) = length(terms.terms)
