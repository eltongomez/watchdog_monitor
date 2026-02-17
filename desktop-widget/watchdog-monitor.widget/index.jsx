// Watchdog Monitor Widget para Übersicht
// Coloque em: ~/Library/Application Support/Übersicht/widgets/

import { css, run } from "uebersicht"
import { React } from "uebersicht"

// Comando para obter dados do monitor
export const command = "cat /tmp/watchdog_status.txt 2>/dev/null || echo '{\"status\":\"MONITOR INATIVO\"}'"

// Atualizar a cada 5 segundos
export const refreshFrequency = 5000

// Posição na tela (canto inferior direito)
export const className = css`
  bottom: 20px;
  right: 20px;
  width: 300px;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
  color: rgba(255, 255, 255, 0.95);
  background: rgba(30, 30, 30, 0.3);
  backdrop-filter: blur(40px) saturate(180%);
  -webkit-backdrop-filter: blur(40px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 14px;
  padding: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15), 0 2px 8px rgba(0, 0, 0, 0.08);
  user-select: none;
`

const titleStyle = css`
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: rgba(255, 255, 255, 0.9);
  letter-spacing: 0.3px;
  text-transform: uppercase;
`

const menuButtonStyle = css`
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 6px;
  padding: 4px 8px;
  font-size: 11px;
  color: rgba(255, 255, 255, 0.8);
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.25);
  }
  
  &:active {
    background: rgba(255, 255, 255, 0.2);
  }
`

const dropdownStyle = css`
  position: absolute;
  top: 45px;
  right: 14px;
  background: rgba(30, 30, 30, 0.95);
  backdrop-filter: blur(40px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  padding: 6px;
  min-width: 200px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
  z-index: 1000;
`

const menuItemStyle = css`
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.85);
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 8px;
  
  &:hover {
    background: rgba(255, 255, 255, 0.1);
    color: rgba(255, 255, 255, 1);
  }
  
  &:active {
    background: rgba(255, 255, 255, 0.15);
  }
`

const menuSeparatorStyle = css`
  height: 1px;
  background: rgba(255, 255, 255, 0.08);
  margin: 4px 0;
`

const statusBadgeStyle = css`
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.3px;
  margin-bottom: 8px;
  transition: all 0.2s;
`

const statusOk = css`
  background: rgba(52, 199, 89, 0.25);
  color: #34C759;
  border: 1px solid rgba(52, 199, 89, 0.3);
`

const statusWarning = css`
  background: rgba(255, 149, 0, 0.25);
  color: #FF9500;
  border: 1px solid rgba(255, 149, 0, 0.3);
  cursor: pointer;
  
  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(255, 149, 0, 0.3);
  }
`

const statusError = css`
  background: rgba(255, 59, 48, 0.25);
  color: #FF3B30;
  border: 1px solid rgba(255, 59, 48, 0.3);
  cursor: pointer;
  
  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(255, 59, 48, 0.3);
  }
`

const metricRowStyle = css`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 7px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  
  &:last-child {
    border-bottom: none;
  }
`

const metricLabelStyle = css`
  font-size: 12px;
  color: rgba(255, 255, 255, 0.65);
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 6px;
`

const metricValueStyle = css`
  font-size: 12px;
  font-weight: 500;
  font-family: "SF Mono", Monaco, monospace;
  color: rgba(255, 255, 255, 0.85);
`

const timestampStyle = css`
  margin-top: 10px;
  font-size: 10px;
  color: rgba(255, 255, 255, 0.4);
  text-align: center;
  font-weight: 400;
`

const inactiveStyle = css`
  text-align: center;
  padding: 20px;
  color: rgba(255, 255, 255, 0.5);
`

const statusIconStyle = css`
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
`

const alertModalStyle = css`
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(30, 30, 30, 0.98);
  backdrop-filter: blur(40px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 14px;
  padding: 20px;
  min-width: 400px;
  max-width: 500px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
  z-index: 2000;
`

const alertOverlayStyle = css`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(8px);
  z-index: 1999;
`

