# Active task queue

Near-term worklist for the Foundry v14 / archmage 1.40.1 migration. Full
background and technical detail live in the project's `../CLAUDE.md` — this
file is just the to-do list. The user has more items in mind not yet
written down here; treat this as a starting point, not the full scope.

## Ranger's Arcane Archer fixed; power-usage-line detection improved (2026-09-14)

Refreshes `packs/ranger` from `13a-rules-db` (commit `8fd08ad`, bump to
0.6.7). The project owner fixed the live SRD page (Arcane Archer's
powers were missing their "Close-quarters power" usage-line entries);
re-scraping surfaced that the type detector added earlier the same day
only ever checked usageLine for "spell"/"Flexible", never "power" — same
convention, different real archmage powerType value. Fixed and merged:
24 entries retyped talent → power, 7 more confirmed-phantom "X Sphere"
divider entries removed. Full detail in `13a-rules-db/docs/TASKS.md`.
**Same usage-line convention confirmed present in Psion (~90 entries,
its whole kit) and smaller counts in Rogue/Savage/Monk/Paladin — not
yet re-scraped/merged for any of them**, flagged there for a dedicated
follow-up pass rather than done unprompted.

## Druid Problems 1 & 7 fixed — real power types, not all "talent" (2026-09-14)

Refreshes `packs/dark-alleys-druid` from `13a-rules-db` (commit `911e2e4`,
bump to 0.6.5). The scraper's assumption that spells/powers always sit at
h4 (and that an entry's type comes purely from the nearest divider
heading) was directly why almost every Druid circle entry exported as
`talent` regardless of what it actually was. Fixed at the source; type
distribution went from ~277 entries nearly all `talent` to a realistic
190 spell / 46 feature / 27 power / 14 flexible / 5 talent split, matching
the project owner's own predictions per circle exactly (War → flexible,
Moon → power/Aspects, Life/Land → spell). Full mechanism writeup in
`13a-rules-db/docs/TASKS.md`'s "Dark Alleys Druid clean-up" Problems 1
and 7. Still outstanding on this class: Problems 3 and 4 (13TW content
cloning, animal companion investigation) and the Import Powers dialog
grouping limitation noted under Problem 2.

## Dark Alleys Druid clean-up in progress (2026-09-14) — full writeup in 13a-rules-db

