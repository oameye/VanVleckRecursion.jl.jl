"""
Display methods and LaTeX generation for Van Vleck recursion terms.

Provides LaTeX output formatting for terms and collections:
- Frequency indexing with automatic m₁, m₂, ... symbols
- Nested Poisson brackets {{H₁,H₂}}
- Denominators with (iω)ⁿ powers
- Rational coefficients and time dependence e^(imω t)

Output follows Venkatraman et al. (2022) conventions.
"""

# Frequency symbol management for LaTeX
"""
    FreqSymbol

Frequency symbol for LaTeX generation with automatic indexing.
Generates symbols like m₁, m₂, etc. for frequency expansion.

Fields: `name::String`, `index::Int`
"""
struct FreqSymbol
    name::String
    index::Int
end

# Arithmetic operations for frequency symbols in LaTeX expressions
Base.show(io::IO, fs::FreqSymbol) = print(io, fs.name)
Base.string(fs::FreqSymbol) = fs.name
Base.:*(fs1::FreqSymbol, fs2::FreqSymbol) = "$(fs1.name)*$(fs2.name)"
Base.:*(fs::FreqSymbol, terms::Terms) = "$(fs.name)*$(terms)"
Base.:*(fs::FreqSymbol, other) = "$(fs.name)*$(other)"
Base.:*(other, fs::FreqSymbol) = "$(other)*$(fs.name)"
Base.:-(fs1::FreqSymbol, fs2::FreqSymbol) = "$(fs1.name) - $(fs2.name)"
Base.:-(other, fs::FreqSymbol) = "$(other) - $(fs.name)"
Base.:-(fs::FreqSymbol, other) = "$(fs.name) - $(other)"

"""
    freq_symbol(i::Int) -> FreqSymbol

Create frequency symbol with index i, formatted as "m_i".

## Example
```julia
sym = freq_symbol(1)  # Creates "m_1"
```
"""
freq_symbol(i::Int) = FreqSymbol("m_$i", i)

"""
    format_frequency_denominator(freqs::Vector) -> String

Format frequency symbols into denominator string with exponents.

Groups identical frequencies and represents with exponents for
LaTeX denominators (e.g., "m_1^2m_2").

## Example
```julia
freqs = [freq_symbol(1), freq_symbol(1), freq_symbol(2)]
denom = format_frequency_denominator(freqs)  # "m_1^2m_2"
```
"""
function format_frequency_denominator(freqs::Vector)
    if isempty(freqs)
        return ""
    end

    # Count occurrences of each frequency
    freq_counts = Dict{String,Int}()
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
    _latex(term::Term, freq_id::Int=1, freq=nothing, freqs::Vector=[]) -> Tuple{String, Int, Vector}

Internal recursive LaTeX generation with frequency indexing.

Core function for converting Van Vleck terms to LaTeX format. Handles nested
Poisson brackets, frequency assignment, and denominator accumulation.

Returns: (latex_string, next_freq_id, updated_freqs)
"""
function _latex(term::Term, freq_id::Int=1, freq=nothing, freqs::Vector=[])
    new_freqs = copy(freqs)

    if term.freq_denom != 0
        # Add frequency term to denominator and possibly increase freq index
        push!(new_freqs, freq)
        if isa(freq, FreqSymbol) &&
            (term.term1 === nothing || term.term1.rotating * term.term2.rotating != 0)
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

# Handle Nothing cases for _latex function - ensures robustness in recursive traversal
_latex(::Nothing, freq_id::Int, freq, freqs::Vector) = ("", freq_id, freqs)

"""
    latex(term::Term; advanced::Bool=true) -> String

Generate LaTeX representation of Van Vleck recursion term.

- `advanced=true`: Sophisticated LaTeX with fractions, frequency indexing, denominators
- `advanced=false`: Simple coefficient*exponential format

## Example
```julia
term = Term(rotating=1, factor=1//2)
latex(term)  # "\\frac{1}{2}H_{m_1}e^{im_1\\omega t}"
latex(term, advanced=false)  # "1/2*1e^{i\\omega t}"
```
"""
function latex(term::Term; advanced::Bool=true)
    if !advanced
        # Simple LaTeX implementation for basic use
        s = "$(term.factor)*$(term.footprint)"
        if term.rotating == 1
            s *= "e^{i\\omega t}"
        end
        return s
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
    latex(terms::Terms; advanced::Bool=true) -> String

Generate LaTeX representation of term collection with proper alignment.

Formats multiple terms (K⁽ⁿ⁾ or S⁽ⁿ⁾ expressions) with line breaks
every 2 terms for readability.

## Example
```julia
k2_terms = K(2)
k2_latex = latex(k2_terms)  # Multi-line LaTeX output
```
"""
function latex(terms::Terms; advanced::Bool=true)
    s = ""
    count = 0
    for term in terms.terms
        count += 1
        s *= latex(term; advanced=advanced)
        if count % 2 == 0
            s *= "\\\\ \n"
        end
    end
    return LaTeXStrings.latexstring(s)
end

# Display methods for Van Vleck recursion terms and collections

"""
    show(io::IO, term::Term)

Display Van Vleck term in compact format for console output.
Shows essential components: factor, footprint, and structure.

Format: `factor*footprint`

## Example
```julia
term = Term(rotating=1, factor=1//2)
println(term)  # "1//2*1"
```
"""
Base.show(io::IO, term::Term) = print(io, "$(term.factor)*$(term.footprint)")

"""
    show(io::IO, terms::Terms)

Display collection of Van Vleck terms, one per line.
Organized output for easy inspection of K⁽ⁿ⁾ or S⁽ⁿ⁾ expressions.

## Example
```julia
k2_terms = K(2)
println(k2_terms)  # Multi-line term display
```
"""
Base.show(io::IO, terms::Terms) = print(io, join(string.(terms.terms), "\n"))

"""
    length(terms::Terms) -> Int

Get number of terms in Van Vleck recursion collection.
Useful for analyzing complexity of K⁽ⁿ⁾ expressions.

## Example
```julia
k3_terms = K(3)
length(k3_terms)  # Number grows with recursion order
```
"""
Base.length(terms::Terms) = length(terms.terms)

# const T_LATEX = Union{<:QField,Diagrams,Diagram,Edge}
# Base.show(io::IO, ::MIME"text/latex", x::T_LATEX) = write(io, latexify(x))
