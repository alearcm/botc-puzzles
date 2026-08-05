# Coverage

Per-character engine coverage. `full` = mechanics faithfully modelled 
(within engine v1 scope: no win conditions, travellers, or madness 
enforcement); `partial` = core behaviour modelled with named 
simplifications; `deferred` = present as data, not yet executable.

Totals: 44 full / 25 partial / 3 deferred (72 characters).

| Script | Character | Team | Coverage | Notes |
|---|---|---|---|---|
| Trouble Brewing | washerwoman | townsfolk | full |  |
| Trouble Brewing | librarian | townsfolk | full |  |
| Trouble Brewing | investigator | townsfolk | full |  |
| Trouble Brewing | chef | townsfolk | full |  |
| Trouble Brewing | empath | townsfolk | full |  |
| Trouble Brewing | fortuneteller | townsfolk | full |  |
| Trouble Brewing | undertaker | townsfolk | full |  |
| Trouble Brewing | monk | townsfolk | full |  |
| Trouble Brewing | ravenkeeper | townsfolk | full | on-death trigger wired in mech.lp (incl. shadow charade) |
| Trouble Brewing | virgin | townsfolk | full | nomination proc in mech.lp from day inputs |
| Trouble Brewing | slayer | townsfolk | full | public day shot in mech.lp from day inputs |
| Trouble Brewing | soldier | townsfolk | full |  |
| Trouble Brewing | mayor | townsfolk | partial | night bounce in death.lp; no-execution-good-wins deferred (win conditions) |
| Trouble Brewing | butler | outsider | partial | master choice modelled (wakes, picks); vote-legality constraint deferred |
| Trouble Brewing | drunk | outsider | full | shadow ability charade, scope S1 |
| Trouble Brewing | recluse | outsider | full | per-occurrence misregistration in info.lp |
| Trouble Brewing | saint | outsider | partial | execution-loss win condition deferred |
| Trouble Brewing | poisoner | minion | full |  |
| Trouble Brewing | spy | minion | partial | misregistration full; grimoire peek is unconstrained evil info (wakes for chambermaid) |
| Trouble Brewing | scarletwoman | minion | full | demon-death takeover in mech.lp |
| Trouble Brewing | baron | minion | full |  |
| Trouble Brewing | imp | demon | full | star pass in mech.lp |
| Bad Moon Rising | grandmother | townsfolk | full |  |
| Bad Moon Rising | sailor | townsfolk | full | either-or drunking + cant_die in mech.lp/death.lp |
| Bad Moon Rising | chambermaid | townsfolk | partial | not-yourself pick restriction not yet enforced |
| Bad Moon Rising | exorcist | townsfolk | partial | demon-block full; different-player-to-last-night not yet enforced |
| Bad Moon Rising | innkeeper | townsfolk | full |  |
| Bad Moon Rising | gambler | townsfolk | full |  |
| Bad Moon Rising | gossip | townsfolk | full | day statement inputs + conditional ST kill in mech.lp |
| Bad Moon Rising | courtier | townsfolk | full |  |
| Bad Moon Rising | professor | townsfolk | full |  |
| Bad Moon Rising | minstrel | townsfolk | full |  |
| Bad Moon Rising | tealady | townsfolk | full |  |
| Bad Moon Rising | pacifist | townsfolk | full |  |
| Bad Moon Rising | fool | townsfolk | full |  |
| Bad Moon Rising | tinker | outsider | partial | night ST-kill licence; day deaths not yet modelled |
| Bad Moon Rising | moonchild | outsider | partial | choice comes as public day input; night-death trigger variant deferred |
| Bad Moon Rising | goon | outsider | partial | first-targeter drunk + alignment flip; ST-targeting subtleties simplified |
| Bad Moon Rising | lunatic | outsider | partial | charade full (incl. fake attacks as picks); real-demon feed not constrained |
| Bad Moon Rising | godfather | minion | partial | outsider-death kill full; night-1 outsider list token deferred |
| Bad Moon Rising | devilsadvocate | minion | partial | execution save full; not-same-player-twice not enforced |
| Bad Moon Rising | assassin | minion | full | pierce kill in death.lp |
| Bad Moon Rising | mastermind | minion | deferred | extra-day-after-demon-death needs win/endgame semantics |
| Bad Moon Rising | zombuul | demon | partial | fake first death + off-night blocking; deadness registration edges open |
| Bad Moon Rising | pukka | demon | partial | poison-now/die-next-night; interaction with protection mid-chain simplified |
| Bad Moon Rising | shabaloth | demon | partial | regurgitation modelled; "chose a dead player" edge simplified |
| Bad Moon Rising | po | demon | partial | self-pick convention = charge; 3-kill burst modelled |
| Sects & Violets | clockmaker | townsfolk | full |  |
| Sects & Violets | dreamer | townsfolk | full |  |
| Sects & Violets | snakecharmer | townsfolk | partial | swap applied at night boundary; new demon does not act the same night |
| Sects & Violets | mathematician | townsfolk | partial | malfunction := acted-while-impaired or charade; see RULINGS charade-mathematician |
| Sects & Violets | flowergirl | townsfolk | full |  |
| Sects & Violets | towncrier | townsfolk | full |  |
| Sects & Violets | oracle | townsfolk | full |  |
| Sects & Violets | savant | townsfolk | full | day-visit statement pairs as quoted formulas; exactly-one-true pattern; Vortox both-false |
| Sects & Violets | seamstress | townsfolk | partial | not-yourself restriction and dead-pickable edge simplified |
| Sects & Violets | philosopher | townsfolk | deferred | ability copying (first-class abilities) not yet in engine |
| Sects & Violets | artist | townsfolk | full | once-per-game day question as quoted formula |
| Sects & Violets | juggler | townsfolk | full | registration evaluated at guess time |
| Sects & Violets | sage | townsfolk | full | on-demon-death token in mech.lp |
| Sects & Violets | mutant | outsider | partial | madness has no enforcement semantics; ST-execution licence is via day inputs |
| Sects & Violets | sweetheart | outsider | full |  |
| Sects & Violets | barber | outsider | full |  |
| Sects & Violets | klutz | outsider | deferred | on-death choice recorded; good-loses outcome needs win semantics |
| Sects & Violets | eviltwin | minion | partial | opposite-alignment pair modelled; win-veto deferred |
| Sects & Violets | witch | minion | full |  |
| Sects & Violets | cerenovus | minion | partial | madness flag only |
| Sects & Violets | pithag | minion | partial | transform + arbitrary-deaths licence; created first-night abilities per relative schedule |
| Sects & Violets | fanggu | demon | full |  |
| Sects & Violets | vigormortis | demon | partial | minion ability persistence + adjacent-townsfolk poison; poison scoping simplified |
| Sects & Violets | nodashii | demon | full |  |
| Sects & Violets | vortox | demon | partial | ALL_FALSE info full; no-execution-evil-wins deferred (win semantics) |

## Engine-wide v1 scope limits

- Win/endgame conditions are not modelled (Saint, Mayor day-win, Klutz,
  Evil Twin veto, Mastermind, Vortox execution rule are all flagged).
- Travellers and Fabled are out of scope.
- Madness (Cerenovus, Mutant) is recorded, not enforced.
- Day events (nominations, votes, executions, slayer shots, juggles,
  gossip/savant/artist statements) are observation inputs, not choices.
- Within-night character swaps take effect at the night boundary
  (Snake Charmer / Barber / star-pass timing simplifications).
- Evil-team private info (minion/demon info, Spy grimoire, Lunatic feed)
  is unconstrained (ST-may-say-anything) in v1.
