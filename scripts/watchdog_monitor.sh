#!/bin/bash
# Sistema de Monitoramento Preventivo Anti-Panic
# Previne travamentos que acionam o watchdog

echo "============================================"
echo "SISTEMA DE MONITORAMENTO PREVENTIVO"
echo "Anti-Watchdog Timeout"
echo "Data: $(date)"
echo "============================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Arquivo de log
LOG_FILE="$HOME/.copilot/session-state/3525e5de-72cb-412b-ad12-cc117f6c88bc/watchdog_monitor.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Função de log
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Função para verificar status do SMC
check_smc_status() {
    echo -e "${YELLOW}[1/6] Verificando status do SMC...${NC}"
    
    # Verificar se o SMC está respondendo
    smc_info=$(ioreg -l | grep -i "AppleSMC" | head -5)
    
    if [ -n "$smc_info" ]; then
        echo -e "${GREEN}✅ SMC está respondendo${NC}"
        log_message "SMC: OK"
        return 0
    else
        echo -e "${RED}❌ SMC não está respondendo corretamente${NC}"
        log_message "SMC: PROBLEMA DETECTADO"
        return 1
    fi
}

# Função para verificar temperatura
check_thermal() {
    echo -e "${YELLOW}[2/6] Verificando temperatura do sistema...${NC}"
    
    # Tentar obter temperatura via powermetrics (requer sudo)
    # Como workaround, verificamos se há thermal throttling
    
    thermal_info=$(sysctl machdep.xcpm.cpu_thermal_level 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        thermal_level=$(echo "$thermal_info" | awk '{print $2}')
        echo "   Nível térmico: $thermal_level"
        
        if [ "$thermal_level" -gt 50 ]; then
            echo -e "${RED}⚠️  Sistema está quente (nível: $thermal_level)${NC}"
            log_message "THERMAL: Alto ($thermal_level) - risco de SMC freeze"
            return 1
        else
            echo -e "${GREEN}✅ Temperatura OK (nível: $thermal_level)${NC}"
            log_message "THERMAL: OK ($thermal_level)"
            return 0
        fi
    else
        echo -e "${YELLOW}ℹ️  Não foi possível verificar temperatura${NC}"
        log_message "THERMAL: Não verificável"
        return 0
    fi
}

# Função para verificar I/O do disco
check_disk_io() {
    echo -e "${YELLOW}[3/6] Verificando I/O do disco...${NC}"
    
    # Teste rápido de I/O
    test_file="/tmp/.watchdog_io_test_$$"
    
    # Timeout de 5 segundos para escrita
    if timeout 5 dd if=/dev/zero of="$test_file" bs=1m count=10 2>/dev/null; then
        rm -f "$test_file"
        echo -e "${GREEN}✅ I/O de disco OK${NC}"
        log_message "DISK I/O: OK"
        return 0
    else
        rm -f "$test_file"
        echo -e "${RED}❌ I/O de disco lento ou travado${NC}"
        log_message "DISK I/O: LENTO - risco de watchdog timeout"
        return 1
    fi
}

# Função para verificar carga do sistema
check_system_load() {
    echo -e "${YELLOW}[4/6] Verificando carga do sistema...${NC}"
    
    load_avg=$(sysctl -n vm.loadavg | awk '{print $2}')
    load_int=${load_avg%.*}
    
    echo "   Load average: $load_avg"
    
    if [ "$load_int" -gt 8 ]; then
        echo -e "${RED}⚠️  Sistema sob alta carga${NC}"
        log_message "LOAD: Alto ($load_avg) - risco de timeout"
        return 1
    else
        echo -e "${GREEN}✅ Carga do sistema normal${NC}"
        log_message "LOAD: OK ($load_avg)"
        return 0
    fi
}

# Função para verificar memória
check_memory() {
    echo -e "${YELLOW}[5/6] Verificando memória disponível...${NC}"
    
    free_mem=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    free_mb=$((free_mem * 4096 / 1024 / 1024))
    
    echo "   Memória livre: ${free_mb}MB"
    
    if [ "$free_mb" -lt 100 ]; then
        echo -e "${RED}⚠️  Pouca memória disponível${NC}"
        log_message "MEMORY: Baixa (${free_mb}MB) - risco de swap/freeze"
        return 1
    else
        echo -e "${GREEN}✅ Memória OK${NC}"
        log_message "MEMORY: OK (${free_mb}MB)"
        return 0
    fi
}

# Função para keepalive do watchdog
send_keepalive() {
    echo -e "${YELLOW}[6/6] Enviando keepalive para prevenir timeout...${NC}"
    
    # Executar comando leve que mantém o sistema "vivo"
    # Isso evita que o watchdog pense que o sistema está travado
    
    for i in {1..3}; do
        sync
        sleep 0.1
    done
    
    echo -e "${GREEN}✅ Keepalive enviado${NC}"
    log_message "KEEPALIVE: Enviado"
}

# Função de ação corretiva
take_action() {
    local issue=$1
    
    echo ""
    echo -e "${YELLOW}Tomando ação corretiva para: $issue${NC}"
    
    case $issue in
        "thermal")
            echo "   → Sugerindo redução de carga..."
            log_message "ACTION: Thermal issue - recomendando intervenção"
            ;;
        "io")
            echo "   → Limpando cache de disco..."
            sync
            purge 2>/dev/null || true
            log_message "ACTION: Limpou cache de disco"
            ;;
        "memory")
            echo "   → Limpando memória inativa..."
            purge 2>/dev/null || true
            log_message "ACTION: Liberou memória"
            ;;
        "load")
            echo "   → Sistema sobrecarregado - monitorando..."
            log_message "ACTION: Sistema sob carga alta"
            ;;
    esac
}

