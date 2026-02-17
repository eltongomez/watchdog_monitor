#!/bin/bash

# Script para ler RPM dos ventiladores do Mac
# Método: Usando sudo powermetrics (disponível nativamente)

read_fan_rpm() {
    # Usar powermetrics com timeout curto para não travar
    local output=$(sudo -n timeout 3 powermetrics --samplers smc -n 1 2>/dev/null | grep -i "fan\|Fan" | head -5)
    
    if [ -z "$output" ]; then
        # Fallback: Sem sudo ou sem suporte, retorna N/A
        echo "N/A"
        return 1
    fi
    
    # Processar output do powermetrics
    # Formato esperado: Fan: 2500 rpm
    local rpm=$(echo "$output" | grep -i "rpm" | awk '{print $2}')
    
    if [ -n "$rpm" ]; then
        echo "${rpm} RPM"
        return 0
    else
        echo "N/A"
        return 1
    fi
}

# Teste rápido
read_fan_rpm
