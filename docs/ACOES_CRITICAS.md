# Ações em Estados Críticos - Watchdog Monitor

## 📊 Comportamento Atual (v1.0)

Quando o monitor detecta problemas, ele:

### ✅ O que já faz:

1. **Notificação Visual**
   - Som de alerta (Basso para avisos, Sosumi para crítico)
   - Notificação do macOS com descrição do problema
   - Ícone da barra de menu muda de cor (laranja/vermelho)

2. **Registro em Log**
   - Grava timestamp e detalhes no `logs/watchdog_monitor.log`
   - Mantém histórico para análise

3. **Atualização de Status**
   - Widget/dashboard mostram status em tempo real
   - Menu bar mostra bolinhas coloridas por métrica

4. **Keepalive Contínuo**
   - Continua fazendo verificações a cada 10-30s
   - Comando `sync` mantém sistema ativo

### ❌ O que NÃO faz ainda:

- Não toma ações corretivas automáticas
- Não reinicia serviços problemáticos
- Não libera memória automaticamente
- Não para processos pesados

---

## 🚀 Comportamento Melhorado (v2.0) - PROPOSTO

### Estados e Ações:

#### 🟢 **OK (0 problemas)**
- Continua monitoramento normal
- Nenhuma ação necessária

#### 🟠 **AVISO (1-2 problemas)**

**Ações Automáticas:**

1. **Memória Baixa**
   ```bash
   # Limpar cache do sistema
   sudo purge
   ```

2. **I/O Lento**
   ```bash
   # Forçar sincronização de disco
   sync && sync
   ```

3. **Carga Alta**
   ```bash
   # Reduzir prioridade de processos pesados
   renice +10 -p <processos_pesados>
   ```

**Notificação ao Usuário:**
- "⚠️ Aviso: [problema] detectado"
- "Ação tomada: [descrição]"
- "Monitorando recuperação..."

#### 🔴 **CRÍTICO (3+ problemas ou SMC falhou)**

**Ações Automáticas:**

1. **SMC não responde** (CRÍTICO!)
   ```bash
   # 1. Notificação urgente
   # 2. Forçar liberação de recursos
   sudo purge
   sync && sync
   
   # 3. Matar processos não-essenciais
   killall -9 Spotlight mds mds_stores
   
   # 4. Se ainda crítico após 30s → Sugerir reinicialização
   ```

2. **Múltiplos problemas simultaneamente**
   ```bash
   # Ação de emergência
   # 1. Salvar trabalho (notificação)
   # 2. Liberar máximo de recursos
   # 3. Countdown de 60s para reinicialização preventiva
   ```

**Notificação ao Usuário:**
```
⚠️ ESTADO CRÍTICO DETECTADO!

Problema: SMC não respondendo
Ação: Liberando recursos do sistema
Tempo restante: 60 segundos

[Cancelar Reinicialização] [Reiniciar Agora]
```

---

## 🛡️ Estratégia de Recuperação por Problema

### 1. **SMC Não Responde** (MAIS CRÍTICO!)

```bash
# Sequência de recuperação
1. Notificar usuário IMEDIATAMENTE
2. Forçar sync de disco
3. Liberar memória (purge)
4. Matar processos não-essenciais
5. Se não melhorar em 30s → Reinicialização assistida
```

**Por quê?** SMC travado é exatamente o que causa kernel panic!

### 2. **Temperatura Alta**

```bash
1. Notificar usuário
2. Identificar processos que usam mais CPU
3. Oferecer reduzir carga
4. Sugerir fechar aplicações pesadas
```

**Orientação:** "Feche aplicações pesadas para resfriar o sistema"

### 3. **I/O Lento**

```bash
1. Forçar sync múltiplos
2. Parar Spotlight temporariamente
3. Parar Time Machine se ativo
4. Verificar processos com I/O alto
```

**Orientação:** "Pausando serviços de background para melhorar I/O"

### 4. **Carga Alta**

