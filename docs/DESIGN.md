# The Formal Language

Status: M0 draft. Everything here is falsifiable by an almanac citation; see
`RULINGS.md` for the settled/switch/open registry that this spec defers to.

## 1. The core object: worlds

A **world** is a complete game history: seating, initial bag, every character /
alignment / life state over time, every Storyteller choice, every token shown,
every public action. An **observation** `o` is the fragment visible from one
seat (or from "the audience" for spectator puzzles): public events, the
observer's own tokens, and the claims made by others.

`Worlds(o)` = the set of worlds consistent with `o` under a declared script and
ruleset. All queries are projections/aggregations of `Worlds(o)`; the engine
never answers "who is the Demon" natively.

Claims semantics (puzzle convention, not game rule — lives in the puzzle
format, not the engine): good players truthfully report their `believed`
character and received tokens; evil players' claims are unconstrained.

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

## 9. Ruleset switches

Every rule is tagged `settled(citation)` | `switch(options, default)` |
`open`. A puzzle declares `(script, switch assignment)`. Well-posedness check:
a puzzle whose answer varies across assignments of undeclared switches is
flagged ill-posed. Registry: `RULINGS.md`.

## 10. Non-goals

- **Atheist**: a license to exit the formal system; excluded by design (no
  puzzle can use it for the same reason).
- **Legion**: expressible (setup deltas + shared trigger) but hostile to
  one-demon search heuristics; deferred, cost is in search not semantics.
- Full 15-player long-history social simulation. The enumerator targets puzzle
  scale; the AI Storyteller consumes the same semantics with policy search,
  not exhaustive enumeration.

## 11. Implementation

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
