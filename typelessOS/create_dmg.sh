#!/bin/bash
set -e

# Configuration
APP_NAME="TypelessOS"
APP_PATH="build/Exported/${APP_NAME}.app"
DIST_DIR="dist"
DMG_ROOT="${DIST_DIR}/dmg_root"
DMG_NAME="${DIST_DIR}/${APP_NAME}.dmg"

# Clean up previous build
rm -rf "${DIST_DIR}"
mkdir -p "${DMG_ROOT}"

# Check if App exists
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: ${APP_PATH} not found. Please build the app first."
    exit 1
fi

echo "Copying app to DMG root..."
cp -R "${APP_PATH}" "${DMG_ROOT}/"

echo "Creating Applications symlink..."
ln -s /Applications "${DMG_ROOT}/Applications"

echo "Creating DMG..."
hdiutil create -volname "${APP_NAME}" -srcfolder "${DMG_ROOT}" -ov -format UDZO "${DMG_NAME}"

echo "Done! DMG created at ${DMG_NAME}"
