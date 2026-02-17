# 🚀 Guia Rápido de Instalação

## ⚡ Instalação em 2 Minutos

### 1. Clone e Configure

```bash
git clone https://github.com/eltongomez/watchdog_monitor.git
cd watchdog_monitor
chmod +x scripts/*.sh desktop-widget/*.sh
```

### 2. Escolha sua Interface

#### 🖥️ Opção A: Widget de Desktop (Recomendado)

**Übersicht (Design Moderno):**
```bash
# Instalar Übersicht
brew install --cask ubersicht

# Instalar widget
cd desktop-widget
./install-ubersicht.sh
```

**GeekTool (Minimalista):**
```bash
# Instalar GeekTool
brew install --cask geektool

# Abrir GeekTool e adicionar "Shell" com:
cat desktop-widget/geektool-widget.sh
```

#### 📊 Opção B: Dashboard Terminal

```bash
# Modo interativo com dashboard visual
./scripts/watchdog_monitor_visual.sh
```

#### 🌐 Opção C: Dashboard Web

```bash
# Abrir no navegador
./scripts/open_dashboard.sh
```

### 3. Inicie o Monitor

```bash
# Terminal interativo
./scripts/watchdog_monitor_visual.sh

# Ou modo daemon (background)
./scripts/watchdog_monitor_visual.sh --daemon
```

---

## 📱 Interfaces Disponíveis

| Interface | Visual | Uso | Comando |
|-----------|--------|-----|---------|
| **Übersicht Widget** | ⭐⭐⭐⭐⭐ | Desktop sempre visível | `./install-ubersicht.sh` |
| **GeekTool Widget** | ⭐⭐⭐ | Desktop customizável | GeekTool + script |
| **Dashboard Terminal** | ⭐⭐⭐⭐ | Terminal interativo | `watchdog_monitor_visual.sh` |
| **Dashboard Web** | ⭐⭐⭐⭐⭐ | Navegador | `open_dashboard.sh` |
| **Menu Bar** | ⭐⭐⭐⭐ | Barra de menu | SwiftBar + widget |

---

## �� Casos de Uso

### Para Uso Diário:
```bash
# 1. Instalar widget Übersicht
cd desktop-widget && ./install-ubersicht.sh

# 2. Iniciar monitor em background
./scripts/watchdog_monitor_visual.sh --daemon
```

### Para Monitoramento Intenso:
```bash
# Dashboard terminal com todas as informações
./scripts/watchdog_monitor_visual.sh
```

### Para Verificação Rápida:
```bash
# Verificação única
./scripts/watchdog_monitor.sh --once
```

### Para Diagnóstico Completo:
```bash
# Executar diagnóstico completo
./scripts/diagnostico_disco.sh
```

---

## 🔧 Troubleshooting Rápido

### Widget não mostra dados:
```bash
# Verificar se monitor está rodando
ps aux | grep watchdog_monitor

# Se não estiver, iniciar
./scripts/watchdog_monitor_visual.sh --daemon
```

### Dashboard web não carrega:
```bash
# Regenerar dashboard
./scripts/open_dashboard.sh
```

### Sistema com kernel panic:
```bash
# 1. Ver logs
./scripts/show_logs.sh

# 2. Executar diagnóstico
./scripts/diagnostico_disco.sh

# 3. (Último caso) Desabilitar watchdog temporariamente
./scripts/disable_watchdog.sh
```

---

## 📚 Documentação Completa

- **[README Principal](README.md)** - Visão geral do projeto
- **[Feedback Visual](docs/FEEDBACK_VISUAL.md)** - Sistema de notificações
- **[Desktop Widgets](desktop-widget/README.md)** - Guia de widgets
- **[Exemplos Visuais](desktop-widget/EXEMPLOS.md)** - Screenshots e demos
- **[Análise do Problema](docs/analise_kernel_panic.md)** - Detalhes técnicos
- **[Workarounds](docs/GUIA_WORKAROUNDS.md)** - Soluções alternativas

---

## ✅ Checklist de Instalação

- [ ] Clonar repositório
- [ ] Tornar scripts executáveis (`chmod +x`)
- [ ] Escolher interface (Übersicht/GeekTool/Terminal/Web)
- [ ] Instalar software necessário (se aplicável)
- [ ] Iniciar monitor (`watchdog_monitor_visual.sh`)
- [ ] Verificar que widget está funcionando
- [ ] (Opcional) Configurar auto-start no boot

---

## 🎓 Próximos Passos

### Configurar Auto-Start:
```bash
# Criar LaunchAgent (em breve)
# Por enquanto, adicionar ao Login Items:
# System Preferences > Users & Groups > Login Items
```

### Personalizar Widget:
```bash
# Übersicht
vim ~/Library/Application\ Support/Übersicht/widgets/watchdog-monitor.widget/index.jsx

# GeekTool
# Editar direto no GeekTool preferences
```

### Ver Histórico:
```bash
# Ver logs completos
./scripts/show_logs.sh

# Ver últimas 50 linhas
tail -50 logs/watchdog_monitor.log
```

---

## 🆘 Precisa de Ajuda?

1. **Ver documentação completa**: [README.md](README.md)
2. **Executar diagnóstico**: `./scripts/diagnostico_disco.sh`
3. **Abrir issue no GitHub**: [github.com/eltongomez/watchdog_monitor/issues](https://github.com/eltongomez/watchdog_monitor/issues)

---

**⚡ Instalação completa em < 5 minutos!**

Repositório: https://github.com/eltongomez/watchdog_monitor
