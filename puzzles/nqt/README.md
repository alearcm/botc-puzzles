# NQT Weekly Puzzle reproductions

Transcriptions of [Not Quite Tangible weekly puzzles](https://notquitetangible.blogspot.com/2024/11/clocktower-puzzle-archive.html)
(by u/Not_Quite_Vertical). Each YAML is a structural transcription of the
puzzle state (players, claims, public events) with a link to the source; the
solver must reproduce the author-confirmed answer from the thread.

| # | Puzzle | Scripts | Solver answer | Official | Match |
|---|---|---|---|---|---|
| 8 | The Stitch-Up | S&V+TB homebrew (all-Seamstress) | evil team {josh, steph}; demon within pair ambiguous | Josh & Steph evil, You poisoned | YES |
| 21 | Eight Jugglers Juggling | homebrew (all-Juggler) + Leviathan/Goblin/Drunk | unique world: Oscar = Leviathan, Tim = Goblin, Aoife = Drunk | same | YES (first experimental characters: cards/exp.yaml) |
| 10 | Don't Overcook It | TB (restricted roster) | unique: Dan = Imp, Fraser = Poisoner | Dan Imp, Fraser Poisoner | YES |
| 13 | Clockblocking | TB+Clockmaker | official world + one spurious star-pass world | Fraser Imp, Oscar Baron, Tim Drunk | PARTIAL — needs position-aware registration (see DEBT: a post-star-pass Imp must register to a later-position Fortune Teller) |
| 22 | One in the Chamber | TB+Chambermaid | sound-unique: Sarah = starting Imp, Steph = Baron (star-pass Imp), You = Drunk | same | YES (forced shadow-pick generalization + roster validation) |
| 26 | A Major Problem | TB | unique: Tom = Imp, Matthew = Poisoner | Tom Imp, Matthew Poisoner | YES |
| 29 | A Dreamer? I'm Not the Only One | homebrew (all-Dreamer) TB+S&V | unique world: Adam = Imp, Jasmine = Poisoner, Hannah = Drunk | same | YES (first solve, no engine changes) |
| 28 | A Study in Scarlet | TB+BMR+S&V | sound-unique: Olivia = No Dashii, Fraser = SW, Matt = Drunk | same | YES (after chambermaid ability-wakes-only fix) |
| 34 | The Vortox Conjecture | S&V | unique: Sula = Vortox, Sarah = Witch | same | YES (forced engine fixes: strict ongoing-play, Vortox-counts-as-malfunction, Mathematician impaired-token scope; witch self-curse stays legal) |
| 43 | Two Many Cooks | TB | unique: Dan = Imp, Fraser = Poisoner | Dan Imp, Fraser Poisoner | YES |
| 55 | The Life of a Flowergirl | S&V | unique world: Anna = Vortox, Jasmine = Witch | same | YES (forced claim-model fixes: evil-at-end claim freedom, living-Mutant madness; first "Potential hidden roles" box) |
| 59 | Fifty-Fifty | TB | unique: Oscar = Imp, Jasmine = Spy (full grimoire certain) | Jasmine Spy, Oscar Imp | YES |

Running total: **11/12 sound-unique reproductions, 1 PARTIAL** (008 at
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
