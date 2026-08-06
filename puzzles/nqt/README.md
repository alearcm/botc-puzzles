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
| 28 | A Study in Scarlet | TB+BMR+S&V | unique: Olivia = No Dashii, Fraser = SW, Matt = Drunk | same | YES (after No Dashii static-poison fix) |
| 43 | Two Many Cooks | TB | unique: Dan = Imp, Fraser = Poisoner | Dan Imp, Fraser Poisoner | YES |
| 59 | Fifty-Fifty | TB | unique: Oscar = Imp, Jasmine = Spy (full grimoire certain) | Jasmine Spy, Oscar Imp | YES |

Running total: **6/6 reproduced** (one initial miss on #28 diagnosed to a real engine rule error — No Dashii poison jumping dead townsfolk — fixed via the author's own thread ruling).

Notes per puzzle live in the YAML header comments. Solver invocation:
`python3 tools/botc.py puzzles/nqt/<file>.yaml`.
