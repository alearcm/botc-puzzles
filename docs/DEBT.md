# Known debt ledger

Tracked deliberately so hacks stay visible instead of fossilizing. Every
entry names the shortcut, why it exists, and what clean looks like. Adding a
hack without an entry here is the actual failure mode.

## Process rules (standing)

1. **Text-first defaults**: a card's pick spec and restrictions come from its
   printed ability text ("choose a player" vs "(not yourself)" vs "an alive
   player"). Deviations require a cited ruling.
2. **Puzzle-inference is weak evidence**: a puzzle's uniqueness may motivate a
   RULINGS entry marked *inferred* and an engine change expressed as a
   general rule — never a character-specific patch. If the general rule can't
   be articulated, the puzzle stays PARTIAL. (Case study: witch-self-curse
   was wrongly restricted to force #34 unique; the real rule was
   Mathematician abnormal-scope. The restriction contradicted printed text
   and was reverted.)
3. Edge cases are edge cases: they get named registry entries and fixtures;
   the default path follows the ability as written.

## Open debt

| Item | Why it exists | Clean version |
|---|---|---|
| `mathematician-abnormal-scope` self-exclusion | Inferred from NQT #34 uniqueness; no primary citation | Find almanac/official Q&A on Mathematician counting semantics (esp. under Vortox and for own token) |
| Votes/nominations carry no per-nomination tallies | `voted(P,D)` is day-scoped; Saint ex1's 4-vs-3 vote comparison inexpressible | Reify nomination events with per-nomination vote sets |
| Evil private info unconstrained | Minion/demon info, Spy grimoire, Lunatic feed treated as free | Model true-by-default evil info (demon bluffs are guaranteed not-in-play, etc.) where puzzles need it |
| Madness is claim-layer only | Cerenovus/Mutant enforcement is social | Fine for puzzles; revisit for AI ST |
| Witch 3-players-live ability loss approximated | Encoded as >=4 check at nomination, not ability loss | Encode as has_ability condition at the 3-alive boundary |
| Solver performance | Sound per-player probes + certain checks are minutes on 9p/4-night puzzles | Projection tuning, symmetry breaking; needed before M4 counting loops |
| Cross-script night order uses townsquare global numbers | Printed sheets don't cover cross-script sets | Acceptable; document as the standard for customs |
| arctic-shift dependence for puzzle harvest | Reddit + Wayback egress-blocked | Cache everything fetched into the repo (done for images/metadata) |
| Charade scope fixed at S1 | Scope ladder defined in RULINGS but not switchable per-puzzle yet | Wire scope selection into the puzzle format |
| `assume_ongoing` is all-or-nothing | Puzzles asking "who wins if..." will need phase-scoped ongoing constraints | Parameterize when such a puzzle appears |
| Evil claimants fully unconstrained | NQT rules say evil players LIE about their role (claim ≠ true role); we model claim freedom only — weaker, admits evil-truthful worlds | Add claim≠char constraint for evil-at-end claimants if a puzzle's uniqueness ever needs it |

## Recently retired

- Po self-pick-as-charge convention → real optional pick (`p1_any_opt`).
- Witch no-self-curse restriction → reverted; discriminator was Mathematician
  scope.
- Pick specs contradicting printed text (sailor, exorcist, pukka, witch,
  seamstress, innkeeper) → text-aligned.
- Vigormortis missing printed [−1 Outsider] setup delta → fixed (text audit).
- Truncation-based demon candidates → sound per-player probes.
