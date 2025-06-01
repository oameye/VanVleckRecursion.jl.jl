using BenchmarkTools
using VanVleckRecursion

const SUITE = BenchmarkGroup()

include("van_Vleck_expansion.jl")

fifth_order_van_Vleck!(SUITE)

BenchmarkTools.tune!(SUITE)
results = BenchmarkTools.run(SUITE; verbose=true)
display(median(results))

BenchmarkTools.save("benchmarks_output.json", median(results))
