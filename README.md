# VanVleckRecursion.jl

[![docs](https://img.shields.io/badge/docs-online-blue.svg)](https://oameye.github.io/KeldyshContraction.jl/)
[![codecov](https://codecov.io/gh/oameye/KeldyshContraction.jl/branch/main/graph/badge.svg)](https://app.codecov.io/gh/oameye/KeldyshContraction.jl)
[![Benchmarks](https://github.com/oameye/KeldyshContraction.jl/actions/workflows/Benchmarks.yaml/badge.svg?branch=main)](https://oameye.github.io/KeldyshContraction.jl/benchmarks/)

[![Code Style: Blue](https://img.shields.io/badge/blue%20style%20-%20blue-4495d1.svg)](https://github.com/JuliaDiff/BlueStyle)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![jet](https://img.shields.io/badge/%F0%9F%9B%A9%EF%B8%8F_tested_with-JET.jl-233f9a)](https://github.com/aviatesk/JET.jl)

A Julia package for computing Van Vleck canonical transformations recurssion formula of rapidly driven quantum systems.

## What does this package do?

This package implements the Van Vleck recursion method to compute effective time-independent Hamiltonians for quantum systems under fast periodic driving. Given a time-dependent Hamiltonian `H(t) = H₀ + H₁cos(ωt) + ...`, the method derives the formula to systematically eliminates secular divergences that plague traditional perturbation theory and produces a static effective Hamiltonian `H_eff` valid for long times.

The recursive algorithm computes:
- **Generators** `S(n)`: Canonical transformation functions that eliminate time dependence
- **Kamiltonians** `K(n,k)`: Effective Hamiltonian contributions ordered by perturbation order `n` and frequency order `k`

## Example

```julia
using VanVleckRecursion

# Define a driven system: H(t) = H₀ + H₁cos(ωt) 
H = Terms([
    Term(rotating=0),      # Static term H₀
    Term(rotating=1)    # Oscillating term H₁cos(ωt)
])

# Set the Hamiltonian and compute effective theory
set_hamiltonian!(H)

# First-order effective Hamiltonian contributions
s1 = S(1)        # First-order generator
k1 = K(1)        # First-order Kamiltonian

# Higher orders
k2 = K(2)        # Second-order corrections
```

## Citation

This package implements the recursive formulas from:

**J. Venkatraman, X. Xiao, R. G. Cortiñas, A. Eickbusch, M. H. Devoret**  
*"On the static effective Hamiltonian of a rapidly driven nonlinear system"*  
Physical Review Letters **129**, 100601 (2022)  
[arXiv:2108.02861](https://arxiv.org/abs/2108.02861) | [DOI:10.1103/PhysRevLett.129.100601](https://doi.org/10.1103/PhysRevLett.129.100601)

```bibtex
@article{venkatraman2022static,
  title={On the static effective Hamiltonian of a rapidly driven nonlinear system},
  author={Venkatraman, Jayameenakshi and Xiao, Xu and Corti{\~n}as, Rodrigo G and Eickbusch, Alec and Devoret, Michel H},
  journal={Physical Review Letters},
  volume={129},
  number={10},
  pages={100601},
  year={2022},
  publisher={American Physical Society},
  doi={10.1103/PhysRevLett.129.100601},
  url={https://arxiv.org/abs/2108.02861}
}
```

Based on the original Python implementation by xiaoxu (2021), translated to Julia.