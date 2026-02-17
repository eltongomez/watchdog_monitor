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
                button.title = "○"
                button.toolTip = "Watchdog Monitor - Inactive"
            }
        }
    }
    
    func updateStatusBar() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let status = self.statusData["status"] as? String,
                  let button = self.statusItem.button else { return }
            
            if status.contains("CRÍTICO") || status.contains("ERRO") {
                button.title = "●"
                button.toolTip = "Watchdog Monitor - ERROR"
            } else if status.contains("AVISO") {
                button.title = "●"
                button.toolTip = "Watchdog Monitor - WARNING"
            } else {
                button.title = "●"
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
            
            // Checks
            if let checks = self.statusData["checks"] as? [String: String] {
                for (key, value) in checks.sorted(by: { $0.key < $1.key }) {
                    let label = key.uppercased()
                    let checkItem = NSMenuItem(title: "\(label): \(value)", action: nil, keyEquivalent: "")
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
