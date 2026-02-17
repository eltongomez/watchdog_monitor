# 🖥️ Desktop Widgets para Watchdog Monitor

Três opções de widgets para mostrar o monitoramento na área de trabalho do macOS.

---

## 📦 Opção 1: Übersicht Widget (Recomendado)

Widget moderno com design glassmorphism que fica sempre visível na área de trabalho.

### Instalação:

1. **Instalar Übersicht:**
   ```bash
   brew install --cask ubersicht
   ```
   Ou baixe em: https://tracesof.net/uebersicht/

2. **Instalar o widget:**
   ```bash
   mkdir -p ~/Library/Application\ Support/Übersicht/widgets/
   cp -r watchdog-monitor.widget ~/Library/Application\ Support/Übersicht/widgets/
   ```

3. **Ativar Übersicht:**
   - Abra Übersicht.app
   - O widget aparecerá no canto inferior direito
   - Atualiza automaticamente a cada 5 segundos

### Personalização:

Edite `index.jsx` para ajustar:
- **Posição**: Linhas 16-17 (bottom, right, top, left)
- **Tamanho**: Linha 18 (width)
- **Intervalo de atualização**: Linha 14 (refreshFrequency em milissegundos)

---

## 🎨 Opção 2: GeekTool Widget

Widget de texto simples, leve e altamente customizável.

### Instalação:

1. **Instalar GeekTool:**
   ```bash
   brew install --cask geektool
   ```
   Ou baixe em: https://www.tynsoe.org/geektool/

2. **Configurar widget:**
   - Abra GeekTool
   - Arraste um "Shell" para a área de trabalho
   - Cole o conteúdo de `geektool-widget.sh`
   - Configure "Refresh every" para 5 segundos
   - Ajuste fonte, cor e posição

### Dicas de Customização:

**Fonte sugerida:**
- Monaco 12pt ou SF Mono 12pt
- Cor: Branca com sombra preta

**Fundo (opcional):**
- Adicione um "Image" no GeekTool
- Use retângulo preto com opacidade 70%
- Posicione atrás do widget

---

## 🪟 Opção 3: Widget Standalone

Widget HTML em janela flutuante (não requer software adicional).

### Uso:

```bash
chmod +x standalone-widget.sh
./standalone-widget.sh
```

**Limitações:**
- Abre no Safari (ou navegador padrão)
- Não fica "sempre visível" sem apps adicionais
- Melhor usar Übersicht ou GeekTool para widget permanente

---

## 📊 Visual de Cada Opção

### Übersicht (Recomendado):
```
┌─────────────────────────────────┐
│ 🛡️ Watchdog Monitor             │
│                                 │
│ 🟢 TODOS OK                     │
│                                 │
│ SMC        ✅ OK                │
│ Thermal    ✅ OK (0)            │
│ I/O        ✅ OK (0s)           │
│ Load       ✅ OK (2.41)         │
│ Memory     ⚠️ BAIXO (67MB)      │
│                                 │
│ Uptime: 319 ciclos • 21:02:01  │
└─────────────────────────────────┘
```

### GeekTool:
```
🛡️  WATCHDOG MONITOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟢  TODOS OK

SMC:     ✅ OK
Thermal: ✅ OK (0)
I/O:     ✅ OK (0s)
Load:    ✅ OK (2.41)
Memory:  ⚠️ BAIXO (67MB)

Uptime: 319 ciclos
Última atualização: 21:02:01
```

---

## 🎯 Qual Escolher?

| Feature | Übersicht | GeekTool | Standalone |
|---------|-----------|----------|------------|
| Visual moderno | ✅ | ⚠️ | ✅ |
| Sempre visível | ✅ | ✅ | ❌ |
| Fácil instalação | ⚠️ | ⚠️ | ✅ |
| Customizável | ✅ | ✅✅ | ⚠️ |
| Leve no sistema | ✅ | ✅✅ | ⚠️ |

**Recomendação:**
- **Para visual moderno**: Übersicht
- **Para minimalismo**: GeekTool
- **Para teste rápido**: Standalone

---

## 🔧 Troubleshooting

### Widget não mostra dados:
```bash
# Verificar se o monitor está rodando
ps aux | grep watchdog_monitor_visual.sh

# Verificar arquivo de status
cat /tmp/watchdog_status.txt

# Reiniciar monitor
~/Projects/watchdog_monitor/scripts/watchdog_monitor_visual.sh
```

### Übersicht não atualiza:
```bash
# Recarregar widget
# Clique no ícone Übersicht > Reload Widgets
```

### GeekTool mostra "MONITOR INATIVO":
- Verifique se o script tem permissão de execução
- Execute o monitor visual primeiro

---

## 📝 Notas

- Todos os widgets leem de `/tmp/watchdog_status.txt`
- Atualização automática a cada 5 segundos
- Funcionam com o monitor visual rodando
- Sem impacto significativo na performance

---

**Desenvolvido para macOS 12+**