const alertTitleStyle = css`
  font-size: 16px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.95);
  margin-bottom: 12px;
`

const alertContentStyle = css`
  font-size: 13px;
  color: rgba(255, 255, 255, 0.75);
  line-height: 1.6;
  margin-bottom: 16px;
`

const alertButtonStyle = css`
  background: rgba(255, 255, 255, 0.12);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.9);
  cursor: pointer;
  transition: all 0.2s;
  float: right;
  
  &:hover {
    background: rgba(255, 255, 255, 0.18);
  }
`

// Renderizar widget
export const render = ({ output, error }) => {
  const [menuOpen, setMenuOpen] = React.useState(false)
  const [alertOpen, setAlertOpen] = React.useState(false)
  const [alertData, setAlertData] = React.useState(null)

  if (error) {
    return (
      <div className={inactiveStyle}>
        <div>● Erro ao carregar dados</div>
      </div>
    )
  }

  try {
    const data = JSON.parse(output)
    
    if (data.status === "MONITOR INATIVO") {
      return (
        <div>
          <div className={titleStyle}>
            <span>System Monitor</span>
            <button 
              className={menuButtonStyle}
              onClick={() => setMenuOpen(!menuOpen)}
            >
              ⋯
            </button>
          </div>
          
          {menuOpen && (
            <div className={dropdownStyle}>
              <div 
                className={menuItemStyle}
                onClick={() => {
                  run(`cd ~/Projects/watchdog_monitor && nohup ./scripts/watchdog_monitor_visual.sh --daemon > /dev/null 2>&1 &`)
                  setMenuOpen(false)
                }}
              >
                <span>▸</span> Start Monitor
              </div>
              <div className={menuSeparatorStyle} />
              <div 
                className={menuItemStyle}
                onClick={() => {
                  run(`osascript -e 'tell application "Terminal" to do script "cd ~/Projects/watchdog_monitor && ./scripts/disable_watchdog.sh"'`)
                  setMenuOpen(false)
                }}
              >
                <span>⚙</span> Disable/Enable Watchdog
              </div>
              <div className={menuSeparatorStyle} />
              <div 
                className={menuItemStyle}
                onClick={() => {
                  run(`open ~/Projects/watchdog_monitor/logs/watchdog_monitor.log`)
                  setMenuOpen(false)
                }}
              >
                <span>≡</span> View Logs
              </div>
              <div 
                className={menuItemStyle}
                onClick={() => {
                  run(`osascript -e 'tell application "Terminal" to do script "cd ~/Projects/watchdog_monitor && ./scripts/diagnostico_disco.sh"'`)
                  setMenuOpen(false)
                }}
              >
                <span>◉</span> Run Diagnostics
              </div>
            </div>
          )}
          
          <div className={inactiveStyle}>
            <div style={{ fontSize: "14px", marginBottom: "8px" }}>■ Monitor Inativo</div>
            <div style={{ fontSize: "10px", marginTop: "8px", opacity: 0.5 }}>
              Click Menu → Start Monitor
            </div>
          </div>
        </div>
      )
    }

    const getStatusClass = () => {
      if (data.status.includes("CRÍTICO") || data.status.includes("ERRO")) {
        return statusError
      } else if (data.status.includes("AVISO")) {
        return statusWarning
      } else {
        return statusOk
      }
    }

    const getStatusColor = () => {
      if (data.status.includes("CRÍTICO") || data.status.includes("ERRO")) {
        return "#FF3B30"
      } else if (data.status.includes("AVISO")) {
        return "#FF9500"
      } else {
        return "#34C759"
      }
    }

    const getCheckValue = (check) => {
      if (!data.checks || !data.checks[check]) return "N/A"
      const value = data.checks[check]
      return value.replace("OK", "").replace("CRÍTICO", "").replace("ERRO", "").replace("AVISO", "").replace("ALTO", "").replace("BAIXO", "").trim()
    }

    const getCheckStatus = (check) => {
      if (!data.checks || !data.checks[check]) return "neutral"
      const value = data.checks[check]
      
      if (value.includes("OK")) return "ok"
      if (value.includes("CRÍTICO") || value.includes("ERRO")) return "error"
      if (value.includes("AVISO") || value.includes("ALTO") || value.includes("BAIXO")) return "warning"
      return "neutral"
    }

    const getCheckIcon = (status) => {
      switch(status) {
        case "ok": return "●"
        case "error": return "●"
        case "warning": return "●"
        default: return "○"
      }
    }

    const getCheckColor = (status) => {
      switch(status) {
        case "ok": return "#34C759"
        case "error": return "#FF3B30"
        case "warning": return "#FF9500"
        default: return "rgba(255, 255, 255, 0.3)"
      }
    }

    const hasWarnings = () => {
      if (!data.checks) return false
      return Object.values(data.checks).some(v => 
        v.includes("AVISO") || v.includes("ALTO") || v.includes("BAIXO") || 
        v.includes("CRÍTICO") || v.includes("ERRO")
      )
    }

    const getWarningDetails = () => {
      if (!data.checks) return []
      const warnings = []
      Object.entries(data.checks).forEach(([key, value]) => {
        if (value.includes("AVISO") || value.includes("ALTO") || value.includes("BAIXO")) {
          warnings.push({ type: "warning", check: key, value: value })
        }
        if (value.includes("CRÍTICO") || value.includes("ERRO")) {
          warnings.push({ type: "error", check: key, value: value })
        }
      })
      return warnings
    }

    const handleStatusClick = () => {
      if (hasWarnings()) {
        setAlertData(getWarningDetails())
        setAlertOpen(true)
      }
    }

    const handleMenuAction = (action) => {
      setMenuOpen(false)
      
      switch(action) {
        case 'stop':
          run(`pgrep -f watchdog_monitor_visual.sh | xargs kill`)
          break
        case 'restart':
          run(`pgrep -f watchdog_monitor_visual.sh | xargs kill && sleep 1 && cd ~/Projects/watchdog_monitor && nohup ./scripts/watchdog_monitor_visual.sh --daemon > /dev/null 2>&1 &`)
          break
        case 'logs':
          run(`open ~/Projects/watchdog_monitor/logs/watchdog_monitor.log`)
          break
        case 'dashboard':
          run(`cd ~/Projects/watchdog_monitor && ./scripts/open_dashboard.sh`)
          break
        case 'diagnostics':
          run(`osascript -e 'tell application "Terminal" to do script "cd ~/Projects/watchdog_monitor && ./scripts/diagnostico_disco.sh"'`)
          break
        case 'terminal':
          run(`osascript -e 'tell application "Terminal" to do script "cd ~/Projects/watchdog_monitor && ./scripts/watchdog_monitor_visual.sh"'`)
          break
        case 'watchdog':
          run(`osascript -e 'tell application "Terminal" to do script "cd ~/Projects/watchdog_monitor && ./scripts/disable_watchdog.sh"'`)
          break
      }
    }

    return (
      <div>
        <div className={titleStyle}>
          <span>System Monitor</span>
          <button 
            className={menuButtonStyle}
            onClick={() => setMenuOpen(!menuOpen)}
          >
            ⋯
          </button>
        </div>
        
        {menuOpen && (
          <div className={dropdownStyle}>
            <div 
              className={menuItemStyle}
              onClick={() => handleMenuAction('terminal')}
            >
              <span>▸</span> Open Terminal View
            </div>
            <div 
              className={menuItemStyle}
              onClick={() => handleMenuAction('dashboard')}
            >
              <span>◆</span> Open Web Dashboard
            </div>
            <div className={menuSeparatorStyle} />
            <div 
              className={menuItemStyle}
              onClick={() => handleMenuAction('restart')}
            >
              <span>↻</span> Restart Monitor
            </div>
            <div 
              className={menuItemStyle}
              onClick={() => handleMenuAction('stop')}
            >
              <span>■</span> Stop Monitor
            </div>
            <div className={menuSeparatorStyle} />
            <div 
              className={menuItemStyle}
              onClick={() => handleMenuAction('watchdog')}
            >
              <span>⚙</span> Disable/Enable Watchdog
            </div>
            <div className={menuSeparatorStyle} />
            <div 
              className={menuItemStyle}
              onClick={() => handleMenuAction('logs')}
            >
              <span>≡</span> View Logs
            </div>
            <div 
              className={menuItemStyle}
              onClick={() => handleMenuAction('diagnostics')}
            >
              <span>◉</span> Run Diagnostics
            </div>
          </div>
        )}
        
        <div>
          <span 
            className={`${statusBadgeStyle} ${getStatusClass()}`}
            onClick={handleStatusClick}
            style={{ cursor: hasWarnings() ? 'pointer' : 'default' }}
            title={hasWarnings() ? 'Click to see details' : ''}
          >
            <span className={statusIconStyle} style={{ background: getStatusColor() }}></span>
            {data.status}
          </span>
        </div>

        {alertOpen && (
          <>
            <div className={alertOverlayStyle} onClick={() => setAlertOpen(false)} />
            <div className={alertModalStyle}>
              <div className={alertTitleStyle}>
                {alertData && alertData.some(w => w.type === 'error') ? 'System Alerts' : 'System Warnings'}
              </div>
              <div className={alertContentStyle}>
                {alertData && alertData.map((warning, i) => (
                  <div key={i} style={{ 
                    marginBottom: '8px', 
                    padding: '8px', 
                    background: 'rgba(255, 255, 255, 0.05)',
                    borderRadius: '6px',
                    borderLeft: `3px solid ${warning.type === 'error' ? '#FF3B30' : '#FF9500'}`
                  }}>
                    <div style={{ 
                      fontWeight: 600, 
                      marginBottom: '4px',
                      color: warning.type === 'error' ? '#FF3B30' : '#FF9500'
                    }}>
                      {warning.check.toUpperCase()}
                    </div>
                    <div>{warning.value}</div>
                  </div>
                ))}
              </div>
              <button 
                className={alertButtonStyle}
                onClick={() => setAlertOpen(false)}
              >
                Close
              </button>
            </div>
          </>
        )}

        <div>
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>
              <span style={{ color: getCheckColor(getCheckStatus("smc")) }}>
                {getCheckIcon(getCheckStatus("smc"))}
              </span>
              SMC Status
            </span>
            <span className={metricValueStyle}>{getCheckValue("smc") || "OK"}</span>
          </div>
          
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>
              <span style={{ color: getCheckColor(getCheckStatus("thermal")) }}>
                {getCheckIcon(getCheckStatus("thermal"))}
              </span>
              Temperature
            </span>
            <span className={metricValueStyle}>{getCheckValue("thermal") || "0"}</span>
          </div>
          
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>
              <span style={{ color: getCheckColor(getCheckStatus("io")) }}>
                {getCheckIcon(getCheckStatus("io"))}
              </span>
              Disk I/O
            </span>
            <span className={metricValueStyle}>{getCheckValue("io") || "0s"}</span>
          </div>
          
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>
              <span style={{ color: getCheckColor(getCheckStatus("load")) }}>
                {getCheckIcon(getCheckStatus("load"))}
              </span>
              System Load
            </span>
            <span className={metricValueStyle}>{getCheckValue("load") || "0.00"}</span>
          </div>
          
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>
              <span style={{ color: getCheckColor(getCheckStatus("memory")) }}>
                {getCheckIcon(getCheckStatus("memory"))}
              </span>
              Memory
            </span>
            <span className={metricValueStyle}>{getCheckValue("memory") || "0MB"}</span>
          </div>
        </div>

        <div className={timestampStyle}>
          {data.uptime ? `${data.uptime} cycles` : ""} • {data.timestamp ? data.timestamp.split(" ")[1] : ""}
        </div>
      </div>
    )
  } catch (e) {
    return (
      <div className={inactiveStyle}>
        <div>● Processing error</div>
      </div>
    )
  }
}
