#!/bin/bash

# Script para obter informações de ventiladores no macOS
# Usa múltiplos métodos para máxima compatibilidade

get_fan_rpm() {
    local method="$1"  # auto, istats, approx, none
    
    # Método 1: iStats (se instalado) - MELHOR
    if command -v istats &>/dev/null; then
        local rpm=$(istats fan --value-only 2>/dev/null | head -1)
        if [ -n "$rpm" ] && [ "$rpm" != "0" ]; then
            echo "$rpm RPM"
            return 0
        fi
    fi
    
    # Método 2: Aproximação via temperatura e carga
    # Baseado em: Temp alta + Load alta = RPM alto
    local temp=$(pmset -g therm 2>/dev/null | grep "CPU_Scheduler_Limit" | awk '{print $3}')
    local load=$(uptime | awk -F'load averages:' '{print $2}' | awk '{print $1}' | tr -d ',')
    
    if [ -n "$load" ]; then
        # Converter load para float comparável
        load_int=$(echo "$load" | awk '{printf "%.0f", $1}')
        
        # Estimativa grosseira baseada em load average
        if [ "$load_int" -ge 5 ]; then
            echo "~3500-4500 RPM (High Load)"
            return 0
        elif [ "$load_int" -ge 3 ]; then
            echo "~2500-3500 RPM (Medium Load)"
            return 0
        else
            echo "~1800-2500 RPM (Low Load)"
            return 0
        fi
    fi
    
    # Fallback
    echo "N/A"
    return 1
}

# Verificar se iStats está instalível via gem
check_istats_available() {
    if command -v gem &>/dev/null; then
        echo "✓ Ruby gems disponível"
        echo "→ Para instalar: sudo gem install iStats"
        return 0
    else
        echo "✗ Ruby gems não disponível"
        return 1
    fi
}

# Executar
case "${1:-auto}" in
    check)
        check_istats_available
        ;;
    install)
        echo "Instalando iStats..."
        sudo gem install iStats
        ;;
    *)
        get_fan_rpm "$1"
        ;;
esac
