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
  width: 320px;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
  color: #ffffff;
  background: rgba(0, 0, 0, 0.75);
  backdrop-filter: blur(20px);
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
`

const titleStyle = css`
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 8px;
`

const statusBadgeStyle = css`
  display: inline-block;
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
`

const statusOk = css`
  background: #34C759;
  color: #ffffff;
`

const statusWarning = css`
  background: #FF9500;
  color: #ffffff;
`

const statusError = css`
  background: #FF3B30;
  color: #ffffff;
`

const metricRowStyle = css`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  
  &:last-child {
    border-bottom: none;
  }
`

const metricLabelStyle = css`
  font-size: 13px;
  opacity: 0.7;
`

const metricValueStyle = css`
  font-size: 14px;
  font-weight: 500;
  font-family: "SF Mono", Monaco, monospace;
`

const timestampStyle = css`
  margin-top: 12px;
  font-size: 11px;
  opacity: 0.5;
  text-align: center;
`

const inactiveStyle = css`
  text-align: center;
  padding: 20px;
  opacity: 0.7;
`

// Renderizar widget
export const render = ({ output, error }) => {
  if (error) {
    return (
      <div className={inactiveStyle}>
        ⚠️ Erro ao carregar dados
      </div>
    )
  }

  try {
    const data = JSON.parse(output)
    
    if (data.status === "MONITOR INATIVO") {
      return (
        <div className={inactiveStyle}>
          <div style={{ fontSize: "32px", marginBottom: "8px" }}>⏸️</div>
          <div>Monitor Inativo</div>
          <div style={{ fontSize: "11px", marginTop: "8px", opacity: 0.6 }}>
            Execute: watchdog_monitor_visual.sh
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

    const getStatusIcon = () => {
      if (data.status.includes("CRÍTICO") || data.status.includes("ERRO")) {
        return "🔴"
      } else if (data.status.includes("AVISO")) {
        return "🟡"
      } else {
        return "🟢"
      }
    }

    const getCheckValue = (check) => {
      if (!data.checks || !data.checks[check]) return "N/A"
      const value = data.checks[check]
      
      if (value.includes("OK")) {
        return `✅ ${value}`
      } else if (value.includes("CRÍTICO") || value.includes("ERRO")) {
        return `🔴 ${value}`
      } else if (value.includes("AVISO") || value.includes("ALTO") || value.includes("BAIXO")) {
        return `⚠️ ${value}`
      }
      return value
    }

    return (
      <div>
        <div className={titleStyle}>
          <span>🛡️ Watchdog Monitor</span>
        </div>
        
        <div style={{ marginBottom: "12px" }}>
          <span className={`${statusBadgeStyle} ${getStatusClass()}`}>
            {getStatusIcon()} {data.status}
          </span>
        </div>

        <div>
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>SMC</span>
            <span className={metricValueStyle}>{getCheckValue("smc")}</span>
          </div>
          
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>Thermal</span>
            <span className={metricValueStyle}>{getCheckValue("thermal")}</span>
          </div>
          
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>I/O</span>
            <span className={metricValueStyle}>{getCheckValue("io")}</span>
          </div>
          
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>Load</span>
            <span className={metricValueStyle}>{getCheckValue("load")}</span>
          </div>
          
          <div className={metricRowStyle}>
            <span className={metricLabelStyle}>Memory</span>
            <span className={metricValueStyle}>{getCheckValue("memory")}</span>
          </div>
        </div>

        <div className={timestampStyle}>
          {data.uptime ? `Uptime: ${data.uptime} ciclos` : ""} • {data.timestamp || ""}
        </div>
      </div>
    )
  } catch (e) {
    return (
      <div className={inactiveStyle}>
        ⚠️ Erro ao processar dados
      </div>
    )
  }
}
