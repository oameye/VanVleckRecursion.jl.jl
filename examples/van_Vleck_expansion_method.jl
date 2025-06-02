# # Tutorial: Computing n-th Order Van Vleck Degenerate Perturbation Theory

# This tutorial demonstrates how to compute n-th order corrections using the Van Vleck degenerate perturbation theory method from [Eckardt & Anisimovas (2015)](https://arxiv.org/abs/1502.06477) implemented using the recursive formulas described in [Venkatraman et al. (2022)](https://arxiv.org/abs/2108.02861).

# The Van Vleck canonical transformation provides a systematic way to derive effective time-independent Hamiltonians for rapidly driven quantum systems. Unlike traditional perturbation theory, this method avoids secular divergences and produces results valid for arbitrarily long times.

# ### The Physical Problem

# Consider a periodically driven quantum system with Hamiltonian:
# ```math
# H(t) = H₀ + H₁cos(ωt) + H₂cos(2ωt) + ... = H₀ + Σ_k H_k cos(kωt)
# ```

# Where:
# - $H₀$: Static (time-independent) part
# - $H₁cos(ωt)$: Primary oscillating drive at frequency ω
# - Higher harmonics can also be included

# The goal is to find an effective time-independent Hamiltonian $H_\mathrm{eff}$ that captures the long-time dynamics of the system. To compute this, we will use the Van Vleck perturbation theory approachm, where the zeroth order Hamiltonian is $H₀$ and on compute higher order corrections by computing the commutators of the time-dependent Hamiltonian terms $H_k$ [see [Eckardt & Anisimovas (2015)](https://arxiv.org/abs/1502.06477)]. However, to know the which commutators to compute to which order, one needs to evaluate the recursive formulas described in [Venkatraman et al. (2022)](https://arxiv.org/abs/2108.02861). VanVleckRecursion.jl implements these recursive formulas to compute the n-th order commutator corrections.

# ## Using VanVleckRecursion.jl

# Let's start with the simplest driven system: $H(t) = H₀ + H₁cos(ωt)$

using VanVleckRecursion

# Define the Hamiltonian components
H = Terms([
    Term(; rotating=0),    # H₀ (static part)
    Term(; rotating=1),     # H₁cos(ωt) (oscillating part)
])

set_hamiltonian!(H)

# Now that we have specified the system, we can evaluate the recursion formulas to compute the effective Hamiltonian corrections. The $K(n)$ function computes the n-th order correction based on the defined Hamiltonian terms.

K(1)

# The output shows the first-order correction to the effective Hamiltonian. Here, we display the internal representation of the correction, which includes the commutator terms and their coefficients. The internal representation has three main components: coefficient, commutator structure, and the Floquet flag.
#  - coefficient: `-1//2` the term has a coefficient of -1/2
#  - commutator structure: `[1/1,1]` we have one commutator (Lie bracket) involving $H_{m_1}$ with itself but conjugate Floquet index `-m_1`. `/1` indicates that we have a Floquet index $m_1$ in the denominator.
#  - Floquet flag: `0` indicates that this term doesn't oscillate.

# We can also display the correction in LaTeX format for better readability:
latex(K(1))

#  For notational simplicity, in the following expressions we suppress the summation symbol. When a Fourier index $m_i$ appears in an expression it implies the summation overall valid $m_i \in \mathbb{Z}$. The(composite) Fourier index of a Hamiltonian term or that of a commutator (computed by summing the indices of the contained terms) should be non-zero unless it is zero by construction. The choices of $m_i$ violating this constraint are excluded. For example, for second order we have:

@show K(2)
latex(K(2))

# Which with summation symbols looks like:
# ```math
# \sum_{m\neq0} \left(
#     \frac{[\hat{H}_{-m},[\hat{H}_0, \hat{H}_{m}]]}{2(m \hbar \omega)^2}
#     + \sum_{m^\prime \neq 0,m} \frac{[\hat{H}_{-m^\prime},[\hat{H}_{m^\prime-m}, \hat{H}_{m}]]}{3m m^\prime (\hbar \omega)^2}
#     \right)
# ```

# From third order on it is clear we need this package :)

latex(K(3))

# ## References

# 1. **Eckardt, A. & Anisimovas, E.** (2015). High-frequency approximation for periodically driven quantum systems from a Floquet-space perspective. *New Journal of Physics* **17**, 093039. [arXiv:1502.06477](https://arxiv.org/abs/1502.06477)

# 2. **Venkatraman, J., Xiao, X., Cortiñas, R. G., Eickbusch, A., & Devoret, M. H.** (2022). On the static effective Hamiltonian of a rapidly driven nonlinear system. *Physical Review Letters* **129**, 100601. [arXiv:2108.02861](https://arxiv.org/abs/2108.02861)

# 3. **Van Vleck, J. H.** (1929). The correspondence principle in the statistical interpretation of quantum mechanics. *Proceedings of the National Academy of Sciences* **14**, 178-188.