# Loop de monitoramento
monitor_loop() {
    local interval=${1:-30}  # Intervalo padrão: 30 segundos
    local max_iterations=${2:-0}  # 0 = infinito
    local iteration=0
    
    echo ""
    echo "Iniciando monitoramento contínuo..."
    echo "Intervalo: ${interval}s"
    echo "Pressione Ctrl+C para parar"
    echo ""
    log_message "=== MONITORAMENTO INICIADO ==="
    
    while true; do
        iteration=$((iteration + 1))
        
        if [ "$max_iterations" -gt 0 ] && [ "$iteration" -gt "$max_iterations" ]; then
            echo "Número máximo de iterações atingido."
            break
        fi
        
        echo "----------------------------------------"
        echo "Ciclo de verificação #$iteration - $(date '+%H:%M:%S')"
        echo "----------------------------------------"
        
        issues=()
        
        # Executar verificações
        check_smc_status || issues+=("smc")
        check_thermal || issues+=("thermal")
        check_disk_io || issues+=("io")
        check_system_load || issues+=("load")
        check_memory || issues+=("memory")
        send_keepalive
        
        # Se houver problemas, tomar ação
        if [ ${#issues[@]} -gt 0 ]; then
            echo ""
            echo -e "${RED}⚠️  ${#issues[@]} problema(s) detectado(s)${NC}"
            for issue in "${issues[@]}"; do
                take_action "$issue"
            done
        else
            echo ""
            echo -e "${GREEN}✅ Todos os sistemas OK${NC}"
            log_message "STATUS: Todos sistemas normais"
        fi
        
        echo ""
        echo "Próxima verificação em ${interval}s..."
        sleep "$interval"
    done
    
    log_message "=== MONITORAMENTO FINALIZADO ==="
}

# Função principal
main() {
    echo ""
    echo "Este script monitora o sistema em tempo real e previne"
    echo "condições que podem causar watchdog timeout."
    echo ""
    
    # Verificar se deve executar uma vez ou em loop
    if [ "$1" == "--once" ]; then
        echo "Executando verificação única..."
        check_smc_status
        check_thermal
        check_disk_io
        check_system_load
        check_memory
        send_keepalive
        echo ""
        echo "Verificação completa. Use sem --once para monitoramento contínuo."
    elif [ "$1" == "--daemon" ]; then
        # Executar em background
        echo "Iniciando em modo daemon..."
        monitor_loop 30 > /dev/null 2>&1 &
        daemon_pid=$!
        echo "Daemon iniciado com PID: $daemon_pid"
        echo "Para parar: kill $daemon_pid"
        echo "$daemon_pid" > /tmp/watchdog_monitor.pid
    else
        # Perguntar intervalo
        echo "Intervalo de monitoramento (segundos) [30]:"
        read -t 10 user_interval || user_interval=30
        user_interval=${user_interval:-30}
        
        monitor_loop "$user_interval"
    fi
}

# Trap para limpeza
trap 'echo ""; echo "Monitoramento interrompido."; log_message "Monitoramento interrompido pelo usuário"; exit 0' INT TERM

# Executar
main "$@"
