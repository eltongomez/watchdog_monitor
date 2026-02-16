#!/bin/bash
# Script de Workaround para Problema do Watchdog
# Desabilita temporariamente o watchdog para testes

echo "============================================"
echo "WORKAROUND: Desabilitar Watchdog"
echo "Data: $(date)"
echo "============================================"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}⚠️  ATENÇÃO: Este script modifica boot arguments do sistema${NC}"
echo ""
echo "O que este script faz:"
echo "  • Desabilita o watchdog do kernel (temporariamente)"
echo "  • Permite testar se o problema persiste sem o watchdog"
echo "  • Pode ser facilmente revertido"
echo ""
echo -e "${RED}IMPORTANTE:${NC}"
echo "  • O watchdog é um mecanismo de SEGURANÇA"
echo "  • Desabilitá-lo remove proteção contra travamentos"
echo "  • Use apenas para DIAGNÓSTICO"
echo "  • Reverta após identificar o problema"
echo ""
echo -e "${BLUE}Status atual:${NC}"

# Verificar boot-args atual
current_args=$(nvram boot-args 2>/dev/null)

if echo "$current_args" | grep -q "watchdog="; then
    echo -e "${YELLOW}Watchdog já está configurado nos boot-args${NC}"
    echo "$current_args"
else
    echo -e "${GREEN}Nenhuma configuração de watchdog nos boot-args${NC}"
fi

echo ""
echo "Escolha uma opção:"
echo ""
echo "1) Desabilitar watchdog (para testes)"
echo "2) Habilitar watchdog (reverter)"
echo "3) Ver status atual e sair"
echo "4) Cancelar"
echo ""

read -p "Opção [1-4]: " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Desabilitando watchdog...${NC}"
        
        # Obter boot-args atuais
        current_args=$(nvram boot-args 2>/dev/null | sed 's/boot-args\t//')
        
        # Remover qualquer watchdog= existente
        new_args=$(echo "$current_args" | sed 's/watchdog=[0-9]//g' | sed 's/  / /g' | xargs)
        
        # Adicionar watchdog=0
        if [ -z "$new_args" ]; then
            new_args="watchdog=0"
        else
            new_args="$new_args watchdog=0"
        fi
        
        echo "Novos boot-args: $new_args"
        echo ""
        
        # Aplicar (pode pedir senha de administrador)
        if sudo nvram boot-args="$new_args"; then
            echo -e "${GREEN}✅ Watchdog desabilitado com sucesso!${NC}"
            echo ""
            echo "Próximos passos:"
            echo "  1. Reinicie o Mac: sudo shutdown -r now"
            echo "  2. Após reiniciar, o watchdog estará desabilitado"
            echo "  3. Use o sistema normalmente por alguns dias"
            echo "  4. Se o panic NÃO ocorrer, confirma que é bug do watchdog"
            echo "  5. Reverta esta configuração executando este script novamente (opção 2)"
            echo ""
            echo -e "${RED}LEMBRE-SE: Reverta após os testes!${NC}"
        else
            echo -e "${RED}❌ Falha ao modificar boot-args${NC}"
            echo "Certifique-se de ter privilégios de administrador"
        fi
        ;;
        
    2)
        echo ""
        echo -e "${YELLOW}Habilitando watchdog (revertendo)...${NC}"
        
        # Obter boot-args atuais
        current_args=$(nvram boot-args 2>/dev/null | sed 's/boot-args\t//')
        
        # Remover watchdog=0
        new_args=$(echo "$current_args" | sed 's/watchdog=[0-9]//g' | sed 's/  / /g' | xargs)
        
        if [ -z "$new_args" ]; then
            # Se ficou vazio, deletar boot-args
            if sudo nvram -d boot-args; then
                echo -e "${GREEN}✅ Watchdog reabilitado (boot-args limpo)${NC}"
            else
                echo -e "${RED}❌ Falha ao limpar boot-args${NC}"
            fi
        else
            # Atualizar com novos args
            if sudo nvram boot-args="$new_args"; then
                echo -e "${GREEN}✅ Watchdog reabilitado${NC}"
            else
                echo -e "${RED}❌ Falha ao modificar boot-args${NC}"
            fi
        fi
        
        echo ""
        echo "Watchdog voltará ao normal após reiniciar o Mac."
        echo "Reinicie: sudo shutdown -r now"
        ;;
        
    3)
        echo ""
        echo -e "${BLUE}Status atual dos boot-args:${NC}"
        nvram boot-args 2>/dev/null || echo "Nenhum boot-arg configurado"
        echo ""
        
        echo -e "${BLUE}Status do driver watchdog:${NC}"
        kextstat | grep watchdog
        ;;
        
    4)
        echo ""
        echo "Operação cancelada."
        exit 0
        ;;
        
    *)
        echo ""
        echo -e "${RED}Opção inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo "============================================"
