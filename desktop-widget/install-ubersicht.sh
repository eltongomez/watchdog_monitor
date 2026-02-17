#!/bin/bash
# Script de instalação rápida do Übersicht Widget

echo "🖥️  Instalador do Watchdog Monitor Widget para Übersicht"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar se Übersicht está instalado
if [ ! -d "/Applications/Übersicht.app" ] && [ ! -d "$HOME/Applications/Übersicht.app" ]; then
    echo "❌ Übersicht não encontrado!"
    echo ""
    echo "📦 Instale Übersicht primeiro:"
    echo "   brew install --cask ubersicht"
    echo ""
    echo "   Ou baixe em: https://tracesof.net/uebersicht/"
    echo ""
    exit 1
fi

echo "✅ Übersicht encontrado!"
echo ""

# Criar diretório de widgets se não existir
WIDGET_DIR="$HOME/Library/Application Support/Übersicht/widgets"
mkdir -p "$WIDGET_DIR"

# Copiar widget
echo "📦 Instalando widget..."
cp -r watchdog-monitor.widget "$WIDGET_DIR/"

if [ $? -eq 0 ]; then
    echo "✅ Widget instalado com sucesso!"
    echo ""
    echo "🎯 Próximos passos:"
    echo "   1. Abra Übersicht.app"
    echo "   2. O widget aparecerá no canto inferior direito"
    echo "   3. Inicie o monitor: ./scripts/watchdog_monitor_visual.sh"
    echo ""
    echo "⚙️  Personalização:"
    echo "   Edite: $WIDGET_DIR/watchdog-monitor.widget/index.jsx"
    echo "   - Posição: linhas 16-17 (bottom, right)"
    echo "   - Tamanho: linha 18 (width)"
    echo ""
    
    # Perguntar se quer abrir Übersicht
    read -p "🚀 Abrir Übersicht agora? (s/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        open -a Übersicht
        echo "✅ Übersicht aberto!"
    fi
else
    echo "❌ Erro ao instalar widget"
    exit 1
fi
