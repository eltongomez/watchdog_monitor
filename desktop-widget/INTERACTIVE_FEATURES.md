# 🎮 Recursos Interativos do Widget

O widget Übersicht agora possui recursos interativos completos para gerenciar o monitoramento diretamente da área de trabalho.

---

## 📋 Menu de Opções

### Como Acessar:
Clique no botão **⋯** no canto superior direito do widget.

### Opções Disponíveis:

#### 📊 Open Terminal View
- Abre o Terminal com o monitor visual interativo
- Exibe dashboard colorido em tempo real
- Útil para acompanhar detalhes completos

#### 🌐 Open Web Dashboard
- Abre o dashboard HTML no navegador
- Interface visual completa
- Atualiza automaticamente

#### 🔄 Restart Monitor
- Para e reinicia o daemon
- Útil após atualizações
- Mantém configurações

#### ■ Stop Monitor
- Para o daemon completamente
- Widget mostra "Monitor Inativo"
- Pode reiniciar via menu

#### 📄 View Logs
- Abre arquivo de logs no editor padrão
- Histórico completo de eventos
- Útil para diagnóstico

#### 🔍 Run Diagnostics
- Executa diagnóstico completo no Terminal
- Verifica SMART, I/O, sistema de arquivos
- Gera relatório detalhado

---

## 🔔 Avisos Clicáveis

### Como Funciona:

Quando o status badge mostra **avisos** ou **erros**, ele se torna **clicável**.

#### Status Normais (Não Clicável):
```
● TODOS OK       (verde, não clicável)
```

#### Status com Avisos (Clicável):
```
● 1 AVISO        (laranja, clicável - mostra detalhes)
● 2 AVISOS       (laranja, clicável)
```

#### Status com Erros (Clicável):
```
● 1 CRÍTICO      (vermelho, clicável - mostra detalhes)
● 2 CRÍTICOS     (vermelho, clicável)
```

### Modal de Detalhes:

Ao clicar no status badge com avisos/erros, um modal aparece mostrando:

**Features do Modal:**
- Fundo blur para foco no conteúdo
- Cada aviso em card separado
- Borda colorida (laranja/vermelho)
- Nome do check em destaque
- Valor completo do aviso
- Fecha ao clicar fora ou no botão

### Cores dos Avisos:

| Tipo | Cor | Border |
|------|-----|--------|
| **Warning** | 🟠 Laranja (#FF9500) | Borda laranja |
| **Error** | 🔴 Vermelho (#FF3B30) | Borda vermelha |

---

## 🎨 Efeitos Visuais

### Hover Effects:

#### Menu Button:
- Normal: Fundo semi-transparente
- Hover: Fundo mais claro + borda mais visível
- Active: Fundo ainda mais claro

#### Menu Items:
- Normal: Transparente
- Hover: Fundo claro + texto branco
- Active: Fundo mais intenso

#### Status Badge com Avisos:
- Normal: Posição normal
- Hover: Eleva 1px + sombra colorida

---

## 🔄 Comportamento

### Menu Dropdown:

1. **Abre** ao clicar no botão ⋯
2. **Fecha** automaticamente após selecionar opção
3. **Fecha** ao clicar fora (em qualquer lugar)
4. **Z-index**: 1000 (sempre visível)

### Modal de Avisos:

1. **Abre** ao clicar no status badge (se houver avisos)
2. **Fecha** ao clicar no overlay (fundo escuro)
3. **Fecha** ao clicar no botão "Close"
4. **Z-index**: 2000 (acima de tudo)

---

## 📱 Estados do Widget

### 1. Monitor Inativo

```
SYSTEM MONITOR              [⋯]

    ■ Monitor Inativo
    
    Click Menu → Start Monitor
```

**Menu disponível:**
- ▶ Start Monitor
- 📄 View Logs
- 🔍 Run Diagnostics

### 2. Monitor Ativo - Normal

```
SYSTEM MONITOR              [⋯]

● TODOS OK

● SMC Status         OK
● Temperature        0
● Disk I/O          0s
● System Load       2.41
● Memory            896MB

1809 cycles • 21:25
```

**Menu completo disponível**

### 3. Monitor Ativo - Com Avisos

```
SYSTEM MONITOR              [⋯]

● 1 AVISO  ← CLICÁVEL

● SMC Status         OK
● Temperature        0
● Disk I/O          0s
● System Load       5.23  ← ALTO
● Memory            896MB

1809 cycles • 21:25
```

**Clique no "1 AVISO" para ver detalhes**

---

## 🎯 Casos de Uso

### Iniciar Monitoramento:
1. Clique em **⋯**
2. Selecione **▶ Start Monitor**
3. Aguarde 5 segundos (widget atualiza)

### Ver Detalhes de um Aviso:
1. Veja status badge laranja/vermelho
2. Clique no badge
3. Leia detalhes no modal
4. Clique "Close" ou fora do modal

### Reiniciar Após Problema:
1. Clique em **⋯**
2. Selecione **🔄 Restart Monitor**
3. Widget reinicia daemon
4. Status volta ao normal

### Verificar Logs:
1. Clique em **⋯**
2. Selecione **📄 View Logs**
3. Arquivo abre no editor padrão

### Diagnóstico Completo:
1. Clique em **⋯**
2. Selecione **🔍 Run Diagnostics**
3. Terminal abre com diagnóstico
4. Aguarde resultados

---

## 🛠️ Integração com Scripts

### Scripts Chamados:

| Ação | Script | Tipo |
|------|--------|------|
| Start | `watchdog_monitor_visual.sh --daemon` | Background |
| Restart | Stop + Sleep + Start | Sequência |
| Dashboard | `open_dashboard.sh` | Script |
| Logs | `open logs/watchdog_monitor.log` | Arquivo |
| Diagnostics | `diagnostico_disco.sh` | Terminal |
| Terminal View | `watchdog_monitor_visual.sh` | Terminal |

---

## ✨ Próximas Melhorias

Possíveis adições futuras:

- [ ] Histórico de avisos
- [ ] Notificações macOS nativas
- [ ] Gráficos de tendência
- [ ] Configurações via widget
- [ ] Temas claro/escuro
- [ ] Atalhos de teclado
- [ ] Widget draggable

---

**Versão:** 3.0 Interactive
**Data:** 2026-02-17
