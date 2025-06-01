"""
Tests for arithmetic operations on Term and Terms objects.
"""

@testset "Arithmetic Operations" begin
    @testset "Term Multiplication" begin
        term = Term(rotating=1, factor=2)
        scaled_term = term * 3
        @test scaled_term.factor == 6

        scaled_term2 = 3 * term
        @test scaled_term2.factor == 6
    end

    @testset "Terms Multiplication" begin
        terms = Terms([Term(rotating=1, factor=2)])
        scaled_terms = terms * 3
        @test scaled_terms.terms[1].factor == 6

        scaled_terms2 = 3 * terms
        @test scaled_terms2.terms[1].factor == 6
    end
end
