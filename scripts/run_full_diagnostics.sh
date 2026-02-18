#!/bin/bash
# Full System Diagnostics - Disco + Profile Wizard
# Executa diagnóstico completo do sistema e recomenda perfil ideal

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║        WATCHDOG MONITOR - DIAGNÓSTICO COMPLETO           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Este diagnóstico possui duas etapas:"
echo ""
echo "1️⃣  Diagnóstico de Disco (SMART, I/O, logs)"
echo "2️⃣  Recomendação de Perfil (baseado em hardware)"
echo ""
echo "═══════════════════════════════════════════════════════════"
read -p "Pressione ENTER para iniciar o diagnóstico..." dummy
echo ""

# ═══════════════════════════════════════════════════════════
# ETAPA 1: DIAGNÓSTICO DE DISCO
# ═══════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          ETAPA 1/2: DIAGNÓSTICO DE DISCO                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

if [ -f "$SCRIPT_DIR/diagnostico_disco.sh" ]; then
    "$SCRIPT_DIR/diagnostico_disco.sh"
    DISK_EXIT=$?
else
    echo "⚠️  Script de diagnóstico de disco não encontrado"
    echo "   Pulando para recomendação de perfil..."
    DISK_EXIT=1
fi

# Pausar entre etapas
echo ""
echo "═══════════════════════════════════════════════════════════"
read -p "Diagnóstico de disco concluído. Pressione ENTER para continuar..." dummy

# ═══════════════════════════════════════════════════════════
# ETAPA 2: PROFILE WIZARD
# ═══════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║       ETAPA 2/2: RECOMENDAÇÃO DE PERFIL                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"

if [ -f "$SCRIPT_DIR/profile_wizard.sh" ]; then
    "$SCRIPT_DIR/profile_wizard.sh"
    WIZARD_EXIT=$?
else
    echo "⚠️  Script profile_wizard.sh não encontrado"
    WIZARD_EXIT=1
fi

# Resumo final
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              DIAGNÓSTICO COMPLETO CONCLUÍDO              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

if [ $DISK_EXIT -eq 0 ]; then
    echo "✅ Diagnóstico de Disco: Executado"
else
    echo "⚠️  Diagnóstico de Disco: Com avisos ou pulado"
fi

if [ $WIZARD_EXIT -eq 0 ]; then
    echo "✅ Recomendação de Perfil: Executado"
else
    echo "⚠️  Recomendação de Perfil: Com avisos"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
read -p "Pressione ENTER para fechar..." dummy
