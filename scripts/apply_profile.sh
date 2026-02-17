#!/bin/bash
# Apply Recovery Profile
# Watchdog Monitor v3.2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/config/recovery.conf"

apply_profile() {
    local profile=$1
    
    case $profile in
        conservative)
            # Conservative: Seguro, age apenas em situações extremas
            sed -i '' 's/^MEMORY_THRESHOLD_CRITICAL=.*/MEMORY_THRESHOLD_CRITICAL=500/' "$CONFIG_FILE"
            sed -i '' 's/^LOAD_THRESHOLD_CRITICAL=.*/LOAD_THRESHOLD_CRITICAL=5.0/' "$CONFIG_FILE"
            sed -i '' 's/^RECOVERY_DELAY=.*/RECOVERY_DELAY=30/' "$CONFIG_FILE"
            sed -i '' 's/^RENICE_LEVEL=.*/RENICE_LEVEL=10/' "$CONFIG_FILE"
            sed -i '' 's/^RECOVERY_PROFILE=.*/RECOVERY_PROFILE=conservative/' "$CONFIG_FILE"
            echo "✓ Conservative profile applied (Safe mode)"
            ;;
            
        balanced)
            # Balanced: Recomendado, equilíbrio entre segurança e performance
            sed -i '' 's/^MEMORY_THRESHOLD_CRITICAL=.*/MEMORY_THRESHOLD_CRITICAL=800/' "$CONFIG_FILE"
            sed -i '' 's/^LOAD_THRESHOLD_CRITICAL=.*/LOAD_THRESHOLD_CRITICAL=4.5/' "$CONFIG_FILE"
            sed -i '' 's/^RECOVERY_DELAY=.*/RECOVERY_DELAY=15/' "$CONFIG_FILE"
            sed -i '' 's/^RENICE_LEVEL=.*/RENICE_LEVEL=15/' "$CONFIG_FILE"
            sed -i '' 's/^RECOVERY_PROFILE=.*/RECOVERY_PROFILE=balanced/' "$CONFIG_FILE"
            echo "✓ Balanced profile applied (Recommended)"
            ;;
            
        aggressive)
            # Aggressive: Age rapidamente, performance máxima
            sed -i '' 's/^MEMORY_THRESHOLD_CRITICAL=.*/MEMORY_THRESHOLD_CRITICAL=1000/' "$CONFIG_FILE"
            sed -i '' 's/^LOAD_THRESHOLD_CRITICAL=.*/LOAD_THRESHOLD_CRITICAL=4.0/' "$CONFIG_FILE"
            sed -i '' 's/^RECOVERY_DELAY=.*/RECOVERY_DELAY=5/' "$CONFIG_FILE"
            sed -i '' 's/^RENICE_LEVEL=.*/RENICE_LEVEL=19/' "$CONFIG_FILE"
            sed -i '' 's/^RECOVERY_PROFILE=.*/RECOVERY_PROFILE=aggressive/' "$CONFIG_FILE"
            # Ativa anti-crash leve automaticamente
            sed -i '' 's/^ANTI_CRASH_MODE=.*/ANTI_CRASH_MODE=1/' "$CONFIG_FILE"
            echo "✓ Aggressive profile applied (Performance mode)"
            ;;
            
        *)
            echo "❌ Unknown profile: $profile"
            echo "Available profiles: conservative | balanced | aggressive"
            exit 1
            ;;
    esac
    
    # Notificar usuário
    osascript -e "display notification \"Profile changed to $profile\" with title \"Watchdog Monitor\" sound name \"Glass\"" 2>/dev/null
    
    # Recarregar daemon para aplicar mudanças
    killall -HUP watchdog_monitor_visual.sh 2>/dev/null
}

# Executar
if [ $# -eq 0 ]; then
    echo "Usage: $0 <conservative|balanced|aggressive>"
    exit 1
fi

apply_profile "$1"
