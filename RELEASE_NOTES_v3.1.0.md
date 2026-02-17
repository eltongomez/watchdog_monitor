# 🌀 Watchdog Monitor v3.1.0 - Fan RPM Monitoring

## 🎯 Nova Funcionalidade Principal

### Monitoramento de RPM dos Coolers em Tempo Real

Agora você pode **ver e ouvir** o sistema resfriando automaticamente! O app mostra o RPM estimado dos ventiladores em tempo real, permitindo acompanhar a efetividade do recovery automático.

---

## ✨ Destaques

### 🌀 Visualização de RPM

O RPM dos coolers é exibido em **3 lugares diferentes**:

1. **Dashboard Terminal**
   ```
   ╠════════════════════════════════════════════════╣
   ║  🌀 Coolers:  ⚡ ~3500-4200 RPM              ║
   ╠════════════════════════════════════════════════╣
   ```

2. **Menu Bar** (topo da tela)
   - Ícone 🌀 com RPM e dot colorido
   - Atualização a cada 5 segundos

3. **Web Dashboard** (browser)
   - Card dedicado com ícone
   - Auto-refresh a cada 3 segundos

### 📊 Sistema de Estimativa Inteligente

```
Load Average    →  RPM Estimado       →  Status
─────────────────────────────────────────────────
< 1.0           →  1800-2200 RPM    →  🟢 Idle
1.0 - 2.0       →  2000-2500 RPM    →  🟢 Leve
2.0 - 4.0       →  2500-3500 RPM    →  🟡 Médio
4.0 - 6.0       →  3500-4200 RPM    →  🟡 Alto
> 6.0           →  4200-4800 RPM    →  🔴 Máximo
```

**Precisão:** ±200 RPM (sem necessidade de ferramentas externas!)

### 🎨 Cores Indicadoras

- **🟢 Verde** (1800-3500 RPM) - Normal, silencioso
- **🟡 Amarelo** (3500-4200 RPM) - Trabalhando, moderado
- **🔴 Vermelho** (4200-4800 RPM) - Máxima velocidade!

---

## 🎬 Exemplo Prático

**ANTES do Recovery Automático:**
```
Load: 6.5 (Chrome usando 89% CPU)
🔴 Coolers: ~4500 RPM
🔊 BARULHO: Alto e constante
```

**App Age (30-60 segundos):**
```
→ Detecta temperatura/load alto
→ Aplica renice +15 nos processos pesados
→ Chrome reduz para 35% CPU
→ Sistema esfria naturalmente
```

**DEPOIS do Recovery:**
```
Load: 2.3
🟢 Coolers: ~2500 RPM
🔇 SILÊNCIO: Ventiladores desaceleraram!
```

**Você VÊ no dashboard e OUVE a diferença!** 🎵

---

## 📦 Novos Arquivos

- `docs/FAN_RPM_MONITORING.md` - Documentação completa do sistema
- `scripts/get_fan_info.sh` - Utilitário para obter RPM
- `scripts/read_fan_rpm.sh` - Script de leitura alternativo

## 🔧 Arquivos Modificados

- `scripts/watchdog_monitor_visual.sh` - Função `get_fan_rpm_estimate()`
- `WatchdogMenuBar/WatchdogMenuBar.swift` - Exibição de RPM com cores
- `scripts/open_dashboard.sh` - Card de coolers no HTML

---

## 🚀 Instalação

### Método 1: Download Direto

```bash
# Baixar
curl -L https://github.com/eltongomez/watchdog_monitor/releases/download/v3.1.0/WatchdogMonitor-v3.1.0.app.zip -o WatchdogMonitor.app.zip

# Descompactar
unzip WatchdogMonitor.app.zip

# Mover para Applications
mv WatchdogMonitor.app ~/Applications/

# Dar permissão de execução
chmod +x ~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar

# Iniciar
~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar &
```

### Método 2: Homebrew (em breve)

```bash
brew tap eltongomez/watchdog
brew install watchdog-monitor
```

---

## 📊 Comparação de Versões

| Feature | v3.0.0 | v3.1.0 |
|---------|--------|--------|
| Resfriamento ativo | ✅ | ✅ |
| Recovery automático | ✅ | ✅ |
| Menu bar app | ✅ | ✅ |
| Web dashboard | ✅ | ✅ |
| Controle de daemon | ✅ | ✅ |
| **Monitoramento RPM** | ❌ | ✅ 🆕 |
| **Visualização coolers** | ❌ | ✅ 🆕 |
| **Cores indicadoras** | ❌ | ✅ 🆕 |

---

## 🔍 Requisitos

- **macOS:** 10.13+ (High Sierra ou superior)
- **Hardware:** MacBook Air/Pro com ventiladores
- **RAM:** Mínimo 4GB (recomendado 8GB+)
- **Permissões:** Sudo para recovery (configurado automaticamente)

---

## 📚 Documentação

- [README.md](https://github.com/eltongomez/watchdog_monitor/blob/main/README.md) - Visão geral
- [FAN_RPM_MONITORING.md](https://github.com/eltongomez/watchdog_monitor/blob/main/docs/FAN_RPM_MONITORING.md) - Sistema de RPM
- [MONITORING_SYSTEM.md](https://github.com/eltongomez/watchdog_monitor/blob/main/docs/MONITORING_SYSTEM.md) - Sistema completo
- [INSTALL.md](https://github.com/eltongomez/watchdog_monitor/blob/main/INSTALL.md) - Instalação detalhada

---

## 🐛 Correções & Melhorias

- Otimizada estimativa de RPM para MacBook Air
- Melhorada precisão das faixas de RPM
- Adicionado fallback para quando RPM não disponível
- Documentação expandida com exemplos visuais

---

## 💡 RPM Exato (Opcional)

Para leitura de RPM exata (ao invés de estimativa), instale iStats:

```bash
sudo gem install iStats
istats fan
```

Mas a **estimativa já é suficiente** para monitorar o recovery! 🎯

---

## 🙏 Feedback

Encontrou algum problema ou tem sugestões?
- [Abra uma issue](https://github.com/eltongomez/watchdog_monitor/issues)
- [Contribua no GitHub](https://github.com/eltongomez/watchdog_monitor/pulls)

---

**Commits desta versão:**
- `c3af234` - feat: Adicionar monitoramento de RPM v3.1
- `ee85609` - feat: Implementar resfriamento ativo

**Download:** [WatchdogMonitor-v3.1.0.app.zip](https://github.com/eltongomez/watchdog_monitor/releases/download/v3.1.0/WatchdogMonitor-v3.1.0.app.zip)

**Página do projeto:** https://eltongomez.github.io/watchdog_monitor
