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
| arctic-shift dependence for puzzle harvest | Reddit + Wayback egress-blocked | Cache everything fetched into the repo (done for images/metadata) |
| Charade scope fixed at S1 | Scope ladder defined in RULINGS but not switchable per-puzzle yet | Wire scope selection into the puzzle format |
| `assume_ongoing` is all-or-nothing | Puzzles asking "who wins if..." will need phase-scoped ongoing constraints | Parameterize when such a puzzle appears |
| Evil claimants fully unconstrained | NQT rules say evil players LIE about their role (claim ≠ true role); we model claim freedom only — weaker, admits evil-truthful worlds | Add claim≠char constraint for evil-at-end claimants if a puzzle's uniqueness ever needs it |
| Life/death positional coverage partial | Empath now reads `alive_neighbor_at` (site clock; NQT #31); Oracle's dead set, Chef's pairs, Vigormortis/mayor-bounce neighbor picks still read phase-boundary state | Migrate remaining readers to `life_pos`/`app_alive_at` as instances arise |
| Day-event yesno reads at phase boundary | Flowergirl/Towncrier evaluate "did a demon vote yesterday" against start-of-following-night state, not the subject's state at vote time (day-time SW takeover corner) | Evaluate against `char_d` of the event day |
| Multi-position sites take the earliest slot | A philosopher-gained ability whose card also has a sheet slot yields two `site_pos` candidates; `site_epos` picks the min | Thread the acting occurrence's own position into site creation (`hpos` now exists for actions; migrate sites to it) |
| Cerenovus on dead players unresolved | Madness persistence for a dead target requires the Cerenovus to keep picking the corpse; text-first "choose a player" allows it, no citation either way | Find a ruling; affects reveal-on-end worlds (nqt-011 world 5) |
| Positional audit incomplete for other action targets | Exorcist demon-pick, gambler guess, pit-hag target chars still read start-of-night state | Migrate to `hpos` + `eff_char_n` as instances arise |

## Recently retired

- Registration at start-of-night granularity → the site clock: every night
  site evaluates at its observer's night-order position and sees all
  `becomes_at`/`align_change_at` changes resolved earlier that night
  (`state-reads-at-site-position`; fixed nqt-013 with zero
  interaction-specific rules).
- Script-coupled instances (`script: [tb, bmr]` to import one character) →
  character pools: `roster:` adds individual ids, editions are shorthand,
  `in_pool/1` replaces `on_script/1`, night order is printed-sheet only when
  the pool IS exactly a base edition (the sole TPI-documented edition rule).
- Po self-pick-as-charge convention → real optional pick (`p1_any_opt`).
- Witch no-self-curse restriction → reverted; discriminator was Mathematician
  scope.
- Pick specs contradicting printed text (sailor, exorcist, pukka, witch,
  seamstress, innkeeper) → text-aligned.
- Vigormortis missing printed [−1 Outsider] setup delta → fixed (text audit).
- Truncation-based demon candidates → sound per-player probes.
