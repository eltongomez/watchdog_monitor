#!/bin/bash
# Build script for WatchdogMonitor.app with icon
# Creates a properly structured macOS app bundle

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/WatchdogMenuBar"
APP_NAME="WatchdogMonitor"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║        Building Watchdog Monitor App v3.2.0              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Compile Swift app
echo "🔨 Compiling Swift source..."
cd "$BUILD_DIR" || exit 1
swiftc -o WatchdogMonitorApp WatchdogMenuBar.swift -framework Cocoa

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed"
    exit 1
fi
echo "✅ Compilation successful"
echo ""

# Create app bundle structure
APP_BUNDLE="$HOME/Applications/$APP_NAME.app"
echo "📦 Creating app bundle at $APP_BUNDLE..."

mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp WatchdogMonitorApp "$APP_BUNDLE/Contents/MacOS/WatchdogMenuBar"
chmod +x "$APP_BUNDLE/Contents/MacOS/WatchdogMenuBar"

# Copy icon
if [ -f "$BUILD_DIR/AppIcon.icns" ]; then
    cp "$BUILD_DIR/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
    echo "✅ Icon installed"
else
    echo "⚠️  Warning: AppIcon.icns not found"
fi

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>WatchdogMenuBar</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>com.eltongomez.watchdogmonitor</string>
	<key>CFBundleName</key>
	<string>Watchdog Monitor</string>
	<key>CFBundleDisplayName</key>
	<string>Watchdog Monitor</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>3.2.0</string>
	<key>CFBundleVersion</key>
	<string>320</string>
	<key>LSMinimumSystemVersion</key>
	<string>10.14</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>LSUIElement</key>
	<true/>
	<key>NSAppleEventsUsageDescription</key>
	<string>Watchdog Monitor needs to control Terminal.app to run diagnostics and show logs.</string>
</dict>
</plist>
EOF

echo "✅ Info.plist created"
echo ""

# Show summary
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                  BUILD COMPLETE                          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "📊 App Details:"
echo "   Location: $APP_BUNDLE"
echo "   Binary: $(du -h "$APP_BUNDLE/Contents/MacOS/WatchdogMenuBar" | awk '{print $1}')"
if [ -f "$APP_BUNDLE/Contents/Resources/AppIcon.icns" ]; then
    echo "   Icon: $(du -h "$APP_BUNDLE/Contents/Resources/AppIcon.icns" | awk '{print $1}')"
fi
echo ""
echo "🚀 To install: kill existing process and run 'open $APP_BUNDLE'"
echo ""
