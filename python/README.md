# Van Vleck Recursion Package

A Python package for computing Van Vleck transformations using recursion formulas.

## Installation

From the project directory:

```bash
pip install -e .
```

Or simply add the project directory to your Python path:

```python
import sys
sys.path.append('/path/to/vanVleck-recursion')
```

## Usage

```python
from vanvleck import Term, Terms, Kamiltonian, Generator, K, S
import sympy as smp

# Create basic terms
t0 = Term(0)  # Non-rotating term
t1 = Term(1)  # Rotating term

# Set up the Hamiltonian
Kamiltonian.set_H(Terms([t0, t1]))

# Compute generators
s1 = S(1)  # First-order generator
s2 = S(2)  # Second-order generator

# Compute Kamiltonian terms
k11 = K(1, 1)  # Kamiltonian K(1)_[1]
k12 = K(1, 2)  # Kamiltonian K(1)_[2]

# Get LaTeX representation
print(s1.latex())
```

## Classes

- `Term`: Represents a single term in the expansion
- `Terms`: Collection of terms with operations
- `Kamiltonian`: Class for computing Kamiltonian terms K(n,k)
- `Generator`: Class for computing generators S(n)

## Functions

- `K(n, k=-1)`: Get Kamiltonian K(n)_[k] or sum over all k if k=-1
- `S(n)`: Get generator S(n)

## Examples

See the `examples/` directory for Jupyter notebooks demonstrating usage.
