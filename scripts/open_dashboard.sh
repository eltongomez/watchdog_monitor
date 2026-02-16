#!/bin/bash
# Desktop Widget - HTML Dashboard
# Abre um dashboard visual no navegador

WIDGET_DIR="$HOME/Projects/watchdog_monitor/widget"
STATUS_FILE="/tmp/watchdog_status.txt"

mkdir -p "$WIDGET_DIR"

# Criar HTML do dashboard
cat > "$WIDGET_DIR/dashboard.html" << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            color: #333;
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
        
        .refresh-btn {
            display: block;
            margin: 20px auto;
            padding: 15px 40px;
            background: rgba(255, 255, 255, 0.2);
            border: 2px solid white;
            color: white;
            border-radius: 50px;
            font-size: 1em;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .refresh-btn:hover {
            background: white;
            color: #667eea;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Watchdog Monitor</h1>
            <div id="status" class="status-badge status-offline">
                Carregando...
            </div>
        </div>
        
        <div class="metrics">
            <div class="metric-card">
                <div class="metric-icon">💻</div>
                <div class="metric-label">SMC</div>
                <div id="smc" class="metric-value">-</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">🌡️</div>
                <div class="metric-label">Temperatura</div>
                <div id="thermal" class="metric-value">-</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">💾</div>
                <div class="metric-label">Disco I/O</div>
                <div id="io" class="metric-value">-</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">⚡</div>
                <div class="metric-label">Carga</div>
                <div id="load" class="metric-value">-</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-icon">🧠</div>
                <div class="metric-label">Memória</div>
                <div id="memory" class="metric-value">-</div>
            </div>
        </div>
        
        <button class="refresh-btn" onclick="loadStatus()">🔄 Atualizar</button>
        
        <div class="timestamp">
            Última atualização: <span id="timestamp">-</span>
        </div>
    </div>
    
    <script>
        async function loadStatus() {
            try {
                const response = await fetch('file:///tmp/watchdog_status.txt');
                const text = await response.text();
                const data = JSON.parse(text);
                
                // Atualizar status geral
                const statusEl = document.getElementById('status');
                statusEl.textContent = data.status;
                
                if (data.status.includes('OK')) {
                    statusEl.className = 'status-badge status-ok';
                } else if (data.status.includes('AVISOS')) {
                    statusEl.className = 'status-badge status-warning';
                } else if (data.status.includes('PROBLEMAS')) {
                    statusEl.className = 'status-badge status-error';
                } else {
                    statusEl.className = 'status-badge status-offline';
                }
                
                // Atualizar métricas
                updateMetric('smc', data.checks.smc);
                updateMetric('thermal', data.checks.thermal);
                updateMetric('io', data.checks.io);
                updateMetric('load', data.checks.load);
                updateMetric('memory', data.checks.memory);
                
                // Atualizar timestamp
                document.getElementById('timestamp').textContent = data.timestamp;
                
            } catch (error) {
                console.error('Erro ao carregar status:', error);
                document.getElementById('status').textContent = 'Monitor offline';
            }
        }
        
        function updateMetric(id, value) {
            const el = document.getElementById(id);
            el.textContent = value;
            
            if (value.includes('OK')) {
                el.className = 'metric-value metric-ok';
            } else if (value.includes('ALTO') || value.includes('LENTO') || value.includes('BAIXO')) {
                el.className = 'metric-value metric-error';
            } else if (value.includes('N/A')) {
                el.className = 'metric-value';
            } else {
                el.className = 'metric-value metric-ok';
            }
        }
        
        // Carregar imediatamente
        loadStatus();
        
        // Auto-refresh a cada 5 segundos
        setInterval(loadStatus, 5000);
    </script>
</body>
</html>
EOF

# Abrir no navegador
open "$WIDGET_DIR/dashboard.html"
