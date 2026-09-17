# Driving Foundry VTT / Forge via Safari MCP

How to remote-control the project owner's real Foundry VTT instance
(Forge-hosted) from a Claude Code session, for live verification of this
module (or `13a-rules-db`'s exports) — login, joining a world, updating
an installed module, installing a fresh test build, and the specific
automation gotchas hit doing this. This is the "how", not the "what to
test" — for an actual test procedure/checklist see `13a-rules-db`'s
`docs/FOUNDRY-TEST-PLAN.md`.

**Never commit a Foundry world/user password to this file or anywhere in
this repo — it's public.** Ask the project owner for the current
Gamemaster password fresh each session; it's never stored in project
files.

## 0. Prerequisites

- The `safari` MCP server (global, not project-scoped — see
  `~/projects/KNOWLEDGE_BASE.md`'s 2026-09-12 entry for the install
  recipe if its tools aren't showing up in a session).
- The project owner has a Forge (forge-vtt.com) instance at
  `https://mk333.as.forge-vtt.com`, with a persistent logged-in Forge
  session in the user's real Safari — navigating straight to that URL
  lands on the Setup screen already authenticated at the Forge level.
  Only the in-world Gamemaster login needs a password, asked fresh each
  session.

## 1. Safari MCP quirks specific to this kind of session

- **Always call `safari_new_tab` first** rather than driving the user's
  already-open tab. Several tools (`safari_resize` at least) refuse to
  act on a tab this MCP session doesn't own ("tab safety" error), and a
  fresh tab is one less thing to accidentally disrupt for the user.
- **`safari_screenshot` reliably renders solid black** for MCP-owned tabs
  in this environment (confirmed 2026-09-17, both a fresh tab and the
  original session tab) — this looks like a window-focus/compositing
  quirk of the automation bridge, not a real page problem. Don't spend
  time troubleshooting it. **Use `safari_read_page`, `safari_snapshot`,
  and `safari_evaluate` instead of screenshots** to verify Foundry state
  — they work correctly regardless.
- **`safari_click` frequently reports "native fallback — synthetic click
  had no effect"** on Foundry's own UI (world-launch buttons, compendium
  entries, dialog menu items) and doesn't actually fire the app's
  delegated event handlers. The reliable fallback:
  `safari_evaluate` with a script that does
  `document.querySelector('<precise selector>').click()` directly. This
  worked consistently for launching a world, opening a compendium item,
  submitting the join form, and clicking Main Menu items.
- **`safari_navigate` can silently fail** ("Safari 'set URL' had no
  effect") on a background/non-frontmost tab. If it does, drive the
  navigation via `safari_evaluate` (`window.location.href = ...`) or
  through in-app UI clicks instead — both work even when `safari_navigate`
  doesn't.
- Foundry's setup screen shows a hard warning below 1024×768 window
  size ("requires a usable window dimensions of 1024px by 768px or
  greater") — cosmetic only in practice (snapshot/evaluate-driven
  interaction still works fine underneath it), not worth fighting via
  `safari_resize` unless a screenshot is specifically needed.
- After any DOM click/submit that triggers a page transition, **don't
  trust an immediate `safari_read_page`/`safari_snapshot`** — it can come
  back empty mid-navigation. Use `safari_wait_for` on distinctive text
  from the destination page, and if that also times out, just retry the
  read after a beat before concluding something's actually broken.

## 2. Logging in and joining a world

1. `safari_new_tab` → `https://mk333.as.forge-vtt.com`. Lands on Foundry's
   Setup screen (`/setup`), already Forge-authenticated.
2. The world list (`safari_read_page`) shows the current worlds — see
   [[forge-test-worlds-by-edition]] for which one to use. As of
   2026-09-17: **"Dark Alleys Test"** (1e content) and **"13th Age 2E
   Test"** (2e content, once that work starts).
3. Launch a world via JS, not `safari_click` (see quirks above):
   ```js
   document.querySelector('li[data-package-id="<world-id>"] a[data-action="worldLaunch"]').click()
   ```
   (`data-package-id` is the world's slug, e.g. `dark-alleys-test`.)
4. `safari_wait_for` text `"Loading"`, then land on `/join`. Select
   Gamemaster and submit via JS (there's normally only one user, but
   confirm the `<option>` value first rather than assuming):
   ```js
   document.querySelector('select[name="userid"]').value = '<the gm option value>';
   document.querySelector('input[name="password"]').value = '<password, asked fresh, never stored>';
   document.querySelector('#join-game-form button[type=submit]').click();
   ```
5. Confirm arrival with `safari_wait_for` on `"Gamemaster"` or by reading
   the page — a wrong password shows `"Invalid password provided for
   Gamemaster!"` right on `/join`, still worth checking for explicitly
   rather than assuming success.

### Returning to Setup from inside a world

Don't navigate the URL directly — use Foundry's own Main Menu, which is
the officially supported "leave without disconnecting weirdly" path:
```js
document.querySelector('button[data-action="menu"]').click();
// then, once the dialog is open:
[...document.querySelectorAll('h2')]
  .find(h => h.textContent.includes('Return to Setup'))
  .closest('li').click();
```

## 3. Updating an already-installed module

**Two different update paths exist, and they behave very differently —
confirmed 2026-09-17:**

- **Setup → Add-on Modules → the per-module "Perform Update If
  Available" control** (`a[data-action="updatePackage"]`, the rotate-arrow
  icon next to a module's name) — pulls from the module's own manifest
  URL (this project's is the GitHub `latest`-tag release). **Worked
  cleanly and immediately** going from 0.6.7 → 0.6.8, no server
  restart needed, no quirks. **Prefer this path.**
  ```js
  document.querySelector('li[data-package-id="13a-dark-alleys-compendium"] a.package-update').click();
  ```
- **Forge's local-zip Import Wizard** (Table Tools → Summon Import
  Wizard → ZIP File) — has a known dedupe/no-op bug: if the uploaded
  `module.json`'s version string matches what's already installed
  server-side, Forge silently no-ops even when the zip's actual content
  differs (confirmed: byte-identical result across two uploads with
  different pack content, survived a full Stop/Start server cycle).
  **Don't rely on this path for iterating on an already-installed
  module at the same version number** — either bump the version first
  (see [[dark-alleys-compendium-version-bumps]]) or do a full
  uninstall + reinstall-from-manifest-URL instead of re-uploading a zip.

After a fresh **install** (not update) via the Import Wizard specifically,
the module does **not** appear in Module Management until a **Stop then
Start of the Forge server itself** (Games Configuration page) —
documented by Forge, easy to miss, and distinct from the update-path
quirk above.

Installing a module on the server and **enabling it for a specific
world** are two separate steps (Setup → Add-on Modules installs it
server-wide; in-world Settings → Manage Modules enables it per-world).
In one earlier session the in-world Manage Modules checkbox+Save did
**not** persist (confirmed via `game.modules.get(id).active` staying
`false` after save+reload) — the forced workaround was the console:
```js
game.settings.set('core', 'moduleConfiguration', {...currentConfig, '<module-id>': true});
// then reload
```
Not confirmed whether this recurs on a fresh session — worth just trying
the normal checkbox+Save first and only falling back to this if it
doesn't stick.

## 4. Installing a new/test module (Import Wizard)

Forge-specific — there's no local filesystem access to a Forge-hosted
world's data directory, so getting a local build onto one needs either
this or Forge's own file browser/API:

1. Build a zip of the module (`module.json` + packs + any assets).
2. Setup page → Table Tools → **Summon Import Wizard** → ZIP File.
3. **Use the `#iw-file` input specifically** — the page's generic first
   `input[type="file"]` is the Server **Banner image** upload, and it
   silently accepts the wrong file with no error if you target the
   wrong one.
4. Full Stop/Start server cycle if the module doesn't show up in Module
   Management afterward (see gotcha above).

## 5. Verifying compendium content live (via console)

Cheaper and more reliable than clicking through the UI. Get every pack's
entry count for a module in one call:
```js
async function run() {
  const packs = game.packs.filter(p => p.metadata.packageName === '<module-id>');
  const results = [];
  for (const p of packs) {
    const idx = await p.getIndex({force: true}); // force: true to bypass a stale cached index after an update
    results.push({id: p.metadata.name, count: idx.size});
  }
  return JSON.stringify(results);
}
run()
```
Compare against `data/1e/classes/*.yaml` entry counts in `13a-rules-db`
(`node -e` with `js-yaml`) to catch anything not making it through the
export/install pipeline — this is exactly how the 2026-09-17 session
caught a stale-install gap (see [[dark-alleys-compendium-version-bumps]]
and `13a-rules-db`'s `docs/TASKS.md` T001).

Check for load-time errors/warnings without a console-capture dance:
```js
JSON.stringify({
  packageWarnings: Object.keys(game.issues?.packageWarnings || {}),
  packageErrors: Object.keys(game.issues?.packageErrors || {}),
  usabilityIssues: Object.keys(game.issues?.usabilityIssues || {}),
  moduleVersion: game.modules.get('<module-id>')?.version,
  moduleActive: game.modules.get('<module-id>')?.active,
})
```

For opening/reading a single item sheet (e.g. to confirm mechanical text
rendered correctly), find its `data-entry-id` from the directory listing
first, then:
```js
document.querySelector('li[data-entry-id="<id>"] a.entry-name').click();
```
then `safari_read_page` targeting the resulting `.application.sheet`
element's id (printed by querying `document.querySelectorAll('.application')`
for one whose text includes the item's name).

## 6. Test fixtures convention

- **Test actors**: one persistent actor per class, named `Claude Test
  <Class>` in the "Dark Alleys Test" world — reuse across sessions,
  don't create throwaways. See [[forge-test-actors-per-class]].
- **Test worlds by edition**: see [[forge-test-worlds-by-edition]].

## 7. Inspecting the raw LevelDB packs locally (without Foundry)

`packs/<name>/` in this repo is a real LevelDB directory, not flat JSON —
readable via `@foundryvtt/foundryvtt-cli`:
```sh
npx -y @foundryvtt/foundryvtt-cli package unpack <pack-name> \
  --type Module --id 13a-dark-alleys-compendium \
  --in packs --out <some-scratch-dir>
```
**Caution**: this CLI opens the LevelDB read-write and touches its
internal bookkeeping files (`CURRENT`, `LOG`, `LOG.old`, `MANIFEST-*`)
even for a read-only unpack — `git status` afterward and
`git checkout -- packs/<name>/{CURRENT,LOG,LOG.old,MANIFEST-*}` plus
removing any stray untracked `MANIFEST-*`/nested directory it left
behind, before committing anything else. Don't run this against a pack
you haven't already committed cleanly, to keep the diff obviously
inert.

## 8. Known Foundry-core behavior (not this module's bug)

- Legacy Token schema fields on Actors (`dimSight`/`brightSight`/
  `lightAngle`/etc., from pre-v10 Foundry) are auto-migrated by Foundry
  core into the modern `sight`/`light`/`texture` structure at load time
  — confirmed via `doc.prototypeToken.sight` etc. on a loaded document.
  No manual conversion needed for old token data.
