#!/bin/bash
set -euo pipefail

# Pushes main + a release tag to trigger the CI release (build, sign, notarize,
# GitHub release, Homebrew tap). Run this yourself — Claude Code's Carta guard
# blocks pushes to this non-Carta repo.
#
# Usage: ./scripts/push_release.sh [vX.Y.Z]   (defaults to latest local tag)

VERSION="${1:-$(git describe --tags --abbrev=0)}"

if ! git rev-parse "$VERSION" >/dev/null 2>&1; then
    echo "Tag $VERSION does not exist locally. Create it first: git tag $VERSION"
    exit 1
fi

echo "Pushing main + $VERSION..."
git push origin main "$VERSION"
echo "Done. Watch the release: gh run watch"
