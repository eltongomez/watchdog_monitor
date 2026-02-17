#!/bin/bash

# Watchdog Recovery - Ações Automáticas de Recuperação
# Executado quando o monitor detecta problemas críticos

LOG_FILE="$HOME/Projects/watchdog_monitor/logs/watchdog_recovery.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/config/recovery.conf"

# Carregar configurações (v3.2)
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Anti-Crash Mode PID tracking (v3.2)
CAFFEINATE_PID_FILE="/tmp/watchdog_caffeinate.pid"

# Preemptive Recovery History (v3.2)
HISTORY_DIR="$PROJECT_DIR/data"
MEMORY_HISTORY="$HISTORY_DIR/memory_history.txt"
LOAD_HISTORY="$HISTORY_DIR/load_history.txt"
TEMP_HISTORY="$HISTORY_DIR/temp_history.txt"

# Criar diretório se não existir
mkdir -p "$HISTORY_DIR"

# Função de log
log_recovery() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "[RECOVERY] $1"
}

# ═══════════════════════════════════════════════════════════
# ANTI-CRASH MODE FUNCTIONS (v3.2)
# ═══════════════════════════════════════════════════════════

# Iniciar keep-alive baseado no nível
start_keepalive() {
    local level=${ANTI_CRASH_MODE:-0}
    
    # Se já está rodando, não iniciar novamente
    if [ -f "$CAFFEINATE_PID_FILE" ]; then
        local old_pid=$(cat "$CAFFEINATE_PID_FILE")
        if ps -p $old_pid > /dev/null 2>&1; then
            return 0
        fi
    fi
    
    case $level in
        0)
            # Off - nada a fazer
            return 0
            ;;
            
        1)
            # Light - caffeinate durante recovery (5 min)
            caffeinate -s -t 300 &
            echo $! > "$CAFFEINATE_PID_FILE"
            log_recovery "⚡ Anti-Crash Light: caffeinate ativado por 5 min"
            ;;
            
        2)
            # Moderate - caffeinate + disable hibernation
            caffeinate -s -t 300 &
            echo $! > "$CAFFEINATE_PID_FILE"
            
            # Desabilitar hibernation
            if sudo -n pmset -a hibernatemode 0 2>/dev/null; then
                log_recovery "⚡ Anti-Crash Moderate: hibernation desabilitado"
            fi
            
            log_recovery "⚡ Anti-Crash Moderate: caffeinate ativado por 5 min"
            ;;
            
        3)
            # Aggressive - caffeinate permanente + disable sleep
            caffeinate -i -s &
            echo $! > "$CAFFEINATE_PID_FILE"
            
            # Desabilitar sleep automático
            if sudo -n pmset -a disablesleep 1 2>/dev/null; then
                log_recovery "⚡ Anti-Crash Aggressive: sleep automático desabilitado"
            fi
            
            log_recovery "⚡ Anti-Crash Aggressive: caffeinate permanente ativado"
            ;;
    esac
}

# Parar keep-alive
stop_keepalive() {
    if [ -f "$CAFFEINATE_PID_FILE" ]; then
        local pid=$(cat "$CAFFEINATE_PID_FILE")
        if ps -p $pid > /dev/null 2>&1; then
            kill $pid 2>/dev/null
            log_recovery "⚡ Anti-Crash: caffeinate parado"
        fi
        rm -f "$CAFFEINATE_PID_FILE"
    fi
    
    # Restaurar configurações normais
    if [ "${ANTI_CRASH_MODE:-0}" -ge 2 ]; then
        sudo -n pmset -a hibernatemode 3 2>/dev/null
        sudo -n pmset -a disablesleep 0 2>/dev/null
        log_recovery "⚡ Anti-Crash: configurações de power management restauradas"
    fi
}

