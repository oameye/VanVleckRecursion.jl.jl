"""
Tests for LaTeX generation and display functionality.
"""

@testset "LaTeX Generation" begin
    using LaTeXStrings
    @testset "Simple Term LaTeX" begin
        term = Term(rotating=1, factor=2)
        latex_str = latex(term; advanced=false)  # Use simple format for this test
        @test isa(latex_str, String)
        @test occursin("2*1", latex_str)

        latex_str = latex(term; advanced=true)
        @test isa(latex_str, String)
        @test occursin("H_{m_1}", latex_str)
    end

    @testset "Terms Collection LaTeX" begin
        terms = Terms([Term(rotating=0), Term(rotating=1)])
        latex_str = latex(terms; advanced=false) # Use simple format for this test
        @test isa(latex_str, LaTeXString)
        @test occursin("1*0", latex_str)
        @test occursin("1*1", latex_str)

        latex_str = latex(terms; advanced=true)
        @test isa(latex_str, LaTeXString)
        @test occursin("H_0", latex_str)
        @test occursin("H_{m_1}", latex_str)
    end
end
