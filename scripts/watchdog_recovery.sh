#!/bin/bash

# Watchdog Recovery - Ações Automáticas de Recuperação
# Executado quando o monitor detecta problemas críticos

LOG_FILE="$HOME/Projects/watchdog_monitor/logs/watchdog_recovery.log"

# Função de log
log_recovery() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "[RECOVERY] $1"
}

# Função para liberar memória
recover_memory() {
    log_recovery "AÇÃO: Liberando memória do sistema"
    
    # Limpar cache com sudo (agora configurado)
    if sudo -n purge 2>/dev/null; then
        log_recovery "✓ Cache limpo com sucesso"
        return 0
    else
        log_recovery "✗ Falha ao limpar cache (erro: $?)"
        log_recovery "  Tentando sync como fallback..."
        sync && sync && sync
        log_recovery "  Sync executado"
        return 1
    fi
}

# Função para melhorar I/O
recover_io() {
    log_recovery "AÇÃO: Sincronizando disco"
    
    # Forçar sincronização múltipla
    sync && sync && sync
    
    log_recovery "✓ Disco sincronizado"
    
    # Parar Spotlight temporariamente se muito ativo
    if pgrep -q mds; then
        log_recovery "AÇÃO: Pausando Spotlight temporariamente"
        sudo mdutil -i off / 2>/dev/null && sleep 5 && sudo mdutil -i on / 2>/dev/null &
        log_recovery "✓ Spotlight pausado temporariamente"
    fi
    
    return 0
}

# Função para reduzir carga
recover_load() {
    log_recovery "AÇÃO: Reduzindo carga do sistema"
    
    # Identificar processos pesados (exceto kernel e essenciais)
    heavy_processes=$(ps aux | grep -v "kernel" | grep -v "root" | sort -rn -k 3 | head -5 | awk '{print $2,$11}')
    
    if [ -n "$heavy_processes" ]; then
        log_recovery "Processos pesados detectados:"
        echo "$heavy_processes" | while read pid name; do
            log_recovery "  PID $pid: $name"
            # Reduzir prioridade (não matar)
            renice +10 -p $pid 2>/dev/null
        done
        log_recovery "✓ Prioridade reduzida para processos pesados"
    fi
    
    return 0
}

# Função para resfriar sistema
recover_thermal() {
    log_recovery "AÇÃO: Tentando resfriar sistema"
    
    # Identificar processos que usam mais CPU
    cpu_hogs=$(ps aux | grep -v "kernel" | sort -rn -k 3 | head -3 | awk '{print $2,$3,$11}')
    
    log_recovery "Top 3 processos por CPU:"
    echo "$cpu_hogs" | while read pid cpu name; do
        log_recovery "  PID $pid ($cpu% CPU): $name"
    done
    
    # Notificar usuário
    osascript -e "display notification \"Feche aplicações pesadas para resfriar o sistema\" with title \"⚠️ Temperatura Alta\" sound name \"Basso\"" 2>/dev/null
    
    log_recovery "✓ Usuário notificado"
    return 0
}

# FUNÇÃO CRÍTICA: Recuperação de SMC travado
emergency_smc_recovery() {
    log_recovery "🚨 EMERGÊNCIA: SMC NÃO RESPONDE!"
    
    # 1. Notificação urgente
    osascript -e 'display notification "SMC travado! Iniciando recuperação de emergência..." with title "🚨 ALERTA CRÍTICO" sound name "Sosumi"' 2>/dev/null
    
    # 2. Liberar memória
    log_recovery "Liberando memória..."
    sudo purge 2>/dev/null
    
    # 3. Sincronizar disco múltiplas vezes
    log_recovery "Sincronizando disco..."
    sync && sync && sync
    
    # 4. Matar processos não-essenciais
    log_recovery "Parando processos não-essenciais..."
    killall -9 Spotlight mds mds_stores 2>/dev/null
    
    # 5. Aguardar 30 segundos
    log_recovery "Aguardando 30s para recuperação..."
    sleep 30
    
    # 6. Verificar se SMC voltou
    if ioreg -l | grep -q AppleSMC; then
        log_recovery "✅ SMC RECUPERADO COM SUCESSO!"
        osascript -e 'display notification "SMC recuperado! Sistema estabilizado." with title "✅ Recuperação Bem-Sucedida" sound name "Glass"' 2>/dev/null
        return 0
    else
        log_recovery "❌ SMC AINDA TRAVADO APÓS 30s"
        
        # 7. Oferecer reinicialização preventiva
        response=$(osascript -e 'display dialog "SMC ainda não responde após 30 segundos.\n\nReinicialização preventiva é RECOMENDADA para evitar kernel panic.\n\nO que deseja fazer?" buttons {"Aguardar", "Reiniciar em 1 min"} default button 2 with title "⚠️ SMC Crítico" with icon caution giving up after 60' 2>/dev/null)
        
        if echo "$response" | grep -q "Reiniciar em 1 min"; then
            log_recovery "Usuário escolheu reinicialização preventiva"
            osascript -e 'display notification "Sistema reiniciará em 1 minuto. Salve seu trabalho!" with title "⚠️ Reinicialização em 1 min" sound name "Sosumi"' 2>/dev/null
            
            # Countdown de 1 minuto
            for i in 60 30 10 5 4 3 2 1; do
                osascript -e "display notification \"Reiniciando em $i segundos...\" with title \"⏱️ Countdown\" sound name \"Tink\"" 2>/dev/null
                sleep 1
            done
            
            log_recovery "Executando reinicialização preventiva..."
            sudo shutdown -r now "Reinicialização preventiva - SMC travado" 2>/dev/null
        else
            log_recovery "Usuário escolheu aguardar - continuando monitoramento intensivo"
            osascript -e 'display notification "Monitoramento intensivo ativado" with title "⚠️ Modo de Alerta" sound name "Basso"' 2>/dev/null
        fi
        
        return 1
    fi
}

# Função principal de recuperação
auto_recover() {
    local problem_type="$1"
    local severity="$2"
    
    log_recovery "════════════════════════════════════════"
    log_recovery "Iniciando recuperação automática"
    log_recovery "Problema: $problem_type | Severidade: $severity"
    
    case "$problem_type" in
        smc)
            if [ "$severity" = "critical" ]; then
                emergency_smc_recovery
            else
                log_recovery "SMC com aviso - monitorando de perto"
            fi
            ;;
        memory)
            recover_memory
            ;;
        io)
            recover_io
            ;;
        load)
            recover_load
            ;;
        thermal)
            recover_thermal
            ;;
        multiple)
            # Múltiplos problemas
            log_recovery "MÚLTIPLOS PROBLEMAS DETECTADOS"
            recover_memory
            recover_io
            recover_load
            ;;
        *)
            log_recovery "Tipo de problema desconhecido: $problem_type"
            ;;
    esac
    
    local result=$?
    log_recovery "Recuperação finalizada (código: $result)"
    log_recovery "════════════════════════════════════════"
    echo ""
    
    return $result
}

# Se executado diretamente
if [ "$1" != "" ]; then
    auto_recover "$1" "$2"
fi
