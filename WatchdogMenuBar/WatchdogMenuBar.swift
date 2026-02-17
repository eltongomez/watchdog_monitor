#!/usr/bin/env swift

import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var timer: Timer?
    var statusData: [String: Any] = [:]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "●"
            button.action = #selector(toggleMenu)
            button.target = self
        }
        
        // Create menu
        menu = NSMenu()
        
        // Start monitoring
        loadStatus()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.loadStatus()
        }
    }
    
    func loadStatus() {
        let statusFile = "/tmp/watchdog_status.txt"
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: statusFile)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            updateStatusBarInactive()
            return
        }
        
        statusData = json
        updateStatusBar()
        updateMenu()
    }
    
    func updateStatusBarInactive() {
        DispatchQueue.main.async { [weak self] in
            if let button = self?.statusItem.button {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: NSColor.systemGray,
                    .font: NSFont.systemFont(ofSize: 8)
                ]
                button.attributedTitle = NSAttributedString(string: "○", attributes: attributes)
                button.toolTip = "Watchdog Monitor - Inactive"
            }
        }
    }
    
    func updateStatusBar() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let status = self.statusData["status"] as? String,
                  let button = self.statusItem.button else { return }
            
            let attributes: [NSAttributedString.Key: Any]
            
            if status.contains("CRÍTICO") || status.contains("ERRO") {
                attributes = [
                    .foregroundColor: NSColor.systemRed,
                    .font: NSFont.systemFont(ofSize: 8)
                ]
                button.attributedTitle = NSAttributedString(string: "●", attributes: attributes)
                button.toolTip = "Watchdog Monitor - ERROR"
            } else if status.contains("AVISO") {
                attributes = [
                    .foregroundColor: NSColor.systemOrange,
                    .font: NSFont.systemFont(ofSize: 8)
                ]
                button.attributedTitle = NSAttributedString(string: "●", attributes: attributes)
                button.toolTip = "Watchdog Monitor - WARNING"
            } else {
                attributes = [
                    .foregroundColor: NSColor.systemGreen,
                    .font: NSFont.systemFont(ofSize: 8)
                ]
                button.attributedTitle = NSAttributedString(string: "●", attributes: attributes)
                button.toolTip = "Watchdog Monitor - OK"
            }
        }
    }
    
    func updateMenu() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.menu.removeAllItems()
            
            // Title
            let titleItem = NSMenuItem(title: "SYSTEM MONITOR", action: nil, keyEquivalent: "")
            titleItem.isEnabled = false
            self.menu.addItem(titleItem)
            self.menu.addItem(NSMenuItem.separator())
            
            // Status
            if let status = self.statusData["status"] as? String {
                let statusItem = NSMenuItem(title: "Status: \(status)", action: nil, keyEquivalent: "")
                statusItem.isEnabled = false
                self.menu.addItem(statusItem)
                self.menu.addItem(NSMenuItem.separator())
            }
            
            // Checks with colored dots
            if let checks = self.statusData["checks"] as? [String: String] {
                let checkOrder = ["smc", "thermal", "io", "load", "memory"]
                let checkLabels = [
                    "smc": "SMC Status",
                    "thermal": "Temperature",
                    "io": "Disk I/O",
                    "load": "System Load",
                    "memory": "Memory"
                ]
                
                for key in checkOrder {
                    guard let value = checks[key],
                          let label = checkLabels[key] else { continue }
                    
                    let color: NSColor
                    if value.contains("OK") {
                        color = NSColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0) // #34C759
                    } else if value.contains("CRÍTICO") || value.contains("ERRO") {
                        color = NSColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0) // #FF3B30
                    } else if value.contains("AVISO") || value.contains("ALTO") || value.contains("BAIXO") {
                        color = NSColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0) // #FF9500
                    } else {
                        color = .systemGray
                    }
                    
                    // Create colored dot image
                    let dotImage = NSImage(size: NSSize(width: 12, height: 12))
                    dotImage.lockFocus()
                    color.setFill()
                    let circle = NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 8, height: 8))
                    circle.fill()
                    dotImage.unlockFocus()
                    
                    let checkItem = NSMenuItem(title: "  \(label): \(value)", action: nil, keyEquivalent: "")
                    checkItem.image = dotImage
                    checkItem.isEnabled = false
                    self.menu.addItem(checkItem)
                }
                self.menu.addItem(NSMenuItem.separator())
            }
            
            // Uptime
            if let uptime = self.statusData["uptime"] as? String,
               let timestamp = self.statusData["timestamp"] as? String {
                let uptimeItem = NSMenuItem(title: "\(uptime) cycles • \(timestamp)", action: nil, keyEquivalent: "")
                uptimeItem.isEnabled = false
                self.menu.addItem(uptimeItem)
                self.menu.addItem(NSMenuItem.separator())
            }
            
            // Actions
            self.menu.addItem(NSMenuItem(title: "Open Terminal View", action: #selector(self.openTerminal), keyEquivalent: "t"))
            self.menu.addItem(NSMenuItem(title: "Open Web Dashboard", action: #selector(self.openDashboard), keyEquivalent: "d"))
            self.menu.addItem(NSMenuItem.separator())
            
            self.menu.addItem(NSMenuItem(title: "Restart Monitor", action: #selector(self.restartMonitor), keyEquivalent: "r"))
            self.menu.addItem(NSMenuItem(title: "Stop Monitor", action: #selector(self.stopMonitor), keyEquivalent: "s"))
            self.menu.addItem(NSMenuItem.separator())
            
            self.menu.addItem(NSMenuItem(title: "Disable/Enable Watchdog", action: #selector(self.toggleWatchdog), keyEquivalent: "w"))
            self.menu.addItem(NSMenuItem.separator())
            
            // View Logs submenu
            let logsMenu = NSMenu()
            logsMenu.addItem(NSMenuItem(title: "Monitor Logs", action: #selector(self.viewMonitorLogs), keyEquivalent: ""))
            logsMenu.addItem(NSMenuItem(title: "Recovery Logs (tail -f)", action: #selector(self.viewRecoveryLogs), keyEquivalent: ""))
            let logsMenuItem = NSMenuItem(title: "View Logs", action: nil, keyEquivalent: "l")
            logsMenuItem.submenu = logsMenu
            self.menu.addItem(logsMenuItem)
            
            self.menu.addItem(NSMenuItem(title: "Run Diagnostics", action: #selector(self.runDiagnostics), keyEquivalent: ""))
            self.menu.addItem(NSMenuItem.separator())
            
            // Settings submenu
            let settingsMenu = NSMenu()
            let autoStartItem = NSMenuItem(title: self.isAutoStartEnabled() ? "✓ Iniciar com o Sistema" : "  Iniciar com o Sistema", 
                                          action: #selector(AppDelegate.toggleAutoStart), 
                                          keyEquivalent: "")
            autoStartItem.target = self
            settingsMenu.addItem(autoStartItem)
            
            let settingsItem = NSMenuItem(title: "Configurações", action: nil, keyEquivalent: "")
            settingsItem.submenu = settingsMenu
            self.menu.addItem(settingsItem)
            self.menu.addItem(NSMenuItem.separator())
            
            self.menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        }
    }
    
    @objc func toggleMenu() {
        if let button = statusItem.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 5), in: button)
        }
    }
    
    @objc func openTerminal() {
        runCommand("osascript -e 'tell application \"Terminal\" to do script \"cd ~/Projects/watchdog_monitor && ./scripts/watchdog_monitor_visual.sh\"'")
    }
    
    @objc func openDashboard() {
        runCommand("cd ~/Projects/watchdog_monitor && ./scripts/open_dashboard.sh")
    }
    
    @objc func restartMonitor() {
        runCommand("pgrep -f watchdog_monitor_visual.sh | xargs kill; sleep 1; cd ~/Projects/watchdog_monitor && nohup ./scripts/watchdog_monitor_visual.sh --daemon > /dev/null 2>&1 &")
    }
    
    @objc func stopMonitor() {
        runCommand("pgrep -f watchdog_monitor_visual.sh | xargs kill")
    }
    
    @objc func toggleWatchdog() {
        runCommand("osascript -e 'tell application \"Terminal\" to do script \"cd ~/Projects/watchdog_monitor && ./scripts/disable_watchdog.sh\"'")
    }
    
    @objc func viewMonitorLogs() {
        runCommand("open ~/Projects/watchdog_monitor/logs/watchdog_monitor.log")
    }
    
    @objc func viewRecoveryLogs() {
        runCommand("osascript -e 'tell application \"Terminal\" to do script \"tail -f ~/Projects/watchdog_monitor/logs/watchdog_recovery.log\"'")
    }
    
    @objc func runDiagnostics() {
        runCommand("osascript -e 'tell application \"Terminal\" to do script \"cd ~/Projects/watchdog_monitor && ./scripts/diagnostico_disco.sh\"'")
    }
    
    func isAutoStartEnabled() -> Bool {
        let launchAgentPath = NSHomeDirectory() + "/Library/LaunchAgents/com.watchdog.menubar.plist"
        return FileManager.default.fileExists(atPath: launchAgentPath)
    }
    
    @objc func toggleAutoStart() {
        let launchAgentPath = NSHomeDirectory() + "/Library/LaunchAgents/com.watchdog.menubar.plist"
        
        if isAutoStartEnabled() {
            // Disable auto-start - apenas remove o arquivo, não unload
            do {
                try FileManager.default.removeItem(atPath: launchAgentPath)
                
                let alert = NSAlert()
                alert.messageText = "Inicialização Automática Desabilitada"
                alert.informativeText = "O app não será mais iniciado automaticamente com o sistema.\n\nNota: A alteração terá efeito no próximo login."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
                
                // Refresh menu
                loadStatus()
            } catch {
                let alert = NSAlert()
                alert.messageText = "Erro"
                alert.informativeText = "Falha ao remover configuração: \(error.localizedDescription)"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        } else {
            // Enable auto-start
            let appPath = Bundle.main.bundlePath
            let executablePath = appPath.hasSuffix(".app") ? 
                "\(appPath)/Contents/MacOS/WatchdogMenuBar" : appPath
            
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>com.watchdog.menubar</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(executablePath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <true/>
            </dict>
            </plist>
            """
            
            do {
                try plistContent.write(toFile: launchAgentPath, atomically: true, encoding: .utf8)
                
                let alert = NSAlert()
                alert.messageText = "Inicialização Automática Habilitada"
                alert.informativeText = "O app será iniciado automaticamente quando você fizer login.\n\nNota: A alteração terá efeito no próximo login."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
                
                // Refresh menu
                loadStatus()
            } catch {
                let alert = NSAlert()
                alert.messageText = "Erro"
                alert.informativeText = "Falha ao configurar inicialização automática: \(error.localizedDescription)"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
    
    func runCommand(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.launch()
    }
}

// Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
