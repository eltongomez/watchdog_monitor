#!/bin/bash
# Widget alternativo para GeekTool
# Copie este script e adicione como "Shell" no GeekTool
# Configure para atualizar a cada 5 segundos

STATUS_FILE="/tmp/watchdog_status.txt"

# Verificar se o arquivo existe
if [ ! -f "$STATUS_FILE" ]; then
    echo "⏸️  MONITOR INATIVO"
    echo ""
    echo "Execute: watchdog_monitor_visual.sh"
    exit 0
fi

# Ler dados
STATUS_JSON=$(cat "$STATUS_FILE")

# Extrair informações usando grep/sed
STATUS=$(echo "$STATUS_JSON" | grep -o '"status": *"[^"]*"' | cut -d'"' -f4)
TIMESTAMP=$(echo "$STATUS_JSON" | grep -o '"timestamp": *"[^"]*"' | cut -d'"' -f4)
UPTIME=$(echo "$STATUS_JSON" | grep -o '"uptime": *"[^"]*"' | cut -d'"' -f4)

SMC=$(echo "$STATUS_JSON" | grep -o '"smc": *"[^"]*"' | cut -d'"' -f4)
THERMAL=$(echo "$STATUS_JSON" | grep -o '"thermal": *"[^"]*"' | cut -d'"' -f4)
IO=$(echo "$STATUS_JSON" | grep -o '"io": *"[^"]*"' | cut -d'"' -f4)
LOAD=$(echo "$STATUS_JSON" | grep -o '"load": *"[^"]*"' | cut -d'"' -f4)
MEMORY=$(echo "$STATUS_JSON" | grep -o '"memory": *"[^"]*"' | cut -d'"' -f4)

# Escolher ícone baseado no status
if [[ "$STATUS" == *"CRÍTICO"* ]] || [[ "$STATUS" == *"ERRO"* ]]; then
    ICON="🔴"
elif [[ "$STATUS" == *"AVISO"* ]]; then
    ICON="🟡"
else
    ICON="🟢"
fi

# Exibir widget
echo "🛡️  WATCHDOG MONITOR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$ICON  $STATUS"
echo ""
echo "SMC:     $SMC"
echo "Thermal: $THERMAL"
echo "I/O:     $IO"
echo "Load:    $LOAD"
echo "Memory:  $MEMORY"
echo ""
echo "Uptime: $UPTIME ciclos"
echo "Última atualização: $TIMESTAMP"