```bash
1. Listar top 5 processos por CPU
2. Sugerir fechar aplicações
3. Reduzir prioridade de processos não-críticos
```

**Orientação:** "Sistema sobrecarregado. Processos pesados: Chrome (34%), Xcode (28%)"

### 5. **Memória Baixa**

```bash
1. sudo purge (limpar cache)
2. Identificar apps com mais memória
3. Sugerir fechar aplicações
```

**Orientação:** "Memória crítica. Feche aplicações não utilizadas"

---

## 🔧 Implementação Proposta

### Arquivo: `scripts/watchdog_recovery.sh`

```bash
#!/bin/bash

# Função de recuperação automática
auto_recover() {
    local problem_type="$1"
    local severity="$2"  # warning, critical, emergency
    
    case "$problem_type" in
        smc)
            # EMERGÊNCIA: SMC travado
            emergency_smc_recovery
            ;;
        memory)
            # Liberar memória
            sudo purge
            ;;
        io)
            # Melhorar I/O
            sync && sync
            sudo mdutil -i off /  # Parar Spotlight
            ;;
        load)
            # Reduzir carga
            reduce_system_load
            ;;
        thermal)
            # Resfriar sistema
            reduce_cpu_usage
            ;;
    esac
}

emergency_smc_recovery() {
    # CRÍTICO: SMC não responde
    
    # 1. Alerta máximo
    osascript -e 'display alert "⚠️ EMERGÊNCIA: SMC TRAVADO" message "Liberando recursos para evitar kernel panic. Sistema pode reiniciar em 60s se não melhorar." as critical'
    
    # 2. Liberar tudo
    sudo purge
    sync && sync && sync
    
    # 3. Matar não-essenciais
    killall Spotlight mds mds_stores 2>/dev/null
    
    # 4. Aguardar 30s
    sleep 30
    
    # 5. Verificar novamente
    if ! ioreg | grep -q AppleSMC; then
        # Ainda travado! Oferecer reinicialização
        osascript -e 'display alert "SMC AINDA TRAVADO" message "Recomendado reiniciar AGORA para evitar kernel panic." buttons {"Cancelar", "Reiniciar Agora"} default button 2' -timeout 30
        
        if [ $? -eq 0 ]; then
            sudo shutdown -r +1 "Reinicialização preventiva - SMC travado"
        fi
    fi
}
```

---

## 📋 Resumo de Ações

| Estado | Problema | Ação Automática | Orientação ao Usuário |
|--------|----------|-----------------|----------------------|
| 🟢 OK | Nenhum | Continuar monitorando | - |
| 🟠 Aviso | Memória baixa | `sudo purge` | "Cache limpo" |
| 🟠 Aviso | I/O lento | `sync && sync` | "Sincronizando disco" |
| 🟠 Aviso | Carga alta | Reduzir prioridade | "Feche apps pesados" |
| 🟠 Aviso | Temp alta | Identificar CPU pesado | "Feche apps que usam CPU" |
| 🔴 Crítico | SMC travado | **EMERGÊNCIA** | "⚠️ Reinicialização em 60s" |
| 🔴 Crítico | 3+ problemas | Liberar recursos | "Estado crítico - salvando" |

---

## ✅ Vantagens da Recuperação Automática

1. **Prevenção Proativa** - Age antes do timeout de 93s
2. **Sem Intervenção Manual** - Usuário não precisa fazer nada em avisos
3. **Opções em Crítico** - Usuário pode cancelar reinicialização se necessário
4. **Logging Completo** - Todas ações registradas para análise
5. **Notificações Claras** - Usuário sempre sabe o que está acontecendo

---

## 🚧 Implementar?

Quer que eu implemente essas ações automáticas de recuperação? Posso:

1. Criar o script `watchdog_recovery.sh`
2. Integrar no `watchdog_monitor_visual.sh`
3. Adicionar configurações (habilitar/desabilitar ações automáticas)
4. Criar interface para usuário controlar o que fazer em cada situação
