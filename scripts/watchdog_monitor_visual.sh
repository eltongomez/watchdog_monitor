#!/bin/bash
# Monitor Watchdog com Feedback Visual
# Versão com notificações, menu bar e dashboard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/logs/watchdog_monitor.log"
STATUS_FILE="/tmp/watchdog_status.txt"
ICON_DIR="$PROJECT_DIR/.icons"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Criar diretório de ícones
mkdir -p "$ICON_DIR"
mkdir -p "$PROJECT_DIR/logs"

# Função para enviar notificação no macOS
send_notification() {
    local title="$1"
    local message="$2"
    local sound="${3:-default}"
    
    osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null
}

# Função para criar badge de status
create_status_badge() {
    local status="$1"
    local color="$2"
    
    echo -e "${color}●${NC} $status"
}

# Função para atualizar arquivo de status (para widget)
update_status_file() {
    local status="$1"
    local smc="$2"
    local thermal="$3"
    local io="$4"
    local load="$5"
    local memory="$6"
    
    cat > "$STATUS_FILE" << EOF
{
    "status": "$status",
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
    "checks": {
        "smc": "$smc",
        "thermal": "$thermal",
        "io": "$io",
        "load": "$load",
        "memory": "$memory"
    },
    "uptime": "$SECONDS"
}
EOF
}

# Função para criar mini dashboard no terminal
show_dashboard() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}🛡️  WATCHDOG MONITOR - DASHBOARD EM TEMPO REAL${NC}    ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} $(date '+%Y-%m-%d %H:%M:%S')                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Status:  $1                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Uptime:  $2                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}VERIFICAÇÕES${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  SMC:         $3                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Temperatura: $4                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Disco I/O:   $5                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Carga:       $6                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Memória:     $7                              ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}ÚLTIMOS EVENTOS${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    
    # Mostrar últimas 5 linhas do log
    if [ -f "$LOG_FILE" ]; then
        tail -5 "$LOG_FILE" | while IFS= read -r line; do
            printf "${CYAN}║${NC}  %-58s ${CYAN}║${NC}\n" "${line:0:58}"
        done
    else
        printf "${CYAN}║${NC}  %-58s ${CYAN}║${NC}\n" "Nenhum evento registrado ainda"
        printf "${CYAN}║${NC}  %-58s ${CYAN}║${NC}\n" ""
        printf "${CYAN}║${NC}  %-58s ${CYAN}║${NC}\n" ""
        printf "${CYAN}║${NC}  %-58s ${CYAN}║${NC}\n" ""
        printf "${CYAN}║${NC}  %-58s ${CYAN}║${NC}\n" ""
    fi
    
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Pressione Ctrl+C para parar o monitoramento${NC}"
    echo ""
}

# Função para verificar SMC
check_smc() {
    smc_info=$(ioreg -l | grep -i "AppleSMC" | head -5)
    if [ -n "$smc_info" ]; then
        echo "OK"
        return 0
    else
        echo "PROBLEMA"
        return 1
    fi
}

# Função para verificar temperatura
check_thermal() {
    thermal_info=$(sysctl machdep.xcpm.cpu_thermal_level 2>/dev/null)
    if [ $? -eq 0 ]; then
        thermal_level=$(echo "$thermal_info" | awk '{print $2}')
        if [ "$thermal_level" -gt 50 ]; then
            echo "ALTO ($thermal_level)"
            return 1
        else
            echo "OK ($thermal_level)"
            return 0
        fi
    else
        echo "N/A"
        return 0
    fi
}

# Função para verificar I/O
check_disk_io() {
    test_file="/tmp/.watchdog_io_test_$$"
    start_time=$(date +%s)
    dd if=/dev/zero of="$test_file" bs=1m count=10 2>/dev/null &
    dd_pid=$!
    
    sleep_count=0
    while kill -0 $dd_pid 2>/dev/null && [ $sleep_count -lt 30 ]; do
        sleep 0.1
        sleep_count=$((sleep_count + 1))
    done
    
    if kill -0 $dd_pid 2>/dev/null; then
        kill $dd_pid 2>/dev/null
        rm -f "$test_file"
        echo "LENTO"
        return 1
    fi
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    rm -f "$test_file"
    echo "OK (${duration}s)"
    return 0
}

# Função para verificar carga
check_load() {
    load_avg=$(sysctl -n vm.loadavg | awk '{print $2}')
    load_avg=$(echo "$load_avg" | tr ',' '.')
    load_int=$(echo "$load_avg" | cut -d. -f1)
    load_int=${load_int:-0}
    
    if [ "$load_int" -gt 8 ]; then
        echo "ALTO ($load_avg)"
        return 1
    else
        echo "OK ($load_avg)"
        return 0
    fi
}

