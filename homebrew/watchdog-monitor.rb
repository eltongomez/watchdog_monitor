class WatchdogMonitor < Formula
  desc "macOS Kernel Panic Prevention with Automatic Recovery System"
  homepage "https://github.com/eltongomez/watchdog_monitor"
  url "https://github.com/eltongomez/watchdog_monitor/releases/download/v3.0.0/WatchdogMonitor-v3.0.0.zip"
  sha256 "3c001ac7dc7ddf606b4de26706f0c99a5a2bfc4207b9419e8246e7075efee456"
  license "MIT"
  version "3.0.0"

  depends_on :macos

  def install
    prefix.install "WatchdogMonitor.app"
    bin.install_symlink prefix/"WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar" => "watchdog-monitor"
  end

  def caveats
    <<~EOS
      Watchdog Monitor instalado! Para iniciar:
        open #{prefix}/WatchdogMonitor.app
      
      Configure sudo para recovery: https://github.com/eltongomez/watchdog_monitor
    EOS
  end

  test do
    assert_predicate prefix/"WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar", :exist?
  end
end
