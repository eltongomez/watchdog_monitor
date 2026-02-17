#!/bin/bash

# Script para desinstalar o app

APP_DIR="$HOME/Applications/WatchdogMonitor"
PLIST="$HOME/Library/LaunchAgents/com.watchdog.menubar.plist"

echo "🗑️  Desinstalando WatchdogMenuBar..."

# Parar LaunchAgent
if [ -f "$PLIST" ]; then
    launchctl unload "$PLIST"
    rm "$PLIST"
fi

# Remover executável
if [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
fi

echo "✅ Desinstalado com sucesso!"
