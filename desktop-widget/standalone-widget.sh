#!/bin/bash
# Widget standalone que cria uma janela flutuante no desktop
# Usa AppleScript para criar janela sempre visível

STATUS_FILE="/tmp/watchdog_status.txt"
UPDATE_INTERVAL=5

# Função para gerar HTML do widget
generate_widget_html() {
    local status_data=$(cat "$STATUS_FILE" 2>/dev/null || echo '{"status":"MONITOR INATIVO"}')
    
    cat << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: transparent;
            padding: 16px;
            width: 320px;
        }
        .widget {
            background: rgba(0, 0, 0, 0.85);
            backdrop-filter: blur(20px);
            border-radius: 12px;
            padding: 16px;
            color: white;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
        }
        .title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 12px;
        }
        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        .status-ok { background: #34C759; }
        .status-warning { background: #FF9500; }
        .status-error { background: #FF3B30; }
        .metric-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .metric-row:last-child {
            border-bottom: none;
        }
        .metric-label {
            font-size: 13px;
            opacity: 0.7;
        }
        .metric-value {
            font-size: 14px;
            font-weight: 500;
            font-family: 'SF Mono', Monaco, monospace;
        }
        .timestamp {
            margin-top: 12px;
            font-size: 11px;
            opacity: 0.5;
            text-align: center;
        }
        .inactive {
            text-align: center;
            padding: 20px;
            opacity: 0.7;
        }
    </style>
    <script>
        let statusData = STATUS_DATA_PLACEHOLDER;
        
        function updateWidget() {
            fetch('file:///tmp/watchdog_status.txt')
                .then(r => r.text())
                .then(data => {
                    statusData = JSON.parse(data);
                    renderWidget();
                })
                .catch(() => {
                    statusData = {status: "MONITOR INATIVO"};
                    renderWidget();
                });
        }
        
        function renderWidget() {
            const container = document.getElementById('widget-content');
            
            if (statusData.status === "MONITOR INATIVO") {
                container.innerHTML = `
                    <div class="inactive">
                        <div style="font-size: 32px; margin-bottom: 8px;">⏸️</div>
                        <div>Monitor Inativo</div>
                        <div style="font-size: 11px; margin-top: 8px; opacity: 0.6;">
                            Execute: watchdog_monitor_visual.sh
                        </div>
                    </div>
                `;
                return;
            }
            
            let statusClass = 'status-ok';
            let statusIcon = '🟢';
            
            if (statusData.status.includes('CRÍTICO') || statusData.status.includes('ERRO')) {
                statusClass = 'status-error';
                statusIcon = '🔴';
            } else if (statusData.status.includes('AVISO')) {
                statusClass = 'status-warning';
                statusIcon = '🟡';
            }
            
            const getCheckValue = (check) => {
                if (!statusData.checks || !statusData.checks[check]) return 'N/A';
                const value = statusData.checks[check];
                
                if (value.includes('OK')) return `✅ ${value}`;
                if (value.includes('CRÍTICO') || value.includes('ERRO')) return `🔴 ${value}`;
                if (value.includes('AVISO') || value.includes('ALTO') || value.includes('BAIXO')) return `⚠️ ${value}`;
                return value;
            };
            
            container.innerHTML = `
                <div class="title">🛡️ Watchdog Monitor</div>
                <div class="status-badge ${statusClass}">${statusIcon} ${statusData.status}</div>
                <div>
                    <div class="metric-row">
                        <span class="metric-label">SMC</span>
                        <span class="metric-value">${getCheckValue('smc')}</span>
                    </div>
                    <div class="metric-row">
                        <span class="metric-label">Thermal</span>
                        <span class="metric-value">${getCheckValue('thermal')}</span>
                    </div>
                    <div class="metric-row">
                        <span class="metric-label">I/O</span>
                        <span class="metric-value">${getCheckValue('io')}</span>
                    </div>
                    <div class="metric-row">
                        <span class="metric-label">Load</span>
                        <span class="metric-value">${getCheckValue('load')}</span>
                    </div>
                    <div class="metric-row">
                        <span class="metric-label">Memory</span>
                        <span class="metric-value">${getCheckValue('memory')}</span>
                    </div>
                </div>
                <div class="timestamp">
                    ${statusData.uptime ? `Uptime: ${statusData.uptime} ciclos • ` : ''}${statusData.timestamp || ''}
                </div>
            `;
        }
        
        // Atualizar a cada 5 segundos
        setInterval(updateWidget, 5000);
        
        // Renderizar inicial
        window.onload = renderWidget;
    </script>
</head>
<body>
    <div class="widget">
        <div id="widget-content"></div>
    </div>
</body>
</html>
EOF
}

# Gerar HTML com dados embutidos
HTML_FILE="/tmp/watchdog_widget.html"

# Ler dados de status
if [ -f "$STATUS_FILE" ]; then
    STATUS_DATA=$(cat "$STATUS_FILE" | tr -d '\n')
else
    STATUS_DATA='{"status":"MONITOR INATIVO"}'
fi

# Gerar HTML e substituir inline
generate_widget_html | sed "s/STATUS_DATA_PLACEHOLDER/${STATUS_DATA}/" > "$HTML_FILE"

# Abrir widget em janela flutuante
osascript << EOF
tell application "Safari"
    activate
    make new document with properties {URL:"file://$HTML_FILE"}
end tell

tell application "System Events"
    tell process "Safari"
        set frontmost to true
        -- Janela flutuante sempre no topo (requer permissões)
    end tell
end tell
EOF

echo "✅ Widget aberto no Safari"
echo "💡 Para manter sempre visível, use Übersicht ou GeekTool"
