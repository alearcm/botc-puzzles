# botc-puzzles

A formal language, solver, generator, and (eventually) platform for Blood on the
Clocktower logic puzzles — built on a single primitive: **world enumeration**.
Given an observation (what one seat knows plus what's public), enumerate every
complete game history consistent with it. Every product is a query against that:

| Product | Query |
|---|---|
| Puzzle solver | project worlds onto "who is the Demon", check singleton |
| "All possibilities" mode | the enumeration itself |
| "Who can you pin down" mode | intersection of atoms across all worlds |
| Evil-seat optimization | argmax over actions of resulting world count |
| Difficulty rater | structural features of the world set / proof tree |
| Puzzle generator | sample world → project observation → filter by world-set shape |
| AI Storyteller | policy over the enumerator's choice points |

## Layout

- `docs/DESIGN.md` — the formal language: ontology, semantics, card format
- `docs/RULINGS.md` — the rulings registry: settled rules (with citations),
  ruleset switches, and open seams
- `docs/ROADMAP.md` — milestones and go/no-go gates

## Design stance in one paragraph

BotC is not formalized character-by-character; an **effect algebra** of ~8
primitives is formalized once, and characters are data over it. The Storyteller
is nondeterminism (labeled choice points), not randomness. Registration
(Recluse/Spy/Zombuul) is a property of each atomic query occurrence, not of the
player. Info is structured claims with truth patterns, not opaque booleans.
Contested rulings are first-class **ruleset switches** that puzzles declare; a
puzzle whose answer depends on an undeclared switch is detected as ill-posed.
