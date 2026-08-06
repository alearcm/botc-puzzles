# Rulings Registry

This registry is the human-readable catalog behind the corpus/candidate
architecture (DESIGN §10): almanac citations are **test fixtures**, the game
rules are **candidate rule files** (base + named deltas), and a candidate
contradicting a cited fixture is falsified.

How entry statuses compile:

- `settled` → **T0 fixtures** (falsifying; requires a citation — almanac,
  wiki, official jinx list). Mind ∃ vs ∀: most examples assert an outcome is
  *admissible*, not mandatory.
- `switch` → a pair of named **deltas**; both sides currently T0-viable.
  Fixtures distinguishing them get tiers by argument strength.
- `principle` → a scope ladder where each rung is a delta; the anchoring
  instance is a T0 fixture, each rung's consequences become T1/T2 fixtures.
- `open` → fixture drafted but unsourced; excluded from scoring and never
  load-bearing for a puzzle.

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
| `reg-survives-death` | Registration flavour survives death: the executed Recluse may show as the Imp to the Undertaker. | Recluse almanac example |
| `mayor-protected-no-bounce` | A Monk-protected Mayor's bounce does not trigger: the attack simply fails, nobody else may die instead. | Monk almanac ex2 |
| `butler-dead-votes-free` | A dead Butler has no ability and votes freely (master constraint gone). | Butler almanac ex3 |
| `sw-count-includes-dying-demon` | Scarlet Woman's "5 or more players alive" counts players alive at the moment the demon dies — the dying demon included. | Scarlet Woman almanac ex2 |
| `source-loss-ends-status-by-dawn` | Ongoing statuses end when their source no longer holds the ability by dawn: the star-passed ex-Poisoner's poison ends. | Poisoner almanac ex5 |
| `undertaker-no-wake` | The Undertaker does not wake on nights following no execution (observable via Chambermaid). | Undertaker almanac ex4 |
| `status-ends-at-source-loss-position` | A status ends AT the night-order position its source stops holding the ability (star pass, death) — not at the night boundary. | Poisoner almanac ex5 + NQT #59 author comment |
| `nodashii-poison-static` | No Dashii poisons its nearest Townsfolk neighbours dead or alive — the poison does not jump past a dead Townsfolk. | Ability text + NQT #28 author ruling |
| `mathematician-abnormal-scope` | "Working abnormally" covers Vortox-falsified Townsfolk AND any token received impaired (incl. death-triggered: a poisoned Sage counts); the Mathematician's own token is not self-counted. | Almanac reading + NQT #34 unique solution |
| `witch-self-curse-allowed` | The Witch may curse herself (and die to her own nomination). | User-confirmed ruling; printed text has no restriction |
| `chambermaid-ability-wakes-only` | The Chambermaid counts wakes due to a player's ABILITY: minion-info/demon-info wakes do not count. | Printed text ("due to their ability"); NQT #28 solver thread |
| `night-sheet-order` | The base editions' printed night sheets differ from the modern global order (TB: Butler before Undertaker; BMR: Innkeeper before Courtier, Professor before Gossip). Engine uses the printed sheets per script. | Official edition night sheets (see data/raw/night_orders_notes.md) |
| `death-trigger-timing` | Death-triggered ongoing effects (e.g. Sweetheart's drunking) begin at the death's position in the night order; abilities that already resolved that night were unimpaired. | Night-order semantics; caught by `snakecharmer-same-night` fixture |

## Switches

| ID | Question | Options | Default |
|---|---|---|---|
| `cannibal-evil-executee` | Card text says the Cannibal *has* the (poisoned) ability of an evil executee; almanac how-to-run says they gain nothing and the ST pretends. Observable only via guard-exempt abilities (evil Ogre: text-reading Cannibal actually changes alignment while poisoned; almanac-reading Cannibal does nothing). | `has_ability_poisoned` / `no_ability` | `no_ability` |
| `gossip-qualify-time` | Must a statement be made *while holding* the Gossip ability to qualify (Pit-Hag creates a Gossip who made a true statement earlier that day)? | `at_utterance` / `at_resolution` | `at_utterance` (no kill) |
| `reg-occurrence-scope` | Exact boundaries of one "occurrence" for exotic aggregate abilities beyond the cited Chef case. | finest / per-ability-use | finest |
| `ogre-friend-tracking` | Optional rule: Ogre's alignment tracks the chosen friend's later alignment changes. | on / off | off |

## Scoped principles

### `charade-persistence`

How far does the Storyteller's simulation of a "you think you are X" charade
extend? Engine object: the shadow ability (DESIGN §9).

**Anchoring instance (hard constraint):** the dead Drunk who thinks they are
the Ravenkeeper is woken to choose a player and learns a character
(Ravenkeeper almanac). Every scope below must reproduce it.

| Rung | Extent | Example consequence | Status |
|---|---|---|---|
| S0 | Cited instances only | Drunk-"Ravenkeeper" wakes on night death; nothing else generalizes | Sound but unprincipled — makes the citation a special case |
| S1 | Believed character's on-death triggers run as theater | Drunk-"Sage" killed by the Demon learns a fake demon pair | Uncited; near-consensus reasonable |
| S2 | Charade mirrors the believed character's full lifecycle, incl. persistence through death | Lunatic-"Zombuul" is kept awake and acting while dead | Uncited; plausible |
| S3 | Thinker's own *real* ability components ride along wherever the charade lives | Actual Demon still learns the dead charading Lunatic's picks | Contested — crosses from theater into world effects |

**Default: S1.** The S2→S3 boundary is categorical, not incremental: S0–S2
touch only the thinker's experience (wakes, FREE tokens); S3 creates real
information flow from a dead player. Puzzles relying on anything above S1
must declare their scope; the well-posedness checker treats undeclared S1–S3
variation like an undeclared switch.

Expected siblings as the character set grows: charade interaction with
Vortox (does the shadow of a Townsfolk count as a "Townsfolk ability" for
falsification — related to `drunk-under-vortox` below), charade wakes vs
Mathematician (below), madness-enforcement scope.

## Open (need a source before use)

| ID | Question |
|---|---|
| `drunk-under-vortox` | The Drunk has no real Townsfolk ability — is their info Vortox-constrained (must be false) or ST-arbitrary? |
| `barista-savant` | Barista'd Savant: `BASE_PATTERN` (one statement still mandatorily false) or all-true? "True info" vs "ability as printed". |
| `gossip-eval-time` | Gossip statement truth evaluated at utterance or at night resolution (state may change during the day after the statement)? |
| `cannibal-registration` | Cannibal's evil-check goes through registration (Spy meal may register good → healthy Cannibal with the real Spy ability; Recluse meal may register evil)? Believed almanac-consistent; needs the citation. |
| `pithag-created-first-night` | Which first-night-only abilities fire on the night of creation vs the next night, for Pit-Hag-created characters? (Relative-schedule default: the night the ability is gained counts as "first night".) |
| `charade-mathematician` | Does a shadow-ability (charade) wake or its FREE info count as an ability "working abnormally" for the Mathematician? (Engine v1 default: yes, a charade always malfunctions.) |
| `droison-strips-misreg` | Does a poisoned/drunk Recluse or Spy lose misregistration? (Engine v1 default: yes.) |

## Planned entries (raised, not yet worked)

Registration corner cases, madness ("thinks"), Mathematician semantics
(what counts as an ability "working abnormally" — requires the reified
`malfunctioned` trace), Chambermaid `woke` boundary cases (does a
dead-but-abled player "wake"?), and others as the character set grows.
