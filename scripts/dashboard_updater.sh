#!/bin/bash
# Auto-updater para o dashboard HTML
# Regenera o HTML a cada 5 segundos com dados atualizados

WIDGET_DIR="$HOME/Projects/watchdog_monitor/widget"
STATUS_FILE="/tmp/watchdog_status.txt"
DASHBOARD_SCRIPT="$HOME/Projects/watchdog_monitor/scripts/open_dashboard.sh"

echo "🔄 Iniciando auto-updater do dashboard..."
echo "Dashboard será atualizado a cada 5 segundos"
echo "Pressione Ctrl+C para parar"
echo ""

# Abrir dashboard pela primeira vez
bash "$DASHBOARD_SCRIPT"

# Loop de atualização
while true; do
    sleep 5
    
    # Regenerar HTML se o arquivo de status existir
    if [ -f "$STATUS_FILE" ]; then
        # Chamar função de geração do dashboard
        source "$DASHBOARD_SCRIPT"
    fi
done
