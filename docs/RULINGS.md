# Rulings Registry

Every entry: **status** (`settled` / `switch` / `open`), source, engine
encoding, and — once M1 lands — a pointer to the executable test that pins it.
`settled` requires a citation (almanac, wiki, official jinx list). `switch`
means TPI materials genuinely conflict or delegate; puzzles must declare a
side. `open` means we have not found a source yet — an `open` entry must not
be load-bearing for any puzzle until resolved to `settled` or `switch`.

Statuses migrate: a hedge that turns out to be cited moves to `settled`; a
"settled" claim that meets a countervailing citation becomes a `switch`.
Memory — the author's, a Storyteller's, or a model's — is never a source.

## Settled

| ID | Ruling | Source |
|---|---|---|
| `mayor-bounce-range` | Mayor bounce may redirect a demon kill onto a protected player (e.g. Soldier), fizzling it. | Mayor almanac |
| `vortox-over-droison` | Poisoned/drunk Townsfolk still receive false info under Vortox. | Vortox almanac |
| `barista-over-vortox` | A Barista'd (sober & healthy) player gets true info even under Vortox. | Barista almanac/wiki |
| `reg-granularity` | Registration is chosen per atomic evaluation occurrence: Imp–Recluse–Poisoner seating can yield Chef 1 (evil for one pair, good for the other, same check). | Recluse almanac example |
| `dead-lose-abilities` | Default: dead players lose abilities; explicit exceptions assert `has_ability` while dead (Vigormortis-killed minions). Rules key on `functioning`, not `alive` — a dead-but-abled Scarlet Woman still receives the demon pass. | Rulebook + Vigormortis almanac |
| `pithag-no-duplicates` | Pit-Hag cannot create an in-play character; nothing happens. | Pit-Hag almanac |
| `spy-ogre` | Jinx: the Spy registers as evil to the Ogre (forced registration — choice point collapsed). | Official jinx |
| `recluse-ogre` | Jinx: if the Recluse registers as evil to the Ogre, the Ogre learns they are evil (effect attached to a registration outcome). | Official jinx |
| `pithag-ogre` | Jinx: an evil player turned into the Ogre can't turn good via their own ability. | Official jinx |
| `vortox-savant` | Vortoxed Savant receives two false statements — Vortox is claim-wise falsification (`ALL_FALSE`), not pattern negation. | Almanac |

## Switches

| ID | Question | Options | Default |
|---|---|---|---|
| `cannibal-evil-executee` | Card text says the Cannibal *has* the (poisoned) ability of an evil executee; almanac how-to-run says they gain nothing and the ST pretends. Observable only via guard-exempt abilities (evil Ogre: text-reading Cannibal actually changes alignment while poisoned; almanac-reading Cannibal does nothing). | `has_ability_poisoned` / `no_ability` | `no_ability` |
| `gossip-qualify-time` | Must a statement be made *while holding* the Gossip ability to qualify (Pit-Hag creates a Gossip who made a true statement earlier that day)? | `at_utterance` / `at_resolution` | `at_utterance` (no kill) |
| `reg-occurrence-scope` | Exact boundaries of one "occurrence" for exotic aggregate abilities beyond the cited Chef case. | finest / per-ability-use | finest |
| `ogre-friend-tracking` | Optional rule: Ogre's alignment tracks the chosen friend's later alignment changes. | on / off | off |

## Open (need a source before use)

| ID | Question |
|---|---|
| `drunk-under-vortox` | The Drunk has no real Townsfolk ability — is their info Vortox-constrained (must be false) or ST-arbitrary? |
| `barista-savant` | Barista'd Savant: `BASE_PATTERN` (one statement still mandatorily false) or all-true? "True info" vs "ability as printed". |
| `gossip-eval-time` | Gossip statement truth evaluated at utterance or at night resolution (state may change during the day after the statement)? |
| `cannibal-registration` | Cannibal's evil-check goes through registration (Spy meal may register good → healthy Cannibal with the real Spy ability; Recluse meal may register evil)? Believed almanac-consistent; needs the citation. |
| `pithag-created-first-night` | Which first-night-only abilities fire on the night of creation vs the next night, for Pit-Hag-created characters? (Relative-schedule default: the night the ability is gained counts as "first night".) |

## Planned entries (raised, not yet worked)

Registration corner cases, madness ("thinks"), Mathematician semantics
(what counts as an ability "working abnormally" — requires the reified
`malfunctioned` trace), Chambermaid `woke` boundary cases (does a
dead-but-abled player "wake"?), and others as the character set grows.
