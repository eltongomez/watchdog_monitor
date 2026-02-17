# 📖 Guia Completo - Watchdog Monitor v3.2

## 🎯 O que é o Watchdog Monitor?

O **Watchdog Monitor** é um sistema profissional de prevenção e recuperação automática de kernel panics para macOS. Ele monitora continuamente 6 métricas vitais do sistema e age proativamente antes que problemas causem crashes.

### 🎯 Para quem é este app?

✅ **Ideal para:**
- MacBook Pro com histórico de kernel panics
- Macs que apresentam "watchdog timeout" errors
- Usuários que perderam trabalho devido a crashes
- Desenvolvedores que precisam de estabilidade máxima
- Sistemas com SMC problemático
- Macs com memória limitada ou carga alta

❌ **Não recomendado para:**
- Macs sem problemas de estabilidade
- Apple Silicon (M1/M2/M3) - ainda não testado
- Usuários que não querem dar permissões sudo

---

## 🚀 Features Principais

### 1. 🎚️ Recovery Profiles
Escolha o perfil ideal para seu caso de uso:

#### Conservative (Seguro)
- Memória crítica: < 500MB
- Load crítico: ≥ 5.0
- Delay entre checks: 30s
- Renice: +10
- **Recomendado para:** Uso geral, sistemas estáveis

#### Balanced (Recomendado)
- Memória crítica: < 800MB
- Load crítico: ≥ 4.5
- Delay entre checks: 15s
- Renice: +15
- **Recomendado para:** Maioria dos usuários, equilíbrio ideal

#### Aggressive (Performance)
- Memória crítica: < 1000MB
- Load crítico: ≥ 4.0
- Delay entre checks: 5s
- Renice: +19
- **Recomendado para:** Sistemas problemáticos, prevenção máxima

### 2. 🛡️ Anti-Crash Mode
Previne idle problemático com keep-alive inteligente:

#### Off (Padrão)
- Sem intervenção de power management
- Sistema funciona normalmente

#### Light
- Ativa `caffeinate` apenas durante recovery (5 min)
- Sistema pode dormir normalmente
- Impacto zero na bateria quando não há problemas

#### Moderate
- Ativa `caffeinate` durante recovery
- Desabilita hibernation (hibernatemode 0)
- Previne idle profundo quando load > 3.0 ou memory < 1000MB
- Impacto mínimo na bateria

#### Aggressive
- Mantém `caffeinate -i -s` constantemente
- Desabilita sleep automático (disablesleep 1)
- Sistema nunca dorme automaticamente
- **Use apenas em Macs com problemas conhecidos**
- Reduz bateria em ~10-20%

### 3. ⚡ Preemptive Recovery
Sistema de machine learning básico que age ANTES dos problemas:

**Como funciona:**
1. Mantém histórico das últimas 100 leituras de memória e load
2. Calcula tendências de variação
3. Age preventivamente quando detecta:
   - Memory declining fast: >100MB por check
   - Memory declining moderate: 50-100MB por check
   - Load rising fast: >1.0 em 5 checks
   - Load rising moderate: >0.5 em 5 checks

**Exemplo real:**
```
Memória em 1500MB (ainda acima do threshold de 800MB)
Mas caindo 120MB por check = declining fast
→ Sistema age AGORA, não espera chegar em 800MB
→ Crash prevenido antes de acontecer!
```

---

## 📊 Monitoramento

### Métricas Verificadas

1. **SMC Status** - System Management Controller
   - OK: SMC respondendo normalmente
   - ERRO: SMC travado (CRÍTICO!)

2. **Thermal** - Temperatura do sistema
   - OK: Temperatura normal
   - AVISO: >70°C
   - CRÍTICO: >85°C

3. **Disk I/O** - Performance de I/O
   - OK: Write < 3s (10MB)
   - LENTO: Write > 3s

4. **System Load** - Carga do processador
   - OK: < 4.0 (configurável por perfil)
   - ALTO: 4.0-5.0
   - CRÍTICO: ≥ 5.0

5. **Memory** - RAM disponível
   - OK: > 1000MB (configurável por perfil)
   - BAIXO: 500-1000MB
   - CRÍTICO: < 500MB

