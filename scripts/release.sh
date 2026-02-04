#!/bin/bash
set -euo pipefail

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
    echo "Usage: ./scripts/release.sh v2.0.0"
    exit 1
fi

echo "🚀 Releasing Snip $VERSION..."

# Run the build with secrets injected from Doppler
doppler run -- ./scripts/package_app.sh "$VERSION"

echo ""
echo "✅ Release complete!"
echo ""
echo "Next steps:"
echo "  1. Test the DMG: open Snip-${VERSION}-macos.dmg"
echo "  2. Create GitHub release:"
echo "     git tag $VERSION"
echo "     git push origin $VERSION"
echo "     gh release create $VERSION Snip-${VERSION}-macos.dmg --title \"Snip $VERSION\" --generate-notes"
