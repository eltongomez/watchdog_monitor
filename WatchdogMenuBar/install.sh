#!/bin/bash

# Script para instalar o app na barra de menu

cd "$(dirname "$0")"

APP_DIR="$HOME/Applications/WatchdogMonitor"
PLIST="$HOME/Library/LaunchAgents/com.watchdog.menubar.plist"

echo "📦 Instalando WatchdogMenuBar..."

# Compilar se necessário
if [ ! -f "WatchdogMenuBar" ]; then
    echo "Compilando primeiro..."
    ./build.sh
fi

# Criar diretório
mkdir -p "$APP_DIR"

# Copiar executável
cp WatchdogMenuBar "$APP_DIR/"
chmod +x "$APP_DIR/WatchdogMenuBar"

# Criar LaunchAgent
cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.watchdog.menubar</string>
    <key>ProgramArguments</key>
    <array>
        <string>$APP_DIR/WatchdogMenuBar</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/WatchdogMenuBar.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/WatchdogMenuBar.error.log</string>
</dict>
</plist>
EOF

# Carregar LaunchAgent
launchctl unload "$PLIST" 2>/dev/null
launchctl load "$PLIST"

echo "✅ Instalado com sucesso!"
echo ""
echo "O app WatchdogMenuBar agora:"
echo "  • Está rodando na barra de menu"
echo "  • Iniciará automaticamente no login"
echo ""
echo "Para desinstalar:"
echo "  ./uninstall.sh"
