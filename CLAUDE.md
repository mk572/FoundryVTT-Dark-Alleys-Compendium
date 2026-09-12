# dark-alleys-compendium

Foundry VTT compendium module for the 13th Age (1e) expansion book *Dark
Alleys & Twisted Path*. Repo: `mk572/FoundryVTT-Dark-Alleys-Compendium`
(public GitHub), cloned locally here 2026-09-12. Uses the `archmage` game
system.

**Sibling project (2026-09-13): `~/projects/13a-rules-db`** is the new
single source of truth for 13th Age rules content generally — the SRD
comparison work happening in this project (see "SRD content comparison"
below) is what feeds it. Once an entry here is verified against the SRD/PDF,
it belongs in `13a-rules-db` too (as a `status: verified` entry), not just
in this module's Foundry packs. `reference/srd-cache/` in *this* project is
raw parsed-SRD material; `13a-rules-db`'s `data/1e/classes/*.yaml` is the
actual curated, schema-validated source of truth built from it.

## Conventions

Follow `~/projects/CODING_GUIDELINES.md`. Project-specific overrides:

- No test suite / build step — this is static compendium data + a
  `module.json` manifest, no application code.

## Commands

- **Build a test zip:** from the project root:
  `zip -r dist/dark-alleys-compendium-test.zip module.json README.md packs`
  (`dist/` is gitignored). This is what gets fed into Forge's Import Wizard
  for testing — see below.
- **Regenerate a pack after editing staged JSON:** use
  `@foundryvtt/foundryvtt-cli`'s `compilePack(srcDir, destDir)` — see
  "Migration tooling" below for the exact key-format gotchas.

## Layout

- `module.json` — manifest, **rewritten to the modern schema this session**
  (was on the pre-v10 schema before). See "2026-09-12 migration" below.
- `packs/` — the 10 compendium packs, now **LevelDB folder format** (was
  flat NeDB `.db` files before this session).
- `_backup-nedb-packs/` (gitignored, not deleted) — the original NeDB `.db`
  files, kept as a safety net until the migration is confirmed solid over
  time. Safe to delete once you're confident; nothing reads from it.
