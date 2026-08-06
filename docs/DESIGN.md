# The Formal Language

Status: M0 draft. Everything here is falsifiable by an almanac citation; see
`RULINGS.md` for the settled/switch/open registry that this spec defers to.

## 1. The core object: worlds

A **world** is a complete game history: seating, initial bag, every character /
alignment / life state over time, every Storyteller choice, every token shown,
every public action. An **observation** `o` is the fragment visible from one
seat (or from "the audience" for spectator puzzles): public events, the
observer's own tokens, and the claims made by others.

`Worlds(o)` = the set of worlds consistent with `o` under a declared
character pool and ruleset. All queries are projections/aggregations of
`Worlds(o)`; the engine never answers "who is the Demon" natively.

**Scripts are just character sets.** All rules live on characters; an
instance declares a pool of character ids, and edition names (`tb`, `bmr`,
`snv`) are shorthand for "every character of that edition". Characters mix
freely across editions. The one legitimately edition-scoped datum is TPI's
printed night sheets, which deviate from the script-tool global order: they
apply only when the pool is exactly that edition; any other pool is a
custom script and uses the global order. Any future edition-scoped rule
needs the same bar — TPI said so, for that edition specifically.

Claims semantics (puzzle convention, not game rule — lives in the puzzle
format, not the engine): good players truthfully report their `believed`
character and received tokens; claim freedom belongs to players who are
evil at the end of the observed window.

## 2. Time and trace

Phases: `setup, night(1), dawn(1), day(1), dusk(1), night(2), …`. Nights are
internally ordered by the script's night order (data, per script and per
first/other night).

The execution trace is **reified**: the world records not just states but
engine events — `woke(P,T)`, `acted(P,Ability,T)`, `malfunctioned(P,T)`,
`stated(P,φ,D)`, `nominated/voted/executed`, `died(P,T,Cause)`. Motivation:
Chambermaid reads `woke`, Mathematician reads `malfunctioned`, Gossip reads
`stated`. A model that resolves abilities without recording that it resolved
them cannot express these characters.

## 3. State ontology

Per player `P`, time `T`:

- `actual_char(P, C, T)` — changes via `become` (Imp star pass, Scarlet Woman,
  Pit-Hag, Snake Charmer…). Inertial.
- `believed_char(P, C)` — what the player thinks they are (Drunk, Lunatic,
  Marionette). Claims are assertions about `believed_char`.
