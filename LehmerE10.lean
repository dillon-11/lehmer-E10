/-
  LehmerE10.lean — the solution root module: `main_theorem`, stated identically to
  `Challenge.lean` and proved.
-/
import LehmerE10.Defs
import LehmerE10.Main

/-- **The claim.**  (i) Lehmer's polynomial is irreducible over ℤ, and (ii) the
characteristic polynomial of a Coxeter element of the E₁₀ Weyl group is Lehmer's
polynomial (McMullen, *Coxeter groups, Salem numbers and the Hilbert metric*,
Publ. Math. IHÉS 95, 2002). -/
theorem main_theorem :
    Irreducible lehmerPolynomial ∧ coxeterE10.charpoly = lehmerPolynomial :=
  ⟨LehmerE10.lehmer_irreducible, LehmerE10.coxeter_charpoly_lehmer⟩

#print axioms main_theorem
