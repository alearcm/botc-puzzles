# Roadmap

Ordered by dependency; each milestone has a go/no-go gate. The gates are the
argument — prose claims about the language's adequacy are worth nothing next
to a corpus of posted puzzles the solver reproduces.

## M0 — Specification (this)

Design doc, rulings registry, roadmap. **Gate:** the three stress
interactions (Vortox×Savant/Barista, Pit-Hag×Gossip, Cannibal×evil-Ogre) and
all five almanac corrections are expressible in the spec without engine-level
special cases. Done on paper; M1 makes it executable.

## M1 — Base-scripts kernel *(in progress — first executable cut landed)*

Status: engine (clingo core + card compiler) runs all three base scripts;
72 characters as card data (44 full / 25 partial / 3 deferred — see
`docs/COVERAGE.md`); per-script printed night sheets transcribed from the
official PDFs (`data/raw/night_orders_notes.md`); 21-fixture seed corpus
green, including chef-1 per-pair registration, Vortoxed-Savant both-false,
the drunk-Ravenkeeper charade anchor, mayor-bounce-to-Soldier, star pass,
and registration-survives-death. Almanac Examples transcription is the big
open item.

Originally scoped as:

- Engine core in clingo: trace, ontology, registration, claims/patterns with
  modifier precedence, kill pipeline, statuses/expiries, schedules.
- Card format (YAML) + Python compiler to ASP; **all 22 TB characters as pure
  data**.
- Queries: `models(o)` (enumerate), `certain(o)` (projected intersection).
- Horizon: dynamic history, capped (target: 3 nights / 2 days).
- Ruleset build: base logic + named deltas composed into candidate rulesets
  (DESIGN §10); no runtime switch machinery.
- Almanac corpus v1: transcribe every TB character's almanac Examples section
  into fixtures (tiered T0/T1/T2, each tagged ∃ or ∀), plus interaction pins
  from RULINGS (`chef-1`, poisoned-Ravenkeeper, Recluse-Slayer, star-pass to
  dead-but-abled SW, Mayor-bounce-to-Soldier,
  drunk-Empath-accidentally-true, …).

**Gate:** every TB character is data (zero hand-written per-character ASP);
the default candidate passes all T0 fixtures; T1/T2 conformance reported.

## M2 — Puzzle corpus + solver CLI

- Puzzle file format: seats, script, ruleset declaration, public events,
  claims, question type.
- Transcribe 10–20 posted puzzles with known answers (TB-solvable ones
  first).
- CLI: `solve <puzzle.yaml>` → answer + world count + well-posedness check
  (answer stable across undeclared switches).

**Gate (the big one):** solver reproduces the published answer on ≥90% of the
corpus, and every miss is diagnosed to a transcription error, a puzzle error,
or a documented rulings gap — not to an inexpressible mechanic.

## M3 — Full query surface

- All-worlds and certain-atoms as user-facing modes.
- Model counting; `argmax` action queries ("you are evil: which kill
  maximizes surviving worlds?") via outer loop + inner count.
- Minimal sufficient subset extraction (smallest set of clues that still
  forces the answer) — doubles as the hint system.

**Gate:** the non-classical puzzle formats from the original vision are all
answerable on corpus puzzles.

## M4 — Generator + difficulty rater

- Generator: sample world → project observation → keep if the world-set has
  the requested shape (unique answer / k-ambiguous / requires
  setup-counting / requires uniqueness-reasoning).
- Difficulty features: minimal-subset size, near-world count (worlds killed
  by exactly one constraint), branching under best-order inference, required
  deduction classes. Structural score now; calibrate against human solve data
  once M5 exists.

**Gate:** generated puzzles pass well-posedness and a blind human solve
matches the intended difficulty ordering on a small sample.

## M5 — Platform (tactics trainer)

- Web front end, daily puzzles, rating system (Glicko per user and per
  puzzle), hint ladder from minimal subsets, "show all worlds" post-solve.
- Difficulty calibration loop: solve-rate data re-fits the structural model.

## M6 — Expansion

- Bad Moon Rising and Sects & Violets character sets (data-only if M1's gate
  held; any needed primitive is a design event worth a RULINGS/DESIGN
  changelog entry).
- Experimental characters by demand, driven by which puzzles the community
  actually posts.
- AI Storyteller: the same semantics, with ST choice points driven by a
  policy (balance/drama objectives) instead of enumeration. Separate design
  doc when M2–M3 have proven the core.

## Standing rules

- Every ruling encoded has a citation; `open` entries are never load-bearing.
- Every interaction dispute becomes an executable test before it is
  considered handled.
- A character that needs engine code instead of card data is a spec bug.
