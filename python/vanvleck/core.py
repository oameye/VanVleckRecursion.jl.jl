#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 16 21:27:50 2021

@author: xiaoxu
"""


import sympy as smp
from copy import deepcopy

class Term(object): #where the "subroutine" is defined
    def __init__(self, rotating = 1):
        self.rotating = rotating
        self.factor = smp.S(1)
        self.freq_denom = 0
        self.term1 = None
        self.term2 = None
        self.footprint = str(rotating)
        self.term_count = 1

    def bracket(self, term, factor = smp.S(1)):
        """
        compute {{self, term}}/factor

        Parameters
        ----------
        term : Term
            DESCRIPTION.
        factor : TYPE, optional
            DESCRIPTION. The default is smp.S(1).

        Returns
        -------
        Terms
        """
        term_r = Term(1)
        term_r.term1 = self
        term_r.term2 = term
        term_r.factor = factor*self.factor*term.factor
        term_r.footprint = '['+self.footprint+','+term.footprint+']'
        term_r.term_count = self.term_count + term.term_count

        term_s = deepcopy(term_r)
        term_s.rotating = 0
        term_s.footprint += '0'
        if self.rotating != term.rotating: return Terms([term_r])
        if self.rotating == 0: return Terms([term_s])
        return Terms([term_s, term_r])

    def dot(self, factor = smp.S(1)):
        if self.rotating == 0: return Terms([])
        new_term = deepcopy(self)
        new_term.factor = new_term.factor*factor
        new_term.freq_denom -= 1

        if new_term.freq_denom == 0:
            #cancles out the frequency prefactor from the integration
            new_term.footprint = new_term.footprint[:-2]
        else:
            #add the frequency denominator to the footprint
            #generally this shouldnt happend
            raise Warning("Unexpected derivative over an unintegrated term")
            new_term.footprint += "/"+str(new_term.freq_denom)
        return Terms([new_term])

    def rot(self, factor = smp.S(1)):
        if self.rotating == 0: return Terms([])
        if factor == 1: return Terms([self])
        new_term = deepcopy(self)
        new_term.factor = new_term.factor*factor
        return Terms([new_term])

    def integrate(self, factor = smp.S(1)):
        if self.rotating == 0:
            raise Exception("secular term generated from time integration")
        new_term = deepcopy(self)
        new_term.factor = new_term.factor*factor
        new_term.freq_denom += 1
        if new_term.freq_denom == 0:
            #cancles out the frequency prefactor from the integration
            #generally this shouldn't happen
            raise Warning("Unexpected integration over a dot term directly")
            new_term.footprint = new_term.footprint[:-3]
        else:
            #add the frequency denominator to the footprint
            new_term.footprint += "/"+str(new_term.freq_denom)

        return Terms([new_term])

    def is_same(self, term):
        if type(term) != self.__class__: return 0
        if self.term_count != term.term_count: return 0 #base case 1
        if self.rotating != term.rotating: return 0 #base case 2
        if self.freq_denom != term.freq_denom: return 0 #base case 3
        if self.term1  == None and term.term1 == None: #base case 4
            if self.rotating == term.rotating: return 1
            else: return 0

        a1, a2 = self.term1, self.term2
        b1, b2 = term.term1, term.term2

        # next we compare if {{a1, a2}} is the same as {{b1, b2}}
        a1b1 = a1.is_same(b1)
        if a1b1 != 0:
            a2b2 = a2.is_same(b2)
            if a2b2 != 0: return a1b1*a2b2

        a1b2 = a1.is_same(b2)
        if a1b2 != 0:
            a2b1 = a2.is_same(b1)
            if a2b1 != 0: return -1*a1b2*a2b1

        if self.rotating == 0:
            #special case. denominator can be swapped between b1 and b2
            b1 = deepcopy(b1)
            b2 = deepcopy(b2)
            if b1.freq_denom != b2.freq_denom:
                temp = b1.freq_denom
                b1.freq_denom = b2.freq_denom
                b2.freq_denom = temp

            a1b1 = a1.is_same(b1)
            if a1b1 != 0:
                a2b2 = a2.is_same(b2)
                if a2b2 != 0: return -1*a1b1*a2b2

            a1b2 = a1.is_same(b2)
            if a1b2 != 0:
                a2b1 = a2.is_same(b1)
                if a2b1 != 0: return a1b2*a2b1

        return 0

    def combine_if_same(self, term):
        same = self.is_same(term)
        if same == 0: return self, False
        combined = deepcopy(self)
        combined.factor += same*term.factor
        return combined, True

    def latex(self):
        freq_id = 1
        if self.rotating == 0: freq = smp.S("0")
        else:
            freq = smp.Symbol("m_1")
            # if self.freq_denom == 0: freq_id +=1
        #if the term is itself rotating, m_1 is reserved for the overall freq
        s, freq_id, freqs = self._latex(freq_id,
                                        freq = freq, freqs = [])
        denom = smp.S(1)
        for freq in freqs:
            denom *= freq
        sign = self.factor > 0

        if len((-denom).free_symbols) < len(denom.free_symbols):
            # if denom has a negative sign, move it to the overall sign
            sign = not sign
            denom *= -1

        p, q = abs(self.factor.p), abs(self.factor.q)
        sall = "+" if sign else "-"
        sall += "\\frac{"
        if p!=1: sall += str(p)
        sall += s+"}{"
        if q!=1: sall += str(q)
        sall += str(denom).replace("**","^").replace("*","")\
            +"(i\\omega)^%d}"%len(freqs)
        if self.rotating == 1:
            sall+="e^{im_1\\omega t}"
        return sall

    def _latex(self, freq_id = 1, freq = smp.Symbol(""), freqs =[]):
        if self.freq_denom != 0:
            #decide if add freq term to denominator and increase freq index
            freqs.append(freq)
            if type(freq) == smp.Symbol and (self.term1 == None or
                                             self.term1.rotating * self.term2.rotating != 0):
                #denominator is a symbol, and no static element in bracket
                freq_id += 1

        if self.term1 == None:#base case
            if self.rotating == 0:
                return "H_0", freq_id, freqs
            return "H_{"+str(freq)+"}", freq_id, freqs

        if self.rotating == 0:
            if self.term1.freq_denom != 0:
                freq1 = smp.Symbol("m_"+str(freq_id))
                freq2 = freq - freq1
            else:
                freq2 = smp.Symbol("m_"+str(freq_id))
                freq1 = freq - freq2

            s1, freq_id, freqs = self.term1._latex(freq_id, freq1, freqs)
            s2, freq_id, freqs = self.term2._latex(freq_id, freq2, freqs)

        else:
            if self.term1.rotating * self.term2.rotating != 0:
                # for both terms in bracket are rotating, the one with
                # freq_denom have a single freq index
                if self.term1.freq_denom != 0:
                    freq1 = smp.Symbol("m_"+str(freq_id))
                    s1, freq_id, freqs = self.term1._latex(freq_id, freq1,
                                                           freqs)
                    s2, freq_id, freqs = self.term2._latex(freq_id,
                                                           freq-1*freq1, freqs)
                else:
                    freq2 = smp.Symbol("m_"+str(freq_id))
                    s1, freq_id,freqs = self.term1._latex(freq_id,
                                                          freq - 1*freq2, freqs)
                    s2, freq_id, freqs = self.term2._latex(freq_id, freq2,
                                                           freqs)
            else: #if one of the term in bracket is static
                #in this case, the freq index should be passed over to next
                #level
                if self.term1.rotating == 0:
                    s1, freq_id, freqs = self.term1._latex(freq_id, smp.S(0),
                                                           freqs)
                    s2, freq_id, freqs = self.term2._latex(freq_id, freq,
                                                           freqs)
                else:
                    s1, freq_id, freqs = self.term1._latex(freq_id, freq,
                                                           freqs)
                    s2, freq_id, freqs = self.term2._latex(freq_id, smp.S(0),
                                                           freqs)
        return "\\{\\!\\!\\{"+s1+","+s2+"\\}\\!\\!\\}", freq_id, freqs

    def __str__(self):
        return str(self.factor)+"*"+self.footprint


    def _repr_pretty_(self, p, cycle):
        if not cycle:
            p.text('Term('+self.__str__()+')')
        else:
            with p.group(8, 'Term([', '])'):
                for idx, item in enumerate(self):
                    if idx:
                        p.text(',')
                        p.breakable()
                    p.pretty(item)

    def __mul__(self, other):
        new_term = deepcopy(self)
        new_term.factor *= other
        return new_term

    def __rmul__(self, other):
        new_term = deepcopy(self)
        new_term.factor *= other
        return new_term

class Terms(object):
    def __init__(self, terms):
        self.terms = list(filter(None, terms))

    def bracket(self, terms, factor = smp.S(1)):
        new_terms = Terms([])
        for ti in self.terms:
            for tj in terms.terms:
                new_terms += ti.bracket(tj, factor)
        # new_terms.simplify()
        return new_terms

    def dot(self, factor = smp.S(1)):
        new_terms = Terms([])
        for ti in self.terms:
            new_terms += ti.dot(factor)
        return new_terms

    def rot(self, factor = smp.S(1)):
        new_terms = Terms([])
        for ti in self.terms:
            new_terms += ti.rot(factor)
        return new_terms

    def integrate(self, factor = smp.S(1)):
        new_terms = Terms([])
        for ti in self.terms:
            new_terms += ti.integrate(factor)
        return new_terms


    def simplify(self):
        # return self
        new_terms_list = []
        for i, ti in enumerate(self.terms):
            new_t = ti
            if ti != None:
                for j, tj in enumerate(self.terms[i+1:]):
                    new_t, same = new_t.combine_if_same(tj)
                    if same: self.terms[i+j+1] = None
                if new_t.factor != 0: new_terms_list.append(new_t)
        self.terms = new_terms_list


    def __add__(self,  terms):
        return Terms(self.terms + terms.terms)

    def __str__(self):
        s = ""
        for ti in self.terms:
            s += str(ti) +"\n"
        return s

    def _repr_pretty_(self, p, cycle):
        if not cycle:
            p.text('Terms(\n'+self.__str__()+')')
        else:
            with p.group(8, 'MyList([', '])'):
                for idx, item in enumerate(self):
                    if idx:
                        p.text(',')
                        p.breakable()
                    p.pretty(item)
    def __len__(self):
        return len(self.terms)

    def latex(self):
        s = "" #"&"
        count = 0
        for ti in self.terms:
            count += 1
            s+= ti.latex()
            if count%2 == 0: s+="\\\\ \n"#s+="\\\\ \n&"
        return s

    def __mul__(self, other):
        new_terms = []
        for term in self.terms:
            new_terms.append(term*other)
        return Terms(new_terms)

    def __rmul__(self, other):
        new_terms = []
        for term in self.terms:
            new_terms.append(other*term)
        return Terms(new_terms)

class Kamiltonian(Terms):

    Ks = {}

    @classmethod
    def get(cls, n, k):
        """
        get Kamiltonian K(n)_[k] according to the recursive formula.
        """
        key = str([n,k])
        # print(key)

        if key in cls.Ks.keys():
            return cls.Ks[key]

        if n == 0 and k == 0:#base case
            raise Exception("Base case of recursion not specified")

        elif n == 0 and k == 1:
            cls.Ks[key] = S(1).dot(smp.S(1))

        elif n != 0 and k == 1:
            term1 = S(n+1).dot(smp.S(1))
            term2 = S(n).bracket(K(0,0))

            cls.Ks[key] = term1 + term2
            #this can be alternatively expressed as static of term2 - rotating
            #parts of other K(n,k'!=k)

        elif k > 1 and k <= n+1:
            # print("general")
            terms = Terms([])
            for m in range(n):
                # print(m,k-1)
                terms += S(n-m).bracket(K(m,k-1),1/smp.S(k))
            cls.Ks[key] = terms
        else:
            # print("zero case")
            return Terms([])
        cls.Ks[key].simplify()
        return cls.Ks[key]

    @classmethod
    def set_H(cls, H):
        cls.Ks[str([0,0])] = H



class Generator(Terms):
    Ss = {}

    @classmethod
    def get(cls, n):
        """
        get generator S(n) according to the recursive formula.
        """
        if n in cls.Ss.keys(): return cls.Ss[n]

        # print("S"+str(n))
        terms = Terms([])
        if n == 0: return Terms([])
        if n == 1:
            terms += smp.S(-1)*K(0,0)
        if n > 1:
            terms += S(n-1).bracket(K(0,0), smp.S(-1))
        for k in range(2, n+1):
            # print(k, n-1)
            terms += smp.S(-1)*K(n-1,k)
        terms = terms.rot().integrate()

        terms.simplify()
        cls.Ss[n] = terms
        # print("S"+str(n)+"done")
        return cls.Ss[n]



def K(n,k = -1):
    if k!= -1: return Kamiltonian.get(n,k)
    Kn = Terms([])
    for ki in range(n+2):
        Kn += Kamiltonian.get(n,ki)
    Kn.simplify()
    return Kn

def S(n):
    return Generator.get(n)