6. **Coolers RPM** - Velocidade dos ventiladores
   - Verde: 2000-2500 RPM (idle/baixo)
   - Amarelo: 3500-4200 RPM (moderado)
   - Vermelho: 4200-4800 RPM (carga alta)

### Frequência de Checks
- **Padrão:** 15 segundos entre cada verificação
- **Ajustável:** Configurável no script (não recomendado < 10s)

---

## 🔧 Ações de Recovery

### Memória Baixa
```bash
sudo purge  # Limpa cache e libera RAM
```
- Libera ~500MB-2GB instantaneamente
- Sem perda de dados
- Reduz swap e I/O

### Load Alto
```bash
renice +15 <PID>  # Reduz prioridade de processos pesados
```
- Identifica 5 processos mais pesados
- Reduz prioridade (não mata)
- Sistema fica mais responsivo

### I/O Lento
```bash
sync && sync && sync  # Sincroniza disco
mdutil -i off /       # Pausa Spotlight temporariamente
```
- Força write de dados pendentes
- Reduz carga de I/O
- Spotlight volta após 5s

### Temperatura Alta
```bash
renice +15 <PID>  # Desacelera processos que usam CPU
sudo purge         # Libera memória (reduz swap = menos I/O = menos calor)
```
- Reduz uso de CPU
- Menos calor gerado
- Sistema resfria em 30-60s

### SMC Travado (CRÍTICO!)
```bash
1. Libera memória máxima
2. Sincroniza disco múltiplas vezes
3. Mata processos não-essenciais
4. Aguarda 30s para SMC recuperar
5. Se falhar: oferece reinicialização preventiva
```
- Recovery de emergência
- Evita kernel panic
- Última chance antes do crash

---

## 🎮 Como Usar

### Primeira Instalação

1. **Clone o repositório:**
```bash
git clone https://github.com/eltongomez/watchdog_monitor.git
cd watchdog_monitor
```

2. **Execute o instalador:**
```bash
./install.sh
```
O instalador configura automaticamente:
- ✅ App em ~/Applications/
- ✅ Daemon configurado
- ✅ Permissões sudo (purge e pmset)
- ✅ LaunchAgent (iniciar com sistema)

3. **Abra o app:**
```bash
open ~/Applications/WatchdogMonitor.app
```

### Configuração Via Menu Bar

1. **Clique no ícone** na barra de menu (🟢/🟡/🔴)

2. **Escolha seu Recovery Profile:**
   - Recovery Profile → Balanced (Recommended)

3. **Configure Anti-Crash Mode:**
   - Anti-Crash Mode → Off (ou escolha nível desejado)

4. **Pronto!** O sistema já está protegido

### Comandos Úteis

```bash
# Ver dashboard em tempo real
cd ~/Projects/watchdog_monitor
./scripts/watchdog_monitor_visual.sh

# Ver logs do monitor
tail -f ~/Projects/watchdog_monitor/logs/watchdog_monitor.log

# Ver logs de recovery
tail -f ~/Projects/watchdog_monitor/logs/watchdog_recovery.log

# Verificar status do daemon
ps aux | grep watchdog_monitor_visual.sh

# Parar daemon manualmente
kill $(cat /tmp/watchdog_monitor_visual.pid)

# Restart completo
killall WatchdogMenuBar
open ~/Applications/WatchdogMonitor.app
```

---

## 🛠️ Troubleshooting

### App não inicia
```bash
# Verificar permissões
ls -l ~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar

# Deve ser executável (x)
chmod +x ~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar

# Tentar via terminal
~/Applications/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar
```

### Daemon não inicia
```bash
# Verificar se já está rodando
ps aux | grep watchdog_monitor_visual.sh

# Iniciar manualmente
cd ~/Projects/watchdog_monitor
./scripts/watchdog_monitor_visual.sh --daemon

# Ver erros
cat /tmp/watchdog_daemon.log
```

### Recovery não funciona
```bash
# Verificar sudo configurado
sudo -n purge

# Se pedir senha:
sudo visudo
# Adicionar linha:
# yourusername ALL=(ALL) NOPASSWD: /usr/sbin/purge, /usr/bin/pmset
```

