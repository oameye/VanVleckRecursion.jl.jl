"""
$(DocStringExtensions.README)
"""
module VanVleckRecursion

using Printf, LaTeXStrings

# Export main types
export AbstractTerm, AbstractTerms, Term, Terms, SymbolicNum

# Export main operations
export bracket, dot, rot, integrate
export is_same, combine_if_same, simplify, simplify!
export latex, latex_simple, latex_advanced

# Export Kamiltonian and Generator functions
export K, S, kamiltonian_get, generator_get, set_hamiltonian!, clear_caches!

# Export caches (for advanced users)
export KAMILTONIAN_CACHE, GENERATOR_CACHE

include("types.jl")
include("operations.jl")
include("comparison.jl")
include("collections.jl")
include("arithmetic.jl")
include("display.jl")
include("kamiltonian.jl")

end # module VanVleckRecursion
