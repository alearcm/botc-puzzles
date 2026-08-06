# Skipped almanac examples

Examples not transcribed, with reasons. Travellers and Fabled are out of
engine scope (docs/COVERAGE.md).

| Character | Example | Reason |
|---|---|---|
| Chef | ex3 — "An evil Scapegoat is sitting between the Imp and a Minion... The Chef learns a '3'." | Involves the Scapegoat traveller. |
| Empath | ex1, second paragraph — "...the players sitting next to the Soldier and the Monk, which are a Librarian and an evil Gunslinger. The Empath now learns a '1'." | Involves the Gunslinger traveller. (First and third paragraphs are transcribed as empath-ex1a / empath-ex1c.) |
| Virgin | ex3 — "A dead player nominates the Virgin. The dead, however, cannot nominate. The Storyteller declares that the nomination does not count. The Virgin does not lose their ability." | Not expressible: nominations are raw inputs and the engine has no dead-players-cannot-nominate rule; recording the nomination would (wrongly) mark the Virgin spent via virgin_spent, and the ST's voiding of an illegal nomination has no atom. |
| Mayor | ex3 — "There are five players alive, including two Travellers. Both Travellers are exiled, and the vote is tied... good wins." | Involves travellers/exile; also relies on tied-vote/no-execution vote arithmetic, which is not modelled (executions are inputs). |
| Saint | ex2 — "The Imp is nominated, and the players vote. The Gunslinger kills the Saint. The Saint dies, and the game continues." | Involves the Gunslinger traveller. |
| Saint | ex3 — "The Saint is executed. However, the Scapegoat's ability is triggered, so the Scapegoat dies instead." | Involves the Scapegoat traveller. |
| Scarlet Woman | ex1 — "There are seven players alive: the Imp, the Scarlet Woman, two Townsfolk, and three Travellers. The Imp is executed, so the game ends... Travellers do not add to the player count." | Involves travellers (and traveller-exclusive alive counting). |

## Partially transcribed

- Undertaker ex3: the "Two Travellers are exiled... exiles are not
  executions" clause is omitted; the Spy-registers-as-Butler core is
  transcribed (undertaker-ex3-spy-butler-token).
- Saint ex1: the per-nomination vote tallies (4 votes vs 3 votes) are not
  encodable — voted/2 has no nominee argument; only the execution outcome is
  transcribed (saint-ex1-executed-evil-wins).
- Imp ex1: minion info and bluffs are evil private info, unconstrained by
  design; only the execution outcome is asserted (imp-ex1-executed-good-wins).
