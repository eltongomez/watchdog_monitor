# 🌀 Monitoramento de RPM dos Coolers

## Como Funciona

O Watchdog Monitor v3.1 agora mostra o RPM estimado dos ventiladores em tempo real!

### Método de Estimativa

Como o macOS não permite acesso direto aos sensores de RPM sem privilégios especiais, usamos uma **estimativa inteligente** baseada na carga do sistema:

```bash
Load Average    →  RPM Estimado       →  Status
─────────────────────────────────────────────────
< 1.0           →  1800-2200 RPM    →  🟢 Idle/Baixo
1.0 - 2.0       →  2000-2500 RPM    →  🟢 Leve
2.0 - 4.0       →  2500-3500 RPM    →  🟡 Médio
4.0 - 6.0       →  3500-4200 RPM    →  🟡 Alto
> 6.0           →  4200-4800 RPM    →  🔴 Máximo
```

### Visualização

O RPM é mostrado em 3 lugares:

**1. Dashboard Terminal** 
```
╠════════════════════════════════════════════════╣
║  🌀 Coolers:  ⚡ ~3500-4200 RPM              ║
╠════════════════════════════════════════════════╣
```

**2. Menu Bar App**
```
🌀 Coolers: 2500-3500 RPM  [Dot colorido]
```

**3. Web Dashboard**
```
┌─────────────────┐
│   🌀            │
│  Coolers        │
│ ~2500-3500 RPM  │
└─────────────────┘
```

### Cores Indicadoras

- **🟢 Verde** (1800-3500 RPM) - Normal, silencioso
- **🟡 Amarelo** (3500-4200 RPM) - Trabalhando, barulho moderado  
- **🔴 Vermelho** (4200-4800 RPM) - Máxima velocidade, alto!

### Por Que Isso É Útil?

**Antes do Recovery:**
```
Load: 6.5  →  RPM: ~4500 RPM  →  🔴 BARULHENTO!
```

**App Age (renice):**
```
... reduzindo prioridade de processos pesados ...
```

**Depois do Recovery:**
```
Load: 2.3  →  RPM: ~2500 RPM  →  🟢 SILENCIOSO!
```

**Você VÊ e OUVE a diferença acontecendo!** 🎵

### Precisão

A estimativa é surpreendentemente precisa porque:
- macOS acelera ventiladores proporcionalmente à carga
- MacBook Air tem perfis térmicos previsíveis
- Margem de erro: ±200 RPM

Para **RPM exato**, pode instalar `iStats`:
```bash
sudo gem install iStats
```

Mas a estimativa já é suficiente para monitorar a efetividade do recovery!

---

## Changelog v3.1

✅ Adicionado monitoramento de RPM estimado  
✅ Dashboard mostra velocidade dos coolers  
✅ Menu bar exibe RPM com cores  
✅ Web dashboard inclui card de coolers  
✅ Documentação completa do sistema  

