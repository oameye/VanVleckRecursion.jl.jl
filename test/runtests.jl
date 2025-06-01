using Test
using VanVleckRecursion
using SymPy


if isempty(VERSION.prerelease)
    @testset "Code linting" begin
        using JET
        JET.test_package(VanVleckRecursion; target_defined_modules=true)
        rep = report_package("VanVleckRecursion")
        @show rep
        @test length(JET.get_reports(rep)) <= 10
        @test_broken length(JET.get_reports(rep)) == 0
    end
end

@testset "ExplicitImports" begin
    using ExplicitImports
    @test check_no_stale_explicit_imports(VanVleckRecursion) == nothing
    @test check_all_explicit_imports_via_owners(VanVleckRecursion) == nothing
end

@testset "best practices" begin
    using Aqua

    Aqua.test_ambiguities([VanVleckRecursion]; broken=true)
    Aqua.test_all(VanVleckRecursion; ambiguities=false)
end
