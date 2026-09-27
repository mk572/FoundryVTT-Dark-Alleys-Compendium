#!/usr/bin/env bash
# Fails CI when shipped release content (module.json, README.md, INSTALL.md, scripts/,
# packs/, assets/ -- the exact list build-release-zip.sh zips) changed since the commit
# that was tagged with the CURRENT module.json version, without that version being bumped.
# Run from the repo root, with full tag history available (checkout must use fetch-depth: 0).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/check-version-bump.sh

Checks that module.json's "version" was bumped if any shipped release content
changed since the last commit tagged with that version. Exits 2 on an unknown
option, before doing any work.

Exit codes:
  0  no problem (version not yet tagged, tagged commit is HEAD, or no shipped
     content changed since that tag)
  1  shipped content changed since the tagged commit but the version wasn't bumped
  2  usage error (bad option)
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    *) echo "check-version-bump.sh: unknown option '$arg'" >&2; usage >&2; exit 2 ;;
  esac
done

SHIPPED_PATHS=(module.json README.md INSTALL.md scripts packs assets)

VERSION=$(node -e "process.stdout.write(require('./module.json').version)")

if ! git rev-parse -q --verify "refs/tags/${VERSION}" >/dev/null; then
  echo "check-version-bump: ${VERSION} isn't tagged yet -- nothing to compare, OK."
  exit 0
fi

TAGGED_COMMIT=$(git rev-list -n 1 "refs/tags/${VERSION}")
HEAD_COMMIT=$(git rev-parse HEAD)

if [ "$TAGGED_COMMIT" = "$HEAD_COMMIT" ]; then
  echo "check-version-bump: HEAD is the commit already tagged ${VERSION}, OK."
  exit 0
fi

if git diff --quiet "$TAGGED_COMMIT" "$HEAD_COMMIT" -- "${SHIPPED_PATHS[@]}"; then
  echo "check-version-bump: no shipped content changed since ${VERSION} was tagged, OK."
  exit 0
fi

echo "check-version-bump: shipped content (module.json/README/INSTALL/scripts/packs/assets)" >&2
echo "changed since ${TAGGED_COMMIT:0:7} (tagged ${VERSION}), but module.json still says ${VERSION}." >&2
echo "Bump the version before pushing -- from 13a-rules-db: node scripts/sync-to-module.mjs" >&2
echo "--module dark-alleys-compendium --bump patch --commit --push (or bump module.json by hand" >&2
echo "if this change didn't come from a sync)." >&2
exit 1