# Função para verificar memória
check_memory() {
    free_mem=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    free_mb=$((free_mem * 4096 / 1024 / 1024))
    
    if [ "$free_mb" -lt 100 ]; then
        echo "BAIXO (${free_mb}MB)"
        return 1
    else
        echo "OK (${free_mb}MB)"
        return 0
    fi
}

# Função de log
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Loop de monitoramento visual
monitor_visual() {
    local interval=${1:-30}
    local iteration=0
    local last_notification=""
    
    log_message "=== MONITORAMENTO VISUAL INICIADO ==="
    send_notification "Watchdog Monitor" "Monitoramento iniciado" "Glass"
    
    while true; do
        iteration=$((iteration + 1))
        
        # Executar verificações
        smc_status=$(check_smc)
        smc_ok=$?
        
        thermal_status=$(check_thermal)
        thermal_ok=$?
        
        io_status=$(check_disk_io)
        io_ok=$?
        
        load_status=$(check_load)
        load_ok=$?
        
        memory_status=$(check_memory)
        memory_ok=$?
        
        # Calcular status geral
        problems=0
        [ $smc_ok -ne 0 ] && problems=$((problems + 1))
        [ $thermal_ok -ne 0 ] && problems=$((problems + 1))
        [ $io_ok -ne 0 ] && problems=$((problems + 1))
        [ $load_ok -ne 0 ] && problems=$((problems + 1))
        [ $memory_ok -ne 0 ] && problems=$((problems + 1))
        
        if [ $problems -eq 0 ]; then
            overall_status="${GREEN}✅ TODOS OK${NC}"
            overall_text="TODOS OK"
            status_icon="✅"
        elif [ $problems -le 2 ]; then
            overall_status="${YELLOW}⚠️  ${problems} AVISOS${NC}"
            overall_text="${problems} AVISOS"
            status_icon="⚠️"
        else
            overall_status="${RED}❌ ${problems} PROBLEMAS${NC}"
            overall_text="${problems} PROBLEMAS"
            status_icon="❌"
        fi
        
        # Badges coloridos
        smc_badge=$([ $smc_ok -eq 0 ] && echo "${GREEN}✓${NC} $smc_status" || echo "${RED}✗${NC} $smc_status")
        thermal_badge=$([ $thermal_ok -eq 0 ] && echo "${GREEN}✓${NC} $thermal_status" || echo "${RED}✗${NC} $thermal_status")
        io_badge=$([ $io_ok -eq 0 ] && echo "${GREEN}✓${NC} $io_status" || echo "${RED}✗${NC} $io_status")
        load_badge=$([ $load_ok -eq 0 ] && echo "${GREEN}✓${NC} $load_status" || echo "${RED}✗${NC} $load_status")
        memory_badge=$([ $memory_ok -eq 0 ] && echo "${GREEN}✓${NC} $memory_status" || echo "${RED}✗${NC} $memory_status")
        
        # Calcular uptime
        uptime_str="${SECONDS}s"
        if [ $SECONDS -ge 60 ]; then
            minutes=$((SECONDS / 60))
            uptime_str="${minutes}m"
            if [ $minutes -ge 60 ]; then
                hours=$((minutes / 60))
                uptime_str="${hours}h"
            fi
        fi
        
        # Atualizar dashboard
        show_dashboard "$overall_status" "$uptime_str" "$smc_badge" "$thermal_badge" "$io_badge" "$load_badge" "$memory_badge"
        
        # Atualizar arquivo de status para widget
        update_status_file "$overall_text" "$smc_status" "$thermal_status" "$io_status" "$load_status" "$memory_status"
        
        # ═══════════════════════════════════════════════════════════
        # RECUPERAÇÃO AUTOMÁTICA (v2.0)
        # ═══════════════════════════════════════════════════════════
        if [ "$RECOVERY_ENABLED" = true ] && [ -f "$RECOVERY_SCRIPT" ]; then
            # SMC crítico
            if [ $smc_ok -ne 0 ]; then
                log_message "CRÍTICO: SMC não responde - iniciando recuperação de emergência"
                source "$RECOVERY_SCRIPT"
                emergency_smc_recovery
            fi
            
            # Múltiplos problemas (3+)
            if [ $problems -ge 3 ]; then
                log_message "CRÍTICO: $problems problemas simultâneos - recuperação automática"
                source "$RECOVERY_SCRIPT"
                auto_recover "multiple" "critical"
            fi
            
            # Problemas individuais
            if [ $memory_ok -ne 0 ] && [ $iteration -gt 1 ]; then
                log_message "AVISO: Memória baixa - liberando cache"
                source "$RECOVERY_SCRIPT"
                recover_memory
            fi
            
            if [ $io_ok -ne 0 ] && [ $iteration -gt 1 ]; then
                log_message "AVISO: I/O lento - sincronizando disco"
                source "$RECOVERY_SCRIPT"
                recover_io
            fi
            
            if [ $load_ok -ne 0 ] && [ $iteration -gt 1 ]; then
                log_message "AVISO: Carga alta - reduzindo prioridade"
                source "$RECOVERY_SCRIPT"
                recover_load
            fi
            
            if [ $thermal_ok -ne 0 ] && [ $iteration -gt 1 ]; then
                log_message "AVISO: Temperatura alta - notificando usuário"
                source "$RECOVERY_SCRIPT"
                recover_thermal
            fi
        fi
        # ═══════════════════════════════════════════════════════════
        
        # Enviar notificação se houver mudança de status
        current_notification="$overall_text"
        if [ "$current_notification" != "$last_notification" ] && [ $iteration -gt 1 ]; then
            if [ $problems -eq 0 ]; then
                send_notification "Watchdog Monitor" "Sistema normalizado ✅" "Glass"
                log_message "NOTIFICAÇÃO: Sistema normalizado"
            elif [ $problems -le 2 ]; then
                send_notification "Watchdog Monitor" "$status_icon $problems avisos detectados" "Basso"
                log_message "NOTIFICAÇÃO: $problems avisos"
            else
                send_notification "Watchdog Monitor" "⚠️ $problems problemas detectados!" "Sosumi"
                log_message "NOTIFICAÇÃO: $problems problemas"
            fi
        fi
        last_notification="$current_notification"
        
        # Log das verificações
        log_message "Ciclo #$iteration - SMC:$smc_status | Thermal:$thermal_status | IO:$io_status | Load:$load_status | Mem:$memory_status"
        
        # ═══════════════════════════════════════════════════════════
        # RECUPERAÇÃO AUTOMÁTICA (v2.0)
        # ═══════════════════════════════════════════════════════════
        if [ "$RECOVERY_ENABLED" = true ] && [ -f "$RECOVERY_SCRIPT" ]; then
            # SMC crítico
            if [ $smc_ok -ne 0 ]; then
                log_message "CRÍTICO: SMC não responde - iniciando recuperação de emergência"
                source "$RECOVERY_SCRIPT"
                emergency_smc_recovery
            fi
            
            # Múltiplos problemas (3+)
            if [ $problems -ge 3 ]; then
                log_message "CRÍTICO: $problems problemas simultâneos - recuperação automática"
                source "$RECOVERY_SCRIPT"
                auto_recover "multiple" "critical"
            fi
            
            # Problemas individuais (apenas no segundo ciclo em diante)
            if [ $iteration -gt 1 ]; then
                if [ $memory_ok -ne 0 ]; then
                    log_message "AVISO: Memória baixa - liberando cache"
                    source "$RECOVERY_SCRIPT"
                    recover_memory
                fi
                
                if [ $io_ok -ne 0 ]; then
                    log_message "AVISO: I/O lento - sincronizando disco"
                    source "$RECOVERY_SCRIPT"
                    recover_io
                fi
                
                if [ $load_ok -ne 0 ]; then
                    log_message "AVISO: Carga alta - reduzindo prioridade"
                    source "$RECOVERY_SCRIPT"
                    recover_load
                fi
                
                if [ $thermal_ok -ne 0 ]; then
                    log_message "AVISO: Temperatura alta - notificando usuário"
                    source "$RECOVERY_SCRIPT"
                    recover_thermal
                fi
            fi
        fi
        # ═══════════════════════════════════════════════════════════
        
        # Keepalive
        sync
        
        # Aguardar próximo ciclo
        sleep "$interval"
    done
}

