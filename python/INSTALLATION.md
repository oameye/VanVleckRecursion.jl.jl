# Van Vleck Recursion Package - Installation Guide

## Overview

The `vanvleck` package has been successfully created from the original `vV_recur.py` file. The package structure is:

```
vanVleck-recursion/
├── vanvleck/                 # Main package directory
│   ├── __init__.py          # Package initialization
│   ├── core.py              # Core functionality (from vV_recur.py)
│   └── README.md            # Package documentation
├── examples/
│   └── basic_usage_py.ipynb # Updated notebook with package usage
├── pyproject.toml           # Modern Python package configuration
└── test_vanvleck.py         # Test script
```

## Usage in Jupyter Notebooks

The `basic_usage_py.ipynb` notebook has been updated to use the new package structure:

```python
import sys
import os

# Add the parent directory to the Python path to import vanvleck
sys.path.append('/var/home/oameye/Documents/vanVleck-recursion')

# Import sympy which is required by vanvleck
import sympy as smp

# Now import the vanvleck package
from vanvleck import Term, Terms, Kamiltonian, Generator, K, S
```

## Package Features

- **Term**: Represents a single term in the expansion
- **Terms**: Collection of terms with mathematical operations
- **Kamiltonian**: Class for computing Kamiltonian terms K(n,k)
- **Generator**: Class for computing generators S(n)
- **K(n, k)**: Function to get Kamiltonian terms
- **S(n)**: Function to get generator terms

## Examples

The notebook includes comprehensive examples showing:
1. Basic term creation and Hamiltonian setup
2. Generator computation (S(1), S(2), etc.)
3. Kamiltonian computation (K(1,1), K(1,2), etc.)
4. Advanced operations like bracket operations, integration
5. LaTeX output generation

## Testing

Run the test script to verify everything works:

```bash
cd /var/home/oameye/Documents/vanVleck-recursion
python test_vanvleck.py
```

The package is now properly organized and ready for use!
