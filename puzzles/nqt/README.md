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
| 28 | A Study in Scarlet | TB+BMR+S&V | official world admitted, but 3 extra demon worlds survive (adam/oscar/fraser variants) | Olivia ND, Fraser SW, Matt Drunk | PARTIAL — under diagnosis |
| 34 | The Vortox Conjecture | S&V | unique: Sula = Vortox, Sarah = Witch | same | YES (forced 3 engine fixes: strict ongoing-play, Vortox-counts-as-malfunction, witch no-self-curse) |
| 43 | Two Many Cooks | TB | unique: Dan = Imp, Fraser = Poisoner | Dan Imp, Fraser Poisoner | YES |
| 59 | Fifty-Fifty | TB | unique: Oscar = Imp, Jasmine = Spy (full grimoire certain) | Jasmine Spy, Oscar Imp | YES |

Running total: **6/7 sound-unique reproductions; #28 partial** (official world
admitted but not unique — under diagnosis). NOTE: earlier scoreboards computed
candidates from a truncated world enumeration; the solver now uses sound
per-player satisfiability probes, which retro-downgraded #28 from YES to
PARTIAL. All other results survived the sound audit.

Notes per puzzle live in the YAML header comments. Solver invocation:
`python3 tools/botc.py puzzles/nqt/<file>.yaml`.
