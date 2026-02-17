# Padrão de Crashes Identificado

## 🎯 Gatilho Específico

**Situação:** Crashes do kernel (watchdog timeout) ocorrem frequentemente ao abrir o projeto `/Users/elima/Projects/compre_certo` no VSCode.

## 📊 Características do Projeto

```
Tamanho total: 2.2 GB
Arquivos totais: 91,922
Arquivos node_modules: 46,752 (51% do total)
Estrutura: Projeto TypeScript/Node.js com cliente e servidor
```

## 🔍 Análise da Causa

### Por que VSCode + este projeto causa problemas?

1. **Indexação Massiva**
   - VSCode indexa 91k+ arquivos ao abrir
   - TypeScript language server analisa tipos
   - ESLint/Prettier escaneiam código
   - Git extension processa histórico

2. **Carga de I/O Extrema**
   - Leitura simultânea de milhares de arquivos
   - node_modules com 46k+ arquivos
   - Watchdog do macOS monitora cada operação de I/O
   - **Gargalo:** SSD responde, mas watchdog do kernel não recebe ACK a tempo

3. **Pressão de Memória**
   - VSCode + extensões carregam em RAM
   - TypeScript server consome ~300-500MB
   - Buffers de I/O enchem
   - **Resultado:** SMC pode congelar temporariamente sob pressão

4. **Processos Electron**
   - VSCode roda múltiplos processos Electron
   - Cada processo pode gerar carga no SMC
   - GPU helper + network service + node services

## 🛡️ Proteção Atual (v2.0)

O sistema de monitoramento já oferece proteção:

### Detecção Preventiva
✅ Monitor verifica I/O a cada 30s
✅ Monitor verifica memória
✅ Monitor verifica carga do sistema
✅ Detecta quando SMC não responde

### Recuperação Automática
Se detectar problemas ao abrir VSCode:
1. **I/O alto:** `sync` + pausa Spotlight
2. **Memória baixa:** `sudo purge` libera cache
3. **Carga alta:** Reduz prioridade de processos pesados
4. **SMC travado:** Sequência de emergência (flush, kill, oferta de reboot)

## 💡 Recomendações Adicionais

### 1. Otimizar VSCode para Projetos Grandes

Adicione ao `.vscode/settings.json` do projeto:

```json
{
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/dist/**": true,
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.git": true,
    "**/pnpm-lock.yaml": true
  },
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true
  },
  "typescript.tsserver.maxTsServerMemory": 4096,
  "typescript.disableAutomaticTypeAcquisition": true
}
```

### 2. Desabilitar Extensões Pesadas

Desative temporariamente:
- GitLens (indexação pesada)
- ESLint (análise em tempo real)
- Prettier (formatação automática)
- IntelliSense pesado

### 3. Usar Workspace Parcial

Em vez de abrir todo o projeto, abra apenas:
- `/client` OU `/server` separadamente
- Reduz 50% da indexação

### 4. Pré-abrir com Monitor Ativo

**Antes de abrir o projeto no VSCode:**

```bash
# Verificar se monitor está ativo
ps aux | grep watchdog_monitor | grep -v grep

# Liberar memória preventivamente
sudo purge

# Monitorar em tempo real durante abertura
tail -f ~/Projects/watchdog_monitor/logs/watchdog_monitor.log
```

### 5. Observar Padrão

Após abrir VSCode com projeto:
- Aguardar 2-3 minutos para indexação inicial
- Observar menu bar app (bolinhas devem ficar verdes)
- Se ficar laranja/vermelho, monitor age automaticamente

## 📈 Métricas Esperadas ao Abrir VSCode

```
Normal:
  Load: 1.5 → 3.5 (pico nos primeiros 30s)
  Memory: +200-500 MB
  I/O: 1-3s (durante indexação)
  Thermal: +10-20°C

Problema (antes do monitor):
  Load: > 5.0
  Memory: > 90% do total
  I/O: > 5s (timeout)
  SMC: não responde → KERNEL PANIC após 93s

Com v2.0:
  Sistema detecta e age antes dos 93s
  Previne o crash
```

## 🧪 Teste Recomendado

1. Garantir monitor v2.0 ativo
2. Abrir Terminal separado com: `tail -f ~/Projects/watchdog_monitor/logs/watchdog_recovery.log`
3. Abrir VSCode com projeto compre_certo
4. Observar se sistema age automaticamente
5. Verificar se crashes param de ocorrer

## 📝 Histórico

- **Antes:** Crash em ~50% das vezes ao abrir projeto
- **v1.0:** Notificação, mas sem ação → ainda crashava
- **v2.0:** Recuperação automática → esperamos 0% crashes

---

**Data:** 2026-02-17  
**Identificado por:** Análise de padrão de uso do usuário
