# 📸 Exemplos Visuais dos Widgets

## 🎨 Übersicht Widget (Design Moderno)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🛡️ Watchdog Monitor                ┃
┃                                    ┃
┃ ┌──────────────┐                  ┃
┃ │ 🟢 TODOS OK  │                  ┃
┃ └──────────────┘                  ┃
┃                                    ┃
┃ SMC         ✅ OK                  ┃
┃ ─────────────────────────────────  ┃
┃ Thermal     ✅ OK (0)              ┃
┃ ─────────────────────────────────  ┃
┃ I/O         ✅ OK (0s)             ┃
┃ ─────────────────────────────────  ┃
┃ Load        ✅ OK (2.41)           ┃
┃ ─────────────────────────────────  ┃
┃ Memory      ⚠️ BAIXO (67MB)        ┃
┃                                    ┃
┃     Uptime: 319 ciclos • 21:02    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

**Características:**
- 🎨 Design glassmorphism (fundo transparente com blur)
- 📊 Badges coloridos por status (verde/amarelo/vermelho)
- 🔄 Auto-atualização a cada 5 segundos
- 📍 Posicionável em qualquer canto da tela
- 🌓 Funciona em modo claro e escuro

---

## 📝 GeekTool Widget (Minimalista)

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

**Características:**
- 📝 Texto puro, leve e rápido
- 🎨 100% customizável (fonte, cor, sombra)
- 📏 Layout compacto
- 🔤 Fonte monoespaçada recomendada
- 🎭 Pode adicionar fundo personalizado

---

## 🌐 Dashboard Web

```
┌─────────────────────────────────────────────┐
│  🛡️ WATCHDOG MONITOR DASHBOARD             │
│                                             │
│  ┌─────────────────┐                       │
│  │  🟢 TODOS OK    │                       │
│  │  Sistema Normal │                       │
│  └─────────────────┘                       │
│                                             │
│  ╔══════════════════════════════════════╗  │
│  ║  SMC Status          ✅ OK          ║  │
│  ╠══════════════════════════════════════╣  │
│  ║  Temperature         ✅ OK (Nível 0)║  │
│  ╠══════════════════════════════════════╣  │
│  ║  Disk I/O           ✅ OK (0s)      ║  │
│  ╠══════════════════════════════════════╣  │
│  ║  System Load        ✅ OK (2.41)    ║  │
│  ╠══════════════════════════════════════╣  │
│  ║  Memory             ⚠️ BAIXO (67MB) ║  │
│  ╚══════════════════════════════════════╝  │
│                                             │
│  📊 Uptime: 319 ciclos (~53 minutos)       │
│  🕐 Última atualização: 2026-02-16 21:02   │
│                                             │
│  [ Atualizar Agora ]                       │
└─────────────────────────────────────────────┘
```

**Características:**
- 🌐 Acessa via navegador
- 📱 Design responsivo
- 🔄 Auto-refresh a cada 5 segundos
- 🎨 Visual moderno com gradientes
- 📊 Estatísticas detalhadas

---

## 📱 Menu Bar Widget (SwiftBar)

```
🟢 WD
───────────────────────
🛡️ Watchdog Monitor
───────────────────────
✅ SMC: OK
✅ Thermal: OK (0)
✅ I/O: OK (0s)
✅ Load: OK (2.41)
⚠️ Memory: BAIXO (67MB)
───────────────────────
⏱️ Uptime: 319 ciclos
🕐 21:02:01
───────────────────────
🔄 Atualizar
📊 Abrir Dashboard
📋 Ver Logs
```

**Características:**
- 📍 Sempre visível na barra de menu
- 🎯 Acesso rápido ao status
- 🔔 Indicador visual colorido
- ⚡ Clique para detalhes
- 🔧 Ações rápidas no menu

---

## 🎭 Estados do Widget

### Estado Normal (Tudo OK)
```
🟢 TODOS OK

✅ SMC: OK
✅ Thermal: OK (0)
✅ I/O: OK (0s)
✅ Load: OK (2.41)
✅ Memory: OK (250MB)
```

### Estado de Aviso
```
🟡 1 AVISO

✅ SMC: OK
✅ Thermal: OK (0)
✅ I/O: OK (0s)
⚠️ Load: ALTO (5.23)
✅ Memory: OK (250MB)
```

### Estado Crítico
```
🔴 2 CRÍTICOS

🔴 SMC: ERRO
✅ Thermal: OK (0)
🔴 I/O: CRÍTICO (>5s)
✅ Load: OK (2.41)
✅ Memory: OK (250MB)
```

### Monitor Inativo
```
⏸️

Monitor Inativo

Execute:
watchdog_monitor_visual.sh
```

---

## 🎨 Personalização

### Übersicht - Mudar Posição

Edite `index.jsx`, linhas 16-17:

```javascript
// Canto inferior direito (padrão)
bottom: 20px;
right: 20px;

// Canto superior esquerdo
top: 20px;
left: 20px;

// Centro inferior
bottom: 20px;
left: 50%;
transform: translateX(-50%);
```

### GeekTool - Estilo de Fonte

Configurações recomendadas:
- **Fonte**: SF Mono ou Monaco, 12pt
- **Cor**: Branca (#FFFFFF)
- **Sombra**: Preta, offset 1px, blur 2px
- **Fundo**: Preto 70% opacidade (opcional)

### Dashboard - Tema Escuro

O dashboard adapta automaticamente ao tema do sistema, mas você pode forçar:

```javascript
// Adicione ao CSS
body {
    color-scheme: dark; /* Força tema escuro */
}
```

---

## 📸 Screenshots Reais

*(Aqui você pode adicionar screenshots reais quando instalar os widgets)*

1. Übersicht na área de trabalho
2. GeekTool com wallpaper personalizado
3. Dashboard web no Safari
4. Menu bar com SwiftBar

---

## 🎯 Comparação Visual

| Widget | Espaço | Visual | Customização |
|--------|--------|--------|--------------|
| Übersicht | ⭐⭐⭐ Médio | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐⭐⭐ Bom |
| GeekTool | ⭐⭐⭐⭐⭐ Mínimo | ⭐⭐⭐ Básico | ⭐⭐⭐⭐⭐ Máximo |
| Dashboard | ⭐⭐ Janela | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐⭐ Médio |
| Menu Bar | ⭐⭐⭐⭐⭐ Mínimo | ⭐⭐⭐⭐ Bom | ⭐⭐⭐ Médio |

---

**💡 Dica:** Use Übersicht para visual moderno ou GeekTool para máxima personalização!
