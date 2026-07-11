# Lehmer's polynomial and the E₁₀ Coxeter element, in Lean 4

[![build + comparator](https://github.com/dillon-11/lehmer-E10/actions/workflows/ci.yml/badge.svg)](https://github.com/dillon-11/lehmer-E10/actions/workflows/ci.yml)

A machine-checked proof of two classical facts about **Lehmer's polynomial**

```
L(x) = x¹⁰ + x⁹ − x⁷ − x⁶ − x⁵ − x⁴ − x³ + x + 1,
```

the integer polynomial of smallest known Mahler measure `> 1` (Lehmer, 1933):

1. **`L` is irreducible over ℤ** (hence over ℚ).
2. **The characteristic polynomial of a Coxeter element of the E₁₀ Weyl group is `L`**
   (the rank-10 instance of McMullen, *Coxeter groups, Salem numbers and the Hilbert
   metric*, Publ. Math. IHÉS 95, 2002).

The claim is stated in [`Challenge.lean`](Challenge.lean) — a single file importing
only Mathlib, which defines `L`, the E₁₀ generalized Cartan matrix, its simple
reflections, and the Coxeter element `s₀s₁⋯s₉` as the product of the reflection
matrices acting on the root lattice, and ends with:

```lean
theorem main_theorem :
    Irreducible lehmerPolynomial ∧ coxeterE10.charpoly = lehmerPolynomial
```

The proof lives in the `LehmerE10` library (~1,500 lines, 6 files) and uses no
axioms beyond Lean's three standard ones (`propext`, `Classical.choice`,
`Quot.sound`). There is exactly one `sorry` in the repository: the intentional
placeholder in `Challenge.lean`.

**Not claimed:** Lehmer's 1933 *conjecture* (a positive lower bound for Mahler
measures exceeding 1) is not claimed, addressed, or assumed anywhere in this
repository. These are two known theorems, formalized.

## Verifying the proof with comparator

