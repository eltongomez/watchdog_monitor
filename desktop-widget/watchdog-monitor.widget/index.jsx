// Watchdog Monitor Widget para Übersicht
import { css, run } from "uebersicht"

// Comando para obter dados do monitor
export const command = "cat /tmp/watchdog_status.txt 2>/dev/null || echo '{\"status\":\"MONITOR INATIVO\"}'"

// Atualizar a cada 5 segundos
export const refreshFrequency = 5000

// Estilos
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

// Renderizar widget
export const render = ({ output, error }) => {
  if (error) {
    return <div style={{ textAlign: "center", padding: "20px", color: "rgba(255, 255, 255, 0.5)" }}>
      Error loading data
    </div>
  }

  let data
  try {
    data = JSON.parse(output)
  } catch (e) {
    return <div style={{ textAlign: "center", padding: "20px", color: "rgba(255, 255, 255, 0.5)" }}>
      Processing error
    </div>
  }

  if (data.status === "MONITOR INATIVO") {
    return <div>
      <div style={{ 
        fontSize: "13px", 
        fontWeight: 600, 
        marginBottom: "10px",
        color: "rgba(255, 255, 255, 0.9)",
        letterSpacing: "0.3px",
        textTransform: "uppercase"
      }}>
        System Monitor
      </div>
      <div style={{ textAlign: "center", padding: "20px", color: "rgba(255, 255, 255, 0.5)" }}>
        <div style={{ fontSize: "14px", marginBottom: "8px" }}>Monitor Inactive</div>
        <div style={{ fontSize: "10px", marginTop: "8px", opacity: 0.5 }}>
          Start from terminal
        </div>
      </div>
    </div>
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

  const getCheckColor = (check) => {
    if (!data.checks || !data.checks[check]) return "rgba(255, 255, 255, 0.3)"
    const value = data.checks[check]
    
    if (value.includes("OK")) return "#34C759"
    if (value.includes("CRÍTICO") || value.includes("ERRO")) return "#FF3B30"
    if (value.includes("AVISO") || value.includes("ALTO") || value.includes("BAIXO")) return "#FF9500"
    return "rgba(255, 255, 255, 0.3)"
  }

  const statusColor = getStatusColor()

  return <div>
    <div style={{ 
      fontSize: "13px", 
      fontWeight: 600, 
      marginBottom: "10px",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      color: "rgba(255, 255, 255, 0.9)",
      letterSpacing: "0.3px",
      textTransform: "uppercase"
    }}>
      <span>System Monitor</span>
    </div>
    
    <div>
      <span style={{
        display: "inline-flex",
        alignItems: "center",
        gap: "6px",
        padding: "6px 10px",
        borderRadius: "8px",
        fontSize: "11px",
        fontWeight: 600,
        letterSpacing: "0.3px",
        marginBottom: "8px",
        background: `rgba(${statusColor === "#34C759" ? "52, 199, 89" : statusColor === "#FF9500" ? "255, 149, 0" : "255, 59, 48"}, 0.25)`,
        color: statusColor,
        border: `1px solid rgba(${statusColor === "#34C759" ? "52, 199, 89" : statusColor === "#FF9500" ? "255, 149, 0" : "255, 59, 48"}, 0.3)`
      }}>
        <span style={{
          width: "8px",
          height: "8px",
          borderRadius: "50%",
          display: "inline-block",
          background: statusColor
        }}></span>
        {data.status}
      </span>
    </div>

    <div>
      <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "7px 0",
        borderBottom: "1px solid rgba(255, 255, 255, 0.06)"
      }}>
        <span style={{
          fontSize: "12px",
          color: "rgba(255, 255, 255, 0.65)",
          fontWeight: 500,
          display: "flex",
          alignItems: "center",
          gap: "6px"
        }}>
          <span style={{ color: getCheckColor("smc") }}>●</span>
          SMC Status
        </span>
        <span style={{
          fontSize: "12px",
          fontWeight: 500,
          fontFamily: '"SF Mono", Monaco, monospace',
          color: "rgba(255, 255, 255, 0.85)"
        }}>{getCheckValue("smc") || "OK"}</span>
      </div>
      
      <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "7px 0",
        borderBottom: "1px solid rgba(255, 255, 255, 0.06)"
      }}>
        <span style={{
          fontSize: "12px",
          color: "rgba(255, 255, 255, 0.65)",
          fontWeight: 500,
          display: "flex",
          alignItems: "center",
          gap: "6px"
        }}>
          <span style={{ color: getCheckColor("thermal") }}>●</span>
          Temperature
        </span>
        <span style={{
          fontSize: "12px",
          fontWeight: 500,
          fontFamily: '"SF Mono", Monaco, monospace',
          color: "rgba(255, 255, 255, 0.85)"
        }}>{getCheckValue("thermal") || "0"}</span>
      </div>
      
      <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "7px 0",
        borderBottom: "1px solid rgba(255, 255, 255, 0.06)"
      }}>
        <span style={{
          fontSize: "12px",
          color: "rgba(255, 255, 255, 0.65)",
          fontWeight: 500,
          display: "flex",
          alignItems: "center",
          gap: "6px"
        }}>
          <span style={{ color: getCheckColor("io") }}>●</span>
          Disk I/O
        </span>
        <span style={{
          fontSize: "12px",
          fontWeight: 500,
          fontFamily: '"SF Mono", Monaco, monospace',
          color: "rgba(255, 255, 255, 0.85)"
        }}>{getCheckValue("io") || "0s"}</span>
      </div>
      
      <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "7px 0",
        borderBottom: "1px solid rgba(255, 255, 255, 0.06)"
      }}>
        <span style={{
          fontSize: "12px",
          color: "rgba(255, 255, 255, 0.65)",
          fontWeight: 500,
          display: "flex",
          alignItems: "center",
          gap: "6px"
        }}>
          <span style={{ color: getCheckColor("load") }}>●</span>
          System Load
        </span>
        <span style={{
          fontSize: "12px",
          fontWeight: 500,
          fontFamily: '"SF Mono", Monaco, monospace',
          color: "rgba(255, 255, 255, 0.85)"
        }}>{getCheckValue("load") || "0.00"}</span>
      </div>
      
      <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "7px 0"
      }}>
        <span style={{
          fontSize: "12px",
          color: "rgba(255, 255, 255, 0.65)",
          fontWeight: 500,
          display: "flex",
          alignItems: "center",
          gap: "6px"
        }}>
          <span style={{ color: getCheckColor("memory") }}>●</span>
          Memory
        </span>
        <span style={{
          fontSize: "12px",
          fontWeight: 500,
          fontFamily: '"SF Mono", Monaco, monospace',
          color: "rgba(255, 255, 255, 0.85)"
        }}>{getCheckValue("memory") || "0MB"}</span>
      </div>
    </div>

    <div style={{
      marginTop: "10px",
      fontSize: "10px",
      color: "rgba(255, 255, 255, 0.4)",
      textAlign: "center",
      fontWeight: 400
    }}>
      {data.uptime ? `${data.uptime} cycles` : ""} • {data.timestamp ? data.timestamp.split(" ")[1] : ""}
    </div>
  </div>
}
