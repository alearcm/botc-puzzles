# Draft fixture index — TB almanac Examples

One fixture per transcribable almanac example (wiki "Examples" sections,
fetched 2026-08-06). All are DRAFTS for review; none have been run.
Tier convention here: T0 = single-legal-ST-outcome almanac demo (exists) or
almanac-mandated outcome (certain); T1 = non-existence (illegality) claims.

Fixtures marked **EXPECTED FAIL** transcribe the almanac faithfully but are
believed to contradict the current engine (see header comments and SKIPPED.md).

| Fixture | Character | Example (short) | Tier | Assert |
|---|---|---|---|---|
| washerwoman-ex1-chef-pair | washerwoman | "learns that either Evin or Amy is the Chef" | T0 | exists |
| washerwoman-ex2-virgin-with-imp | washerwoman | "Julian is the Imp... learns that either... is the Virgin" | T0 | exists |
| washerwoman-ex3-spy-ravenkeeper | washerwoman | "Spy is registering as... the Ravenkeeper" | T0 | exists |
| librarian-ex1-saint-pair | librarian | "either Benjamin or Filip is the Saint" | T0 | exists |
| librarian-ex2-no-outsiders | librarian | "no Outsiders... learns a '0'" | T0 | exists |
| librarian-ex3-drunk-true-char | librarian | "learns that either Abdallah or Douglas is the Drunk" | T0 | exists |
| investigator-ex1-baron-pair | investigator | "either Amy or Julian is the Baron" | T0 | exists |
| investigator-ex2-spy-pair | investigator | "either Angelus or Lewis is the Spy" | T0 | exists |
| investigator-ex3-recluse-poisoner | investigator | "Recluse is registering as a Minion... the Poisoner" | T0 | exists |
| chef-ex1-zero | chef | "No evil players sitting next to each other... '0'" | T0 | exists |
| chef-ex2-two-pairs | chef | "Imp next to Baron... Poisoner next to Scarlet Woman... '2'" | T0 | exists |
| chef-ex4-recluse-one | chef | "Recluse between Imp and Poisoner... '1'" | T0 | exists |
| empath-ex1a-good-neighbours-zero | empath | "neighbours two good players... learns a '0'" | T0 | exists |
| empath-ex1c-three-alive-two | empath | "three players left alive... no matter who is seated where, '2'" | T0 | certain |
| fortuneteller-ex1-monk-undertaker-no | fortuneteller | "chooses the Monk and the Undertaker... 'no'" | T0 | exists |
| fortuneteller-ex2-imp-empath-yes | fortuneteller | "chooses the Imp and the Empath... 'yes'" | T0 | exists |
| fortuneteller-ex3-dead-imp-yes | fortuneteller | "an alive Butler and a dead Imp... 'yes'" | T0 | exists |
| fortuneteller-ex4-red-herring-self-pick | fortuneteller | "themselves and a Saint. The Saint is the Red Herring... 'yes'" | T0 | exists |
| undertaker-ex1-mayor-token | undertaker | "Mayor is executed... shown the Mayor token" | T0 | exists |
| undertaker-ex2-drunk-token | undertaker | "Drunk... executed... shown the Drunk token" | T0 | exists |
| undertaker-ex3-spy-butler-token | undertaker | "Spy is executed... shown the Butler token" | T0 | exists |
| undertaker-ex4-no-execution | undertaker | "Nobody was executed... does not wake" (as: no token) | T0 | certain |
| monk-ex1-protect-fortuneteller | monk | "protects the Fortune Teller... No deaths occur tonight" | T0 | exists |
| monk-ex2-protect-mayor | monk | "protects the Mayor... Nobody dies tonight" (bounce seam noted) | T0 | exists |
| monk-ex3-protect-imp | monk | "protects the Imp... a new Imp is not created" | T0 | certain |
| ravenkeeper-ex1-learns-empath | ravenkeeper | "killed by the Imp... Benjamin is the Empath" | T0 | exists |
| ravenkeeper-ex2-bounce-dead-recluse | ravenkeeper | "Ravenkeeper dies instead... dead Recluse... Scarlet Woman" | T0 | exists |
| virgin-ex1-washerwoman-proc | virgin | "Washerwoman nominates the Virgin... immediately executed" | T0 | exists |
| virgin-ex2-drunk-no-proc | virgin | "Drunk... nominates... remains alive... Virgin loses ability" | T0 | exists |
| slayer-ex1-shoots-imp | slayer | "chooses the Imp. The Imp dies, and good wins!" | T0 | certain |
| slayer-ex2-recluse-dies | slayer | "chooses the Recluse... registers as the Imp, so the Recluse dies" | T0 | exists |
| slayer-ex3-imp-bluff | slayer | "Imp is bluffing as the Slayer... Nothing happens" | T0 | certain |
| soldier-ex1-imp-attack-safe | soldier | "Imp attacks the Soldier... nobody dies that night" | T0 | certain |
| soldier-ex2-poisoned-dies | soldier | "Poisoner poisons the Soldier... The Soldier dies" | T0 | certain |
| soldier-ex3-actually-drunk | soldier | "Soldier dies, because they are actually the Drunk" | T0 | certain |
| mayor-ex1-bounce-ravenkeeper | mayor | "ST chooses that the Ravenkeeper dies instead" | T0 | exists |
| mayor-ex2-three-alive-win | mayor | "three players alive... no nominations... Good wins" | T0 | certain |
| butler-ex1-vote-with-master | butler | "if Filip raises his hand... the Butler may too" | T0 | exists |
| butler-ex2-master-lowers-hand | butler | "Master lowers their hand... Butler must lower theirs" | T1 | exists:false |
| butler-ex3-dead-butler-votes | butler | "Butler is dead... may vote... at any time" **EXPECTED FAIL** | T0 | exists |
| drunk-ex1-thinks-soldier | drunk | "thinks they are the Soldier... The Drunk dies" | T0 | certain |
| drunk-ex2-thinks-empath | drunk | "thinks they are the Empath... learns a '0'... then a '1'" | T0 | exists |
| drunk-ex3-thinks-ravenkeeper | drunk | "thinks they are the Ravenkeeper... learn... the Poisoner" | T0 | exists |
| drunk-ex4-thinks-undertaker | drunk | "thinks they are Undertaker, learns that the Drunk died" | T0 | exists |
| recluse-ex1-slayer-shot | recluse | "Slayer uses their ability on the Recluse... Recluse dies" | T0 | exists |
| recluse-ex2-empath-flicker | recluse | "Empath... learns... one evil... next night... no evil" | T0 | exists |
| recluse-ex3-investigator-sw | recluse | "either the Recluse or the Saint is the Scarlet Woman" | T0 | exists |
| recluse-ex4-undertaker-imp | recluse | "Recluse is executed. The Undertaker learns... the Imp" | T0 | exists |
| saint-ex1-executed-evil-wins | saint | "The Saint is executed, and evil wins" (votes dropped) | T0 | certain |
| poisoner-ex1-slayer-fizzle | poisoner | "poisons the Slayer... Nothing happens" | T0 | certain |
| poisoner-ex2-empath-flicker | poisoner | "poisoned Empath... '0'... no longer poisoned... '2'" | T0 | exists |
| poisoner-ex3-investigator-false | poisoner | "Investigator is poisoned... Baron, even though neither is a Minion" | T0 | exists |
| poisoner-ex4-undertaker-false | poisoner | "Undertaker is poisoned... learns that the Virgin died" | T0 | exists |
| poisoner-ex4b-saint-safe | poisoner | "a poisoned Saint dies, and the game continues" | T0 | exists:false |
| poisoner-ex5-star-pass-poison-ends | poisoner | "becomes the Imp. The Mayor is no longer poisoned" **EXPECTED FAIL** | T0 | exists |
| spy-ex1-washerwoman-ravenkeeper | spy | "Douglas is the Spy registering as the Ravenkeeper" | T0 | exists |
| spy-ex2-chef-empath-flicker | spy | "Chef learns a '1'... later that night, the Empath learns a '0'" | T0 | exists |
| spy-ex3-virgin-undertaker | spy | "Spy nominates the Virgin... Undertaker learns that the Drunk died" | T0 | exists |
| scarletwoman-ex2-five-alive-takeover | scarletwoman | "five players alive... Imp is executed... becomes the Imp" **EXPECTED FAIL** | T0 | certain |
| scarletwoman-ex3-fortuneteller-flip | scarletwoman | "FT... 'no'. Later, the Imp dies... 'yes'" | T0 | exists |
| baron-ex1-seven-player-setup | baron | "seven players... three Townsfolk, two Outsider, one Minion, one Demon" | T0 | exists |
| baron-ex2-fifteen-player-drunk | baron | "fifteen players... add a Drunk and a Recluse" | T0 | exists |
| imp-ex1-executed-good-wins | imp | "the Imp is executed and good wins" (bluffs unconstrained) | T0 | certain |
| imp-ex2-star-pass-poisoner | imp | "chooses themselves to die... the Poisoner becomes the Imp" | T0 | certain |

64 fixtures; 7 examples skipped (see SKIPPED.md).
