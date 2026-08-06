# NQT Weekly Puzzle reproductions

Transcriptions of [Not Quite Tangible weekly puzzles](https://notquitetangible.blogspot.com/2024/11/clocktower-puzzle-archive.html)
(by u/Not_Quite_Vertical). Each YAML is a structural transcription of the
puzzle state (players, claims, public events) with a link to the source; the
solver must reproduce the author-confirmed answer from the thread.

| # | Puzzle | Scripts | Solver answer | Official | Match |
|---|---|---|---|---|---|
| 8 | The Stitch-Up | S&V+TB homebrew (all-Seamstress) | evil team {josh, steph}; demon within pair ambiguous | Josh & Steph evil, You poisoned | YES |
| 20 | Three Wise Men | TB+Village Idiot | unique world: Balthazar = Imp, Mary = Baron (Caspar drunk VI, Gabriel Drunk-as-Ravenkeeper) | same | YES (first experimental info character: VI duplicates + extras-drunk) |
| 21 | Eight Jugglers Juggling | homebrew (all-Juggler) + Leviathan/Goblin/Drunk | unique world: Oscar = Leviathan, Tim = Goblin, Aoife = Drunk | same | YES (first experimental characters: cards/exp.yaml) |
| 10 | Don't Overcook It | TB (restricted roster) | unique: Dan = Imp, Fraser = Poisoner | Dan Imp, Fraser Poisoner | YES |
| 11 | False Is the New Black | S&V (guest puzzle) | demon unique: Aoife = Vortox; minion {sarah, matthew, tom} | Aoife Vortox, Sarah minion | PARTIAL — demon reproduced; minion ambiguity via an unadjudicated night-1 Snake-Charmer swap line (thread eliminations use soft priors). Drove 6 general claim/engine fixes |
| 13 | Clockblocking | TB+Clockmaker | sound-unique: Fraser = Imp, Oscar = Baron, Tim = Drunk | same | YES (forced the site-clock refactor: registration evaluates at the observer's night-order position) |
| 22 | One in the Chamber | TB+Chambermaid | sound-unique: Sarah = starting Imp, Steph = Baron (star-pass Imp), You = Drunk | same | YES (forced shadow-pick generalization + roster validation) |
| 26 | A Major Problem | TB | unique: Tom = Imp, Matthew = Poisoner | Tom Imp, Matthew Poisoner | YES |
| 29 | A Dreamer? I'm Not the Only One | homebrew (all-Dreamer) TB+S&V | unique world: Adam = Imp, Jasmine = Poisoner, Hannah = Drunk | same | YES (first solve, no engine changes) |
| 28 | A Study in Scarlet | TB+BMR+S&V | sound-unique: Olivia = No Dashii, Fraser = SW, Matt = Drunk | same | YES (after chambermaid ability-wakes-only fix) |
| 31 | No, Your Other Left | TB | unique: Adam = Imp, Sarah = Baron | same | YES (forced positional life state: deaths join the site clock — a night-3 Empath read skips that night's earlier victim) |
| 33 | Twice is Coincidence, Thrice is Proof | TB | unique: Tom = Imp, Sula = Poisoner | same | YES (first solve, no engine changes) |
| 34 | The Vortox Conjecture | S&V | unique: Sula = Vortox, Sarah = Witch | same | YES (forced engine fixes: strict ongoing-play, Vortox-counts-as-malfunction, Mathematician impaired-token scope; witch self-curse stays legal) |
| 36 | What is Your Weapon of Choice? | TB | unique: Fraser = Imp, Oscar = Poisoner | same | YES (forced drunk-token-not-in-play: the Drunk can't believe an in-play character, dup_ok exempt) |
| 40 | Nine Lives | TB (9p) | unique: Adam = Imp, Tim = Baron | same | YES (first solve; Empath night-2 read leans on positional death visibility) |
| 43 | Two Many Cooks | TB | unique: Dan = Imp, Fraser = Poisoner | Dan Imp, Fraser Poisoner | YES |
| 55 | The Life of a Flowergirl | S&V | unique world: Anna = Vortox, Jasmine = Witch | same | YES (forced claim-model fixes: evil-at-end claim freedom, living-Mutant madness; first "Potential hidden roles" box) |
| 59 | Fifty-Fifty | TB | unique: Oscar = Imp, Jasmine = Spy (full grimoire certain) | Jasmine Spy, Oscar Imp | YES |

Running total: **17/18 sound-unique + 1 PARTIAL (#11: demon unique, minion open)** (008 at
team level by
design). #28 was temporarily PARTIAL after the solver switched to sound
per-player probes; diagnosis found the discriminator in the Chambermaid's
printed wording ("woke due to their ability" — info wakes don't count).

Regression note: the #55 claim-model change (turned-evil players claim
freely) initially re-opened #28 and #34 — their transcriptions were missing
their "Potential hidden roles" boxes, which the old too-strict claim model
had been silently compensating for. Both boxes are now encoded, and
`evil_at_end` applies the final night's alignment change (a demon swapped
good by the Snake Charmer on the last night is good, and claims truthfully).

Notes per puzzle live in the YAML header comments. Solver invocation:
`python3 tools/botc.py puzzles/nqt/<file>.yaml`.
