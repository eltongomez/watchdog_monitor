#!/usr/bin/env swift

import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var timer: Timer?
    var statusData: [String: Any] = [:]
    var daemonStartedByApp = false
    var daemonPID: Int32 = 0
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configurar app como acessório (não aparece no Dock mas pode ser iniciado)
        NSApp.setActivationPolicy(.accessory)
        
        // Configurar handler para sinais de término
        signal(SIGTERM) { _ in
            NSApp.terminate(nil)
        }
        signal(SIGINT) { _ in
            NSApp.terminate(nil)
        }
        
        // Iniciar daemon do monitor
        startDaemon()
        
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
                let checkOrder = ["smc", "thermal", "io", "load", "memory", "fan_rpm"]
                let checkLabels = [
                    "smc": "SMC Status",
                    "thermal": "Temperature",
                    "io": "Disk I/O",
                    "load": "System Load",
                    "memory": "Memory",
                    "fan_rpm": "Coolers"
                ]
                
                for key in checkOrder {
                    guard let value = checks[key],
                          let label = checkLabels[key] else { continue }
                    
                    let color: NSColor
                    if key == "fan_rpm" {
                        // Cor especial para RPM baseado no valor
                        if value.contains("4200-") || value.contains("4800") {
                            color = NSColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0) // Vermelho
                        } else if value.contains("3500-") {
                            color = NSColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0) // Laranja
                        } else {
                            color = NSColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0) // Verde
                        }
                    } else if value.contains("OK") {
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
            
            // Recovery Profile submenu (v3.2)
            let profileMenu = NSMenu()
            let currentProfile = self.getConfigValue("RECOVERY_PROFILE") ?? "conservative"
            
            let conservativeItem = NSMenuItem(title: currentProfile == "conservative" ? "✓ Conservative (Safe)" : "  Conservative (Safe)", 
                                             action: #selector(self.setProfile(_:)), 
                                             keyEquivalent: "")
            conservativeItem.representedObject = "conservative"
            profileMenu.addItem(conservativeItem)
            
            let balancedItem = NSMenuItem(title: currentProfile == "balanced" ? "✓ Balanced (Recommended)" : "  Balanced (Recommended)", 
                                         action: #selector(self.setProfile(_:)), 
                                         keyEquivalent: "")
            balancedItem.representedObject = "balanced"
            profileMenu.addItem(balancedItem)
            
            let aggressiveItem = NSMenuItem(title: currentProfile == "aggressive" ? "✓ Aggressive (Performance)" : "  Aggressive (Performance)", 
                                           action: #selector(self.setProfile(_:)), 
                                           keyEquivalent: "")
            aggressiveItem.representedObject = "aggressive"
            profileMenu.addItem(aggressiveItem)
            
            let profileItem = NSMenuItem(title: "Recovery Profile", action: nil, keyEquivalent: "")
            profileItem.submenu = profileMenu
            self.menu.addItem(profileItem)
            
            // Anti-Crash Mode submenu (v3.2)
            let antiCrashMenu = NSMenu()
            let currentMode = self.getConfigValue("ANTI_CRASH_MODE") ?? "0"
            
            let offItem = NSMenuItem(title: currentMode == "0" ? "✓ Off" : "  Off", 
                                    action: #selector(self.setAntiCrashMode(_:)), 
                                    keyEquivalent: "")
            offItem.representedObject = "0"
            antiCrashMenu.addItem(offItem)
            
            let lightItem = NSMenuItem(title: currentMode == "1" ? "✓ Light" : "  Light", 
                                      action: #selector(self.setAntiCrashMode(_:)), 
                                      keyEquivalent: "")
            lightItem.representedObject = "1"
            antiCrashMenu.addItem(lightItem)
            
            let moderateItem = NSMenuItem(title: currentMode == "2" ? "✓ Moderate" : "  Moderate", 
                                         action: #selector(self.setAntiCrashMode(_:)), 
                                         keyEquivalent: "")
            moderateItem.representedObject = "2"
            antiCrashMenu.addItem(moderateItem)
            
            let aggressiveModeItem = NSMenuItem(title: currentMode == "3" ? "✓ Aggressive" : "  Aggressive", 
                                               action: #selector(self.setAntiCrashMode(_:)), 
                                               keyEquivalent: "")
            aggressiveModeItem.representedObject = "3"
            antiCrashMenu.addItem(aggressiveModeItem)
            
            let antiCrashItem = NSMenuItem(title: "Anti-Crash Mode", action: nil, keyEquivalent: "")
            antiCrashItem.submenu = antiCrashMenu
            self.menu.addItem(antiCrashItem)
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
        // Parar daemon
        let killTask = Process()
        killTask.launchPath = "/bin/bash"
        killTask.arguments = ["-c", "pgrep -f watchdog_monitor_visual.sh | xargs kill 2>/dev/null || true"]
        killTask.launch()
        killTask.waitUntilExit()
        
        // Aguardar
        sleep(1)
        
        // Reiniciar
        startDaemon()
    }
    
    @objc func stopMonitor() {
        stopDaemon()
        daemonStartedByApp = false
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
        let launchAgentPath = NSHomeDirectory() + "/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist"
        return FileManager.default.fileExists(atPath: launchAgentPath)
    }
    
    @objc func toggleAutoStart() {
        let launchAgentPath = NSHomeDirectory() + "/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist"
        
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
                <string>com.eltongomez.watchdogmonitor</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(executablePath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <false/>
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
    
    func startDaemon() {
        // Verificar se daemon já está rodando
        let checkTask = Process()
        checkTask.launchPath = "/bin/bash"
        checkTask.arguments = ["-c", "pgrep -f 'watchdog_monitor_visual.sh --daemon'"]
        
        let pipe = Pipe()
        checkTask.standardOutput = pipe
        checkTask.launch()
        checkTask.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if output.isEmpty {
            // Daemon não está rodando, iniciar
            let startTask = Process()
            startTask.launchPath = "/bin/bash"
            startTask.arguments = ["-c", "cd ~/Projects/watchdog_monitor && ./scripts/watchdog_monitor_visual.sh --daemon > /tmp/watchdog_daemon.log 2>&1 &"]
            startTask.launch()
            
            daemonStartedByApp = true
            
            // Aguardar daemon iniciar
            sleep(3)
            
            // Capturar PID do daemon iniciado
            let pidTask = Process()
            pidTask.launchPath = "/bin/bash"
            pidTask.arguments = ["-c", "pgrep -f 'watchdog_monitor_visual.sh --daemon'"]
            
            let pidPipe = Pipe()
            pidTask.standardOutput = pidPipe
            pidTask.launch()
            pidTask.waitUntilExit()
            
            let pidData = pidPipe.fileHandleForReading.readDataToEndOfFile()
            if let pidString = String(data: pidData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "\n").first,
               let pid = Int32(String(pidString)) {
                daemonPID = pid
            }
        } else if let pid = Int32(output.split(separator: "\n").first.map(String.init) ?? "") {
            // Daemon já estava rodando, não parar ao fechar app
            daemonPID = pid
            daemonStartedByApp = false
        }
    }
    
    func stopDaemon() {
        if daemonStartedByApp && daemonPID > 0 {
            // Parar apenas se o app que iniciou
            kill(daemonPID, SIGTERM)
            daemonPID = 0
            daemonStartedByApp = false
        }
    }
    
    // Helper function to get config values (v3.2)
    func getConfigValue(_ key: String) -> String? {
        let configPath = NSHomeDirectory() + "/Projects/watchdog_monitor/config/recovery.conf"
        
        guard let content = try? String(contentsOfFile: configPath, encoding: .utf8) else {
            return nil
        }
        
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.starts(with: key + "=") {
                let value = trimmed.replacingOccurrences(of: key + "=", with: "")
                return value.trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
    
    // Recovery Profile actions (v3.2)
    @objc func setProfile(_ sender: NSMenuItem) {
        guard let profile = sender.representedObject as? String else { return }
        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "cd ~/Projects/watchdog_monitor && ./scripts/apply_profile.sh \(profile)"]
        task.launch()
        task.waitUntilExit()
        
        // Refresh menu to show new selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadStatus()
        }
    }
    
    // Anti-Crash Mode actions (v3.2)
    @objc func setAntiCrashMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? String else { return }
        
        let configPath = NSHomeDirectory() + "/Projects/watchdog_monitor/config/recovery.conf"
        
        // Update config file
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "sed -i '' 's/^ANTI_CRASH_MODE=.*/ANTI_CRASH_MODE=\(mode)/' \(configPath)"]
        task.launch()
        task.waitUntilExit()
        
        // Notify user
        let modeNames = ["0": "Off", "1": "Light", "2": "Moderate", "3": "Aggressive"]
        let modeName = modeNames[mode] ?? "Unknown"
        
        let notifyTask = Process()
        notifyTask.launchPath = "/bin/bash"
        notifyTask.arguments = ["-c", "osascript -e 'display notification \"Anti-Crash Mode set to \(modeName)\" with title \"Watchdog Monitor\" sound name \"Glass\"'"]
        notifyTask.launch()
        
        // Restart daemon to apply changes
        restartMonitor()
        
        // Refresh menu to show new selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.loadStatus()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Parar timer
        timer?.invalidate()
        
        // Parar daemon quando app fechar
        stopDaemon()
    }
}

// Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
