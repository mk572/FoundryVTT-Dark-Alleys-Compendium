# dark-alleys-compendium

Public release repo for the Foundry VTT module `13a-dark-alleys-compendium`
(13th Age 1e expansion *Dark Alleys & Twisted Path*, `archmage` system).
Repo: `mk572/FoundryVTT-Dark-Alleys-Compendium`. **Its only job is publishing
the finished module.** All development (data, scrapers, tagger, docs, task
lists, migration history, SRD comparison) lives in `~/projects/13a-rules-db`.
Don't document dev work here.

## Layout

- `module.json` — manifest. `manifest`/`download` point at the `latest`
  GitHub Release assets; existing installs update from that URL, so it must
  keep resolving.
- `packs/` — compendium packs, LevelDB folder format.
- `assets/icons/` — custom icons that pack entries reference (`custom/<file>`).
- `scripts/setup.js` — module load script (from 13a-rules-db).
- `scripts/build-release-zip.sh` — builds the release zip.
- `scripts/check-version-bump.sh` — CI check, fails if shipped content changed
  without a `module.json` version bump.
- `.github/workflows/main.yml` — on push: version check, zip, GitHub Releases
  for `<version>` and `latest`.
- `README.md`, `INSTALL.md` — user-facing, shipped in the zip.
- `reference/` — tracked archive folders (`legacy-packs-pre-2026/`,
  `13-cld-cleric-needs-owner/`); not shipped.
- Gitignored local-only: `notes/`, `dist/` (test zips), `_backup-nedb-packs/`
  (original NeDB packs, rollback path; don't delete without asking), `docs/`.

## Release rules

- **Sync target, not a place to hand-edit.** Packs, `scripts/setup.js` and
  `assets/icons/` come from `~/projects/13a-rules-db`'s `sync-to-module.mjs`.
  Never hand-commit or push a fix to anything in the release zip (including
  `scripts/build-release-zip.sh` and `.github/workflows/`) without going
  through that script's `--bump`. Forge only updates when the version changes;
  a hand-edit that skipped the bump once left a live world broken. CI's
  `check-version-bump.sh` is a safety net, not permission. Full rule:
  13a-rules-db's `CLAUDE.md`, "Notes for Claude".
- The zip contains `module.json README.md INSTALL.md scripts/ packs/ assets/`
  at its root, no wrapper folder.
- One repo per module. Keep the repo name and the `latest` tag stable.
- Test zip: `zip -r dist/dark-alleys-compendium-test.zip module.json README.md packs assets`.
