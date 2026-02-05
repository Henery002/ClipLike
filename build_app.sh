#!/bin/bash

set -e

# Configuration
SCHEME="ClipLike"
PROJECT="ClipLike.xcodeproj"
BUILD_DIR="./build"
ARCHIVE_PATH="${BUILD_DIR}/${SCHEME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/Exported"
EXPORT_PLIST="${BUILD_DIR}/ExportOptions.plist"
TEAM_ID="3243Z9Y3P8" # Auto-detected from project.pbxproj

# Clean previous build
echo "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 1. Archive
echo "Archiving project..."
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -quiet || { echo "Archive failed"; exit 1; }

echo "Archive successful."

# 2. Create ExportOptions.plist
echo "Creating ExportOptions.plist..."
cat <<EOF > "$EXPORT_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF

# 3. Export Archive
echo "Exporting .app..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  -allowProvisioningUpdates \
  -quiet || { echo "Export failed"; exit 1; }

# Get Version for Zip naming
VERSION=$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showBuildSettings | grep "MARKETING_VERSION =" | head -n 1 | sed 's/.*= //')
ZIP_NAME="${SCHEME}_v${VERSION}.zip"
ZIP_PATH="${EXPORT_PATH}/${ZIP_NAME}"

echo "Compressing to ${ZIP_NAME}..."
cd "$EXPORT_PATH"
zip -r "$ZIP_NAME" "${SCHEME}.app" > /dev/null
cd - > /dev/null

echo "------------------------------------------------"
echo "Build complete!"
echo "App location: ${EXPORT_PATH}/${SCHEME}.app"
echo "Zip package:  ${ZIP_PATH}"
echo "------------------------------------------------"
echo "Opening export directory..."
open "$EXPORT_PATH"
