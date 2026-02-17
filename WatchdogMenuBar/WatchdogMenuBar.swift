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
            
            self.menu.addItem(NSMenuItem(title: "View Logs", action: #selector(self.viewLogs), keyEquivalent: "l"))
            self.menu.addItem(NSMenuItem(title: "Run Diagnostics", action: #selector(self.runDiagnostics), keyEquivalent: ""))
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
    
    @objc func viewLogs() {
        runCommand("open ~/Projects/watchdog_monitor/logs/watchdog_monitor.log")
    }
    
    @objc func runDiagnostics() {
        runCommand("osascript -e 'tell application \"Terminal\" to do script \"cd ~/Projects/watchdog_monitor && ./scripts/diagnostico_disco.sh\"'")
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
