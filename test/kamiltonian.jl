"""
Tests for Kamiltonian and Generator calculations.
"""

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
