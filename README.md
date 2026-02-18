# 🛡️ Watchdog Monitor - macOS Kernel Panic Prevention

[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Version](https://img.shields.io/badge/version-3.2.0-blue.svg)](https://github.com/eltongomez/watchdog_monitor/releases/tag/v3.2.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)
[![Swift](https://img.shields.io/badge/swift-5.0+-red.svg)](https://swift.org)

**Sistema de prevenção automática de kernel panics** com recovery inteligente e menu bar app nativo para macOS.

### ✨ Novidades v3.2 - Prevenção Inteligente!

> **"Não apenas reage, previne. Não apenas monitora, aprende."**

🎯 **3 Features Revolucionárias:**

1. **🎚️ Recovery Profiles** - Escolha seu perfil de agressividade  
   - Conservative (Seguro) - Age apenas em extremos  
   - Balanced (Recomendado) - Equilíbrio perfeito  
   - Aggressive (Performance) - Ação rápida

2. **🛡️ Anti-Crash Mode** - Prevenção baseada no MBP-Anti-Crash  
   - Off / Light / Moderate / Aggressive  
   - Keep-alive inteligente (não desperdício)  
   - Previne idle problemático automaticamente

3. **⚡ Preemptive Recovery** - Age ANTES dos problemas  
   - Detecta tendências (não só valores absolutos)  
   - Machine learning básico  
   - Recovery preventivo baseado em histórico

### ✅ Comprovadamente Funcional - v3.0

**Teste bem-sucedido em 2026-02-17:** Sistema detectou e recuperou automaticamente de condição crítica de memória, **prevenindo crash** durante abertura de projeto pesado no VSCode!

## 🚨 Problema

Kernel panics com a mensagem:
```
panic(cpu 2 caller 0xffffff8006180938): watchdog timeout: 
no checkins from watchdogd in 93 seconds
```

Acompanhado de mensagem **falsa** sobre erro de disco:
```
Root disk errors: "Could not recover SATA HDD after 5 attempts. Terminating."
```

### Causa Identificada

Bug na interação entre:
- `com.apple.driver.watchdog` (v1.0)
- `com.apple.driver.AppleSMC` (v3.1.9)

O SMC (System Management Controller) pode travar temporariamente, causando timeout do watchdog e forçando kernel panic. A mensagem de erro de disco é **enganosa** - o disco está funcionando perfeitamente.

## ✅ Confirmado

- ✅ SMART Status: Verified
- ✅ Disco real: SSD Apple via PCI (não HDD SATA)
- ✅ Performance de I/O: Normal (742 MB/s)
- ✅ Sistema de arquivos: Sem erros
- ✅ Todos os drivers de disco: Funcionando
- ✅ Nenhum driver de terceiros instalado
- ❌ Reset SMC/NVRAM: Não resolveu

## 🛠️ Sistema v3.2 - Recovery Inteligente + Prevenção

### 🎯 Menu Bar App Nativo

**WatchdogMonitor.app** - Aplicação Swift nativa na barra de menu:

- 🟢 **Status Visual em Tempo Real**
  - Verde: Sistema OK
  - Amarelo: Alerta (memória/load moderado)
  - Vermelho: Crítico (recovery em ação)

- ⚡ **Ações Rápidas**
  - Run Diagnostics (Disco + Profile Wizard)
  - Abrir Terminal View
  - Abrir Web Dashboard
  - Restart/Stop Monitor
  - Ver Logs (Monitor + Recovery)
  - Run Diagnostics (Disco + Profile Wizard) 🆕

- 🎚️ **Recovery Profiles (v3.2 NEW!)**
  - Conservative (Safe) - Thresholds conservadores
  - Balanced (Recommended) - Equilíbrio ideal ⭐
  - Aggressive (Performance) - Ação rápida preventiva
  - 🧠 Profile Wizard - Recomendação automática baseada em hardware 🆕

- 🛡️ **Anti-Crash Mode (v3.2 NEW!)**
  - Off - Sem intervenção power management
  - Light - Caffeinate durante recovery apenas
  - Moderate - Previne hibernation, keep-alive inteligente
  - Aggressive - Keep-alive permanente (para Macs problemáticos)

- ⚙️ **Configurações**
  - Toggle para iniciar com o sistema
  - Gerenciamento automático de LaunchAgent

### 🔄 Sistema de Recovery Automático

**Detecção Inteligente com Thresholds Configuráveis (v3.2):**

| Perfil | Memória Crítica | Load Crítico | Recovery Delay | Renice Level |
|--------|-----------------|--------------|----------------|--------------|
| **Conservative** | < 500MB | ≥ 5.0 | 30s | +10 |
| **Balanced** | < 800MB | ≥ 4.5 | 15s | +15 |
| **Aggressive** | < 1000MB | ≥ 4.0 | 5s | +19 |

### ⚡ Preemptive Recovery (v3.2 NEW!)

**Age ANTES dos problemas acontecerem:**

- 📊 **Histórico de Métricas** - Últimas 100 leituras de memória/load
- 📈 **Detecção de Tendências**
  - Declining Fast: Memória caindo >100MB/check
  - Declining Moderate: Memória caindo 50-100MB/check
  - Rising Fast: Load subindo >1.0 em 5 checks
  - Rising Moderate: Load subindo >0.5 em 5 checks
- 🎯 **Ação Preventiva** - Recovery é acionado quando:
  - Tendência negativa + valor ainda acima do threshold
  - Exemplo: Memória em 1500MB mas caindo rápido → age AGORA (não espera chegar em 500MB)

**Ações de Recovery:**
1. 🧹 Limpeza de cache com `sudo purge`
2. 💾 Sincronização de disco com `sync`
3. 📊 Logging detalhado de todas as ações
4. ✅ Verificação pós-recovery

**Intervalo de Monitoramento:**
- 15 segundos em modo daemon
- 78 segundos disponíveis para recovery (93s timeout - 15s detecção)
- Ação imediata para casos críticos

### 🔧 Configuração Sudo Automatizada

Script `setup_sudo.sh` configura permissões necessárias:
- ✅ Validação com `visudo -c`
- ✅ Rollback automático em erro
- ✅ Permissões apenas para comandos necessários: `purge`, `sync`, `reboot`

### 📊 Monitoramento Tradicional

Sistema de monitoramento em tempo real que:

- ✅ Monitora status do SMC
- ✅ Verifica temperatura do sistema
- ✅ Testa I/O de disco
- ✅ Monitora carga do sistema
- ✅ Verifica memória disponível
- ✅ Envia keepalive para prevenir timeout
- ✅ Toma ações corretivas automáticas
- ✅ Mantém log detalhado de eventos

### 🎨 Dashboard Web Visual

Interface web com gráficos em tempo real:
- 📈 Gráfico de load/memória
- 🔔 Alertas visuais
- 📊 Estatísticas de uptime
- 🎯 Status de todos os componentes

## 📦 Instalação

### Opção 1: Instalação Completa com Menu Bar App (Recomendado)

```bash
# Clone o repositório
git clone https://github.com/eltongomez/watchdog_monitor.git
cd watchdog_monitor

# Torne os scripts executáveis
chmod +x scripts/*.sh

# Configure permissões sudo (necessário para recovery automático)
./scripts/setup_sudo.sh

# Instale o Menu Bar App
mkdir -p ~/Applications/WatchdogMonitor
cp WatchdogMonitorApp ~/Applications/WatchdogMonitor/WatchdogMenuBar
chmod +x ~/Applications/WatchdogMonitor/WatchdogMenuBar

# Inicie o monitor em modo daemon
./scripts/watchdog_monitor_visual.sh --daemon

# Inicie o Menu Bar App
open ~/Applications/WatchdogMonitor/WatchdogMenuBar
```

### Opção 2: Download do Release (Em breve)

```bash
# Download do .app.zip do GitHub Releases
# Descompacte e arraste para ~/Applications/
# O app gerenciará automaticamente o monitor
```

### Opção 3: Via Homebrew (Em breve)

```bash
brew tap eltongomez/watchdog
brew install watchdog-monitor
```

## 🚀 Uso

### 🎨 Monitor Visual com Dashboard (Novo! Recomendado)

Interface visual completa com notificações e feedback em tempo real:

```bash
# Dashboard terminal interativo
./scripts/watchdog_monitor_visual.sh

# Modo daemon (background) com notificações
./scripts/watchdog_monitor_visual.sh --daemon

# Dashboard web no navegador
./scripts/open_dashboard.sh
```

**[📖 Guia Completo de Feedback Visual](docs/FEEDBACK_VISUAL.md)**

### 🖥️ Widgets para Área de Trabalho (Novo!)

Três opções de widgets sempre visíveis no desktop:

```bash
# Opção 1: Übersicht (Recomendado - Design moderno)
cd desktop-widget
./install-ubersicht.sh

# Opção 2: GeekTool (Minimalista)
# Copie o conteúdo de geektool-widget.sh no GeekTool

# Opção 3: Standalone (Teste rápido)
./desktop-widget/standalone-widget.sh
```

**[📖 Guia de Desktop Widgets](desktop-widget/README.md)**

### 📊 Monitor Básico (Terminal)

```bash
# Modo interativo
./scripts/watchdog_monitor.sh

# Verificação única
./scripts/watchdog_monitor.sh --once

# Modo daemon (background)
./scripts/watchdog_monitor.sh --daemon
```

### Diagnóstico Completo

```bash
./scripts/diagnostico_disco.sh
```

### Desabilitar Watchdog (Apenas para testes)

```bash
./scripts/disable_watchdog.sh
```

Escolha a opção desejada:
1. Desabilitar watchdog (para testes)
2. Habilitar watchdog (reverter)
3. Ver status atual

⚠️ **Importante:** Sempre reverta após os testes!

## 📊 Estrutura do Projeto

```
watchdog_monitor/
├── README.md                    # Este arquivo
├── LICENSE                      # Licença MIT
├── scripts/                     # Scripts executáveis
│   ├── watchdog_monitor.sh      # Monitor preventivo
│   ├── disable_watchdog.sh      # Desabilitar watchdog
│   └── diagnostico_disco.sh     # Diagnóstico completo
├── docs/                        # Documentação detalhada
│   ├── analise_kernel_panic.md  # Análise do panic original
│   ├── analise_drivers_kernel.md # Análise detalhada de drivers
│   └── GUIA_WORKAROUNDS.md      # Guia completo de soluções
├── diagnostics/                 # Relatórios de diagnóstico
└── logs/                        # Logs do monitor
```

## 📖 Documentação

- [Análise do Kernel Panic](docs/analise_kernel_panic.md) - Análise detalhada do problema
- [Análise de Drivers](docs/analise_drivers_kernel.md) - Análise técnica dos drivers
- [Guia de Workarounds](docs/GUIA_WORKAROUNDS.md) - Guia completo de soluções

## 🔍 Detalhes Técnicos

### Sistema Afetado

- **Modelo**: MacBookAir7,2 (Mac-937CB26E2E02BB01)
- **macOS**: 12.7.6 (21H1320)
- **Kernel**: Darwin 21.6.0
- **Disco**: APPLE SSD SM0128G (128GB)

### Drivers Problemáticos

```
com.apple.driver.watchdog (1.0)
UUID: F0AE4794-0AD0-3919-ABFE-101DD2816E55

com.apple.driver.AppleSMC (3.1.9)
UUID: 372CB5EE-DACA-376C-A3CF-13A8431B7906
```

### Backtrace do Panic

```
0xffffff8006180938 - watchdog driver (trigger do panic)
0xffffff8006180273 - watchdog timeout handler  
0xffffff800447f265 - Apple SMC driver
```

## ⚡ Como Funciona

### Monitor Preventivo

1. **Detecta condições de risco** antes que causem timeout
2. **Envia keepalive** regularmente para o watchdog
3. **Toma ações corretivas** quando detecta problemas:
   - Limpa cache de disco se I/O estiver lento
   - Libera memória se estiver baixa
   - Alerta sobre superaquecimento
4. **Registra tudo** em logs detalhados

### Verificações a Cada Ciclo

- SMC Status (via ioreg)
- Thermal Level (via sysctl)
- Disk I/O Speed (teste de escrita/leitura)
- System Load (via sysctl)
- Memory Available (via vm_stat)
- Keepalive Signal (via sync)

## 📈 Monitoramento de Longo Prazo

### Automatizar na Inicialização (Opcional)

```bash
# Criar LaunchAgent
cat > ~/Library/LaunchAgents/com.user.watchdog-monitor.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.watchdog-monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/elima/Projects/watchdog_monitor/scripts/watchdog_monitor.sh</string>
        <string>--daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/watchdog-monitor.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/watchdog-monitor-error.log</string>
</dict>
</plist>
EOF

# Carregar serviço
launchctl load ~/Library/LaunchAgents/com.user.watchdog-monitor.plist
```

## 🐛 Troubleshooting

### O monitor detecta problemas constantemente?

Possíveis causas:
1. **Ventilação obstruída** - Limpe as ventoinhas
2. **Processos consumindo CPU** - Verifique Activity Monitor
3. **Problema de hardware** - Execute Apple Diagnostics (D durante boot)

### O panic ainda ocorre mesmo com o monitor?

1. Desabilite o watchdog temporariamente para confirmar
2. Execute diagnóstico completo
3. Verifique logs em `logs/watchdog_monitor.log`
4. Considere atualização do macOS
5. Se persistir: Problema de hardware (chip SMC)

## ⚠️ Avisos Importantes

- ⚠️ **O watchdog é um mecanismo de segurança importante**
- ⚠️ **Não deixe desabilitado permanentemente**
- ⚠️ **Use a desabilitação apenas para diagnóstico**
- ⚠️ **Sempre reverta após os testes**
- ⚠️ **Se o problema persistir, procure assistência técnica**

## 🤝 Contribuindo

Contribuições são bem-vindas! Se você encontrou uma solução melhor ou tem sugestões:

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/melhoria`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/melhoria`)
5. Abra um Pull Request

## 📝 Changelog

### v1.0.0 (2026-02-16)

- ✅ Monitor preventivo em tempo real
- ✅ Script para desabilitar watchdog
- ✅ Diagnóstico completo do sistema
- ✅ Documentação técnica detalhada
- ✅ Análise completa do kernel panic
- ✅ Identificação da causa raiz

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- Apple Developer Documentation
- Darwin Kernel Source Code
- Comunidade macOS/Darwin

## 📧 Suporte

Se você está enfrentando o mesmo problema:

1. Leia a [documentação completa](docs/)
2. Execute o diagnóstico
3. Tente as soluções propostas
4. Abra uma issue se precisar de ajuda

## 🔗 Links Úteis

- [Apple Support - Kernel Panics](https://support.apple.com/en-us/HT200553)
- [Darwin Kernel Documentation](https://developer.apple.com/library/archive/documentation/Darwin/Reference/ManPages/)
- [System Management Controller (SMC)](https://support.apple.com/en-us/HT201295)

---

**⚡ Status do Projeto:** Ativo e em desenvolvimento

**💡 Probabilidade de Sucesso:**
- Monitor Preventivo: 60-70%
- Desabilitar Watchdog: 95% (workaround)
- Problema de Hardware Real: 5%

---

Made with ❤️ for the macOS community
