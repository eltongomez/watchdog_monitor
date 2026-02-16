#!/bin/bash
# Script para mostrar logs do watchdog monitor

LOG_FILE="$HOME/Projects/watchdog_monitor/logs/watchdog_monitor.log"

if [ -f "$LOG_FILE" ]; then
    echo "=== ÚLTIMOS 50 EVENTOS DO WATCHDOG MONITOR ==="
    echo ""
    tail -50 "$LOG_FILE"
    echo ""
    echo "Pressione qualquer tecla para fechar..."
    read -n 1
else
    echo "Nenhum log encontrado ainda."
    echo ""
    echo "Pressione qualquer tecla para fechar..."
    read -n 1
fi
