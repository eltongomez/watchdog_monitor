# 📊 Feedback Visual - Guia de Instalação e Uso

## 🎨 Sistemas de Feedback Implementados

Este projeto agora inclui **3 sistemas de feedback visual**:

1. **Dashboard Terminal Interativo** - Atualização em tempo real no terminal
2. **Notificações macOS** - Alertas nativos do sistema
3. **Dashboard Web** - Interface HTML moderna e responsiva
4. **Menu Bar Widget** *(opcional)* - Ícone na barra de menu (requer SwiftBar/BitBar)

---

## 🚀 Uso Rápido

### 1️⃣ Dashboard Terminal (Recomendado)

Monitor visual completo com atualização em tempo real no terminal:

```bash
cd ~/Projects/watchdog_monitor
./scripts/watchdog_monitor_visual.sh
```

**Características:**
- ✅ Interface visual colorida em tempo real
- ✅ Status de todas as verificações
- ✅ Últimos eventos em formato dashboard
- ✅ Notificações automáticas do macOS
- ✅ Atualização a cada intervalo configurado

**Screenshot do Dashboard Terminal:**
```
╔════════════════════════════════════════════════════════════╗
║     🛡️  WATCHDOG MONITOR - DASHBOARD EM TEMPO REAL        ║
╠════════════════════════════════════════════════════════════╣
║ 2026-02-16 20:35:42                                        ║
╠════════════════════════════════════════════════════════════╣
║  Status:  ✅ TODOS OK                                      ║
║  Uptime:  5m                                               ║
╠════════════════════════════════════════════════════════════╣
║  VERIFICAÇÕES                                              ║
╠════════════════════════════════════════════════════════════╣
║  SMC:         ✓ OK                                         ║
║  Temperatura: ✓ OK (0)                                     ║
║  Disco I/O:   ✓ OK (1s)                                    ║
║  Carga:       ✓ OK (1.25)                                  ║
║  Memória:     ✓ OK (2450MB)                                ║
╠════════════════════════════════════════════════════════════╣
║  ÚLTIMOS EVENTOS                                           ║
╠════════════════════════════════════════════════════════════╣
║  [2026-02-16 20:35:40] SMC: OK                             ║
║  [2026-02-16 20:35:40] THERMAL: OK (0)                     ║
║  [2026-02-16 20:35:41] DISK I/O: OK (1s)                   ║
║  [2026-02-16 20:35:41] LOAD: OK (1.25)                     ║
║  [2026-02-16 20:35:41] MEMORY: OK (2450MB)                 ║
╚════════════════════════════════════════════════════════════╝

Pressione Ctrl+C para parar o monitoramento
```

### 2️⃣ Modo Daemon (Background)

Executar em background sem ocupar o terminal:

```bash
cd ~/Projects/watchdog_monitor
./scripts/watchdog_monitor_visual.sh --daemon
```

**Características:**
- ✅ Roda em background
- ✅ Notificações macOS quando há problemas
- ✅ Logs salvos automaticamente
- ✅ Pode ser iniciado no boot (via LaunchAgent)

**Para parar o daemon:**
```bash
kill $(cat /tmp/watchdog_monitor_visual.pid)
```

### 3️⃣ Dashboard Web

Interface HTML moderna que abre no navegador:

```bash
cd ~/Projects/watchdog_monitor
./scripts/open_dashboard.sh
```

**Características:**
- ✅ Interface moderna e responsiva
- ✅ Atualização automática a cada 5 segundos
- ✅ Gráficos visuais coloridos
- ✅ Funciona em qualquer navegador
- ✅ Pode ficar aberto em segundo plano

**Preview:**
- Status geral com badge colorido (verde/amarelo/vermelho)
- Cards individuais para cada métrica
- Ícones intuitivos (💻 SMC, 🌡️ Temperatura, 💾 Disco, etc)
- Botão de refresh manual
- Auto-refresh a cada 5 segundos

---

## 📱 Notificações macOS

O sistema envia notificações automáticas quando:

- ✅ **Monitor iniciado** - Confirmação de início
- ⚠️ **Problemas detectados** - Alerta com som quando encontra problemas
- ✅ **Sistema normalizado** - Confirmação quando problemas são resolvidos

**Sons usados:**
- `Glass` - Início do monitor
- `Basso` - Avisos (1-2 problemas)
- `Sosumi` - Problemas críticos (3+ problemas)

---

## 🔔 Menu Bar Widget (Opcional)

Para ter um ícone na barra de menu do macOS com status em tempo real:

### Instalação do SwiftBar

1. **Instalar SwiftBar via Homebrew:**
```bash
brew install --cask swiftbar
```

2. **Configurar diretório de plugins:**
```bash
mkdir -p ~/.swiftbar
ln -s ~/Projects/watchdog_monitor/scripts/watchdog_widget.1m.sh ~/.swiftbar/
```

3. **Abrir SwiftBar:**
- Abra SwiftBar nas Aplicações
- Clique no ícone do SwiftBar na barra de menu
- Selecione "Preferences"
- Defina "Plugin Folder" como `~/.swiftbar`
- Clique em "Refresh All"

### Resultado

Você verá um ícone na barra de menu:
- **✅** - Tudo OK (verde)
- **⚠️** - Avisos (amarelo)
- **❌** - Problemas (vermelho)
- **🛡️** - Offline (cinza)

