#!/bin/bash
# Profile Recommendation Wizard
# Analisa hardware e uso do sistema para recomendar perfil ideal

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
RECOVERY_CONFIG="$PROJECT_ROOT/config/recovery.conf"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "           PROFILE RECOMMENDATION WIZARD"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Detectar hardware
echo "🔍 Analisando hardware..."
echo ""

RAM_BYTES=$(sysctl -n hw.memsize 2>/dev/null)
RAM_GB=$((RAM_BYTES / 1024 / 1024 / 1024))
CPU_PHYSICAL=$(sysctl -n hw.physicalcpu 2>/dev/null)
CPU_LOGICAL=$(sysctl -n hw.logicalcpu 2>/dev/null)
CPU_BRAND=$(sysctl -n machdep.cpu.brand_string 2>/dev/null | xargs)

echo "🖥️  Hardware Detectado:"
echo "   ├─ RAM: ${RAM_GB} GB ($(numfmt --to=iec-i --suffix=B $RAM_BYTES 2>/dev/null || echo "$RAM_BYTES bytes"))"
echo "   ├─ CPU: $CPU_PHYSICAL cores físicos, $CPU_LOGICAL lógicos"
echo "   └─ Modelo: $CPU_BRAND"
echo ""

# Analisar uso médio de recursos
echo "📊 Analisando uso de recursos..."
sleep 2

# Memory disponível (páginas livres * page size)
FREE_PAGES=$(vm_stat | awk '/Pages free/ {print $3}' | tr -d '.')
PAGE_SIZE=$(pagesize 2>/dev/null || echo 4096)
FREE_MB=$((FREE_PAGES * PAGE_SIZE / 1024 / 1024))
USED_MB=$((RAM_GB * 1024 - FREE_MB))
MEMORY_USAGE_PCT=$((USED_MB * 100 / (RAM_GB * 1024)))

# Load average (1 min)
LOAD_AVG=$(uptime | awk -F'load averages: ' '{print $2}' | awk '{print $1}')

echo ""
echo "   ├─ Uso de RAM: ${MEMORY_USAGE_PCT}% (${USED_MB} MB / $((RAM_GB * 1024)) MB)"
echo "   └─ Load Average: $LOAD_AVG"
echo ""

# Algoritmo de recomendação
echo "🧠 Calculando perfil ideal..."
echo ""

RECOMMENDED=""
REASON=""
MEMORY_THRESHOLD=""
LOAD_THRESHOLD=""
RECOVERY_DELAY=""

# Lógica de decisão
if [ $RAM_GB -le 4 ]; then
    # Hardware muito limitado
    RECOMMENDED="conservative"
    REASON="RAM limitada (≤4GB) - priorizar estabilidade e proteção agressiva"
    MEMORY_THRESHOLD="1200"
    LOAD_THRESHOLD="3.0"
    RECOVERY_DELAY="10"
elif [ $RAM_GB -eq 8 ] && [ $CPU_PHYSICAL -le 2 ]; then
    # Hardware dual-core com RAM moderada
    RECOMMENDED="balanced"
    REASON="Hardware moderado (8GB RAM, dual-core) - equilíbrio entre proteção e performance"
    MEMORY_THRESHOLD="800"
    LOAD_THRESHOLD="4.5"
    RECOVERY_DELAY="15"
elif [ $RAM_GB -ge 16 ] && [ $CPU_PHYSICAL -ge 6 ]; then
    # Workstation potente
    RECOMMENDED="aggressive"
    REASON="Hardware robusto (≥16GB RAM, ≥6 cores) - maximizar performance"
    MEMORY_THRESHOLD="500"
    LOAD_THRESHOLD="8.0"
    RECOVERY_DELAY="30"
elif [ $RAM_GB -ge 12 ] && [ $CPU_PHYSICAL -ge 4 ]; then
    # Hardware bom, mas não top
    RECOMMENDED="balanced"
    REASON="Hardware acima da média - equilíbrio otimizado"
    MEMORY_THRESHOLD="800"
    LOAD_THRESHOLD="4.5"
    RECOVERY_DELAY="15"
else
    # Casos intermediários
    if [ $MEMORY_USAGE_PCT -gt 80 ]; then
        RECOMMENDED="conservative"
        REASON="Uso de RAM elevado ($MEMORY_USAGE_PCT%) - proteção reforçada recomendada"
        MEMORY_THRESHOLD="1200"
        LOAD_THRESHOLD="3.0"
        RECOVERY_DELAY="10"
    else
        RECOMMENDED="balanced"
        REASON="Configuração padrão recomendada para maioria dos casos"
        MEMORY_THRESHOLD="800"
        LOAD_THRESHOLD="4.5"
        RECOVERY_DELAY="15"
    fi
fi

# Perfil atual
CURRENT_PROFILE=$(grep "^RECOVERY_PROFILE=" "$RECOVERY_CONFIG" 2>/dev/null | cut -d'=' -f2)

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              RECOMENDAÇÃO DE PERFIL                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "🎯 Perfil Recomendado: $(echo $RECOMMENDED | tr '[:lower:]' '[:upper:]')"
echo ""
echo "💡 Razão:"
echo "   $REASON"
echo ""
echo "⚙️  Configurações do Perfil $(echo $RECOMMENDED | tr '[:lower:]' '[:upper:]'):"
echo "   ├─ Memory Threshold: ${MEMORY_THRESHOLD} MB"
echo "   ├─ Load Threshold: ${LOAD_THRESHOLD}"
echo "   └─ Recovery Delay: ${RECOVERY_DELAY}s"
echo ""

if [ -n "$CURRENT_PROFILE" ]; then
    echo "📋 Perfil Atual: ${CURRENT_PROFILE}"
    echo ""
fi

# Perguntar se quer aplicar
if [ "$CURRENT_PROFILE" = "$RECOMMENDED" ]; then
    echo "✅ Seu sistema já está usando o perfil recomendado!"
    echo ""
else
    echo "═══════════════════════════════════════════════════════════"
    read -p "Deseja aplicar o perfil $(echo $RECOMMENDED | tr '[:lower:]' '[:upper:]') agora? [S/n]: " APPLY
    echo ""
    
    if [ -z "$APPLY" ] || [ "$APPLY" = "s" ] || [ "$APPLY" = "S" ]; then
        echo "🔧 Aplicando perfil ${RECOMMENDED}..."
        
        if [ -f "$SCRIPT_DIR/apply_profile.sh" ]; then
            "$SCRIPT_DIR/apply_profile.sh" "$RECOMMENDED"
            
            echo ""
            echo "✅ Perfil aplicado com sucesso!"
            echo ""
            echo "⚠️  IMPORTANTE: Reinicie o monitor para aplicar as mudanças:"
            echo "   Via menu bar: Clique em 'Restart Monitor'"
            echo "   Via terminal: killall watchdog_monitor_visual.sh && ./start_watchdog.sh"
            echo ""
        else
            echo "❌ Erro: Script apply_profile.sh não encontrado"
            exit 1
        fi
    else
        echo "ℹ️  Perfil não alterado. Você pode mudar manualmente via:"
        echo "   • Menu Bar → Recovery Profile → $(echo $RECOMMENDED | tr '[:lower:]' '[:upper:]')"
        echo "   • Terminal: ./scripts/apply_profile.sh ${RECOMMENDED}"
        echo ""
    fi
fi

echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📚 Documentação completa: docs/COMPLETE_GUIDE.md"
echo ""
