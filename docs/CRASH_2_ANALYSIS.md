# Análise do Segundo Crash

## 📊 Cronologia

**Último ciclo registrado:** 00:13:32 - "Memória baixa - liberando cache"  
**Crash:** 00:34:09 (21 minutos depois)  
**Gap:** Monitor parou de registrar logs

## 🔍 O Que Aconteceu

### Timeline Detalhada

```
00:10:57 - Ciclo #1: Mem OK (2562MB) - Sistema recém reiniciado
00:11:27 - Ciclo #2: Mem OK (2564MB)
00:11:58 - Ciclo #3: Mem OK (1964MB) - Começando a cair
00:12:29 - Ciclo #4: Mem OK (1561MB) - Caindo mais
00:12:59 - Ciclo #5: Mem OK (1560MB)
00:13:32 - AVISO: Memória baixa - liberando cache
         ↓
         [21 MINUTOS DE SILÊNCIO - MONITOR PAROU]
         ↓
00:34:09 - KERNEL PANIC
```

## ⚠️ Problemas Identificados

### 1. Monitor Morreu ou Travou
**Evidência:** 21 minutos sem logs entre 00:13 e 00:34

**Possíveis causas:**
- Monitor tentou executar `sudo purge` sem permissões
- Script travou aguardando senha
- Processo foi morto por pressão de memória
- Erro fatal não capturado

### 2. Intervalo de 30s É Muito Lento
**Problema:** VSCode causa pico instantâneo, monitor só checa a cada 30s

**Janela crítica:**
- VSCode abre e indexa 91k arquivos
- Memória cai de 1560MB → < 100MB em segundos
- Monitor pode estar entre checks quando SMC trava
- Timeout de 93s do watchdog acontece antes do próximo check

### 3. Recovery Sem Sudo Não Funcionou
**Detectou:** "Memória baixa - liberando cache" (00:13:32)  
**Tentou:** `sudo purge` (sem permissões)  
**Resultado:** Falhou, monitor provavelmente travou

### 4. Sem Mecanismo de Watchdog para o Monitor
**Problema:** Monitor não se auto-monitora  
**Resultado:** Se o monitor morre, sistema fica desprotegido

## �� Por Que Falhou Desta Vez

1. **Monitor detectou** problema (00:13:32)
2. **Tentou agir** mas falhou (sem sudo)
3. **Monitor provavelmente travou** aguardando/errando
4. **21 minutos desprotegido** - sem monitoramento
5. **Sistema sucumbiu** à pressão de memória + VSCode
6. **SMC congelou** → watchdog timeout → panic

## ✅ Soluções Necessárias

### CRÍTICO - Configurar Sudo
```bash
~/Projects/watchdog_monitor/scripts/setup_sudo.sh
```
**Sem isso, recovery não funciona.**

### CRÍTICO - Reduzir Intervalo de Check
**Atual:** 30 segundos  
**Necessário:** 10-15 segundos durante operações críticas

**Implementar modo adaptativo:**
```
Estado OK: Check a cada 30s
Detectou problema: Check a cada 10s por 5 minutos
Problema crítico: Check a cada 5s até estabilizar
```

### CRÍTICO - Watchdog do Monitor
**Problema:** Se monitor trava, não há proteção  
**Solução:** LaunchAgent com KeepAlive ou script supervisor

### RECOMENDADO - Ação Preventiva para VSCode
**Antes de abrir VSCode com projetos grandes:**

```bash
# Script de pré-abertura
~/Projects/watchdog_monitor/scripts/prepare_vscode.sh
```

Deve executar:
1. `sudo purge` (limpar cache preventivamente)
2. `sync && sync` (flush disco)
3. Parar Spotlight temporariamente
4. Aumentar prioridade do monitor
5. Ativar modo turbo (checks a cada 10s)

### RECOMENDADO - Limites de Memória para VSCode
Configurar VSCode para usar menos memória:

```json
{
  "typescript.tsserver.maxTsServerMemory": 2048,
  "extensions.autoUpdate": false,
  "files.watcherExclude": {
    "**/node_modules/**": true
  }
}
```

## 📈 Métricas de Falha

```
Teste #1 (23:54-23:58):
  - Monitor detectou Load 12.19 + Mem 23MB
  - Tentou recovery (sem variáveis definidas)
  - Crash em 4 minutos
  - Resultado: FALHOU

Teste #2 (00:13-00:34):
  - Monitor detectou Mem baixa
  - Tentou recovery (sem sudo)
  - Monitor provavelmente travou
  - Crash em 21 minutos
  - Resultado: FALHOU
```

## 🔬 Próximos Passos

### Imediato (DEVE FAZER)
1. ✅ Executar `setup_sudo.sh` para permitir recovery
2. ⏳ Reduzir intervalo de check para 15s
3. ⏳ Adicionar tratamento de erro robusto no recovery
4. ⏳ Garantir monitor não trava se sudo falha

### Curto Prazo
5. ⏳ Implementar modo adaptativo (30s → 10s quando detectar problema)
6. ⏳ Criar script de preparação pré-VSCode
7. ⏳ Adicionar watchdog para o próprio monitor
8. ⏳ Melhorar logs de erro (capturar falhas de sudo)

### Médio Prazo
9. ⏳ Criar perfil específico para desenvolvimento
10. ⏳ Integrar com VSCode para preparação automática
11. ⏳ Machine learning para prever crashes

## 💡 Lição Aprendida

**"Detectar não é suficiente - precisa agir E não pode travar"**

- ✅ Detecção funciona
- ❌ Ação falha sem sudo
- ❌ Monitor trava quando falha
- ❌ Sem proteção se monitor morre

**Próximo teste:** Só após configurar sudo E reduzir intervalo

---

**Data:** 2026-02-17 00:36  
**Status:** Sistema precisa de reforços antes do próximo teste
