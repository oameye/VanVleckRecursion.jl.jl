
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