**Clicando no ícone:**
```
✅
---
🛡️ Watchdog Monitor
Status: TODOS OK
Última verificação: 2026-02-16 20:35:42
---
📊 Verificações:
  SMC: OK
  Temperatura: OK (0)
  Disco I/O: OK (1s)
  Carga: OK (1.25)
  Memória: OK (2450MB)
---
🔄 Atualizar
📋 Ver Logs
⚙️ Abrir Dashboard
🛑 Parar Monitor
```

---

## ⚙️ Configuração Avançada

### Iniciar Automaticamente no Boot

Criar LaunchAgent para iniciar o monitor automaticamente:

```bash
cat > ~/Library/LaunchAgents/com.user.watchdog-monitor-visual.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.watchdog-monitor-visual</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/elima/Projects/watchdog_monitor/scripts/watchdog_monitor_visual.sh</string>
        <string>--daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/watchdog-monitor-visual.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/watchdog-monitor-visual-error.log</string>
</dict>
</plist>
EOF

# Carregar o serviço
launchctl load ~/Library/LaunchAgents/com.user.watchdog-monitor-visual.plist
```

**Para desabilitar:**
```bash
launchctl unload ~/Library/LaunchAgents/com.user.watchdog-monitor-visual.plist
rm ~/Library/LaunchAgents/com.user.watchdog-monitor-visual.plist
```

### Personalizar Intervalo

Por padrão, o monitor verifica a cada 30 segundos. Para mudar:

```bash
# No modo interativo, digite o intervalo desejado
./scripts/watchdog_monitor_visual.sh
# Digite: 15 (para 15 segundos)

# No modo daemon, edite o script e mude a linha:
monitor_visual 30  # para o valor desejado
```

### Personalizar Notificações

Edite `watchdog_monitor_visual.sh` e modifique a função `send_notification`:

```bash
# Desabilitar som das notificações
send_notification "Título" "Mensagem" ""

# Usar outro som (veja: /System/Library/Sounds/)
send_notification "Título" "Mensagem" "Funk"
```

---

## 📊 Logs

Todos os eventos são registrados em:
```
~/Projects/watchdog_monitor/logs/watchdog_monitor.log
```

**Ver logs em tempo real:**
```bash
tail -f ~/Projects/watchdog_monitor/logs/watchdog_monitor.log
```

**Ver últimos 50 eventos:**
```bash
./scripts/show_logs.sh
```

---

## 🎨 Código de Cores

### Terminal Dashboard

| Cor | Significado |
|-----|-------------|
| 🟢 Verde | Tudo OK |
| 🟡 Amarelo | Aviso |
| 🔴 Vermelho | Problema |
| 🔵 Azul | Informação |

### Status Geral

| Ícone | Status | Descrição |
|-------|--------|-----------|
| ✅ | TODOS OK | Todas as verificações passaram |
| ⚠️ | X AVISOS | 1-2 problemas detectados |
| ❌ | X PROBLEMAS | 3+ problemas críticos |

---

## 🔍 Troubleshooting

### Notificações não aparecem

1. **Verificar permissões:**
   - System Preferences → Notifications
   - Procure por "Script Editor" ou "Terminal"
   - Ative "Allow Notifications"

2. **Testar manualmente:**
```bash
osascript -e 'display notification "Teste" with title "Watchdog"'
```

### Dashboard Web não carrega status

1. **Verificar se o monitor está rodando:**
```bash
ps aux | grep watchdog_monitor
```

2. **Verificar arquivo de status:**
```bash
cat /tmp/watchdog_status.txt
```

3. **Reiniciar o monitor:**
```bash
./scripts/watchdog_monitor_visual.sh --daemon
```

### Widget da barra de menu não aparece

1. **Verificar se SwiftBar está instalado:**
```bash
brew list | grep swiftbar
```

2. **Verificar permissões do script:**
```bash
ls -l ~/.swiftbar/watchdog_widget.1m.sh
```

3. **Refresh manual no SwiftBar:**
- Clique no ícone do SwiftBar
- Selecione "Refresh All"

---

## 📈 Performance

O monitor tem impacto **mínimo** no sistema:

- **CPU**: < 0.5% em média
- **Memória**: ~10MB
- **Disco**: Apenas logs (crescimento lento)
- **Verificações**: Leves e rápidas (< 2s cada ciclo)

---

## 🎯 Recomendações de Uso

### Para Uso Diário
```bash
# Terminal: Dashboard visual
./scripts/watchdog_monitor_visual.sh

# Ou daemon + dashboard web
./scripts/watchdog_monitor_visual.sh --daemon
./scripts/open_dashboard.sh
```

### Para Monitoramento de Longo Prazo
```bash
# Daemon + LaunchAgent (auto-start no boot)
# + SwiftBar widget na barra de menu
```

### Para Diagnóstico de Problemas
```bash
# Dashboard terminal (ver em tempo real)
./scripts/watchdog_monitor_visual.sh

# Revisar logs
./scripts/show_logs.sh
```

---

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs: `~/Projects/watchdog_monitor/logs/watchdog_monitor.log`
2. Teste cada componente individualmente
3. Abra uma issue no GitHub com detalhes

---

**Aproveite o monitoramento visual! 🎉**
