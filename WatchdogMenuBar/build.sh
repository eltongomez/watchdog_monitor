#!/bin/bash

# Script para compilar o aplicativo de menu bar

cd "$(dirname "$0")"

echo "🔨 Compilando WatchdogMenuBar..."

# Compilar
swiftc -o WatchdogMenuBar WatchdogMenuBar.swift

if [ $? -eq 0 ]; then
    echo "✅ Compilado com sucesso!"
    echo ""
    echo "Para executar:"
    echo "  ./WatchdogMenuBar"
    echo ""
    echo "Para iniciar automaticamente no login:"
    echo "  ./install.sh"
else
    echo "❌ Erro na compilação"
    exit 1
fi
