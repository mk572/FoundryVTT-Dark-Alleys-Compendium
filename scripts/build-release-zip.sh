#!/usr/bin/env bash
# Builds dark-alleys-compendium.zip for a GitHub release. Run from the repo root.
# Kept as a plain script (not inlined in .github/workflows/main.yml) so that
# changing what's bundled in a release never requires a .github/workflows/*
# edit, which needs the `workflow` OAuth scope to push.
set -euo pipefail

zip -r ./dark-alleys-compendium.zip module.json README.md INSTALL.md scripts/ packs/
