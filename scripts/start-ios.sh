#!/bin/bash

# Start Magizh Calendar iOS App
# Usage: ./start-ios.sh [--build]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_DIR="$SCRIPT_DIR/../ios"

cd "$IOS_DIR" || exit 1

echo "📱 Starting Magizh Calendar iOS..."
echo "📁 Directory: $IOS_DIR"

# Boot simulator if needed
SIMULATOR_ID="627AE548-5D18-408B-8AEE-43C61BF227B4"
echo "🔧 Booting iPhone 16 Pro simulator..."
xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
open -a Simulator

if [ "$1" == "--build" ]; then
    echo "🔨 Building app..."
    xcodebuild -scheme magizh-calendar-ios -sdk iphonesimulator build CONFIGURATION_BUILD_DIR=/tmp/magizh-build -quiet

    echo "📲 Installing app..."
    xcrun simctl install "$SIMULATOR_ID" /tmp/magizh-build/magizh-calendar-ios.app
fi

echo "🚀 Launching app..."
xcrun simctl launch "$SIMULATOR_ID" com.sats.magizh-calendar-ios

echo ""
echo "✅ iOS app launched!"
