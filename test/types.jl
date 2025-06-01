"""
Tests for Term and Terms type construction and basic properties.
"""

@testset "Term Construction and Basic Properties" begin
    @testset "Default Term Construction" begin
        term = Term()
        @test term.rotating == 1
        @test term.factor == 1
        @test term.freq_denom == 0
        @test isnothing(term.term1)
        @test isnothing(term.term2)
        @test term.footprint == "1"
        @test term.term_count == 1
    end

    @testset "Custom Term Construction" begin
        static_term = Term(rotating=0, factor=2 // 3)
        @test static_term.rotating == 0
        @test static_term.factor == 2 // 3
        @test static_term.footprint == "0"

        rotating_term = Term(rotating=1, factor=3 // 2)
        @test rotating_term.rotating == 1
        @test rotating_term.factor == 3 // 2
        @test rotating_term.footprint == "1"
    end
end

@testset "Terms Collection Operations" begin
    @testset "Terms Construction" begin
        term1 = Term(rotating=0)
        term2 = Term(rotating=1)
        terms = Terms([term1, term2])

        @test length(terms.terms) == 2
        @test terms.terms[1] == term1
        @test terms.terms[2] == term2
    end

    @testset "Terms Addition" begin
        term1 = Term(rotating=0)
        term2 = Term(rotating=1)
        terms1 = Terms([term1])
        terms2 = Terms([term2])

        combined = terms1 + terms2
        @test length(combined.terms) == 2
    end

    @testset "Terms Filtering" begin
        # Test that Terms constructor filters out nothing values
        terms = Terms([Term(), nothing, Term(rotating=0)])
        @test length(terms.terms) == 2
    end
end

@testset "Term Comparison and Simplification" begin
    @testset "Same Term Detection" begin
        term1 = Term(rotating=1, factor=2)
        term2 = Term(rotating=1, factor=3)

        @test is_same(term1, term2) == 1
    end

    @testset "Different Terms" begin
        term1 = Term(rotating=0)
        term2 = Term(rotating=1)

        @test is_same(term1, term2) == 0
    end

    @testset "Term Combination" begin
        term1 = Term(rotating=1, factor=2)
        term2 = Term(rotating=1, factor=3)

        combined, was_combined = combine_if_same(term1, term2)
        @test was_combined == true
        @test combined.factor == 5
    end

    @testset "Terms Simplification" begin
        term1 = Term(rotating=1, factor=2)
        term2 = Term(rotating=1, factor=3)
        term3 = Term(rotating=0, factor=1)

        terms = Terms([term1, term2, term3])
        simplified = simplify(terms)

        @test length(simplified.terms) == 2  # Two different types

        # Find the rotating term (should have combined factor)
        rotating_term = filter(t -> t.rotating == 1, simplified.terms)[1]
        @test rotating_term.factor == 5
    end
end
