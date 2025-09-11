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

echo "Creating polished DMG..."

# Remove existing DMGs if they exist
rm -f Lumin.dmg Lumin-temp.dmg

# Create a temporary directory for the DMG contents
rm -rf dmg-build
mkdir -p dmg-build

# Copy the app to the temporary directory
cp -r Lumin.app dmg-build/

# Add Applications symlink for drag-and-drop install
ln -sf /Applications dmg-build/Applications

# Optional background image for clear instruction (place your PNG at Resources/dmg-background.png)
BG_SRC="Resources/dmg-background.png"
mkdir -p dmg-build/.background
if [ -f "$BG_SRC" ]; then
  cp "$BG_SRC" dmg-build/.background/bg.png
fi

# Create a temporary read/write DMG so we can customize Finder layout
hdiutil create -volname "Lumin" -srcfolder dmg-build -ov -format UDRW Lumin-temp.dmg

# Attach, customize layout with Finder, then detach and convert to compressed DMG
MOUNT_POINT="$(/usr/bin/hdiutil attach -readwrite -noverify -noautoopen Lumin-temp.dmg | awk '/Volumes/ {print $3; exit}')"

# Give Finder a moment to register the volume
sleep 2

# Ensure .background is hidden if present
if [ -d "$MOUNT_POINT/.background" ]; then
  /usr/bin/chflags hidden "$MOUNT_POINT/.background" || true
fi

# Use AppleScript to set window size, icon view, background, and icon positions
/usr/bin/osascript <<'APPLESCRIPT'
tell application "Finder"
  set theDisk to disk "Lumin"
  open theDisk
  set current view of container window of theDisk to icon view
  set toolbar visible of container window of theDisk to false
  set statusbar visible of container window of theDisk to false
  set bounds of container window of theDisk to {200, 200, 900, 600}

  set theViewOptions to the icon view options of container window of theDisk
  set arrangement of theViewOptions to not arranged
  set icon size of theViewOptions to 128

  try
    set background picture of theViewOptions to file ".background:bg.png"
  end try

  -- Position icons to visually suggest dragging
  try
    set position of item "Lumin.app" of theDisk to {180, 260}
  end try
  try
    set position of item "Applications" of theDisk to {560, 260}
  end try

  delay 1
  update theDisk without registering applications
  delay 1
  close container window of theDisk
  delay 1
  open theDisk
  delay 1
  -- leave window open for saved state
end tell
APPLESCRIPT

# Detach and convert to final compressed DMG
/usr/bin/hdiutil detach "$MOUNT_POINT" -quiet || true
/usr/bin/hdiutil convert Lumin-temp.dmg -format UDZO -o Lumin.dmg -quiet

# Cleanup
rm -rf dmg-build Lumin-temp.dmg

echo "DMG created successfully: Lumin.dmg"
