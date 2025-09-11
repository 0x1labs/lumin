#!/usr/bin/env bash
set -euo pipefail

# Build the project (debug)
swift build

# Create the application bundle
rm -rf Lumin.app
mkdir -p Lumin.app/Contents/MacOS
mkdir -p Lumin.app/Contents/Resources

# Stage binary and resources
cp .build/debug/Lumin Lumin.app/Contents/MacOS/Lumin
cp Info.plist Lumin.app/Contents/Info.plist

# Create a minimal PkgInfo file
echo -n "APPL????" > Lumin.app/Contents/PkgInfo

# Ad-hoc sign without entitlements for local runs
codesign -s - --deep --force Lumin.app 2>/dev/null || echo "Warning: Codesigning failed (not critical for local runs)"

echo "Built Lumin.app"
open Lumin.app