# Checar e aplicar keep-alive baseado no estado do sistema
apply_keepalive_if_needed() {
    local level=${ANTI_CRASH_MODE:-0}
    
    # Level 0 ou 1: não faz nada aqui (level 1 só ativa durante recovery)
    if [ $level -le 1 ]; then
        return 0
    fi
    
    # Level 2: ativar se load alto ou memory baixa
    if [ $level -eq 2 ]; then
        local load=$(sysctl -n vm.loadavg | awk '{print $2}')
        local free_mb=$(vm_stat | awk '/Pages free/ {print int($3) * 4096 / 1048576}')
        
        # Verificar se precisa prevenir idle
        if (( $(echo "$load > 3.0" | bc -l) )); then
            start_keepalive
            return 0
        elif [ $free_mb -lt 1000 ]; then
            start_keepalive
            return 0
        fi
    fi
    
    # Level 3: sempre ativo
    if [ $level -eq 3 ]; then
        start_keepalive
    fi
}

# ═══════════════════════════════════════════════════════════
# RECOVERY FUNCTIONS
# ═══════════════════════════════════════════════════════════

# Função para liberar memória
recover_memory() {
    log_recovery "AÇÃO: Liberando memória do sistema"
    
    # Ativar keep-alive se modo Light ou superior
    if [ "${ANTI_CRASH_MODE:-0}" -ge 1 ]; then
        start_keepalive
    fi
    
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
    
    # Ativar keep-alive se modo Light ou superior
    if [ "${ANTI_CRASH_MODE:-0}" -ge 1 ]; then
        start_keepalive
    fi
    
    # Identificar processos pesados (exceto kernel e essenciais)
    heavy_processes=$(ps aux | grep -v "kernel" | grep -v "root" | sort -rn -k 3 | head -5 | awk '{print $2,$11}')
    
    # Pegar nível de renice da config (padrão 10)
    local renice_level=${RENICE_LEVEL:-10}
    
    if [ -n "$heavy_processes" ]; then
        log_recovery "Processos pesados detectados:"
        echo "$heavy_processes" | while read pid name; do
            log_recovery "  PID $pid: $name"
            # Reduzir prioridade (não matar)
            renice +$renice_level -p $pid 2>/dev/null
        done
        log_recovery "✓ Prioridade reduzida (+$renice_level) para processos pesados"
    fi
    
    return 0
}

