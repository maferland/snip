#!/bin/bash
set -euo pipefail

VERSION="${1:-v0.0.0}"
BUILD_DIR=".build/release"
APP_NAME="CleanCopy"
APP_BUNDLE="${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}-macos.dmg"

BUNDLE_ID="com.maferland.CleanCopy"
EXECUTABLE="${BUILD_DIR}/${APP_NAME}"

echo "📦 Packaging ${APP_NAME} ${VERSION}..."

# Build release binary
swift build -c release

# Create app bundle structure
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp "${EXECUTABLE}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Create Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create icns from png if sips is available
if command -v sips &> /dev/null && [ -f "assets/icon.png" ]; then
    ICONSET_DIR="/tmp/${APP_NAME}.iconset"
    rm -rf "${ICONSET_DIR}"
    mkdir -p "${ICONSET_DIR}"
    
    sips -z 16 16     assets/icon.png --out "${ICONSET_DIR}/icon_16x16.png" 2>/dev/null
    sips -z 32 32     assets/icon.png --out "${ICONSET_DIR}/icon_16x16@2x.png" 2>/dev/null
    sips -z 32 32     assets/icon.png --out "${ICONSET_DIR}/icon_32x32.png" 2>/dev/null
    sips -z 64 64     assets/icon.png --out "${ICONSET_DIR}/icon_32x32@2x.png" 2>/dev/null
    sips -z 128 128   assets/icon.png --out "${ICONSET_DIR}/icon_128x128.png" 2>/dev/null
    sips -z 256 256   assets/icon.png --out "${ICONSET_DIR}/icon_128x128@2x.png" 2>/dev/null
    sips -z 256 256   assets/icon.png --out "${ICONSET_DIR}/icon_256x256.png" 2>/dev/null
    sips -z 512 512   assets/icon.png --out "${ICONSET_DIR}/icon_256x256@2x.png" 2>/dev/null
    sips -z 512 512   assets/icon.png --out "${ICONSET_DIR}/icon_512x512.png" 2>/dev/null
    sips -z 1024 1024 assets/icon.png --out "${ICONSET_DIR}/icon_512x512@2x.png" 2>/dev/null
    
    iconutil -c icns "${ICONSET_DIR}" -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns" 2>/dev/null || true
    rm -rf "${ICONSET_DIR}"
fi

echo "✅ Created ${APP_BUNDLE}"

# Create DMG
echo "💿 Creating DMG..."
rm -rf /tmp/CleanCopy-dmg
mkdir -p /tmp/CleanCopy-dmg
cp -R "${APP_BUNDLE}" /tmp/CleanCopy-dmg/
ln -s /Applications /tmp/CleanCopy-dmg/Applications

hdiutil create -volname "CleanCopy ${VERSION}" \
    -srcfolder /tmp/CleanCopy-dmg \
    -ov -format UDZO \
    "${DMG_NAME}"

rm -rf /tmp/CleanCopy-dmg

echo "✅ Created ${DMG_NAME}"