Project owner reported the Dark Alleys Druid as "a total mess" — 5
problems (full list + status in `13a-rules-db/docs/TASKS.md`'s "Dark
Alleys Druid clean-up" entry). First fix landed here: refreshed
`packs/dark-alleys-druid` and `packs/ranger`/`packs/paladin`/
`packs/occultist`/`packs/fighter`/`packs/barbarian`-adjacent... wait, only
`dark-alleys-druid` actually changed content this round (the tier-divider
scraper fix touched ranger/paladin/occultist/fighter/barbarian too, but
those packs weren't refreshed here yet — see next task). This refresh:
every entry now has its `group` set to its own Circle's display name
("Circle of the Fang", etc.) via a new `circle`-aware grouping rule in
`export-to-foundry.mjs`, so Import Powers' "Group by: Custom Groups" view
sorts the ~280 entries by circle instead of one flat list. Bumped to
0.6.4. Still outstanding: entry types (everything currently exports as
`talent` regardless of circle), 13TW base content cloning, and the
animal companion investigation — see 13a-rules-db's TASKS.md.

## Tier-divider scraper fix — now shipped (2026-09-14)

`13a-rules-db` commit `2abd64b` fixed a scraper bug affecting Ranger,
Barbarian, Paladin, Occultist and Fighter (Champion/Epic tier talents
were either phantom-scraped as fake entries or silently stuck at level 1
instead of their real 5/8 — see that repo's TASKS.md for full detail).
Deliberately deferred copying it into this module's `packs/` at the time
— **that turned out to be the wrong call**: the project owner found
Ranger's Champion/Epic talents still at level 1 in the published `0.6.5`
release, since the fix genuinely never shipped. Refreshed all 5 packs at
once this round rather than wait for the other 4 to be reported
separately — verified level distributions match the source exactly
(Barbarian 5/8, Paladin 5/8, Occultist 5/8, Fighter 5/6/8 — Fighter's own
Champion tier is 6, not 5 — Ranger 5/8). Bumped to `0.6.6`.

## Cleric Invocations added, 35 new items (2026-09-14) — full writeup in 13a-rules-db

Refreshed `packs/cleric` again from `13a-rules-db` commit `46ed1ee`
(version bump to 0.6.3) — adds 35 "Invocation of X" talent entries, one
per domain, matching how base archmage's own Cleric class already works
(a domain and its invocation are two separate selectable items). Full
detail in `13a-rules-db/docs/TASKS.md`'s "Cleric Issue 6" entry.

## Cleric fixes from a live review (2026-09-14) — full writeup in 13a-rules-db

Refreshed `packs/cleric`, `packs/cleric-summons`, `packs/chaos-mage`,
`packs/dark-alleys-druid`, `packs/ranger` and `scripts/setup.js` from
`13a-rules-db` (commit `88ef328`) to ship 5 fixes from a live Cleric
review: DATP domains now show up as selectable talents (were missing a
`level`, invisible in Import Powers), redundant "(Nth Level)" stripped
from 123 Cleric names (+178 across the other 3 refreshed classes), 3
wrong `level` values corrected, and the scraper itself
(`scripts/scrape_srd_by_headings.py` in 13a-rules-db) fixed so this
class of bug doesn't recur. Full detail, including the still-open
domain-gated-spell-visibility design question (Cleric spells should only
be selectable once the matching domain is chosen — data model already
supports it via `granted_spells`, nothing consumes it yet) and the
still-no-images task, is in `13a-rules-db/docs/TASKS.md`'s "Cleric
review" entry — don't duplicate it here, this is a pointer.

## Removed 10 legacy pre-2026 packs from the live module (2026-09-14)

A reviewer reported "the power importer opens [powers], the sheet does
not" — reproduced live in Forge as a swallowed JS `TypeError` on
`system.feats[i].tier.value` when an item sheet rendered. Root cause:
`module.json` was listing **two separate compendium packs for the same
class** on 9 of the DATP extension classes — an original pre-2026 pack
(`dark-alleys-cleric`, `dark-alleys-barbarian`, `dark-alleys-wizard-spells`,
`dark-alleys-sorcerer-spells`, `dark-alleys-bard-features`,
`dark-alleys-fighter`, `dark-alleys-necromancer-spells`,
`dark-alleys-occultist-spells`, `dark-alleys-cleric-summons`, all dating
to the module's original 2020 release) alongside a newer unprefixed one
generated by `13a-rules-db`'s export pipeline (`cleric`, `barbarian`,
`wizard`, etc.). The old packs still carried a `feats` schema from before
a fix made in `13a-rules-db` (commit `b736f61`, 2026-09-13) — every item
in them with real Champion/Epic feat text hit the broken shape, 602 items
total across the 9 packs (confirmed via a full scan; live/current packs
scanned clean — 0 broken items).

**Fix**: removed all 10 pre-2026 packs (the 9 duplicates plus
`13-cld-cleric`, a genuinely unrelated third-party product that was never
actually part of Dark Alleys) from `module.json` and `packs/`. Archived
as plain JSON (not shipped, not loaded by Foundry):
- `reference/legacy-packs-pre-2026/` — the 9 superseded duplicates, kept
  because `dark-alleys-cleric` went through a real documented SRD-fix pass
  (see `../CLAUDE.md`) whose value outlives the retired pack itself.
- `reference/13-cld-cleric-needs-owner/` — kept separately pending the
  project owner finding this content's actual owner (not archived as a
  general reference; explicitly not this project's content to redistribute
  even privately long-term).

**Not yet done — needs verification before either archive is truly
"safe to forget":**
- **Cleric coverage gap.** The new `cleric` pack (166 items) and old
  `dark-alleys-cleric` (164 items) share almost no item names (159 of 164
  old names not found in the new pack) — the new one looks structured
  completely differently (grouped by domain rather than a flat spell
  list). Not yet confirmed whether the new pack's domain-grouped content
  actually has full mechanical coverage of what the old, SRD-verified
  pack had. Compare against `reference/legacy-packs-pre-2026/dark-alleys-cleric/`
  before treating Cleric as fully migrated.
- The other 8 pairs (barbarian, bard, fighter, necromancer, occultist,
  sorcerer, wizard, cleric-summons) were spot-checked by name only — the
  new pack is a near-complete superset (0-1 name mismatches each, likely
  typos) — not a line-by-line mechanical re-verification the way Cleric
  still needs.

## Next up

1. ~~Cut a real GitHub Release for v0.6.0~~ **Done long ago** — this note
   was stale as of the 2026-09-14 wrap-up pass. The module has been on a
   real, working CI-published release pipeline for a while now (currently
   `0.6.5`; every version bump documented in the sections above and in
   `13a-rules-db/docs/TASKS.md` auto-publishes via `.github/workflows/
   main.yml` → `scripts/build-release-zip.sh`). Left struck through
   rather than deleted so a future stale-doc sweep can see this was
   checked, not just silently dropped.
2. **Decide the fate of `_backup-nedb-packs/`.** Currently kept locally
   (gitignored) as a safety net per explicit request. Revisit once the
   v0.6.0 release has been out and unproblematic for a while.
3. **Retest the "Manage Modules Save doesn't persist" quirk** on a fresh
   session (new world load, no prior reload cycle) to confirm whether it's
   a real Forge/Foundry bug worth reporting upstream, or was an artifact of
   this session's specific state. See `CLAUDE.md` "Foundry/Forge
   operational gotchas."
4. **Player-side testing.** Only the GM view was verified this session
   (via the Foundry API directly + sheet rendering). Never tested from a
   Player-permission account — worth a pass before calling this fully
   done, especially ownership/permission levels on the migrated docs.

## SRD content comparison (in progress, started 2026-09-12)

Compare each pack's rules text against the public 13th Age SRD to catch
missing entries or rules errata. Method is written up in `../CLAUDE.md`
("SRD content comparison"). **Flavor text is out of scope** — only
mechanical differences count as findings. The user supplies the SRD source
URL for each pack as we get to it. Parsed page structure for each class
already checked is cached at `../reference/srd-cache/<class>.json` — read
that before re-fetching/re-parsing a page.

- [x] **`dark-alleys-barbarian`** (talents) — checked against
      `13thagesrd.com/classes/barbarian/barbarian-talents-3pp/`. Clean: all
      20 DATP-sourced talents present, tiers correct, no rules differences.
      One apparent gap ("Primitive Strength") turned out to be a wrong
      source tag on the SRD itself, not a module omission.
- [x] **`dark-alleys-bard-features`** (talents/battlecries/songs/spells) —
      checked against `13thagesrd.com/classes/bard/bard-talents-battlecries-songs-and-spells-3pp/`,
      cross-checked against the printed PDF where the SRD looked off. 66/66
      real DATP entries present ("Song of Sustenance" is SRD-only content,
      confirmed absent from the printed book too — not a module gap).
      **3 real issues found and fixed**: March of the Emperor had
      pre-errata wording (no mook-count cap); Soothing Melody and Ready to
      Rock! were both missing their ×2-at-5th/×3-at-8th tier scaling. All
      three fixed directly in the pack — see `../CLAUDE.md` "Bard" for the
      exact wording used and why a computed formula was deliberately
      avoided for the scaling fix.
- [x] **`13-cld-cleric`** — checked against `13thagesrd.com/classes/cleric/cleric-domains-and-spells-3pp/`.
      Confirmed **not actually DATP content** (all 13 items trace to a
      separate "13ClD"/"13CDS" product) — correctly excluded, nothing to
      compare. See `../CLAUDE.md` "Cleric".
- [~] **`dark-alleys-cleric`** — same source as above. **Paused mid-way
      2026-09-13** (name-level pass done and clean; full mechanical
      dice/numbers comparison across its ~100 domain spells not started).
      Cached parse at `../reference/srd-cache/cleric.json`. Resume from
      there, not from scratch.
- [ ] `dark-alleys-fighter` — source: `13thagesrd.com/classes/fighter/fighter-talents-and-maneuvers-3pp/`
- [ ] `dark-alleys-occultist-spells` — source: `13thagesrd.com/classes/occultist/occultist-talents-and-spells-3pp/`
- [ ] `dark-alleys-wizard-spells` — source: `13thagesrd.com/classes/wizard/wizard-schools-talents-and-spells-3pp/`
- [ ] `dark-alleys-sorcerer-spells` — source: `13thagesrd.com/classes/sorcerer/sorcerer-bloodlines-talents-and-spells-3pp/`
- [ ] `dark-alleys-necromancer-spells` — source: `13thagesrd.com/classes/necromancer/necromancer-talents-and-spells-3pp/`
- [ ] `dark-alleys-cleric-summons` (Actor pack — likely needs a different
      kind of SRD source than a talent-list page, e.g. a monster/summon
      entry; confirm with the user what the reference source is when we
      get here)
- (explicitly deferred by the user) **Druid** — "more complex," skip for
  now. Source URL received 2026-09-13 for whenever we do pick it up:
  `13thagesrd.com/classes/druid/druid-circles-revised-druid-3pp/`

### Phase 2 — net-new content, not comparison (do after Phase 1 above)

**Chaos Mage, Commander, Monk, Paladin, Ranger, Rogue.** Clarified
2026-09-13: this isn't a wrong-project mixup — DATP-tagged content for
these six classes exists on the SRD but **was never digitized into any
Foundry module at all**, Dark Alleys Compendium or otherwise. So this
phase is *conversion work* (build new Foundry compendium entries from the
SRD text), not a diff against existing module content. Source URLs:
- Chaos Mage: `13thagesrd.com/classes/chaos-mage/chaos-mage-talents-and-spells-3pp/`
- Commander: `13thagesrd.com/classes/commander/commander-talents-commands-and-tactics-3pp/`
- Monk: `13thagesrd.com/classes/monk/monk-talents-and-forms-3pp/`
- Paladin: `13thagesrd.com/classes/paladin/paladin-talents-3pp/`
- Ranger: `13thagesrd.com/classes/ranger/ranger-talents-3pp/`
- Rogue: `13thagesrd.com/classes/rogue/rogue-talents-and-powers-3pp/`

Open question for when we get here: which module this new content should
actually ship in — a new pack added to Dark Alleys Compendium itself
(same source book, so it'd fit thematically), or somewhere else entirely.
Ask the user before creating anything; don't assume.

## Blocked / waiting on external input

- **DPAS ("Dark Pacts 13th Age 2e") author reply.** The user is waiting to
  hear back from hairyscotsman about what exactly they did in that
  (separate, unrelated) module — this was the reason `notes/
  abomination-dump.md` exists. Not blocking the Dark Alleys release; keep
  separate.
- **1e vs 2e classification for DPAS content** — parked on the above reply.
  Not a Dark Alleys Compendium task at all; tracked here only because it
  came up in the same session. Consider moving to its own project/notes
  location if it turns into real work.

## To be filled in

The user mentioned there are more tasks in mind not yet described in this
session — add them here as they come up rather than guessing at scope.
