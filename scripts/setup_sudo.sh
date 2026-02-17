#!/bin/bash
# Script para configurar permissões sudo para Watchdog Recovery
# Permite que o monitor execute comandos críticos sem senha

set -e

SUDOERS_FILE="/etc/sudoers.d/watchdog"
TEMP_FILE="/tmp/watchdog_sudoers_temp"
USER=$(whoami)

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🔧 Configuração de Permissões Sudo - Watchdog Monitor    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verificar se está rodando como usuário normal
if [ "$USER" = "root" ]; then
    echo "❌ Erro: Não execute este script como root"
    echo "   Execute como usuário normal: ./setup_sudo.sh"
    exit 1
fi

echo "👤 Usuário: $USER"
echo "📝 Arquivo destino: $SUDOERS_FILE"
echo ""

# Criar arquivo temporário com as permissões
cat > "$TEMP_FILE" << EOF
# Watchdog Monitor - Recovery Permissions
# Permite comandos críticos sem senha para prevenir kernel panics
# Gerado automaticamente em $(date)

# Liberar memória cache
$USER ALL=(ALL) NOPASSWD: /usr/sbin/purge

# Reinicialização de emergência (apenas se configurado)
$USER ALL=(ALL) NOPASSWD: /sbin/reboot

# Sincronização de disco
$USER ALL=(ALL) NOPASSWD: /bin/sync
EOF

echo "✅ Arquivo de configuração criado"
echo ""
echo "📋 Conteúdo que será instalado:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$TEMP_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validar sintaxe do arquivo sudoers
echo "🔍 Validando sintaxe do arquivo sudoers..."
if visudo -c -f "$TEMP_FILE" > /dev/null 2>&1; then
    echo "✅ Sintaxe válida"
else
    echo "❌ Erro: Sintaxe inválida no arquivo sudoers"
    echo "   O arquivo não será instalado por segurança"
    rm -f "$TEMP_FILE"
    exit 1
fi

echo ""
echo "⚠️  ATENÇÃO: Este script vai solicitar sua senha para:"
echo "   1. Instalar configuração em /etc/sudoers.d/watchdog"
echo "   2. Configurar permissões corretas (0440)"
echo ""
read -p "Deseja continuar? (s/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo "❌ Operação cancelada pelo usuário"
    rm -f "$TEMP_FILE"
    exit 0
fi

echo ""
echo "🔐 Instalando configuração (sua senha será solicitada)..."

# Instalar arquivo com sudo
if sudo cp "$TEMP_FILE" "$SUDOERS_FILE" 2>/dev/null; then
    echo "✅ Arquivo copiado"
else
    echo "❌ Erro ao copiar arquivo"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Definir permissões corretas (necessário para sudoers)
if sudo chmod 0440 "$SUDOERS_FILE" 2>/dev/null; then
    echo "✅ Permissões configuradas (0440)"
else
    echo "❌ Erro ao configurar permissões"
    sudo rm -f "$SUDOERS_FILE"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Validar arquivo instalado
echo "🔍 Validando instalação..."
if sudo visudo -c > /dev/null 2>&1; then
    echo "✅ Configuração instalada com sucesso"
else
    echo "❌ Erro: Configuração inválida detectada"
    echo "   Removendo arquivo por segurança..."
    sudo rm -f "$SUDOERS_FILE"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Limpar arquivo temporário
rm -f "$TEMP_FILE"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ Configuração concluída com sucesso!                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🧪 Testando permissões..."
echo ""

# Testar se sudo purge funciona sem senha
if sudo -n purge 2>/dev/null; then
    echo "✅ sudo purge funciona sem senha"
else
    echo "⚠️  sudo purge ainda requer senha (pode precisar de nova sessão)"
fi

echo ""
echo "📝 Próximos passos:"
echo "   1. As permissões estão ativas imediatamente"
echo "   2. O monitor agora pode executar recovery automático"
echo "   3. Teste abrindo VSCode com o projeto compre_certo"
echo ""
echo "🛡️  O sistema agora pode prevenir crashes automaticamente!"
echo ""
