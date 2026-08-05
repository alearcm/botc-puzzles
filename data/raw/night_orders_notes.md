# Night orders — sourcing and transcription notes

Compiled 2026-08-05. Per-script (printed night-sheet) orders for the three base
editions: Trouble Brewing (tb), Bad Moon Rising (bmr), Sects & Violets (snv).

## Sources actually used

The task's primary source — the official wiki edition pages — could **not** be used:

- https://wiki.bloodontheclocktower.com/Trouble_Brewing
- https://wiki.bloodontheclocktower.com/Bad_Moon_Rising
- https://wiki.bloodontheclocktower.com/Sects_%26_Violets

As served right now, these pages contain only Synopsis / Gameplay / character-list
sections. I verified via the MediaWiki API (`action=parse&prop=wikitext`) that the
current wikitext has no "Night Order" section, searched the wiki fulltext for
"night order", "first night" and "minion info" (0 hits), and enumerated all 205
main-namespace pages and all templates/images — the wiki has no night-order
content anywhere. Page history shows the wiki was created 2023-03-03 and the
edition pages never contained night order sections. Wayback Machine and
archive.today were unreachable from this environment (connection reset /
fetch blocked), so older wiki snapshots could not be consulted.

**Fallback (per task instructions): the official printable night sheets.**
I used the official edition script/night-sheet PDFs (© Steven Medway,
bloodontheclocktower.com — page 2 of each PDF is the fold-over night sheet with
"First Night" on one half and "Other Nights" upside-down on the other), as
archived in the `tjhowse/botc` repo (`official_pdfs/`, pulled 2021-05-05 from
Google Docs links shared by the developers; repo README documents provenance):

- tb:  https://github.com/tjhowse/botc/blob/b71c37051e9ebcf355b64001877f594fa83e2b24/official_pdfs/Trouble%20Brewing%20script.pdf
- bmr: https://github.com/tjhowse/botc/blob/b71c37051e9ebcf355b64001877f594fa83e2b24/official_pdfs/Bad%20Moon%20Rising%20script.pdf
- snv: https://github.com/tjhowse/botc/blob/b71c37051e9ebcf355b64001877f594fa83e2b24/official_pdfs/Sects%20%26%20Violets%20script.pdf

The night-sheet pages are image-based (no extractable text), so I rendered each
page (and 180-degree-rotated crops of the upside-down "Other Nights" columns) to
PNG at 150–300 dpi and transcribed the entries visually, entry by entry.

## Markers

- The printed sheets show "Minion info" / "Demon info" (first night) and
  "Dusk" / "Dawn"; encoded as `MINION_INFO`, `DEMON_INFO`, `DUSK`, `DAWN`.
- **No `DUSK` on any First Night list** — the printed first-night columns start
  directly with their first entry (Minion info for tb/bmr, Philosopher for snv).
  `DUSK` appears only on the Other Nights side. `DAWN` closes every list.
- Sheet-order quirks faithfully preserved: on the BMR first night the **Lunatic
  sits between Minion info and Demon info**; on the SnV first night the
  **Philosopher precedes Minion info**.

## Name → id mapping

Display names mapped to `data/raw/townsquare_roles.json` ids by
lowercasing and dropping spaces/apostrophes/hyphens. Every id was verified to
exist in that file. Non-obvious mappings:

- "Fortune Teller" → `fortuneteller`, "Scarlet Woman" → `scarletwoman`
- "Devil's Advocate" → `devilsadvocate`
- "Snake Charmer" → `snakecharmer`, "Evil Twin" → `eviltwin`
- "Pit-Hag" → `pithag`, "Fang Gu" → `fanggu`, "No Dashii" → `nodashii`
- "Town Crier" → `towncrier`

## Travellers

Travellers do **not** appear on any of the three printed night sheets, even
though townsquare_roles.json assigns night numbers to several same-edition
travellers (tb: bureaucrat, thief; bmr: apprentice, first night only; snv:
barista, bonecollector, harlot). They are therefore omitted from the lists.

## Characters absent from a sheet

Only characters with no night action in that phase are absent (expected):
e.g. tb first night lacks Undertaker/Monk/Ravenkeeper/Virgin/Slayer/Soldier/
Mayor/Drunk/Recluse/Saint/Scarlet Woman/Baron/Imp; cross-checking each
edition's sheet against townsquare `firstNight`/`otherNight` > 0 (travellers
excluded) found **zero missing characters and zero extras** in all six lists.

## Transcription oddity (kept as printed)

The SnV **Other Nights** sheet prints the pair **Sweetheart, Sage twice in a
row**: ... Barber, Sweetheart, Sage, Sweetheart, Sage, Dreamer ... I zoomed to
300 dpi to confirm this is genuinely two separate printed rows (an apparent
misprint/layout duplication in the official PDF), not a rendering artifact.
It is transcribed as-is in night_orders.json; deduplicating (keeping first
occurrence) yields the expected ... barber, sweetheart, sage, dreamer ...

## Discrepancies vs townsquare_roles.json numeric night order
(restricted to same-edition, non-traveller characters)

- **tb other nights:** sheet has **Butler before Undertaker**
  (... fortuneteller, butler, undertaker, spy ...); townsquare numbers order
  Undertaker (55) before Butler (67).
- **bmr other nights:** sheet has **Innkeeper before Courtier**; townsquare has
  Courtier (8) before Innkeeper (9). Sheet has **Professor before Gossip**;
  townsquare has Gossip (38) before Professor (43).
- All other lists (tb first, bmr first, snv first, snv other after
  deduplication) match the relative order implied by townsquare
  `firstNight`/`otherNight` exactly.

## Caveat

These PDFs reflect the 2021 printing. Later printings/revisions of the sheets
(if any) were not retrievable in this environment (wiki lacks the lists;
web archives blocked). For comparison, the official Script Tool's current
global night order (extracted from script.bloodontheclocktower.com's app
bundle) agrees with the townsquare numbers on the three discrepant pairs
above, i.e. those three pairs are printed-sheet vs modern-global-order
differences, not transcription errors.
