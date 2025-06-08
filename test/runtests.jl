"""
Test suite for VanVleckRecursion.jl

This test suite verifies the functionality of the Van Vleck recursion implementation.
"""

using Test
using VanVleckRecursion

if isempty(VERSION.prerelease)
    @testset "Code linting" begin
        using JET
        JET.test_package(VanVleckRecursion; target_defined_modules=true)
        rep = report_package("VanVleckRecursion")
        @show rep
        @test length(JET.get_reports(rep)) <= 2
        @test_broken length(JET.get_reports(rep)) == 0
    end
end

@testset "ExplicitImports" begin
    using ExplicitImports
    @test check_no_implicit_imports(VanVleckRecursion) == nothing
    @test check_all_explicit_imports_via_owners(VanVleckRecursion) == nothing
    @test check_all_explicit_imports_are_public(VanVleckRecursion) == nothing
    @test check_no_stale_explicit_imports(VanVleckRecursion) == nothing
    @test check_all_qualified_accesses_via_owners(VanVleckRecursion) == nothing
    @test check_all_qualified_accesses_are_public(VanVleckRecursion) == nothing
    @test check_no_self_qualified_accesses(VanVleckRecursion) == nothing
end

@testset "best practices" begin
    using Aqua

    Aqua.test_ambiguities([VanVleckRecursion]; broken=true)
    Aqua.test_all(VanVleckRecursion; ambiguities=false)
end

@testset "Concretely typed" begin
    import VanVleckRecursion as VVR
    using CheckConcreteStructs

    all_concrete(VVR.Term)
    all_concrete(VVR.Terms)
end

# Include all test files
include("types.jl")
include("operations.jl")
include("arithmetic.jl")
include("display.jl")
include("kamiltonian.jl")
include("van_Vleck_expansion.jl")

@testset "Documentation" begin
    using Documenter
    DocMeta.setdocmeta!(
        VanVleckRecursion, :DocTestSetup, :(using VanVleckRecursion); recursive=true
    )
    Documenter.doctest(VanVleckRecursion)
end
