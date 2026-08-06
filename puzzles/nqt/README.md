# NQT Weekly Puzzle reproductions

Transcriptions of [Not Quite Tangible weekly puzzles](https://notquitetangible.blogspot.com/2024/11/clocktower-puzzle-archive.html)
(by u/Not_Quite_Vertical). Each YAML is a structural transcription of the
puzzle state (players, claims, public events) with a link to the source; the
solver must reproduce the author-confirmed answer from the thread.

| # | Puzzle | Scripts | Solver answer | Official | Match |
|---|---|---|---|---|---|
| 8 | The Stitch-Up | S&V+TB homebrew (all-Seamstress) | evil team {josh, steph}; demon within pair ambiguous | Josh & Steph evil, You poisoned | YES |
| 10 | Don't Overcook It | TB (restricted roster) | unique: Dan = Imp, Fraser = Poisoner | Dan Imp, Fraser Poisoner | YES |
| 26 | A Major Problem | TB | unique: Tom = Imp, Matthew = Poisoner | Tom Imp, Matthew Poisoner | YES |
| 28 | A Study in Scarlet | TB+BMR+S&V | sound-unique: Olivia = No Dashii, Fraser = SW, Matt = Drunk | same | YES (after chambermaid ability-wakes-only fix) |
| 34 | The Vortox Conjecture | S&V | unique: Sula = Vortox, Sarah = Witch | same | YES (forced 3 engine fixes: strict ongoing-play, Vortox-counts-as-malfunction, witch no-self-curse) |
| 43 | Two Many Cooks | TB | unique: Dan = Imp, Fraser = Poisoner | Dan Imp, Fraser Poisoner | YES |
| 59 | Fifty-Fifty | TB | unique: Oscar = Imp, Jasmine = Spy (full grimoire certain) | Jasmine Spy, Oscar Imp | YES |

Running total: **7/7 sound-unique reproductions** (008 at team level by
design). #28 was temporarily PARTIAL after the solver switched to sound
per-player probes; diagnosis found the discriminator in the Chambermaid's
printed wording ("woke due to their ability" — info wakes don't count).

Notes per puzzle live in the YAML header comments. Solver invocation:
`python3 tools/botc.py puzzles/nqt/<file>.yaml`.
