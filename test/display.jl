"""
Tests for LaTeX generation and display functionality.
"""

@testset "LaTeX Generation" begin
    using LaTeXStrings
    @testset "Simple Term LaTeX" begin
        term = Term(rotating=1, factor=2)
        latex_str = latex_simple(term)  # Use simple format for this test
        @test isa(latex_str, LaTeXString)
        @test occursin("2*1", latex_str)
    end

    @testset "Terms Collection LaTeX" begin
        terms = Terms([Term(rotating=0), Term(rotating=1)])
        latex_str = latex_simple(terms)  # Use simple format for this test
        @test isa(latex_str, LaTeXString)
    end
end
