#!/bin/bash

# Build script for creating a DMG of the Lumin app

set -euo pipefail

echo "Building Lumin app..."

# Build the project using Swift Package Manager
swift build -c release

# Remove existing app bundle if it exists
rm -rf Lumin.app

# Create the application bundle structure
mkdir -p Lumin.app/Contents/MacOS
mkdir -p Lumin.app/Contents/Resources

# Copy the built binary
cp .build/release/Lumin Lumin.app/Contents/MacOS/Lumin

# Copy Info.plist
cp Info.plist Lumin.app/Contents/Info.plist

# Copy the app icon - this is required for the icon to show correctly
cp Resources/AppIcon.icns Lumin.app/Contents/Resources/AppIcon.icns

# Create a minimal PkgInfo file
echo -n "APPL????" > Lumin.app/Contents/PkgInfo

# Sign the app bundle (this will use ad-hoc signing if no certificate is specified)
# For distribution, you would need to specify a Developer ID certificate
codesign -s - --deep --force --options runtime Lumin.app 2>/dev/null || echo "Warning: Codesigning failed"

echo "Creating DMG..."

# Remove existing DMG if it exists
rm -f Lumin.dmg

# Create a temporary directory for the DMG contents
rm -rf dmg-build
mkdir -p dmg-build

# Copy the app to the temporary directory
cp -r Lumin.app dmg-build/

# Create the DMG
hdiutil create -volname "Lumin" -srcfolder dmg-build -ov -format UDZO Lumin.dmg

# Clean up temporary directory
rm -rf dmg-build

echo "DMG created successfully: Lumin.dmg"