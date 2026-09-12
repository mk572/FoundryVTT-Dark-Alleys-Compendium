# Active task queue

Near-term worklist for the Foundry v14 / archmage 1.40.1 migration. Full
background and technical detail live in the project's `../CLAUDE.md` — this
file is just the to-do list. The user has more items in mind not yet
written down here; treat this as a starting point, not the full scope.

## Next up

1. **Cut a real GitHub Release for v0.6.0.** The manifest's `manifest`/
   `download` URLs still point at the old `latest` release tag (from
   v0.5.0) — nothing public has been updated yet. Needs: tag `0.6.0`,
   rebuild the distributable zip (same recipe as
   `dist/dark-alleys-compendium-test.zip` but as a real release asset),
   write release notes (the migration summary in `CLAUDE.md` is a good
   starting point), attach `module.json` + the zip to the release, matching
   the existing `.github` release-asset naming convention already in the
   repo.
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
