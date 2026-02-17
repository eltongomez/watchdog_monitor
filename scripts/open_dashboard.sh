#!/bin/bash
# Desktop Widget - HTML Dashboard
# Gera dashboard HTML com dados embutidos e auto-refresh

WIDGET_DIR="$HOME/Projects/watchdog_monitor/widget"
STATUS_FILE="/tmp/watchdog_status.txt"

mkdir -p "$WIDGET_DIR"

# Função para gerar HTML com dados atualizados
generate_dashboard() {
    local status="OFFLINE"
    local timestamp="N/A"
    local smc="N/A"
    local thermal="N/A"
    local io="N/A"
    local load="N/A"
    local memory="N/A"
    local status_class="status-offline"
    
    # Ler dados do arquivo se existir
    if [ -f "$STATUS_FILE" ]; then
        status=$(grep '"status"' "$STATUS_FILE" | cut -d'"' -f4)
        timestamp=$(grep '"timestamp"' "$STATUS_FILE" | cut -d'"' -f4)
        smc=$(grep '"smc"' "$STATUS_FILE" | cut -d'"' -f4)
        thermal=$(grep '"thermal"' "$STATUS_FILE" | cut -d'"' -f4)
        io=$(grep '"io"' "$STATUS_FILE" | cut -d'"' -f4)
        load=$(grep '"load"' "$STATUS_FILE" | cut -d'"' -f4)
        memory=$(grep '"memory"' "$STATUS_FILE" | cut -d'"' -f4)
        
        # Determinar classe CSS do status
        if [[ "$status" == *"OK"* ]]; then
            status_class="status-ok"
        elif [[ "$status" == *"AVISOS"* ]]; then
            status_class="status-warning"
        elif [[ "$status" == *"PROBLEMAS"* ]]; then
            status_class="status-error"
        fi
    fi
    
    # Gerar HTML
    cat > "$WIDGET_DIR/dashboard.html" << EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="5">
    <title>Watchdog Monitor Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            color: #333;
            margin-bottom: 10px;
        }
        
        .status-badge {
            display: inline-block;
            padding: 10px 30px;
            border-radius: 50px;
            font-weight: bold;
            font-size: 1.2em;
            margin: 10px 0;
        }
        
        .status-ok {
            background: #10b981;
            color: white;
        }
        
        .status-warning {
            background: #f59e0b;
            color: white;
        }
        
        .status-error {
            background: #ef4444;
            color: white;
        }
        
        .status-offline {
            background: #6b7280;
            color: white;
        }
        
        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .metric-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }
        
        .metric-card:hover {
            transform: translateY(-5px);
        }
        
        .metric-icon {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .metric-label {
            font-size: 0.9em;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
        }
        
        .metric-value {
            font-size: 1.3em;
            font-weight: bold;
        }
        
        .metric-ok {
            color: #10b981;
        }
        
        .metric-warning {
            color: #f59e0b;
        }
        
        .metric-error {
            color: #ef4444;
        }
        
        .timestamp {
            text-align: center;
            color: rgba(255, 255, 255, 0.9);
            margin-top: 20px;
            font-size: 0.9em;
        }
        
        .auto-refresh {
            text-align: center;
            color: rgba(255, 255, 255, 0.7);
            margin-top: 10px;
            font-size: 0.8em;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 0.7; }
            50% { opacity: 1; }
        }
        
        .manual-refresh {
            display: block;
            margin: 10px auto;
            padding: 12px 35px;
            background: rgba(255, 255, 255, 0.2);
            border: 2px solid white;
            color: white;
            border-radius: 50px;
            font-size: 0.9em;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
        }
        
        .manual-refresh:hover {
            background: white;
            color: #667eea;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Watchdog Monitor</h1>
            <div class="status-badge $status_class">
                $status
            </div>
        </div>
        
        <div class="metrics">
            <div class="metric-card">
                <div class="metric-icon">💻</div>
                <div class="metric-label">SMC</div>
                <div class="metric-value metric-$(get_metric_class "$smc")">$smc</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">🌡️</div>
                <div class="metric-label">Temperatura</div>
                <div class="metric-value metric-$(get_metric_class "$thermal")">$thermal</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">💾</div>
                <div class="metric-label">Disco I/O</div>
                <div class="metric-value metric-$(get_metric_class "$io")">$io</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">⚡</div>
                <div class="metric-label">Carga</div>
                <div class="metric-value metric-$(get_metric_class "$load")">$load</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">🧠</div>
                <div class="metric-label">Memória</div>
                <div class="metric-value metric-$(get_metric_class "$memory")">$memory</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">⚡</div>
                <div class="metric-label">Coolers</div>
                <div class="metric-value metric-ok">~${fan_rpm} RPM</div>
            </div>
        </div>
        
        <a href="dashboard.html" class="manual-refresh">🔄 Atualizar Agora</a>
        
        <div class="auto-refresh">
            ⟳ Atualização automática a cada 5 segundos
        </div>
        
        <div class="timestamp">
            Última atualização: $timestamp
        </div>
    </div>
</body>
</html>
EOF
}

# Função para determinar classe CSS da métrica
get_metric_class() {
    local value="$1"
    if [[ "$value" == *"OK"* ]]; then
        echo "ok"
    elif [[ "$value" == *"ALTO"* ]] || [[ "$value" == *"LENTO"* ]] || [[ "$value" == *"BAIXO"* ]]; then
        echo "error"
    elif [[ "$value" == *"N/A"* ]] || [[ "$value" == *"PROBLEMA"* ]]; then
        echo "warning"
    else
        echo "ok"
    fi
}

# Gerar dashboard
generate_dashboard

# Abrir no navegador
open "$WIDGET_DIR/dashboard.html"

echo "✅ Dashboard aberto!"
echo ""
echo "💡 O dashboard será atualizado automaticamente a cada 5 segundos."
echo "   Ou clique no botão 'Atualizar Agora' para refresh manual."

