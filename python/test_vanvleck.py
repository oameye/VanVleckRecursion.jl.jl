#!/usr/bin/env python3
"""
Test script for the vanvleck package
"""

import sys
import os

# Add the package to Python path
sys.path.append('/var/home/oameye/Documents/vanVleck-recursion')

# Import required modules
import sympy as smp
from vanvleck import Term, Terms, Kamiltonian, Generator, K, S

def test_basic_functionality():
    """Test basic functionality of the vanvleck package"""
    print("Testing vanvleck package...")
    
    # Create basic terms
    t0 = Term(0)  # Non-rotating term
    t1 = Term(1)  # Rotating term
    
    # Set up the Hamiltonian
    Kamiltonian.set_H(Terms([t0, t1]))
    
    # Test generators
    print("\n1. Testing generators:")
    s1 = S(1)
    print(f"   S(1) has {len(s1.terms)} terms")
    
    s2 = S(2)
    print(f"   S(2) has {len(s2.terms)} terms")
    
    # Test Kamiltonians
    print("\n2. Testing Kamiltonians:")
    k11 = K(1, 1)
    print(f"   K(1,1) has {len(k11.terms)} terms")
    
    k12 = K(1, 2)
    print(f"   K(1,2) has {len(k12.terms)} terms")
    
    # Test bracket operations
    print("\n3. Testing bracket operations:")
    bracket_result = t1.bracket(t0)
    print(f"   {{t1, t0}} has {len(bracket_result.terms)} terms")
    
    # Test LaTeX output
    print("\n4. Testing LaTeX output:")
    print(f"   S(1) LaTeX: {s1.latex()}")
    
    print("\nAll tests passed successfully!")

if __name__ == "__main__":
    test_basic_functionality()
