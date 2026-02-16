#!/bin/bash
# Script de Diagnóstico de Disco - macOS
# Determina se o problema é hardware ou software

echo "============================================"
echo "DIAGNÓSTICO DE DISCO - macOS"
echo "Data: $(date)"
echo "============================================"
echo ""

# 1. RESET SMC E NVRAM (SOFTWARE)
echo "=== 1. TENTATIVAS DE CORREÇÃO POR SOFTWARE ==="
echo ""
echo "Para resetar SMC (System Management Controller):"
echo "  1. Desligue o Mac"
echo "  2. Pressione Shift+Control+Option (lado esquerdo) + botão Power"
echo "  3. Segure por 10 segundos, depois solte tudo"
echo "  4. Ligue o Mac normalmente"
echo ""
echo "Para resetar NVRAM:"
echo "  1. Desligue o Mac"
echo "  2. Ligue e IMEDIATAMENTE pressione: Command+Option+P+R"
echo "  3. Segure até ouvir o som de inicialização 2 vezes"
echo "  4. Solte as teclas"
echo ""
echo "Pressione ENTER para continuar com os testes..."
read

# 2. VERIFICAR STATUS SMART DO DISCO
echo ""
echo "=== 2. VERIFICANDO STATUS SMART DO DISCO ==="
echo "SMART status indica saúde física do disco..."
echo ""

DISK_INFO=$(diskutil info disk0 2>&1)
echo "$DISK_INFO" | grep -E "(Device|SMART|Solid State|Protocol)"
echo ""

SMART_STATUS=$(echo "$DISK_INFO" | grep "SMART Status" | awk -F: '{print $2}' | xargs)
if [ "$SMART_STATUS" == "Verified" ]; then
    echo "✅ SMART Status: OK - Disco reporta estar saudável"
else
    echo "❌ SMART Status: $SMART_STATUS - PROBLEMA DETECTADO NO DISCO"
fi
echo ""

# 3. VERIFICAR ERROS NO DISCO
echo ""
echo "=== 3. VERIFICANDO DISCO COM DISKUTIL ==="
echo "Executando verificação básica..."
echo ""
diskutil verifyVolume / 2>&1
echo ""

# 4. VERIFICAR LOGS DO SISTEMA
echo ""
echo "=== 4. VERIFICANDO LOGS DE ERRO DO DISCO ==="
echo "Procurando por erros de I/O nos últimos 7 dias..."
echo ""
log show --predicate 'eventMessage contains "disk" OR eventMessage contains "I/O" OR eventMessage contains "SATA"' --info --last 7d | grep -i "error\|fail\|timeout" | tail -20
echo ""

# 5. TESTE DE LEITURA/ESCRITA
echo ""
echo "=== 5. TESTE SIMPLES DE LEITURA/ESCRITA ==="
echo "Criando arquivo de teste..."
echo ""

TEST_FILE="/tmp/disk_test_$(date +%s).tmp"
echo "Testando escrita..."
time dd if=/dev/zero of="$TEST_FILE" bs=1m count=100 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Escrita: OK"
    echo "Testando leitura..."
    time dd if="$TEST_FILE" of=/dev/null bs=1m 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ Leitura: OK"
    else
        echo "❌ Leitura: FALHOU"
    fi
    rm -f "$TEST_FILE"
else
    echo "❌ Escrita: FALHOU"
fi
echo ""

# 6. VERIFICAR KERNEL EXTENSIONS PROBLEMÁTICAS
echo ""
echo "=== 6. VERIFICANDO KERNEL EXTENSIONS ==="
echo "Kexts relacionadas a disco/storage carregadas:"
echo ""
kextstat | grep -i "storage\|disk\|ata\|ahci\|nvme"
echo ""

# 7. INFORMAÇÕES DO SISTEMA
echo ""
echo "=== 7. INFORMAÇÕES DO SISTEMA ==="
system_profiler SPStorageDataType 2>&1 | head -30
echo ""

# 8. VERIFICAR SE HÁ ATUALIZAÇÕES PENDENTES
echo ""
echo "=== 8. VERIFICANDO ATUALIZAÇÕES DO SISTEMA ==="
softwareupdate --list 2>&1
echo ""

# DIAGNÓSTICO FINAL
echo ""
echo "============================================"
echo "PRÓXIMOS PASSOS:"
echo "============================================"
echo ""
echo "Se o SMART status está OK:"
echo "  → Tente resetar SMC e NVRAM (instruções acima)"
echo "  → Execute First Aid no Utilitário de Disco"
echo "  → Considere reinstalar o macOS (sem apagar dados)"
echo ""
echo "Se o SMART status está FAILED:"
echo "  → É problema FÍSICO no disco"
echo "  → FAÇA BACKUP IMEDIATAMENTE"
echo "  → Substitua o disco"
echo ""
echo "Se testes de leitura/escrita falharam:"
echo "  → Alta probabilidade de problema físico"
echo "  → Backup urgente necessário"
echo ""
echo "============================================"
