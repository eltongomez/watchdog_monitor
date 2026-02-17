#!/bin/bash
# Script de Preparação Pré-VSCode
# Execute antes de abrir projetos grandes no VSCode

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🚀 Preparação para VSCode - Projeto Grande               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 1. Liberar memória cache
echo "1/4 Liberando memória cache..."
if sudo -n purge 2>/dev/null; then
    echo "  ✅ Cache liberado"
else
    echo "  ⚠️  Falha ao liberar cache (configure sudo primeiro)"
fi

# 2. Sincronizar disco
echo "2/4 Sincronizando disco..."
sync && sync && sync
echo "  ✅ Disco sincronizado"

# 3. Verificar monitor está ativo
echo "3/4 Verificando monitor..."
if pgrep -f watchdog_monitor_visual > /dev/null; then
    echo "  ✅ Monitor ativo"
else
    echo "  ⚠️  Monitor não está rodando!"
    echo "     Execute: ~/Projects/watchdog_monitor/scripts/watchdog_monitor_visual.sh --daemon"
fi

# 4. Mostrar status do sistema
echo "4/4 Status do sistema:"
load=$(sysctl -n vm.loadavg | awk '{print $2}')
mem=$(vm_stat | grep "Pages free" | awk '{print int($3 * 4096 / 1024 / 1024)}')
echo "  Load: $load"
echo "  Memória livre: ${mem}MB"

echo ""
echo "✅ Sistema preparado!"
echo ""
echo "🎯 Agora pode abrir o VSCode com segurança"
echo ""
