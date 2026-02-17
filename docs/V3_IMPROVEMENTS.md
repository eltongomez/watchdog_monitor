# Melhorias v3.0 - Thresholds Ajustados

## 📊 Mudanças Implementadas

### 1. Thresholds de Memória Ajustados

**Antes:**
```
< 100MB = BAIXO (return 1)
>= 100MB = OK (return 0)
```

**Depois:**
```
< 500MB = CRÍTICO (return 2) - Ação imediata
< 1000MB = BAIXO (return 1) - Ação na 2ª iteração  
>= 1000MB = OK (return 0)
```

**Racional:**
- Ciclo #12 crash anterior: 1549MB ainda era "OK"
- Ciclo #13 crash anterior: 225MB já era tarde demais
- Agora age quando memória < 1000MB (muito antes do perigo)

### 2. Thresholds de Load Ajustados

**Antes:**
```
> 8 = ALTO (return 1)
<= 8 = OK (return 0)
```

**Depois:**
```
>= 5.0 = CRÍTICO (return 2) - Ação imediata
>= 4.0 = ALTO (return 1) - Ação na 2ª iteração
< 4.0 = OK (return 0)
```

**Racional:**
- Load 4.52 no Ciclo #12 não ativava nada (threshold era 8)
- Load 6.07 no Ciclo #13 ainda não ativava
- Agora age em >= 4.0 (preventivo) e >= 5.0 (crítico)

### 3. Ação Imediata para Casos Críticos

**Antes:**
```bash
# Todas as ações só na 2ª iteração (iteration > 1)
if [ $iteration -gt 1 ]; then
    if [ $memory_ok -ne 0 ]; then
        recover_memory
    fi
fi
```

**Depois:**
```bash
# Memória CRÍTICA (< 500MB) - age IMEDIATAMENTE
if [ $memory_ok -eq 2 ]; then
    log_message "CRÍTICO: Memória crítica (< 500MB) - ação imediata"
    recover_memory
fi

# Memória BAIXA (< 1000MB) - age na 2ª iteração
elif [ $memory_ok -eq 1 ] && [ $iteration -gt 1 ]; then
    log_message "AVISO: Memória baixa (< 1000MB) - liberando cache"
    recover_memory
fi

# Load CRÍTICO (>= 5.0) - age IMEDIATAMENTE
if [ $load_ok -eq 2 ]; then
    log_message "CRÍTICO: Load crítico (>= 5.0) - ação imediata"
    recover_load
fi

# Load ALTO (>= 4.0) - age na 2ª iteração
elif [ $load_ok -eq 1 ] && [ $iteration -gt 1 ]; then
    log_message "AVISO: Carga alta (>= 4.0) - reduzindo prioridade"
    recover_load
fi
```

**Benefícios:**
- Casos críticos: Ação **instantânea** (1ª detecção)
- Casos warnings: Ação na 2ª detecção (evita falsos positivos)
- Logs mais descritivos com thresholds

### 4. Intervalo Mantido em 15s

**Atual:** Check a cada 15 segundos (reduzido de 30s)

**Benefício:**
- Janela de detecção: 15s (antes 30s)
- Margem para ação: 93s - 15s = 78s disponíveis
- Caso crítico detectado: Age imediatamente

### 5. Menu Bar App Atualizado

**Novo recurso:**
- Menu "Configurações" com toggle "Iniciar com o Sistema"
- Gerenciamento automático de LaunchAgent
- Marca visual (✓) quando habilitado
- Alertas de confirmação

## 📈 Comparação de Cenários

### Crash Anterior (#3)

```
00:52:17 - Ciclo #12: Load 4.52, Mem 1549MB
           Status: TODOS OK (thresholds não atingidos)
           Ação: NENHUMA

00:52:34 - Ciclo #13: Load 6.07, Mem 225MB
           Status: Detectado mas não agiu
           Ação: NENHUMA (morreu antes de agir)
           
00:58:29 - CRASH (6 minutos depois)
```

### Com v3.0 (Esperado)

```
Ciclo #1: Load 4.52, Mem 1549MB
          Status: Load ALTO (>= 4.0)
          Ação: Aguarda 2ª iteração

Ciclo #2: Load 4.8, Mem 1200MB  
          Status: Load ALTO + Mem BAIXA
          Ação: recover_memory + recover_load
          Resultado: sudo purge + sync + renice

Ciclo #3: Load 3.5, Mem 2500MB
          Status: Sistema estabilizado
          Ação: Monitoramento continua

Resultado: SEM CRASH ✅
```

### Cenário Extremo

```
Ciclo #1: Load 6.5, Mem 400MB
          Status: Load CRÍTICO + Mem CRÍTICA
          Ação: IMEDIATA (sem esperar 2ª iteração)
          - sudo purge (libera cache)
          - sync (flush disco)
          - renice (reduz prioridade VSCode)
          
Ciclo #2: Load 4.2, Mem 1800MB
          Status: Estabilizando
          Ação: Continua monitorando

Ciclo #3: Load 2.1, Mem 2900MB
          Status: OK
          Ação: Voltou ao normal

Resultado: CRASH EVITADO ✅
```

## 🎯 Próximo Teste

**Condições:**
- ✅ Monitor com thresholds v3.0 ativo (PID: 889)
- ✅ Intervalo: 15 segundos
- ✅ Sudo configurado
- ✅ Menu bar app recompilado

**Expectativa:**
1. Abrir VSCode com compre_certo
2. Load sobe para ~4-6
3. Memória cai para ~1000-1500MB
4. Monitor detecta no Ciclo #1 ou #2
5. Recovery age: purge + sync
6. Sistema estabiliza
7. **SEM CRASH** ✅

**Logs esperados:**
```
[01:XX:XX] Ciclo #N - Load:ALTO (4.52) | Mem:BAIXO (1549MB)
[01:XX:XX] AVISO: Carga alta (>= 4.0) - reduzindo prioridade
[01:XX:XX] AVISO: Memória baixa (< 1000MB) - liberando cache
[01:XX:XX] RECOVERY: Executando sudo purge...
[01:XX:XX] RECOVERY: ✓ Cache limpo com sucesso
[01:XX:XX] Ciclo #N+1 - Load:OK (2.1) | Mem:OK (2500MB)
```

---

**Data:** 2026-02-17 01:20  
**Status:** v3.0 ativo e pronto para teste  
**Monitor PID:** 889  
**App:** Recompilado com menu Configurações
