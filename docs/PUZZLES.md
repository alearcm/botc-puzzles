# Puzzle transcription guide

Puzzles (`puzzles/**/*.yaml`) are observations the solver conditions on.
Format: `id`, `script`, `horizon`, `players` (seating order, index 0 first),
`claims`, `given`, optional `statements` (quoted formulas for Savant/Artist/
Gossip), optional `assume_ongoing: false` to disable the ongoing-play
constraint (on by default).

## Claims

One entry per public claim: `{player, character, info: [shown/picked atoms]}`.
Semantics (compiled by `tools/botc.py claim_rules`): a good claimant truthfully
is their believed character and received exactly the listed tokens (Drunk
charade included); a LIVING Mutant may claim any Townsfolk with fabricated
info, per the NQT convention text ("A living Mutant fully complies with
madness... Other good players truthfully report") — a dead Mutant falls
under the truthful clause of THAT TEXT, not under any game mechanic (talk
is free; see `dead-mutant-claims-truthfully` in RULINGS); Cerenovus-mad
players claim their mad character.
Claim freedom belongs to players who are evil at the END of the observed
window (`align/align_change` at `horizon`) — this covers initial evils and
turned-evil players (Fang Gu jump, Goon flip), while an ex-evil player
swapped good (Snake Charmer) must claim truthfully like any good player.

## The fact-vs-constraint rule (IMPORTANT)

Whether an observation goes into `given` as a **fact** or a **constraint**
depends on the atom's role in the engine:

- **True inputs** (no generating rule in the engine — the world doesn't
  produce them, the day does): assert as facts.
  `executed/2, nominated/3, voted/2, slayer_shot/3, juggle/4, stmt/4,
  gossip_stmt/3, artist_q/3, moonchild_choice/3, klutz_choice/3,
  proc_virgin/2, no_proc_virgin/2`.
- **Choice-generated atoms** (the engine already has a cardinality choice for
  them — a fact just pins the choice): facts are fine.
  `picked/4, picked2/5, pickedc/4, shown_* , uses_once/3, believed_init/2,
  twin_pair/2, grandchild/2, red_herring/1, initial/2, po_extra/3`.
- **Derived atoms** (produced by rules from the world's mechanics): NEVER
  assert as facts — a fact invents the event with no mechanism and silently
  corrupts the solution. Constrain instead:
  `":- not announced_dead(matthew,2)"` — the world must PRODUCE the death.
  Applies to: `announced_dead, dies_night, dies_day, day_kill, exec_death,
  death_event, ended, becomes, char, align, status_on, woke, malfunctioned`.
  (Caught live: asserting a night death as a fact flipped puzzle nqt-010's
  answer by letting a player die with no killer.)

Negative observations are plain constraints:
`":- day_kill(fraser,2)"` (the shot fizzled),
`":- announced_dead(P,1), player(P)"` (nobody died night 1).

## Puzzle-specific rules text

NQT puzzles state per-puzzle setup restrictions ("the only Outsiders that
could be in play are...", "one minion of {...}"). Encode as roster
constraints in `given`: `":- initial(P,butler), player(P)"`. The stated
"default Outsider count" matches base setup arithmetic and needs no encoding;
Baron deltas are already engine-side.

Later puzzles carry a **"Potential hidden roles"** box: each player's true
role is either their visible claimed role or one of the listed hidden roles.
Encode as a pooled fact plus one constraint per player (see nqt-055):

```yaml
- "hidden55(fanggu; vigormortis; nodashii; vortox; witch; mutant)"
- ":- initial(aoife,C), C != artist, not hidden55(C)"
```

Omitting this leaves the whole script in scope and admits exotic lines the
puzzle never intended (Philosopher-gains-Snake-Charmer demon swaps made 7 of
8 players viable demons in #55 before the box was encoded).

"You are not evil" → `":- align(you,evil,1)"`.

## Character pools (scripts are just character sets)

An instance's character pool is any set of ids: `script:` names editions as
shorthand for "all their characters", `roster:` adds individual ids, and the
pool is the union. NQT puzzles freely import single characters across
editions — encode a Chambermaid in a TB game as `script: tb` +
`roster: [chambermaid]`, not by loading all of BMR. Every claimed character
must be in the pool — the compiler errors otherwise, because a claim for an
out-of-pool character makes the good/drunk branches silently unsatisfiable
and corrupts the solve (caught on nqt-022).

No rule keys on an edition. The single edition-scoped datum is TPI's printed
night sheets: they apply only when the pool IS exactly that base edition;
any other pool is a custom script and uses the script tool's global order.

## Ordering conventions

`picked2(P,C,T,Q1,Q2)` requires `Q1 < Q2` in clingo term order (alphabetical
for plain constants) — sort pair picks when transcribing.
`shown_among2(P,C,T,Char,Q1,Q2)` likewise.

Player constants: lowercase ASCII names from the image, in SEATING order
(the circle, clockwise from any fixed player; `seat/2` is emitted from list
position).

## Answer checking

`python3 tools/botc.py <puzzle.yaml>` prints world count, demon candidates,
and certain atoms. Reproduction = the published answer appears as the unique
demon candidate (or unique certain assignment for "solve the grimoire"
questions). Record the official answer and source thread in the header
comment of each transcription.
