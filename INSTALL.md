# Installing the Dark Alleys Compendium

## Requirements

Before installing, make sure you have:

1. **Foundry Virtual Tabletop**, version 13 or later (built and tested
   against version 14).
2. **The `archmage` game system** installed in Foundry, version 1.40.1
   or later. This module adds *content* to that system — it doesn't work
   without it. If you don't have it yet: in Foundry's Setup screen, go to
   **Game Systems → Install System**, search for "13th Age (archmage)",
   and install it.
3. **A World** created using the `archmage` system.

If you're using a hosted service like [The Forge](https://forge-vtt.com/),
the same requirements apply — you just install through Forge's own
interface instead of a local Foundry install (see the Forge note below).

## Quick install

1. Copy this manifest URL:

   ```
   https://github.com/mk572/FoundryVTT-Dark-Alleys-Compendium/releases/download/latest/module.json
   ```

2. In Foundry's **Setup** screen, click the **Add-on Modules** tab, then
   **Install Module**.
3. Paste the URL into the **Manifest URL** field at the top of the
   dialog and click **Install**.
4. Once it finishes, launch your World.
5. In your World, open **Game Settings → Manage Modules**, check the box
   next to **"13th Age Dark Alleys Compendium"**, and click **Save
   Module Settings**. Foundry will reload.

That's it — the compendium packs now appear under the **Compendium**
sidebar tab, grouped under this module's name.

### If you're on The Forge

Forge-hosted worlds work the same way for a manifest-URL install: from
your Forge dashboard, go to **Setup → Add-on Modules → Install Module**
and paste the same manifest URL above. If you'd rather install from a
downloaded `.zip` file instead, use Forge's own **Table Tools → Summon
Import Wizard**, which accepts a module `.zip` directly (grab the
`dark-alleys-compendium.zip` asset from the [latest
release](https://github.com/mk572/FoundryVTT-Dark-Alleys-Compendium/releases/tag/latest)
instead of the manifest URL). Either way, still finish with the "Manage
Modules" step above inside your World.

## Using the compendium

Once enabled, open the **Compendium** tab in Foundry's sidebar. You'll
see one pack per class (e.g. "Barbarian", "Cleric") plus a few "(Summons)"
packs holding creatures some classes can summon. Open a pack, find a
power or talent, and drag it onto a character sheet to add it — just
like any other compendium content in Foundry.

## Troubleshooting

- **The module doesn't show up after installing.** Some hosting
  providers (including Forge) require a server restart before a newly
  installed module appears in Manage Modules. Try restarting your
  Foundry server, then check again.
- **Powers don't show up for a class.** Double check the module is
  *enabled* for your specific World (the "Manage Modules" step above) —
  installing and enabling are two separate steps.
- **Still stuck?** Open an issue on this project's [GitHub
  page](https://github.com/mk572/FoundryVTT-Dark-Alleys-Compendium/issues).

## Support the creators

This compendium is provided free of charge, built from two 13th-Age-compatible
sourcebooks by **Kinoko Games**. If you find it useful, please consider
picking up the original books:

- [**Dark Alleys & Twisted Paths**](https://www.drivethrurpg.com/en/product/295925/dark-alleys-twisted-paths-13th-age-compatible)
  — new talents, spells, powers, and feats for the 15 core 13th Age classes.
- [**Dark Pacts & Ancient Secrets**](https://www.drivethrurpg.com/en/product/219473/dark-pacts-ancient-secrets-13th-age-compatible)
  — six brand-new classes: Abomination, Fateweaver, Psion, Savage,
  Swordmage, and Warlock.
- Browse all of [Kinoko Games' titles on
  DriveThruRPG](https://www.drivethrurpg.com/browse/pub/11929/Kinoko-Games).
