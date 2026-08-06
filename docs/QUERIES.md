# The query surface (M3)

Every product is a projection or aggregation over `Worlds(o)` — the same
primitive that solves puzzles. `tools/botc.py` subcommands:

## solve <puzzle>

Classic mode: sound per-player demon probes + certain atoms. Reproduction
scoreboard semantics.

## worlds <puzzle> [--show initial/2,becomes/3] [--limit N]

All DISTINCT worlds of the observation, projected onto the given atoms.
Uses clingo `--project`, so each projected world is enumerated once —
duplicate full models can neither inflate a count nor eat the enumeration
budget. `truncated: true` flags an exhausted limit (raise it or refine the
projection).

## count <puzzle> [--show ...]

Distinct-world count under a projection. "How ambiguous is this state?"
as a number — nqt-011's documented minion ambiguity measures exactly 21
distinct initial-assignments.

## certain <puzzle>

"Who can you figure out": per-player possible initial characters across
ALL worlds, split into `pinned` (unique) and `ambiguous` (the candidate
set). Sound when not truncated.

## evilmax <puzzle> --night N --truth "fact;fact;..."

Evil-perspective planning. The demon KNOWS the true grimoire (`--truth`
facts pin it). The puzzle file must be a PREFIX observation — events and
tokens up to the prior dusk only. For each victim realizable in the truth
world at night N, the query counts the distinct worlds still consistent
for the town once that death is announced; evil prefers the kill leaving
the most worlds standing. Self-kill (star pass) is a candidate like any
other — it's just another world the engine can realize.

Semantics note: counts are pre-reveal — night-N info tokens (a dying
Ravenkeeper's pick, the next morning's claims) are not marginalized; a
fuller version would average over the Storyteller's information choices.

Demo: `puzzles/queries/033-night3-evilmax.yaml` — puzzle #33 as of dusk
day 2, true world Tom = Imp, Sula = Poisoner. Killing Hannah or Jasmine
leaves 7 worlds; killing Oscar, Sula, or himself (star pass) leaves 8.
The actual puzzle's demon killed Jasmine — one of the WORST
confusion-preserving picks, because the author was optimizing for a
unique-solution puzzle, not for the demon.