# Função para resfriar sistema
recover_thermal() {
    log_recovery "AÇÃO: Tentando resfriar sistema"
    
    # Identificar processos que usam mais CPU (>= 30%)
    cpu_hogs=$(ps aux | grep -v "kernel" | awk '$3 >= 30.0 {print $2,$3,$11}' | head -5)
    
    if [ -z "$cpu_hogs" ]; then
        log_recovery "Nenhum processo pesado detectado (todos < 30% CPU)"
        return 0
    fi
    
    log_recovery "Top processos por CPU (>= 30%):"
    echo "$cpu_hogs" | while read pid cpu name; do
        log_recovery "  PID $pid ($cpu% CPU): $name"
        
        # Reduzir prioridade agressivamente para resfriar
        if renice +15 -p $pid 2>/dev/null; then
            log_recovery "  ✓ Prioridade reduzida: PID $pid"
        else
            log_recovery "  ✗ Falha ao reduzir prioridade: PID $pid"
        fi
    done
    
    # Aguardar um pouco para CPU desacelerar
    sleep 2
    
    # Liberar memória também ajuda (menos swap = menos I/O = menos calor)
    if sudo -n purge 2>/dev/null; then
        log_recovery "✓ Memória liberada (reduz swap e I/O)"
    fi
    
    # Sincronizar disco para reduzir I/O pendente
    sync
    
    log_recovery "✓ Ações de resfriamento concluídas"
    log_recovery "  → Processos pesados com prioridade reduzida"
    log_recovery "  → Menos CPU = Menos calor gerado"
    log_recovery "  → Sistema deve resfriar em 30-60 segundos"
    
    # Notificar usuário
    osascript -e 'display notification "Processos pesados foram desacelerados para resfriar o sistema" with title "🌡️ Resfriamento Ativo" sound name "Basso"' 2>/dev/null
    
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

# ═══════════════════════════════════════════════════════════
# PREEMPTIVE RECOVERY (v3.2)
# ═══════════════════════════════════════════════════════════

# Adicionar valor ao histórico (limita a 100 últimas entradas)
add_to_history() {
    local file=$1
    local value=$2
    
    echo "$value" >> "$file"
    
    # Manter apenas últimas 100 linhas
    if [ $(wc -l < "$file") -gt 100 ]; then
        tail -100 "$file" > "${file}.tmp"
        mv "${file}.tmp" "$file"
    fi
}

# Detectar tendência de memória
detect_memory_trend() {
    local current=$1
    
    # Precisa de pelo menos 5 leituras
    if [ ! -f "$MEMORY_HISTORY" ] || [ $(wc -l < "$MEMORY_HISTORY") -lt 5 ]; then
        echo "insufficient_data"
        return 0
    fi
    
    # Pegar últimas 5 leituras
    local readings=($(tail -5 "$MEMORY_HISTORY"))
    local prev5=${readings[0]}
    local prev4=${readings[1]}
    local prev3=${readings[2]}
    local prev2=${readings[3]}
    local prev1=${readings[4]}
    
    # Calcular taxa de decline (MB por iteração)
    local decline=$(( (prev5 - current) / 5 ))
    
    # Se caindo > 100MB por iteração = rápido
    if [ $decline -gt 100 ]; then
        echo "declining_fast"
        return 1
    # Se caindo 50-100MB = moderate
    elif [ $decline -gt 50 ]; then
        echo "declining_moderate"
        return 1
    else
        echo "stable"
        return 0
    fi
}

# Detectar tendência de load
detect_load_trend() {
    local current=$1
    
    # Precisa de pelo menos 5 leituras
    if [ ! -f "$LOAD_HISTORY" ] || [ $(wc -l < "$LOAD_HISTORY") -lt 5 ]; then
        echo "insufficient_data"
        return 0
    fi
    
    # Pegar últimas 5 leituras
    local prev5=$(tail -5 "$LOAD_HISTORY" | head -1)
    
    # Calcular aumento
    local increase=$(echo "$current - $prev5" | bc 2>/dev/null || echo "0")
    
    # Se subindo > 1.0 em 5 iterações = rápido
    if (( $(echo "$increase > 1.0" | bc -l) )); then
        echo "rising_fast"
        return 1
    # Se subindo > 0.5 = moderate
    elif (( $(echo "$increase > 0.5" | bc -l) )); then
        echo "rising_moderate"
        return 1
    else
        echo "stable"
        return 0
    fi
}

# Recovery pré-emptivo (chamado pelo monitor loop)
preemptive_recovery() {
    # Obter métricas atuais
    local free_mem=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local memory=$((free_mem * 4096 / 1024 / 1024))
    
    local load=$(sysctl -n vm.loadavg | awk '{print $2}' | tr ',' '.')
    
    # Adicionar ao histórico
    add_to_history "$MEMORY_HISTORY" "$memory"
    add_to_history "$LOAD_HISTORY" "$load"
    
    # Detectar tendências
    local mem_trend=$(detect_memory_trend $memory)
    local load_trend=$(detect_load_trend $load)
    
    # Agir preventivamente na memória
    if [ "$mem_trend" == "declining_fast" ] && [ $memory -lt 1500 ]; then
        log_recovery "⚡ PREEMPTIVE: Memory declining fast ($memory MB), acting NOW"
        log_recovery "  Trend: Memory dropping >100MB per check"
        recover_memory
        return 0
    elif [ "$mem_trend" == "declining_moderate" ] && [ $memory -lt 1000 ]; then
        log_recovery "⚡ PREEMPTIVE: Memory declining moderate ($memory MB), acting NOW"
        log_recovery "  Trend: Memory dropping 50-100MB per check"
        recover_memory
        return 0
    fi
    
    # Agir preventivamente no load
    if [ "$load_trend" == "rising_fast" ] && (( $(echo "$load > 3.0" | bc -l) )); then
        log_recovery "⚡ PREEMPTIVE: Load rising fast ($load), acting NOW"
        log_recovery "  Trend: Load increased >1.0 in last 5 checks"
        recover_load
        return 0
    elif [ "$load_trend" == "rising_moderate" ] && (( $(echo "$load > 3.5" | bc -l) )); then
        log_recovery "⚡ PREEMPTIVE: Load rising moderate ($load), acting NOW"
        log_recovery "  Trend: Load increased >0.5 in last 5 checks"
        recover_load
        return 0
    fi
    
    return 0
}

# Se executado diretamente
if [ "$1" != "" ]; then
    auto_recover "$1" "$2"
fi
