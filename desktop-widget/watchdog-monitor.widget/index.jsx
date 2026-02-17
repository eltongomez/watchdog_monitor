// Watchdog Monitor Widget para Übersicht
// Coloque em: ~/Library/Application Support/Übersicht/widgets/

import { css } from "uebersicht"

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
`

const titleStyle = css`
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  gap: 6px;
  color: rgba(255, 255, 255, 0.9);
  letter-spacing: 0.3px;
  text-transform: uppercase;
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
`

const statusError = css`
  background: rgba(255, 59, 48, 0.25);
  color: #FF3B30;
  border: 1px solid rgba(255, 59, 48, 0.3);
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

const iconStyle = css`
  width: 12px;
  height: 12px;
  opacity: 0.8;
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

// Renderizar widget
export const render = ({ output, error }) => {
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
        <div className={inactiveStyle}>
          <div style={{ fontSize: "14px", marginBottom: "8px" }}>■ Monitor Inativo</div>
          <div style={{ fontSize: "10px", marginTop: "8px", opacity: 0.5 }}>
            watchdog_monitor_visual.sh
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

    return (
      <div>
        <div className={titleStyle}>
          <span>System Monitor</span>
        </div>
        
        <div>
          <span className={`${statusBadgeStyle} ${getStatusClass()}`}>
            <span className={statusIconStyle} style={{ background: getStatusColor() }}></span>
            {data.status}
          </span>
        </div>

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