You do not need to read (or trust) the proof library to check the claim. Inspect
`Challenge.lean` (the trust surface, Mathlib imports only), then verify mechanically
with [comparator](https://github.com/leanprover/comparator), which checks that
`main_theorem` in the `LehmerE10` library proves *exactly* the statement in
`Challenge.lean`, uses only the permitted axioms, and is accepted by the Lean
kernel:

```bash
# toolchain
elan toolchain install leanprover/lean4:v4.32.0-rc1

# tools (see https://github.com/leanprover/comparator for pinned setup)
git clone https://github.com/leanprover/comparator && (cd comparator && lake build comparator)
git clone https://github.com/leanprover/lean4export && (cd lean4export && lake build)
git clone https://github.com/Zouuup/landrun && (cd landrun && go build -o landrun cmd/landrun/main.go)   # Linux sandbox

# this repository
lake exe cache get   # fetch Mathlib build cache
lake build           # builds Challenge (one sorry warning, intentional) and LehmerE10
lake env path/to/comparator/.lake/build/bin/comparator config.json
```

On systems without kernel-level sandbox support, use comparator's development shim:

```bash
COMPARATOR_LANDRUN=path/to/comparator/scripts/fake-landrun.sh \
COMPARATOR_LEAN4EXPORT=path/to/lean4export/.lake/build/bin/lean4export \
lake env path/to/comparator/.lake/build/bin/comparator config.json
```

Expected output: `Your solution is okay!`

## Repository layout

| File | Contents |
| --- | --- |
| `Challenge.lean` | the trusted claim statement (Mathlib imports only, one `sorry`) |
| `LehmerE10.lean` | `main_theorem`, stated identically and proved |
| `LehmerE10/Defs.lean` | the claim's definitions, byte-identical to `Challenge.lean` |
| `LehmerE10/Kronecker.lean` | evaluation witnesses; **Kronecker's theorem** (1857, root form): a monic ℤ-polynomial with all complex roots on the unit circle has only roots of unity as roots — via Mathlib's `NumberField.Embeddings.pow_eq_one_of_norm_eq_one` in ℚ⟮z⟯ |
| `LehmerE10/CyclotomicKill.lean` | no cyclotomic polynomial divides `L`: one uniform argument from `L(2) = 1291` prime with `ord₁₂₉₁(2) = 1290`, so `Φ_k ∣ L ⟹ 1290 ∣ k ⟹ φ(k) ≥ 336 > 10`; plus the conditional charpoly identity via Cayley–Hamilton and minimal-polynomial divisibility |
| `LehmerE10/TraceQuintic.lean` | `L(x) = x⁵ q(x + 1/x)` with `q(y) = y⁵ + y⁴ − 5y³ − 5y² + 4y + 3`; the five real roots of `q` located by intermediate-value sign checks (four in `(−2,2)`, one in `(2, 21/10)`) |
| `LehmerE10/UnitCircleFactors.lean` | no monic factor of `L` of positive degree has all roots on the unit circle (Kronecker + the cyclotomic kill) |
| `LehmerE10/Main.lean` | the trace-root census, root classification (8 roots on the circle, one simple reciprocal Salem pair `{μ, 1/μ}` off it), the factor argument `⟹` irreducibility; the Coxeter element evaluated and annihilated by `L` (kernel computations), `⟹` the charpoly identity |

## Proof sketch

**Irreducibility.** Every complex root `z` of `L` has trace `y = z + 1/z` a root of
the quintic `q`. Four roots of `q` lie in `(−2,2)` — each giving a conjugate pair of
roots of `L` *on* the unit circle — and the fifth lies in `(2, 21/10)`, giving the
reciprocal pair `{μ, 1/μ}` with `1/μ < 1 < μ` off the circle (Salem's
configuration). If `L = F·G` properly, then `F(0)G(0) = L(0) = 1` forces
`|F(0)| = 1`; but `|F(0)| = ∏|roots of F| = μᵃ(1/μ)ᵇ` with `a, b ∈ {0,1}`, and each
of the four cases fails: `(1,0)`/`(0,1)` contradict `μ ≠ 1`, while `(0,0)`/`(1,1)`
make one factor all-on-circle — impossible, since by Kronecker's theorem such a
factor has a root of unity as a root, whose cyclotomic minimal polynomial would
divide `L` (Gauss), contradicting the uniform-1291 cyclotomic kill.

**The charpoly identity.** The Coxeter element `s₀s₁⋯s₉` evaluates to an explicit
integer matrix `C` (kernel computation), and `L(C) = 0` (kernel computation). Over
ℚ, the minimal polynomial of `C` divides both `L` (irreducible, so equals it) and
the characteristic polynomial; both are monic of degree 10, hence equal; the
identity descends to ℤ by injectivity of the coefficient map.

## E₁₀ diagram cross-check

`cartanE10` in [`Defs.lean`](LehmerE10/Defs.lean) encodes an A₉ chain (nodes `0..8`)
with node `9` attached to node `2` — a trivalent diagram with arms of length `2, 1, 6`
(nodes `0,1` / node `9` alone / nodes `3..8`) hanging off the branch node `2`, for
`2 + 1 + 6 + 1 (branch node) = 10` nodes total. This is the standard E₁₀ hyperbolic
Kac–Moody diagram: McMullen's `Y_{p,q,r}` notation (arm lengths counted *inclusive*
of the shared branch node) identifies E₁₀ with `Y_{2,3,7}`, i.e. arms of length
`1, 2, 6` excluding the branch node — matching `cartanE10` up to the order the three
arms are listed. This is also the diagram appearing as the "(2,3,7)-star" in
Hironaka's *What is Lehmer's number?* and as `E₈⁽¹⁾` extended once more (`E₉ = E₈⁽¹⁾`
already sits at arms `1, 2, 5`; E₁₀ extends the length-`5` arm to `6`) — consistent
with the docstring's "extended once more past `E₉ = E₈⁽¹⁾`". The proved identity
`coxeterE10.charpoly = lehmerPolynomial` is itself independent numerical confirmation:
McMullen proved this is *the* diagram whose Coxeter element realizes Lehmer's number
as spectral radius, so an incorrectly-wired diagram would not reproduce `L` exactly.

## Provenance

The formalization was produced in AI-assisted sessions (Claude, agent mode)
directed by the author; the decomposition into the route above and all statements
were reviewed by the author, and every kernel computation was cross-checked
numerically before formalization. Self-reporting metadata:
[`formalization.yaml`](formalization.yaml). Verification does not require trusting
any of this — that is what `Challenge.lean` + comparator are for.

## License

Apache-2.0.