# Função principal
main() {
    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}     ${BOLD}🛡️  WATCHDOG MONITOR COM FEEDBACK VISUAL${NC}           ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ "$1" == "--daemon" ]; then
        echo "Iniciando em modo daemon..."
        monitor_visual 30 > /dev/null 2>&1 &
        daemon_pid=$!
        echo "$daemon_pid" > /tmp/watchdog_monitor_visual.pid
        echo -e "${GREEN}✅ Daemon iniciado com PID: $daemon_pid${NC}"
        echo ""
        echo "Para ver o dashboard:"
        echo "  $0"
        echo ""
        echo "Para parar:"
        echo "  kill $daemon_pid"
        echo "  # ou"
        echo "  kill \$(cat /tmp/watchdog_monitor_visual.pid)"
    else
        # Perguntar intervalo
        echo "Intervalo de monitoramento em segundos [30]:"
        read -t 10 user_interval || user_interval=30
        user_interval=${user_interval:-30}
        
        echo ""
        echo -e "${GREEN}Iniciando monitoramento visual...${NC}"
        echo ""
        sleep 2
        
        monitor_visual "$user_interval"
    fi
}

# Trap para limpeza
trap 'clear; echo ""; echo "Monitoramento interrompido."; log_message "=== MONITORAMENTO VISUAL FINALIZADO ==="; exit 0' INT TERM

# Executar
main "$@"
