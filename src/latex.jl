
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

function latex(self::Terms)
    # s = "&"
    s = ""
    count = 0
    for ti in self.terms
        count += 1
        s *= latex(ti)
        if count % 2 == 0
            # s *= "\\\\ \n&"
            s *= "\\\\ \n"
        end
    end
    return s
end
