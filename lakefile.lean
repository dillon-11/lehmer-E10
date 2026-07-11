import Lake
open Lake DSL

package lehmerE10 where
  srcDir := "."

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.32.0-rc1"

/-- The trusted claim statement (Mathlib-only imports, `sorry` placeholder). -/
lean_lib Challenge where
  roots := #[`Challenge]

/-- The proof. -/
@[default_target]
lean_lib LehmerE10 where
  roots := #[`LehmerE10]
  globs := #[.andSubmodules `LehmerE10]