- `notes/` (gitignored) — scratch reference material, not part of the
  module. Currently holds `abomination-dump.md`, a markdown dump of the
  Abomination class from an **unrelated third-party module** ("Dark Pacts
  13th Age 2e" / DPAS, by hairyscotsman + the project owner) — pulled in to
  help judge whether its classes are 1e- or 2e-flavored. Not part of Dark
  Alleys; parked pending a reply from the DPAS author.
- `dist/` (gitignored) — build output (test zips). Not committed.
- `reference/srd-cache/` — **tracked, not gitignored** (unlike the above —
  this is real reference work product, not scratch). One JSON file per
  13th Age SRD class page already parsed for the SRD content comparison
  task (see below). Read before re-fetching a page you've already done.

## 2026-09-12 migration (Foundry v14 / archmage 1.40.1)

The module was stuck at v0.5.0 (2021), declaring `minimumCoreVersion:
0.6.0` / `compatibleCoreVersion: 0.7.9` / `minimumSystemVersion: 1.5.0`,
with packs in the old flat NeDB `.db` format (`data`/`permission` fields).
This session migrated it to v0.6.0, targeting Foundry v14 and archmage
1.40.1, and **verified working end-to-end in a live Forge-hosted Foundry
v14 instance** (world "Dark Alleys Test" on `mk333.as.forge-vtt.com`).

**What changed:**
- All 10 packs converted from NeDB flat files to LevelDB folder packs.
- Field renames: `data`→`system`, `permission`→`ownership` (recursively,
  including the summons pack's embedded NPC items).
- `module.json`: `name`→`id`, `minimumCoreVersion`/`compatibleCoreVersion`
  →`compatibility: {minimum, verified}`, `minimumSystemVersion`→
  `relationships.systems[]`, per-pack `entity`→`type`, pack `path` now
  points at directories instead of `.db` files.
- Fixed a real bug in the old manifest: `dark-alleys-cleric-summons` was
  declared `entity: "Item"` even though its content is NPC actors — now
  correctly `type: "Actor"`.
- All original `_id` values preserved exactly (existing worlds referencing
  these by UUID won't break).

**Migration tooling** (not kept in the repo — was run from a scratch
working dir using `@foundryvtt/foundryvtt-cli`'s `compilePack`/
`extractPack`): the tricky part is that `compilePack` expects one JSON file
per document with a modern `_key` field, and **embedded documents (e.g. an
Actor's owned Items) need their own composite key** —
`!actors.items!<actorId>.<itemId>` (general pattern: `!<sublevel>!<id>`
where nesting joins with `.`). This isn't obvious from Foundry's docs; it
was reverse-engineered by reading `node_modules/@foundryvtt/foundryvtt-cli/lib/package.mjs`
directly (`applyHierarchy`/`mapHierarchy`/`HIERARCHY` constant). If a pack
needs re-migrating or another old module needs the same treatment, re-derive
this from that source rather than guessing.

**Data-quality finding, not a bug:** several packs show fewer documents
than the old `.db` files' raw line counts (e.g. 28 lines → 13 items in
`13-cld-cleric`; 24→12 in `dark-alleys-cleric-summons`). Confirmed cause:
the original NeDB files were never compacted — NeDB appends a new line per
edit rather than overwriting in place, so old `.db` files (checked into git
raw) had stale duplicate `_id` lines from years of edits. The migration
kept the last-written line per `_id`, i.e. exactly what real NeDB
compaction would do. The lower counts are the *correct* de-duplicated
totals, not lost data. Verified line-by-line with a duplicate-`_id` count
per file before concluding this.

**Foundry/Forge operational gotchas hit during testing** (useful if you're
setting up another test round):
- After using Forge's Import Wizard, the imported module does **not**
  appear in Module Management until you **Stop then Start the Forge
  server** (Games Configuration page) — documented by Forge, easy to miss.
- Installing a module on the server (Setup → Add-on Modules) and
  **enabling it for a specific World** (in-world Settings → Module
  Management) are two separate steps.
- In this test, the in-world "Manage Modules" form's checkbox + Save
  button did **not** actually persist the active-module change (confirmed
  via `game.modules.get(id).active` staying `false` after save+reload).
  Had to force it via the console: `game.settings.set('core',
  'moduleConfiguration', {...current, '<module-id>': true})` then reload.
  Unclear if this is a general Foundry v14/Forge bug or an artifact of the
  session's reload cycle — worth retesting fresh before assuming it'll
  recur.
- Legacy Token schema fields on Actors (`dimSight`/`brightSight`/
  `lightAngle`/etc., from pre-v10 Foundry) are **auto-migrated by Foundry
  core** into the modern `sight`/`light`/`texture` structure at load time —
  confirmed via `doc.prototypeToken.sight` etc. on a loaded document. No
  manual conversion needed for old token data in general.

## SRD content comparison (started 2026-09-12)

Separate from the technical migration: comparing each pack's rules text
against the public 13th Age SRD (13thagesrd.com) to catch missing talents,
rules errata, or transcription drift from the original PDF-era digitization.
Progress and per-pack findings live in `docs/TASKS.md`; this section is the
reusable *method*.

**Local SRD cache (started 2026-09-13):** `reference/srd-cache/<class>.json`
holds the parsed-and-structured result for each class page already checked
— not raw HTML, not markdown, but the same structured facts (entry name,
tier, source tag, full text, plus whatever page-specific structure that
class needed — see each file's own `page_structure` note, since pages are
**not** structurally uniform, see point 10 below) already extracted via the
method below. Read an existing cache file before re-fetching a page you've
already done. Write a new one any time you finish parsing a class page,
even if the comparison itself gets paused/deferred — the parsing work is
the expensive part, not the comparison. A full site-wide scrape-everything-
upfront approach was considered and rejected 2026-09-13: each class page
needs its own parsing logic anyway (confirmed by how differently Cleric's
page is structured from Barbarian/Bard's), so there's no shortcut around
doing this page-by-page as we get to each class.

**The reliable method — read the raw HTML yourself, don't trust one
summarized `WebFetch` pass for an inventory.** A single `WebFetch` call
against an SRD talent-list page (asking it to summarize "every entry tagged
Source: DATP") silently **dropped real entries** on the Barbarian page
(missed "Fury of the North Wind" and "Meat Grinder", and separately invented
two false positives by lumping same-tier talents together regardless of
their actual Source tag). Don't rely on that for a count or a completeness
check. Instead:
1. `curl` the page's raw HTML to a local file.
2. Strip tags with a quick Python regex pass (`<script>`/`<style>` removed
   first, then all remaining tags → newlines, then `html.unescape`) to get
   one text-chunk per line.
3. Find every literal `Source` line; the talent name is 1 line before it,
   the source abbreviation is 1 line after it. This is a byte-exact,
   deterministic parse — no summarization risk.
4. Only pull mechanical text for the entries you've deterministically
   confirmed matter (base effect + Champion/Epic Feat blocks live between
   one talent's name and the next in page order).
5. Compare against the pack's extracted JSON (`extractPack` from
   `@foundryvtt/foundryvtt-cli` — see the migration tooling note above) on:
   presence/absence, tier (`powerLevel` 1/5/8 ↔ Adventurer/Champion/Epic),
   and the mechanical numbers in `system.effect` / `system.feats[].description`.
   **Flavor text is explicitly out of scope** — the user doesn't want it
   tracked or flagged as missing; only mechanical differences matter.
6. The SRD itself isn't infallible — it mis-tagged "Primitive Strength"'s
   source (confirmed wrong by the project owner, who knows the source
   material), so a name that looks "missing" from the module may actually
   be an SRD tagging error, not a module gap. Flag mismatches for the
   user to confirm rather than assuming the module is wrong.
7. **When the SRD and the module disagree, check the printed source PDF
   before concluding either is wrong** — `~/Documents/rpg/13th age/dark
   alleys playtest/final/DarkAlleys_Digital-Apr10_2020.pdf` (244 pages) is
   the actual Dark Alleys & Twisted Paths book. It's readable with
   PyMuPDF (`import fitz` — installed; ignore the "use pymupdf instead"
   deprecation warning, `fitz` works fine) page-by-page via
   `page.get_text()`, so a project-wide text search across all 244 pages
   is one script, not 13 chunked `Read` calls. This caught a second SRD
   error: "Song of Sustenance" (bard) doesn't exist anywhere in the
   printed book at all — it's an SRD-only entry with no real source,
   not a module gap. Also useful for confirming an SRD "Errata" note
   actually describes a pre-errata/post-errata wording change (see Bard
   findings below) rather than something already reflected everywhere.
8. **Number-set diffing narrows manual review fast, but needs two
   corrections before it's trustworthy:** extract all `\d+d\d+`/`+N`/`-N`
   tokens from both sides and flag entries whose sets differ. Two false-
   positive sources to strip first: (a) every attack-roll power's Foundry
   `attack` field contributes a `d20` from the `[[d20 + ...]]` formula
   that the SRD's prose never restates (it's implied by "make an attack
   roll") — exclude bare `d20` from the diff; (b) archmage stores a
   power's text across ~15 possible fields depending on power type
   (`effect`, `hit`/`miss`, `castBroadEffect`, `castPower`,
   `sustainedEffect`, `finalVerse`, `spellLevel2`-`spellLevel11`, etc. —
   see the "Cast for Power" section, this file's Bard entry) — pulling
   only `effect`+`feats` (as the Barbarian pass did) silently produces
   empty text for every spell/battlecry/song-type power. Concatenate
   *every* text field before diffing, not just `effect`.
9. **Name-matching must normalize curly quotes and `&`/`and` before
   comparing**, or apostrophe'd talent names ("Can't Touch This!",
   "You Don't Dance!") false-positive as "missing." Normalize both sides
   with the same regex before set comparison.
10. **Pages are not structurally uniform — don't assume Barbarian/Bard's
    per-entry-Source-tag pattern generalizes.** Cleric's page tags source
    at the *domain-section* level, not per individual spell, and defaults
    untagged sections to DATP (confirmed by the project owner 2026-09-13 —
    the SRD only bothers tagging a domain/spell when its source *isn't*
    DATP, since most of the page is DATP by volume). Check each new class
    page's actual structure before assuming the Barbarian/Bard recipe
    applies as-is.
11. **A page's own compact summary table can be stale relative to its own
    detailed write-ups** — Cleric's top-of-page domain→spell-name table
    still names 3 spells that were renamed in the page's own detailed
    section below (e.g. table says "Water Breathing," the actual write-up
    is titled "Purification (1st Level)"), and omits several spells from
    a domain's count entirely even though they have full write-ups further
    down. Don't conclude the module is missing something on the strength
    of a summary table alone — search the full page text for a
    "<Name> (Nth Level)"-style heading before flagging it as absent.
12. **Cache the parsed result once you've done the work of understanding a
    page's structure** — see "Local SRD cache" above. Don't re-derive the
    same page's structure from scratch in a later session.

**Barbarian — done, clean (2026-09-12).** 21 SRD entries tagged DATP; one
("Primitive Strength") is a confirmed-wrong SRD source tag, leaving 20 —
which is exactly what the module has. Tiers match exactly. No mechanical/
rules differences found in any of the 20 (a couple of trivial Foundry
inline-roll-formula-vs-prose differences that mean the same thing, not
counted as issues). Two talents (Bulwark, Spirit Guardian) are missing an
opening flavor sentence in the module — explicitly not a concern per the
user.

**Bard — done, 3 fixes applied (2026-09-12).** 67 SRD entries tagged DATP;
one ("Song of Sustenance") doesn't exist in the printed PDF at all (SRD-
only content, not a module gap — see method point 7). The other 66 are
all present (module has 69 items: 66 named entries + 3 "(Attack)"
sub-documents that are the paired attack-roll half of Ethereal Dancers/
Manic Cacophony/Wail of the Banshee, not separate SRD entries). Three
real issues found and **fixed in `packs/dark-alleys-bard-features/`**:
- **March of the Emperor** had pre-errata wording. The SRD carries an
  explicit errata note ("Target now limited to one group of mooks, with
  up to one mook per song level + Cha") which its own live talent text
  already reflects; the module's `sustainedEffect` field still said "Each
  nearby group of mooks" with no size cap at all — considerably more
  powerful than the corrected rule. Fixed to match the errata'd wording.
- **Soothing Melody** and **Ready to Rock!** were both missing their
  tier-based scaling (SRD: "×2 at 5th level, ×3 at 8th" on the healing/
  temp-HP bonus). Fixed by appending the scaling as plain-text parenthetical
  to the `effect` field, next to the existing `[[@cha.dmg]]` inline roll —
  **deliberately not** as a computed formula or via the `spellLevelN`
  fields (see next point), since neither was verifiable without a live
  Foundry render and a wrong dynamic formula is worse than a manual note.
- Note on `spellLevelN` fields: archmage's power template supports
  `spellLevel2` through `spellLevel11` for "Nth level spell: X" scaling
  (see `Riding into Battle` in this same pack, which legitimately uses
  `spellLevel3/5/7/9`), but only `spellLevel3/5/7/9` were ever populated
  in this pack's existing data — never `spellLevel8`, which is what
  Soothing Melody/Ready to Rock! would have needed. Unknown whether the
  archmage sheet even renders arbitrary `spellLevelN` keys beyond that
  hardcoded 3/5/7/9 set — untested, hence the plain-text fix instead.
  If picking this back up: test in a live Foundry instance before trusting
  a `spellLevel8` field to display.

**Cleric — paused mid-way, name-level pass clean (2026-09-13).** Two packs
cover cleric content and they turned out to need very different treatment:
- `13-cld-cleric` (labelled "13ClD Cleric Features" in the module's own
  `module.json` — the naming already told the truth): **0 of its 13 items
  are actually DATP-sourced.** All trace to a separate, unrelated
  third-party product abbreviated `13ClD`/`13ClDS`/`13CDS` on the SRD.
  Correctly excluded from the DATP comparison entirely — not a module bug,
  just a different bundled product.
- `dark-alleys-cleric` (164 items) is the real DATP pack. Its "Domain: Any"
  group (5 spells) exactly matches the SRD's 5 DATP-tagged
  all-domains spells. Its ~34 individual thematic domains (~100 spells)
  passed a **name-and-presence** check — every spell name confirmed
  present and correct once the SRD's own stale-summary-table issue (see
  method point 11) is accounted for. **Not yet done:** the deeper
  mechanical (dice/numbers/feat-tier) comparison for those ~100 domain
  spells, the way Barbarian/Bard got checked line-by-line — the user
  paused before that pass. Pick up from `reference/srd-cache/cleric.json`
  rather than re-parsing the page.

## Notes for Claude

- The GitHub repo's `manifest`/`download` URLs still point at a `latest`
  release tag from the old version — **no new GitHub Release has been cut
  yet** for this migration. See `docs/TASKS.md`.
- Don't delete `_backup-nedb-packs/` without asking — that's the rollback
  path if something surfaces later that this session's testing didn't
  catch.
- Record reusable lessons (the ones likely to matter outside this specific
  project, e.g. the foundryvtt-cli embedded-key format) in
  `~/projects/KNOWLEDGE_BASE.md` too, not just here.