- `alignment(P, A, T)` — independent axis from character (evil Ogre: good-team
  Outsider, evil alignment). Inertial; changed by effects, possibly linked
  (Ogre's optional friend-tracking — a switch).
- `alive(P, T)` — raw life state. Referenced by ability semantics **only where
  the printed text says "alive"**.
- `has_ability(P, Ab, T)` — defaults from `alive` via the "dead players lose
  their abilities" rule, but independent: Vigormortis-killed minions keep
  theirs; abilities are first-class values that can be copied/moved (Cannibal,
  Philosopher, Alchemist, Boffin) and a player may not know which ability they
  hold (`believed` layer applies to abilities too).
- `functioning(P, Ab, T)` = `has_ability ∧ ¬impaired` — the guard on every
  effect, **unless the effect declares a guard exemption** ("even if drunk or
  poisoned", e.g. Ogre). Rules reference `functioning`, never `alive` directly.
- `status(P, Kind, Source, Expiry)` — poisoned/drunk/protected/sober-healthy/….
  `Expiry` is an **event pattern**, not a timer: "until dusk", "until the
  source loses this ability" (the default), "until a good player dies by
  execution" (Cannibal). Per-status overrides are data.

## 4. Registration

`reg(Subject, Predicate, Occ)` — a Storyteller choice point, indexed by the
**atomic evaluation occurrence**, the finest granularity. Settled by the
Recluse/Chef almanac example: sitting Imp–Recluse–Poisoner, the Chef may learn
1 — the Recluse registers evil for one adjacency pair and good for the other
within a single check. So each pair of a Chef count, each ping of an Empath
read, each evil-check of a Cannibal meal is its own occurrence.

- Default: `reg(P, Pred, _)` iff P actually satisfies Pred.
- Cards override with **may-register sets** (Recluse: evil/minion/demon; Spy:
  good/townsfolk/outsider) — each occurrence is a free choice in the set.
- Jinxes may **force** a registration (Spy registers evil to the Ogre —
  collapses the choice point) or **attach effects to a registration outcome**
  (Recluse registering evil to the Ogre ⇒ the Ogre learns they are evil).
- Registration applies to *any* predicate evaluation, not just info: Slayer's
  demon-check, Cannibal's evil-check, and — critically — **deadness itself**
  (`reg(P, dead, Occ)`, for Zombuul). Alive-counts in ability text (Scarlet
  Woman's "5 or more") go through deadness registration.
- **The site clock**: every occurrence evaluates at its observer's night-order
  position and sees the character/alignment state as of that position — all
  changes (`becomes_at`, `align_change_at`) that resolved earlier that night
  are visible. A Fortune Teller checking after a star pass sees the new Imp
  because the Imp acts earlier in the order, not via any coded pairing. The
  same positional principle already governs status expiry and death triggers.

## 5. Information: claims and truth patterns

Every info ability produces a **token**: a list of atomic claims, each a closed
formula of the language (registration atoms and a time tag included), shown to
a player. The Storyteller authors token *content* freely (a choice point); the
world constrains it via the card's **truth pattern**:

- default pattern: all claims true
- Savant: exactly one of two claims true
- (patterns are per-card data)

The binding constraint on a token is selected — not composed — from the
applicable modifiers by **precedence**:

```
mode ∈ { BASE_PATTERN, ALL_FALSE, FREE }

barista(sober&healthy)  → BASE_PATTERN   (highest)
vortox                  → ALL_FALSE      (each atomic claim false)
drunk/poisoned          → FREE
(none)                  → BASE_PATTERN   (lowest)
```

Why selection, not predicate composition: negating Savant's pattern would
permit two true statements; the almanac says a Vortoxed Savant gets two false
ones. `ALL_FALSE` operates claim-wise. Why precedence: droison(S)→⊤ then
vortox(⊤)→⊥ is nonsense; the settled orderings are vortox > droison (poisoned
players still get false info in a Vortox world) and barista > vortox (a
sober-and-healthy player gets true info even under Vortox). Two modifiers on
the same token with no declared order is a **static error** surfaced to the
script/puzzle author — that is how the language reports "TPI has not ruled",
instead of silently picking.

Vortox's scope is Townsfolk abilities, per its text; scope is card data.

Droison's two failure modes fall out without per-character code: info effects
go `FREE` (token unconstrained — may be accidentally true), world effects are
**nulled** (a poisoned Monk's protection never enters the world).

## 6. Effects

Primitives: `learn(token)`, `kill`, `protect/grant(status)`, `impair(status)`,
`become(character | alignment)`, `setup_delta`, `schedule(trigger)`,
`license(X)`. Each effect instance carries: its guard (default `functioning`,
exemptable), its target selection (player choice / ST choice / fixed), and its
resolution semantics.

- **Kills enter a pipeline**, not an atomic death:
  `attack → guard(source functioning) → shield check (safe_from_demon etc.) →
  bounce choice points (Mayor; range unconstrained — bouncing into a doomed
  kill on the Soldier is legal, almanac-settled) → died event`.
- **`become` guards**: Pit-Hag cannot create in-play characters ("nothing
  happens"); Pit-Hag creating a Demon grants `license(arbitrary_deaths)` — an
  explicit ST choice point over death sets replacing the pipeline for one
  night. Licenses are the general mechanism for "the rules step aside" clauses
  that are still *bounded* (unlike the Atheist, which is unbounded and
  excluded).
- **Pending effects re-check their source at resolution time**: a Gossip
  transformed by the Pit-Hag before their kill resolves no longer has the
  ability; no death. Utterance-time vs resolution-time for *qualifying* a
  statement is a switch (see RULINGS).
- **Triggers use relative schedules**: "first night" means first night
  *holding the ability* — a Cannibal-acquired Ogre ability fires the night
  after the meal; Pit-Hag-created characters likewise. Night position comes
  from the script's night order; "works twice" (Barista option 2) is the
  scheduler firing a trigger twice.

## 7. Reflection

Gossip statements, Juggler guesses, and Fortune Teller picks are **quoted
formulas** of the language, stored in the trace with their evaluation-time
tag, and evaluated by the same registration-aware evaluator as everything else
(a Gossip statement about the Recluse hits `reg` choice points). The almanac's
requirement that Gossip statements be "definite" corresponds to: the statement
is a closed formula of the fragment. Puzzles restrict natural-language
statements to this fragment by construction.

## 8. Setup

`setup_delta` effects (Baron: +2 Outsiders; Drunk: replaces a Townsfolk slot,
setting `actual = drunk`, `believed = ST-chosen Townsfolk`) apply to the base
counts for the player count. Setup arithmetic is part of the world, so
setup-counting deductions ("a second Outsider claim implies a Baron") are
ordinary consequences of enumeration.

## 9. Shadow abilities (running the believed layer)

Self-misinformed characters (Drunk, Lunatic, Marionette) don't just have a
`believed_char` — the Storyteller actively *simulates* the believed character
at them. The engine models this as a **shadow ability**:
`shadow(P, C_believed)` copies `C_believed`'s trigger schedule, with every
effect replaced by theater: `learn` with `FREE` tokens, and real `woke` trace
events. One object owns the charade instead of per-character improvisation.

Theater is not entirely inert: charade wakes are genuine `woke` atoms in the
reified trace (Chambermaid happens not to observe them — she chooses alive
players — but whether a charade wake counts as an ability "working
abnormally" for the Mathematician is an open seam; see RULINGS).

Two independently dialed questions about a shadow:

1. **Persistence** — how much of `C_believed`'s lifecycle does the charade
   mirror? On-death triggers (dead drunk-"Ravenkeeper" wakes and chooses —
   almanac-cited)? Persistence through death (Lunatic-as-"Zombuul" kept awake
   while dead)?
2. **Attachment** — do the *thinker's own real* ability components ride along
   wherever the charade lives (dead charading Lunatic's picks still fed to
   the actual Demon)?

Persistence is theater (touches only the thinker's experience); attachment
crosses into world effects. The formalism keeps them separate precisely so
the debate between them can be stated. Both are governed by a scoped
principle (§10, `charade-persistence` in RULINGS).

## 10. Candidate rulesets and the almanac corpus

The almanac is not the rules — it is *evidence about* the rules: worked
examples generated by unstated general principles. The architecture treats it
exactly that way:

- **Candidate rulesets** are complete, executable theories of the game:
  a shared **base** logic file plus named **deltas** (alternative clauses for
  contested seams — binary switches and scope-ladder rungs alike). A concrete
  candidate = base + delta selection, composed at build time. There is no
  runtime switch machinery; a "switch" is just the diff between two
  candidates.
- **The corpus** is a fixture suite transcribed from cited material (the
  almanac's per-character Examples sections are already in given/then form),
  plus fixtures for interactions raised in design discussion. Each fixture:
  a scenario, an assertion, and an **authority tier**:
  - **T0** — cited verbatim. Falsifying: a candidate that contradicts a T0
    fixture is dead.
  - **T1** — near-forced generalization of a citation (refusing it makes the
    citation an unprincipled special case). Strong soft evidence: failures
    are scored and reported, not fatal.
  - **T2** — plausible extension. Informational.
- Fixture assertions are explicitly **∃ or ∀**: most almanac examples
  demonstrate *one legal Storyteller outcome* (∃ — the Chef-1 seating admits
  a world where the Chef learns 1), not the only outcome. Encoding ∃
  examples as ∀ is the easiest way to corrupt the corpus and is treated as a
  transcription bug.

The **viable set** is every candidate passing all T0 fixtures; within it,
candidates are ranked by T1/T2 conformance — "most almanac-faithful
candidate" is a computed object. Induction distance lives in the tiers: how
far a citation generalizes is measured by which tier its extensions sit in,
and contested seams are visible as T0-viable candidates that disagree.

### 10a. Scoring rulesets: the interpreter/data split and maximum laziness

What separates a good ruleset from a bad one when BOTH pass every fixture:

- **Data vs theory.** Printed ability text (structured onto cards) is
  observation — TPI supplied it, it costs nothing. A ruleset is the
  INTERPRETER that gives card data meaning: "each night, choose a player"
  means one thing, uniformly, for every card that prints it. The degenerate
  ruleset — a lookup table spelling out every character x character
  interaction — is the theory that smuggles all content out of the
  interpreter into per-pair data. It can pass every current fixture and is
  still wrong.
- **Maximum laziness = minimum description length.** Among T0-admissible
  candidates, prefer the shortest, in a vocabulary that charges generic
  quantified rules cheaply and per-character/per-pair enumerations heavily.
  The lookup table is O(n^2) in characters and predicts nothing about the
  next character added; "state reads happen at the reader's night-order
  position" is one sentence that decided Fortune-Teller-after-star-pass,
  double-Snake-Charmer, and Empath-after-Imp before any of them was seen.
  Laziness is not aesthetics; it IS the generalization pressure.
- **Defaults with exceptions tacked on (defeasible layering).** Rules
  stratify: general default < cited exception < explicit TPI ruling (jinx).
  ASP expresses this natively — the default guarded by `not blocked`, the
  exception asserting `blocked` and carrying its citation. An exception is
  LICENSED only by a citation that forces divergence from the general rule;
  an uncited exception is tech debt by definition. Between axiomatizations
  with the same extension, rank by: fewer per-character atoms, then reuse of
  an existing mechanism (one site clock, four instantiations: characters,
  alignments, deaths, action targets), then citation coverage of exceptions.
- **Open questions are switches, not rules.** Where nothing cited decides,
  the ruleset takes a FREE PARAMETER with named settings, each
  T0-admissible. A complete candidate is a point in the product space of
  switch settings; the family is the space. Queries then have two honest
  modes: answer under a declared setting, or under ALL viable settings —
  reporting which conclusions are robust ("the demon is X under every
  setting") and which are setting-dependent. For a publisher that is
  sometimes inconsistent, answer intervals are the truthful output type.
- **Tie-break order between candidates**: T0 admissibility (hard) >
  T1/T2 agreement > description length > exceptions-carry-citations >
  prediction record on newly arriving fixtures. Every new puzzle is an
  out-of-sample test; the reproduction scoreboard is the ruleset's track
  record, and a rule adopted to force one puzzle unique (rather than
  derived general and cited) shows up later as a failed prediction.

Well-posedness: a puzzle either declares its candidate ruleset, or claims
robustness — its answer is invariant across the viable set (or a declared
subset). A puzzle whose answer varies across viable candidates it did not
declare between is flagged ill-posed.

`RULINGS.md` is the human-readable catalog of this: each entry compiles to
fixtures (with tiers) and, where contested, to named deltas.

**Text-first discipline.** Card data defaults come from the printed ability
text: "choose a player" permits self and the dead unless the text says
otherwise; "(not yourself)" and "alive" restrictions exist exactly where
printed. A puzzle's unique solution is *weak evidence* — it may motivate a
RULINGS entry marked inferred and an engine change stated as a general rule,
never a character-specific patch. Edge cases get named entries and fixtures;
the default path behaves as written. Known shortcuts live in `DEBT.md` — an
undocumented hack is the failure mode, not the shortcut itself.

## 11. Non-goals

- **Atheist**: a license to exit the formal system; excluded by design (no
  puzzle can use it for the same reason).
- **Legion**: expressible (setup deltas + shared trigger) but hostile to
  one-demon search heuristics; deferred, cost is in search not semantics.
- Full 15-player long-history social simulation. The enumerator targets puzzle
  scale; the AI Storyteller consumes the same semantics with policy search,
  not exhaustive enumeration.

## 12. Implementation

- Core: **ASP (clingo)**. Choice rules model ST nondeterminism natively;
  `--project` implements the certain-atoms query; enumeration/counting are
  built in; the encoding reads like the rulebook, which is the point.
- Cards: YAML data compiled to ASP by a Python compiler. A character requiring
  hand-written ASP is a design smell: either a primitive is missing or the
  card format is wrong.
- Dynamic-history model from day one (the trace is the ontology), horizon
  capped per puzzle. Static-grimoire is the degenerate 1-night case, not a
  separate model.
- `argmax |Worlds|` queries (evil-seat optimization) are an outer Python loop
  over actions with an inner clingo count — Σ₂-ish, fine at puzzle scale by
  decision.
