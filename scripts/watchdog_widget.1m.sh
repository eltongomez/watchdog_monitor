#!/bin/bash
# Watchdog Monitor Menu Bar Widget
# Para usar com SwiftBar ou BitBar

STATUS_FILE="/tmp/watchdog_status.txt"

# Ler status do arquivo
if [ -f "$STATUS_FILE" ]; then
    status=$(cat "$STATUS_FILE" | grep '"status"' | cut -d'"' -f4)
    timestamp=$(cat "$STATUS_FILE" | grep '"timestamp"' | cut -d'"' -f4)
    
    smc=$(cat "$STATUS_FILE" | grep '"smc"' | cut -d'"' -f4)
    thermal=$(cat "$STATUS_FILE" | grep '"thermal"' | cut -d'"' -f4)
    io=$(cat "$STATUS_FILE" | grep '"io"' | cut -d'"' -f4)
    load=$(cat "$STATUS_FILE" | grep '"load"' | cut -d'"' -f4)
    memory=$(cat "$STATUS_FILE" | grep '"memory"' | cut -d'"' -f4)
else
    status="OFFLINE"
    timestamp="N/A"
    smc="N/A"
    thermal="N/A"
    io="N/A"
    load="N/A"
    memory="N/A"
fi

# Ícone no menu bar baseado no status
case "$status" in
    "TODOS OK")
        echo "✅ | color=green"
        ;;
    *"AVISOS"*)
        echo "⚠️ | color=orange"
        ;;
    *"PROBLEMAS"*)
        echo "❌ | color=red"
        ;;
    *)
        echo "🛡️ | color=gray"
        ;;
esac

echo "---"
echo "🛡️ Watchdog Monitor"
echo "Status: $status"
echo "Última verificação: $timestamp"
echo "---"
echo "📊 Verificações:"
echo "  SMC: $smc"
echo "  Temperatura: $thermal"
echo "  Disco I/O: $io"
echo "  Carga: $load"
echo "  Memória: $memory"
echo "---"
echo "🔄 Atualizar | refresh=true"
echo "📋 Ver Logs | bash=/Users/elima/Projects/watchdog_monitor/scripts/show_logs.sh terminal=true"
echo "⚙️ Abrir Dashboard | bash=/Users/elima/Projects/watchdog_monitor/scripts/watchdog_monitor_visual.sh terminal=true"
echo "🛑 Parar Monitor | bash=/usr/bin/killall -9 watchdog_monitor_visual.sh terminal=false"
