# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [3.0.0] - 2026-02-17

### 🎉 Recovery System Success

Versão 3.0 marca o primeiro sucesso completo do sistema de prevenção de crashes!

### ✨ Adicionado

- **Sistema de Recovery Automático** (`watchdog_recovery.sh`)
  - Liberação automática de memória com `sudo purge`
  - Fallback para `sync` quando sudo não disponível
  - Logging detalhado de todas as ações de recovery
  - Verificação de status pós-recovery

- **Menu Bar App em Swift** (`WatchdogMenuBar`)
  - Ícone nativo na barra de menu do macOS
  - Status visual em tempo real (🟢 OK, 🟡 Alerta, 🔴 Crítico)
  - Menu interativo com ações rápidas
  - Submenu "Configurações" com toggle de auto-inicialização
  - Submenu "View Logs" com acesso a Monitor e Recovery logs
  - Integração com LaunchAgent para iniciar com o sistema

- **Script de Configuração Sudo** (`setup_sudo.sh`)
  - Configuração automatizada de permissões sudo
  - Validação com `visudo -c` antes de aplicar
  - Rollback automático em caso de erro
  - Documentação completa do processo

- **Documentação Expandida**
  - `CRASH_2_ANALYSIS.md` - Análise do segundo crash
  - `CRASH_3_ANALYSIS.md` - Análise do terceiro crash com thresholds
  - `V3_IMPROVEMENTS.md` - Documentação das melhorias v3.0
  - `SUDO_SETUP.md` - Guia de configuração sudo
  - `CRASH_PATTERN.md` - Padrões identificados nos crashes

### 🔧 Modificado

- **Thresholds Ajustados** (v3.0)
  - Memória: `< 500MB` = CRÍTICO (ação imediata), `< 1000MB` = BAIXO (2ª iteração)
  - Load: `>= 5.0` = CRÍTICO (ação imediata), `>= 4.0` = ALTO (2ª iteração)
  - Antes: Single threshold muito conservador (< 100MB, > 8 load)

- **Lógica de Recovery Aprimorada**
  - Ação imediata para casos críticos (sem esperar 2ª iteração)
  - Casos de alerta ainda aguardam confirmação
  - Melhor balanceamento entre prevenção e falsos positivos

- **Intervalo de Monitoramento Reduzido**
  - De 30s para 15s em modo daemon
  - Detecção mais rápida de problemas
  - 78 segundos disponíveis para recovery (93s timeout - 15s detecção)

- **WatchdogMenuBar.swift**
  - Toggle de auto-start agora apenas gerencia plist (não mata app)
  - Mudanças de auto-start tomam efeito no próximo login
  - Corrigido weak self capture em closures

### 🐛 Corrigido

- Monitor não executava recovery devido a variáveis não configuradas
- Recovery falhava por falta de permissões sudo
- App crashava ao desativar auto-start (launchctl unload matava o processo)
- Thresholds muito conservadores não detectavam problemas a tempo
- Weak self em closures causava erros de compilação Swift

### ✅ Testado e Aprovado

**Teste Final - 2026-02-17 01:40:**
- ✅ Aberto VSCode com projeto grande
- ✅ Sistema detectou Mem: 753MB (BAIXO) no Ciclo #33
- ✅ Recovery executado: "✓ Cache limpo com sucesso"
- ✅ Memória recuperou: 753MB → 3137MB
- ✅ **Nenhum crash ocorreu - Sistema estabilizado!**

### 📊 Comparação de Performance

| Teste | Detecção | Ação | Resultado |
|-------|----------|------|-----------|
| Crash #1 (v2.0) | Load 12.19, Mem 23MB | ❌ Variáveis faltando | 💥 CRASH |
| Crash #2 (v2.5) | Mem baixa | ❌ Sem sudo | 💥 CRASH |
| Crash #3 (v2.5) | Load 6.07, Mem 225MB | ❌ Thresholds altos | 💥 CRASH |
| **v3.0 SUCCESS** | Load 3.11, Mem 753MB | ✅ sudo purge | ✅ **EVITADO** |

## [2.5.0] - 2026-02-16

### Adicionado
- Sistema de recovery com watchdog_recovery.sh
- Configuração via recovery.conf
- Integração entre monitor e recovery

### Problemas Conhecidos
- Recovery não executava por variáveis não configuradas
- Sudo não configurado para purge
- Thresholds muito conservadores

## [2.0.0] - 2026-02-15

### Adicionado
- Dashboard web visual com gráficos
- Desktop widget interativo
- Sistema de alertas visuais
- Modo daemon aprimorado

## [1.0.0] - 2026-02-14

### Adicionado
- Monitor inicial de sistema
- Diagnóstico de disco
- Scripts de análise
- Documentação básica

[3.0.0]: https://github.com/eltongomez/watchdog_monitor/releases/tag/v3.0.0
[2.5.0]: https://github.com/eltongomez/watchdog_monitor/releases/tag/v2.5.0
[2.0.0]: https://github.com/eltongomez/watchdog_monitor/releases/tag/v2.0.0
[1.0.0]: https://github.com/eltongomez/watchdog_monitor/releases/tag/v1.0.0
