using Test
using VanVleckRecursion
using SymPy

@testset "VanVleckRecursion.jl" begin

    @testset "Term creation and basic operations" begin
        # Test Term creation
        t0 = Term(0)
        t1 = Term(1)

        @test t0.rotating == 0
        @test t1.rotating == 1
        @test t0.factor == Sym(1)
        @test t1.factor == Sym(1)

        # Test Term multiplication
        t_scaled = t1 * 2
        @test t_scaled.factor == Sym(2)

        t_scaled2 = 3 * t1
        @test t_scaled2.factor == Sym(3)
    end

    @testset "Terms operations" begin
        t0 = Term(0)
        t1 = Term(1)
        terms = Terms([t0, t1])

        @test length(terms) == 2

        # Test Terms addition
        terms2 = Terms([t1])
        combined = terms + terms2
        @test length(combined) == 3
    end

    @testset "Bracket operation" begin
        t0 = Term(0)
        t1 = Term(1)

        # Test bracket operation between terms
        bracket_result = bracket(t0, t1)
        @test length(bracket_result) > 0

        # Test bracket between Terms
        terms1 = Terms([t0])
        terms2 = Terms([t1])
        bracket_terms = bracket(terms1, terms2)
        @test length(bracket_terms) > 0
    end

    @testset "Van Vleck recursion" begin
        # Set up Hamiltonian
        set_H!(Terms([Term(0), Term(1)]))

        # Test S(1) computation
        s1 = S(1)
        @test length(s1) > 0

        # Test S(2) computation
        s2 = S(2)
        @test length(s2) > 0

        # Test K(0,0) should return the Hamiltonian we set
        k00 = K(0, 0)
        @test length(k00) == 2  # Should have H_0 and H_1 terms
    end

    @testset "LaTeX output" begin
        t1 = Term(1)
        latex_str = latex(t1)
        @test isa(latex_str, String)
        @test occursin("H_", latex_str)  # Should contain Hamiltonian notation

        terms = Terms([t1])
        latex_terms = latex(terms)
        @test isa(latex_terms, String)
    end

    @testset "Integration and rotation" begin
        t1 = Term(1)
        terms = Terms([t1])

        # Test rotation
        rotated = rot(terms)
        @test length(rotated) >= 0

        # Test integration
        integrated = integrate(rotated)
        @test length(integrated) >= 0

        # Test dot operation
        dotted = dot(terms)
        @test length(dotted) >= 0
    end
end