### Preemptive não ativa
```bash
# Verificar histórico
ls -lh ~/Projects/watchdog_monitor/data/

# Deve ter memory_history.txt e load_history.txt com conteúdo
cat ~/Projects/watchdog_monitor/data/memory_history.txt

# Preemptive só ativa após 5º ciclo (75 segundos)
```

---

## 🔐 Segurança

### Permissões Necessárias

**Sudo sem senha:**
```bash
# Apenas para 2 comandos específicos:
/usr/sbin/purge  # Limpar cache
/usr/bin/pmset   # Configurar power management
```

**Por que é seguro:**
- Comandos limitados (não é sudo completo)
- Operações não-destrutivas
- Apenas leitura/limpeza de cache
- Configuração de energia reversível

### Dados Coletados
- ❌ **Nenhum dado é enviado para internet**
- ✅ Logs salvos localmente em `~/Projects/watchdog_monitor/logs/`
- ✅ Histórico salvo em `~/Projects/watchdog_monitor/data/`
- ✅ Todo código é open source e auditável

---

## 📈 Performance

### Impacto no Sistema

| Recurso | Uso |
|---------|-----|
| **CPU** | < 0.5% (daemon + app) |
| **RAM** | ~12MB (app) + ~1MB (daemon) |
| **Disco** | < 1MB (logs por dia) |
| **Rede** | 0 (sem conexão) |

### Bateria (apenas com Anti-Crash Mode)

| Modo | Impacto |
|------|---------|
| **Off** | 0% |
| **Light** | < 1% (só durante recovery) |
| **Moderate** | ~2-5% |
| **Aggressive** | ~10-20% |

---

## 🎖️ Comparação

### vs MBP-Anti-Crash Fix

| Feature | MBP-Anti-Crash | Watchdog v3.2 |
|---------|----------------|---------------|
| **Método** | Loop constante | Inteligente |
| **Energia** | ❌ Gasta 10-30% | ✅ Eficiente |
| **Prevenção** | ✅ Sim (bruta) | ✅ Sim (smart) |
| **Configurável** | 🟡 3 níveis fixos | ✅ Perfis + modos |
| **Recovery** | ❌ Nenhum | ✅ Completo |
| **Monitoring** | ❌ Nenhum | ✅ 6 métricas |
| **Trends** | ❌ Nenhum | ✅ ML básico |

### vs Sistema Padrão do macOS

| Feature | macOS Padrão | Watchdog v3.2 |
|---------|--------------|---------------|
| **Detecção SMC** | ❌ | ✅ |
| **Recovery Automático** | ❌ | ✅ |
| **Prevenção** | ❌ | ✅ |
| **Visual Feedback** | ❌ | ✅ |
| **Configurável** | ❌ | ✅ |

---

## 📝 Changelog

### v3.2.0 (2026-02-17)
- ✨ NEW: Recovery Profiles (Conservative/Balanced/Aggressive)
- ✨ NEW: Anti-Crash Mode (4 níveis)
- ✨ NEW: Preemptive Recovery (ML básico)
- 🎨 Menu bar com seleção de perfil e modo
- 📊 Sistema de histórico (últimas 100 leituras)
- 🔧 Thresholds configuráveis

### v3.0.0 (2026-02-16)
- 🎯 Menu bar app nativo (Swift)
- 🔄 Recovery automático comprovado
- 📱 Dashboard web com status em tempo real
- ⚙️ Auto-start configurável
- 🌀 Monitoramento de RPM dos coolers

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:
1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Add: MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

---

## 📄 Licença

MIT License - Veja [LICENSE](LICENSE) para detalhes

---

## 🆘 Suporte

- 📖 [Documentação](https://github.com/eltongomez/watchdog_monitor)
- 🐛 [Report Bugs](https://github.com/eltongomez/watchdog_monitor/issues)
- 💬 [Discussions](https://github.com/eltongomez/watchdog_monitor/discussions)

---

**Desenvolvido com dedicação para a comunidade macOS** 🍎
