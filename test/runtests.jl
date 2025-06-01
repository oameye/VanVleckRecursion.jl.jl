"""
Test suite for VanVleckRecursion.jl

This test suite verifies the functionality of the Van Vleck recursion implementation.
"""

using Test
using VanVleckRecursion

@testset "VanVleckRecursion.jl Tests" begin

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
            static_term = Term(rotating=0, factor=2//3)
            @test static_term.rotating == 0
            @test static_term.factor == 2//3
            @test static_term.footprint == "0"

            rotating_term = Term(rotating=1, factor=3//2)
            @test rotating_term.rotating == 1
            @test rotating_term.factor == 3//2
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

    @testset "Bracket Operations" begin
        @testset "Basic Bracket Operation" begin
            term1 = Term(rotating=0)
            term2 = Term(rotating=1)
            result = bracket(term1, term2)

            @test length(result.terms) == 1
            @test result.terms[1].rotating == 1
            @test result.terms[1].footprint == "[0,1]"
        end

        @testset "Bracket with Same Rotating Terms" begin
            term1 = Term(rotating=1)
            term2 = Term(rotating=1)
            result = bracket(term1, term2)

            @test length(result.terms) == 2
            # Should have both static and rotating components
            rotating_terms = filter(t -> t.rotating == 1, result.terms)
            static_terms = filter(t -> t.rotating == 0, result.terms)
            @test length(rotating_terms) == 1
            @test length(static_terms) == 1
        end

        @testset "Bracket with Factor" begin
            term1 = Term(rotating=0, factor=2)
            term2 = Term(rotating=1, factor=3)
            result = bracket(term1, term2, 1//2)

            @test result.terms[1].factor == 2 * 3 * (1//2)
        end
    end

    @testset "Time Derivative Operations" begin
        @testset "Dot Operation on Rotating Term" begin
            term = Term(rotating=1, factor=2)
            result = dot(term)

            @test length(result.terms) == 1
            @test result.terms[1].factor == 2
            @test result.terms[1].freq_denom == -1
        end

        @testset "Dot Operation on Static Term" begin
            term = Term(rotating=0)
            result = dot(term)

            @test length(result.terms) == 0  # Should return empty
        end

        @testset "Dot with Factor" begin
            term = Term(rotating=1, factor=3)
            result = dot(term, 2//3)

            @test result.terms[1].factor == 3 * (2//3)
        end
    end

    @testset "Rotation Operations" begin
        @testset "Rot Operation on Rotating Term" begin
            term = Term(rotating=1, factor=2)
            result = rot(term, 3//2)

            @test length(result.terms) == 1
            @test result.terms[1].factor == 2 * (3//2)
        end

        @testset "Rot Operation on Static Term" begin
            term = Term(rotating=0)
            result = rot(term)

            @test length(result.terms) == 0
        end

        @testset "Rot with Unity Factor" begin
            term = Term(rotating=1)
            result = rot(term, 1)

            @test length(result.terms) == 1
            @test result.terms[1] === term  # Should return same term
        end
    end

    @testset "Integration Operations" begin
        @testset "Integration of Rotating Term" begin
            term = Term(rotating=1, factor=2)
            result = integrate(term, 3)

            @test length(result.terms) == 1
            @test result.terms[1].factor == 6
            @test result.terms[1].freq_denom == 1
        end

        @testset "Integration of Static Term Should Error" begin
            term = Term(rotating=0)
            @test_throws ErrorException integrate(term)
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

    @testset "LaTeX Generation" begin
        @testset "Simple Term LaTeX" begin
            term = Term(rotating=1, factor=2)
            latex_str = latex_simple(term)  # Use simple format for this test
            @test isa(latex_str, String)
            @test occursin("2*1", latex_str)
        end

        @testset "Terms Collection LaTeX" begin
            terms = Terms([Term(rotating=0), Term(rotating=1)])
            latex_str = latex_simple(terms)  # Use simple format for this test
            @test isa(latex_str, String)
        end
    end

    @testset "Kamiltonian and Generator Calculations" begin
        @testset "Setup and Basic Calculations" begin
            # Set up Hamiltonian
            H = Terms([Term(rotating=0), Term(rotating=1)])
            set_hamiltonian!(H)

            @testset "First Order Generator" begin
                s1 = S(1)
                @test isa(s1, Terms)
                @test length(s1.terms) > 0
            end

            @testset "Kamiltonian K(1,1)" begin
                k11 = K(1, 1)
                @test isa(k11, Terms)
                @test length(k11.terms) > 0
            end

            @testset "Full Kamiltonian K(1)" begin
                k1 = K(1)
                @test isa(k1, Terms)
                @test length(k1.terms) > 0
                # K(1) should contain all terms from K(1,k) for k=0,1,2,...
                # so it should have at least as many terms as any individual K(1,k)
                @test length(k1.terms) >= 1
            end
        end

        @testset "Caching Behavior" begin
            # Clear cache to test
            clear_caches!()

            H = Terms([Term(rotating=0), Term(rotating=1)])
            set_hamiltonian!(H)

            # First calculation
            s1_first = S(1)
            @test haskey(GENERATOR_CACHE, 1)

            # Second calculation should use cache
            s1_second = S(1)
            @test s1_first.terms == s1_second.terms
        end

        @testset "Error Cases" begin
            # Clear the Hamiltonian to test error case
            clear_caches!()
            @test_throws ErrorException kamiltonian_get(0, 0)

            # Restore Hamiltonian for other tests
            H = Terms([Term(rotating=0), Term(rotating=1)])
            set_hamiltonian!(H)
        end
    end
end
