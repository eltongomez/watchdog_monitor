# Instalação do Watchdog Monitor v3.0

## 🚀 Instalação Rápida

### Método 1: Download do App (Mais Fácil)

1. **Download do WatchdogMonitor.app:**
   - Acesse: [GitHub Releases](https://github.com/eltongomez/watchdog_monitor/releases/latest)
   - Baixe: `WatchdogMonitor-v3.0.0.zip`
   - Descompacte o arquivo

2. **Instale o App:**
   ```bash
   # Mova para a pasta Applications
   mv WatchdogMonitor.app ~/Applications/
   
   # Primeira execução
   open ~/Applications/WatchdogMonitor.app
   ```

3. **Configure Permissões Sudo (Importante!):**
   ```bash
   # Clone apenas os scripts de configuração
   curl -O https://raw.githubusercontent.com/eltongomez/watchdog_monitor/main/scripts/setup_sudo.sh
   chmod +x setup_sudo.sh
   ./setup_sudo.sh
   ```

4. **Ative Auto-Start:**
   - Clique no ícone do Watchdog na barra de menu
   - Vá em: **Configurações** → **Iniciar com o Sistema**
   - ✓ O app agora inicia automaticamente no login

### Método 2: Instalação Completa (Para Desenvolvedores)

```bash
# 1. Clone o repositório
git clone https://github.com/eltongomez/watchdog_monitor.git
cd watchdog_monitor

# 2. Torne os scripts executáveis
chmod +x scripts/*.sh

# 3. Configure sudo (necessário para recovery)
./scripts/setup_sudo.sh

# 4. Inicie o monitor
./scripts/watchdog_monitor_visual.sh --daemon

# 5. Instale o Menu Bar App
mkdir -p ~/Applications/WatchdogMonitor
cp -R WatchdogMonitor.app ~/Applications/
open ~/Applications/WatchdogMonitor.app
```

### Método 3: Via Homebrew (Em breve!)

```bash
brew tap eltongomez/watchdog
brew install watchdog-monitor
```

## ⚙️ Configuração Inicial

### 1. Permissões Sudo

O sistema de recovery precisa de permissões sudo para executar `purge` (limpeza de memória).

**Script automático:**
```bash
./scripts/setup_sudo.sh
```

**Manual (se preferir):**
```bash
# Edite o arquivo sudoers
sudo visudo -f /etc/sudoers.d/watchdog

# Adicione esta linha (substitua 'seu_usuario' pelo seu username):
seu_usuario ALL=(ALL) NOPASSWD: /usr/sbin/purge, /sbin/reboot, /bin/sync

# Salve com: Ctrl+O, Enter, Ctrl+X
```

### 2. Iniciar com o Sistema

**Via App (Recomendado):**
- Clique no ícone na barra de menu
- **Configurações** → **Iniciar com o Sistema** ✓

**Manual:**
```bash
# Copie o LaunchAgent
cp ~/Projects/watchdog_monitor/com.eltongomez.watchdogmonitor.plist ~/Library/LaunchAgents/

# Carregue o agent
launchctl load ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist
```

## 🎯 Verificação

### Confirme que está funcionando:

```bash
# 1. Monitor daemon está rodando?
pgrep -lf watchdog_monitor

# 2. Menu bar app está rodando?
ps aux | grep WatchdogMenuBar | grep -v grep

# 3. Sudo funciona sem senha?
sudo -n purge

# 4. Veja os logs
tail -f ~/Projects/watchdog_monitor/logs/watchdog_monitor.log
tail -f ~/Projects/watchdog_monitor/logs/watchdog_recovery.log
```

### Status esperado:
- ✅ Ícone 🛡️ visível na barra de menu
- ✅ Status: 🟢 (verde = OK)
- ✅ Logs atualizando a cada 15 segundos
- ✅ `sudo -n purge` executa sem pedir senha

## 📱 Uso do App

### Menu Principal:
- **Open Terminal View** - Visualização interativa no Terminal
- **Open Web Dashboard** - Dashboard visual no navegador
- **Restart Monitor** - Reinicia o daemon de monitoramento
- **Stop Monitor** - Para o daemon
- **Disable/Enable Watchdog** - Desabilita watchdog do sistema (diagnóstico)
- **View Logs** → 
  - Monitor Logs - Logs principais
  - Recovery Logs (tail -f) - Logs de recovery em tempo real
- **Run Diagnostics** - Executa diagnósticos completos
- **Configurações** →
  - Iniciar com o Sistema - Toggle de auto-start

### Interpretação do Status:
- 🟢 **Verde** - Sistema OK (Load < 4.0, Mem > 1000MB)
- 🟡 **Amarelo** - Alerta (Load 4.0-5.0 ou Mem 500-1000MB)
- 🔴 **Vermelho** - Crítico (Load > 5.0 ou Mem < 500MB) - Recovery ativo!

## 🔧 Troubleshooting

### App não abre?
```bash
# Verifique permissões
chmod +x ~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar

# Tente abrir via terminal para ver erros
~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar
```

### Recovery não funciona?
```bash
# Verifique sudo
sudo -n purge
# Se pedir senha, rode novamente:
./scripts/setup_sudo.sh
```

### Monitor não inicia no boot?
```bash
# Verifique LaunchAgent
ls -l ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist

# Recarregue
launchctl unload ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist
launchctl load ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist
```

## 🗑️ Desinstalação

```bash
# 1. Pare os processos
pkill -f watchdog_monitor
pkill -f WatchdogMenuBar

# 2. Remova LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist
rm ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist

# 3. Remova o app
rm -rf ~/Applications/WatchdogMonitor.app

# 4. Remova sudo config (opcional)
sudo rm /etc/sudoers.d/watchdog

# 5. Remova logs e configs (opcional)
rm -rf ~/Projects/watchdog_monitor
```

## 📞 Suporte

- **Issues**: https://github.com/eltongomez/watchdog_monitor/issues
- **Discussões**: https://github.com/eltongomez/watchdog_monitor/discussions
- **Email**: [seu_email]

## 🔄 Atualizações

Para atualizar para uma nova versão:

```bash
# Pare o app atual
pkill -f WatchdogMenuBar

# Baixe a nova versão do GitHub Releases
# Substitua o app antigo
mv WatchdogMonitor.app ~/Applications/ (sobrescrever)

# Reinicie
open ~/Applications/WatchdogMonitor.app
```

---

**Versão:** 3.0.0  
**Data:** 2026-02-17  
**Licença:** MIT
