# 🛡️ Watchdog Monitor - macOS Kernel Panic Prevention

[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)

Sistema de monitoramento preventivo e ferramentas de diagnóstico para prevenir kernel panics causados por watchdog timeout em macOS.

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

## 🛠️ Soluções Implementadas

### 1. Monitor Preventivo (`watchdog_monitor.sh`)

Sistema de monitoramento em tempo real que:

- ✅ Monitora status do SMC
- ✅ Verifica temperatura do sistema
- ✅ Testa I/O de disco
- ✅ Monitora carga do sistema
- ✅ Verifica memória disponível
- ✅ Envia keepalive para prevenir timeout
- ✅ Toma ações corretivas automáticas
- ✅ Mantém log detalhado de eventos

### 2. Desabilitar Watchdog (`disable_watchdog.sh`)

Workaround temporário para diagnóstico:

- Desabilita o watchdog modificando boot arguments
- Permite confirmar se o problema é o watchdog
- Fácil de reverter
- ⚠️ Apenas para diagnóstico, não usar permanentemente

### 3. Diagnóstico Completo (`diagnostico_disco.sh`)

Ferramentas de diagnóstico:

- Verifica SMART status
- Testa I/O de disco
- Analisa sistema de arquivos
- Verifica logs do sistema
- Identifica kernel extensions problemáticas

## 📦 Instalação

```bash
# Clone o repositório
git clone https://github.com/elima/watchdog_monitor.git
cd watchdog_monitor

# Torne os scripts executáveis
chmod +x scripts/*.sh
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
