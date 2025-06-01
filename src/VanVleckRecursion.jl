"""
$(DocStringExtensions.README)
"""
module VanVleckRecursion

using DocStringExtensions
using Printf, LaTeXStrings

# Export Kamiltonian and Generator functions
export K, S, kamiltonian_get, generator_get, set_hamiltonian!, clear_caches!, latex

include("types.jl")
include("operations.jl")
include("comparison.jl")
include("collections.jl")
include("arithmetic.jl")
include("display.jl")
include("kamiltonian.jl")

end # module VanVleckRecursion
