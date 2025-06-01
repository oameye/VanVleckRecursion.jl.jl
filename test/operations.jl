"""
Tests for quantum operations: brackets, time derivatives, rotation, and integration.
"""

@testset "Bracket Operations" begin
    using VanVleckRecursion: bracket
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
        result = bracket(term1, term2, 1 // 2)

        @test result.terms[1].factor == 2 * 3 * (1 // 2)
    end
end

@testset "Time Derivative Operations" begin
    using VanVleckRecursion: dot
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
        result = dot(term, 2 // 3)

        @test result.terms[1].factor == 3 * (2 // 3)
    end
end

@testset "Rotation Operations" begin
    using VanVleckRecursion: rot
    @testset "Rot Operation on Rotating Term" begin
        term = Term(rotating=1, factor=2)
        result = rot(term, 3 // 2)

        @test length(result.terms) == 1
        @test result.terms[1].factor == 2 * (3 // 2)
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
    using VanVleckRecursion: integrate
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
