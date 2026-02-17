# Sistema de Recuperação Automática v2.0

Implementado em 17/02/2026

## ✅ Novos Recursos

### 1. Script de Recuperação (`scripts/watchdog_recovery.sh`)

Ações automáticas para cada tipo de problema:

- **SMC travado** → Recuperação de emergência completa
- **Memória baixa** → `sudo purge` (limpar cache)
- **I/O lento** → Sincronização + pausar Spotlight
- **Carga alta** → Reduzir prioridade de processos
- **Temperatura alta** → Notificar usuário + identificar CPU hogs
- **Múltiplos problemas** → Ações combinadas

### 2. Integração no Monitor

O `watchdog_monitor_visual.sh` agora:

- Detecta problemas em tempo real
- Chama funções de recuperação automaticamente
- Log completo de todas as ações
- Notificações em cada etapa

### 3. Arquivo de Configuração (`config/recovery.conf`)

Controle total sobre:

- Habilitar/desabilitar recuperação global
- Ações específicas por tipo de problema
- Thresholds personalizáveis
- Comportamento de notificações
- Log detalhado

## 🚨 Recuperação de Emergência SMC

Quando SMC trava (situação CRÍTICA):

1. ✅ Notificação urgente imediata
2. ✅ Liberar memória (`sudo purge`)
3. ✅ Sincronizar disco (3x)
4. ✅ Matar processos não-essenciais
5. ⏱️ Aguardar 30s para recuperação
6. 🔄 Verificar se SMC voltou
7. ❓ Se não: Oferecer reinicialização preventiva

### Diálogo Interativo

Se SMC não recuperar em 30s:

```
⚠️ SMC Crítico

SMC ainda não responde após 30 segundos.

Reinicialização preventiva é RECOMENDADA 
para evitar kernel panic.

O que deseja fazer?

[Aguardar]  [Reiniciar em 1 min]
```

## 📊 Fluxo de Recuperação

```
Problema Detectado
       ↓
Verificar Severidade
       ↓
   ┌───┴───┐
   │       │
 AVISO  CRÍTICO
   │       │
   ↓       ↓
 Ação   Emergência
 Auto    SMC
   │       │
   ↓       ↓
Notificar  Recuperar
   │       │
   ↓       ↓
 Log     Verificar
   │       │
   ↓       ↓
Continuar  OK?
           │
       ┌───┴───┐
       │       │
      SIM     NÃO
       │       │
       ↓       ↓
    Sucesso  Reboot?
```

## 🎛️ Configuração

Edite `config/recovery.conf` para customizar:

```bash
# Habilitar recuperação automática
RECOVERY_ENABLED=true

# SMC - reinicialização automática sem perguntar
SMC_AUTO_REBOOT=false  # Recomendado: false

# Memória - limpar cache automaticamente  
MEMORY_AUTO_PURGE=true

# I/O - parar Spotlight temporariamente
IO_STOP_SPOTLIGHT=true

# Threshold para múltiplos problemas
MULTIPLE_PROBLEMS_THRESHOLD=3
```

## 📝 Logs

Dois arquivos de log:

1. **watchdog_monitor.log** - Monitor geral
2. **watchdog_recovery.log** - Ações de recuperação específicas

Formato:
```
[2026-02-17 01:23:45] AÇÃO: Liberando memória do sistema
[2026-02-17 01:23:46] ✓ Cache limpo com sucesso
[2026-02-17 01:23:50] 🚨 EMERGÊNCIA: SMC NÃO RESPONDE!
[2026-02-17 01:24:20] ✅ SMC RECUPERADO COM SUCESSO!
```

## ⚠️ Permissões

Algumas ações requerem `sudo`:

- `sudo purge` - Limpar cache
- `sudo mdutil` - Controlar Spotlight  
- `sudo shutdown` - Reinicialização

Configure sudo sem senha para usuário:
```bash
sudo visudo
# Adicionar:
seu_usuario ALL=(ALL) NOPASSWD: /usr/sbin/purge, /usr/bin/mdutil, /sbin/shutdown
```

Ou execute o monitor com sudo (menos recomendado).

## 🧪 Testar Recuperação

### Simular memória baixa:
```bash
# Consumir memória
stress --vm 2 --vm-bytes 2G --timeout 60s
```

### Simular I/O lento:
```bash
# Estressar disco
dd if=/dev/zero of=/tmp/test_io bs=1m count=5000
```

### Simular carga alta:
```bash
# Usar CPU
yes > /dev/null &
yes > /dev/null &
# Depois: killall yes
```

## ✅ Status Atual

- ✅ Script de recuperação criado
- ✅ Integrado ao monitor
- ✅ Configuração personalizável
- ✅ Logs detalhados
- ✅ Notificações interativas
- ✅ Documentação completa

## 🚀 Uso

O sistema está **ativo por padrão**. Para desabilitar:

```bash
# Editar config
nano ~/Projects/watchdog_monitor/config/recovery.conf

# Mudar para:
RECOVERY_ENABLED=false

# Reiniciar monitor
pgrep -f watchdog_monitor_visual.sh | xargs kill
cd ~/Projects/watchdog_monitor
./scripts/watchdog_monitor_visual.sh --daemon
```
