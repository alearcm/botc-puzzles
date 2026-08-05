# Coverage

Per-character engine coverage for the three base scripts. `full` =
mechanics faithfully modelled within the engine's v1 scope (below);
notes name any deliberate simplification or rulings default in play.

Totals: 72 full / 0 partial / 0 deferred (72 characters).

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
| Trouble Brewing | mayor | townsfolk | full | night bounce; 3-alive-no-execution day win in endgame.lp |
| Trouble Brewing | butler | outsider | full | master choice + vote-legality constraint (votes are day inputs) |
| Trouble Brewing | drunk | outsider | full | shadow ability charade, scope S1 |
| Trouble Brewing | recluse | outsider | full | per-occurrence misregistration in info.lp |
| Trouble Brewing | saint | outsider | full | functioning execution ends game for evil (endgame.lp) |
| Trouble Brewing | poisoner | minion | full |  |
| Trouble Brewing | spy | minion | full | misregistration full; grimoire peek is true-but-unconstrained evil info by design |
| Trouble Brewing | scarletwoman | minion | full | demon-death takeover in mech.lp |
| Trouble Brewing | baron | minion | full |  |
| Trouble Brewing | imp | demon | full | star pass in mech.lp |
| Bad Moon Rising | grandmother | townsfolk | full |  |
| Bad Moon Rising | sailor | townsfolk | full | either-or drunking + cant_die in mech.lp/death.lp |
| Bad Moon Rising | chambermaid | townsfolk | full |  |
| Bad Moon Rising | exorcist | townsfolk | full |  |
| Bad Moon Rising | innkeeper | townsfolk | full |  |
| Bad Moon Rising | gambler | townsfolk | full |  |
| Bad Moon Rising | gossip | townsfolk | full | day statement inputs + conditional ST kill in mech.lp |
| Bad Moon Rising | courtier | townsfolk | full |  |
| Bad Moon Rising | professor | townsfolk | full |  |
| Bad Moon Rising | minstrel | townsfolk | full |  |
| Bad Moon Rising | tealady | townsfolk | full |  |
| Bad Moon Rising | pacifist | townsfolk | full |  |
| Bad Moon Rising | fool | townsfolk | full |  |
| Bad Moon Rising | tinker | outsider | full | ST-kill licence night and day |
| Bad Moon Rising | moonchild | outsider | full | public choice is a day input; good choice dies the following night |
| Bad Moon Rising | goon | outsider | full | first-targeter drunk + alignment flip via reified targeting order |
| Bad Moon Rising | lunatic | outsider | full | charade full (fake attacks as picks); demon feed is evil info, unconstrained by design |
| Bad Moon Rising | godfather | minion | full | outsider list token (spy may appear); outsider-death kill |
| Bad Moon Rising | devilsadvocate | minion | full |  |
| Bad Moon Rising | assassin | minion | full | pierce kill in death.lp |
| Bad Moon Rising | mastermind | minion | full | extension day + executed-team-loses in endgame.lp |
| Bad Moon Rising | zombuul | demon | full | fake first death registers dead everywhere (app_alive); off-night blocking |
| Bad Moon Rising | pukka | demon | full | poison-now/die-next-night through the kill pipeline; protection saves the life, poison expiry unchanged |
| Bad Moon Rising | shabaloth | demon | full | regurgitation of a previous victim |
| Bad Moon Rising | po | demon | full | self-pick convention = charge; exactly-3 burst (fewer if fewer alive) |
| Sects & Violets | clockmaker | townsfolk | full |  |
| Sects & Violets | dreamer | townsfolk | full |  |
| Sects & Violets | snakecharmer | townsfolk | full | same-night demon handover: new demon acts, old demon blocked, new charmer permanently poisoned |
| Sects & Violets | mathematician | townsfolk | full | malfunction := acted-while-impaired or charade (RULINGS charade-mathematician default) |
| Sects & Violets | flowergirl | townsfolk | full |  |
| Sects & Violets | towncrier | townsfolk | full |  |
| Sects & Violets | oracle | townsfolk | full |  |
| Sects & Violets | savant | townsfolk | full | day-visit statement pairs as quoted formulas; exactly-one-true pattern; Vortox both-false |
| Sects & Violets | seamstress | townsfolk | full |  |
| Sects & Violets | philosopher | townsfolk | full | ability copying with relative schedules; in-play holder drunk while held |
| Sects & Violets | artist | townsfolk | full | once-per-game day question as quoted formula |
| Sects & Violets | juggler | townsfolk | full | registration evaluated at guess time |
| Sects & Violets | sage | townsfolk | full | on-demon-death token in mech.lp |
| Sects & Violets | mutant | outsider | full | madness as claim-layer semantics (mutant claims a townsfolk); ST execution via day inputs |
| Sects & Violets | sweetheart | outsider | full |  |
| Sects & Violets | barber | outsider | full |  |
| Sects & Violets | klutz | outsider | full | on-death choice input; evil pick ends game for evil (registration applies) |
| Sects & Violets | eviltwin | minion | full | pair + good-twin-executed evil win + both-alive blocks good wins |
| Sects & Violets | witch | minion | full |  |
| Sects & Violets | cerenovus | minion | full | madness flag feeds claim-layer semantics; enforcement is ST licence via day inputs |
| Sects & Violets | pithag | minion | full | transform + in-play guard + arbitrary-deaths licence; created first-night abilities fire on first held night |
| Sects & Violets | fanggu | demon | full |  |
| Sects & Violets | vigormortis | demon | full | minion ability persists dead; poisons an alive townsfolk neighbour of the minion |
| Sects & Violets | nodashii | demon | full |  |
| Sects & Violets | vortox | demon | full | ALL_FALSE info + no-execution evil win (endgame.lp) |

## Engine-wide v1 scope

- Win/endgame semantics ARE modelled (endgame.lp): demon elimination,
  2-alive, Saint, Klutz, Mayor day win, Vortox no-execution, Evil Twin
  (good-twin execution + both-alive block), Mastermind extension day.
  Puzzles automatically assume play is ongoing (`assume_ongoing`),
  making survival-to-the-current-phase itself evidence.
- Travellers and Fabled are out of scope.
- Madness is claim-layer semantics (mutant claims a townsfolk;
  cerenovus-mad players claim their mad character); ST enforcement
  executions arrive as day inputs.
- Day events (nominations, votes, executions, slayer shots, juggles,
  gossip/savant/artist statements, moonchild/klutz choices) are
  observation inputs, not engine choices.
- Evil private info (minion/demon info, Spy grimoire, Lunatic feed,
  Evil Twin sightings) is real but unconstrained for the solver.
- Death-triggered effects apply at the death's night-order position
  (earlier same-night acts already resolved unimpaired).
