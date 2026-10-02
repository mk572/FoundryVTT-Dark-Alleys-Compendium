# Legacy pre-2026 packs (reference only, not shipped)

These are the 9 original compendium packs that shipped in this module
before `13a-rules-db` existed (the module's first GitHub release dates to
2020). Each one duplicated a class that `13a-rules-db`'s newer export
pipeline now generates under an unprefixed pack name (`dark-alleys-cleric`
→ `cleric`, `dark-alleys-barbarian` → `barbarian`, etc.) — both versions
ended up listed in `module.json` at once, which is how they were found:
the old copies still carried a broken `system.feats` schema (pre-dating a
fix made in `13a-rules-db` commit `b736f61`, 2026-09-13) that threw a
console error when their item sheets rendered in Foundry. See
`docs/TASKS.md` for the full writeup.

**Removed from `module.json` and `packs/` on 2026-09-14** — extracted here
as plain JSON (via `@foundryvtt/foundryvtt-cli`'s `extractPack`, one file
per Item) purely as reference material, not as something Foundry loads.
Kept because `dark-alleys-cleric` in particular went through a real,
documented SRD-comparison-and-fix pass in an earlier session (see this
project's own `CLAUDE.md`, "SRD content comparison") — that verification
work has value even though the pack itself is retired, especially since
the new `cleric` pack's content looks structured completely differently
(grouped by domain rather than a flat spell list) and has NOT yet been
confirmed to have full coverage. See the Cleric follow-up task in
`docs/TASKS.md` before treating `dark-alleys-cleric` as safe to delete
outright.

Do not reintroduce these into `module.json`/`packs/` without re-running
them through `13a-rules-db`'s current export pipeline first — the shape
here is stale.
