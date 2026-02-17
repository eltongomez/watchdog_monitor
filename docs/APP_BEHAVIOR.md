# Comportamento do Watchdog Monitor App

## 🎯 Como Funciona

O **WatchdogMonitor.app** é um aplicativo tipo **menu bar** (acessório do macOS) que:

- ✅ **Pode ser iniciado clicando** no ícone em Applications
- ✅ **Não aparece no Dock** quando rodando (apenas na barra de menu)
- ✅ **Pode auto-iniciar** no login do sistema (configurável)
- ✅ **Não cria janela principal** (funciona apenas via menu bar)

## 🚀 Formas de Iniciar o App

### 1. Clicando no Ícone (Manual)
```
1. Abra Finder
2. Vá para Applications
3. Clique em WatchdogMonitor.app
4. App aparece na barra de menu (ícone ●)
```

### 2. Via Terminal
```bash
open ~/Applications/WatchdogMonitor.app
# ou
open -a "WatchdogMonitor"
```

### 3. Auto-Start no Login (Automático)
```
1. Clique no ícone na barra de menu
2. Configurações → Iniciar com o Sistema ✓
3. App inicia automaticamente no próximo login
```

## ⚙️ Configuração Técnica

### activationPolicy = .accessory

O app usa `NSApp.setActivationPolicy(.accessory)` que significa:

- **Pode ser iniciado** via Finder, Spotlight, Terminal
- **Não aparece no Dock** quando ativo
- **Não tem janela principal** (menu bar only)
- **Pode ser fechado** via menu "Quit"

### Antes vs Depois

**Antes (LSUIElement = true no Info.plist):**
- ❌ Não iniciava ao clicar no ícone
- ✅ Não aparecia no Dock
- ⚠️ Só funcionava via LaunchAgent ou Terminal

**Agora (activationPolicy = .accessory):**
- ✅ Inicia ao clicar no ícone
- ✅ Não aparece no Dock
- ✅ Funciona via clique, LaunchAgent ou Terminal

## 🔄 Auto-Start

### Como Habilitar
```
Menu Bar → Configurações → Iniciar com o Sistema ✓
```

Isso cria o arquivo:
```
~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist
```

Com conteúdo:
```xml
<key>RunAtLoad</key>
<true/>
<key>ProgramArguments</key>
<array>
    <string>/Users/[seu_usuario]/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar</string>
</array>
```

### Como Desabilitar
```
Menu Bar → Configurações → Iniciar com o Sistema (desmarcar)
```

Isso remove o arquivo LaunchAgent.

**Nota**: Mudanças no auto-start têm efeito no **próximo login**, não imediatamente.

## 🛑 Como Fechar o App

### Via Menu
```
Menu Bar → Quit
```

### Via Terminal
```bash
# Encontrar PID
ps aux | grep WatchdogMenuBar | grep -v grep

# Fechar (substitua PID pelo número)
kill [PID]
```

## 🔍 Troubleshooting

### App não abre ao clicar no ícone
```bash
# Verificar permissões
ls -la ~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar

# Deve mostrar: -rwxr-xr-x (executável)
# Se não for executável:
chmod +x ~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar
```

### App já está rodando
```bash
# Verificar se já está rodando
ps aux | grep WatchdogMenuBar | grep -v grep

# Se estiver, feche primeiro
kill [PID]

# Depois abra novamente
open ~/Applications/WatchdogMonitor.app
```

### App não auto-inicia no login
```bash
# Verificar se LaunchAgent existe
ls -la ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist

# Verificar se está carregado
launchctl list | grep watchdog

# Recarregar
launchctl unload ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist
launchctl load ~/Library/LaunchAgents/com.eltongomez.watchdogmonitor.plist
```

### Múltiplas instâncias rodando
```bash
# Ver todas as instâncias
ps aux | grep WatchdogMenuBar | grep -v grep

# Fechar todas
ps aux | grep WatchdogMenuBar | grep -v grep | awk '{print $2}' | xargs kill
```

## 📱 Comportamento Esperado

### Cenário 1: Primeira Instalação
1. Usuário clica em WatchdogMonitor.app no Finder
2. App inicia e ícone ● aparece na barra de menu
3. Auto-start: **Desabilitado** (padrão)
4. App fecha quando faz logout

### Cenário 2: Com Auto-Start Habilitado
1. Usuário habilita: Configurações → Iniciar com o Sistema
2. Faz logout/login
3. App inicia automaticamente
4. Ícone ● aparece na barra de menu
5. App persiste entre logins

### Cenário 3: Uso Manual
1. Auto-start: **Desabilitado**
2. Usuário abre WatchdogMonitor.app quando precisar
3. App roda até ser fechado manualmente
4. Não inicia no próximo login

## 🎨 Ícone na Barra de Menu

O ícone muda de cor baseado no status:

- 🟢 **Verde**: Sistema OK (Load < 4.0, Mem > 1000MB)
- 🟡 **Amarelo**: Alerta (Load 4.0-5.0 ou Mem 500-1000MB)
- 🔴 **Vermelho**: Crítico (Load > 5.0 ou Mem < 500MB)
- ⚪ **Cinza**: Monitor inativo ou erro

## 📝 Logs

### App Logs (se houver problemas)
```bash
# Logs do LaunchAgent
tail -f /tmp/watchdog-menubar.log
tail -f /tmp/watchdog-menubar-error.log

# Logs do monitor
tail -f ~/Projects/watchdog_monitor/logs/watchdog_monitor.log

# Logs de recovery
tail -f ~/Projects/watchdog_monitor/logs/watchdog_recovery.log
```

---

**Versão**: 3.0.1  
**Data**: 2026-02-17  
**Tipo**: Menu Bar App (Accessory)
