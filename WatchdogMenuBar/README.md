# Watchdog Menu Bar App

Aplicativo nativo do macOS para monitorar o sistema diretamente da barra de menu.

## Características

- **Nativo do macOS**: Escrito em Swift, totalmente integrado ao sistema
- **Leve e eficiente**: Consome mínimos recursos
- **Menu interativo**: Todas as opções de controle em um clique
- **Atalhos de teclado**: Acesso rápido às funções principais
- **Auto-start**: Inicia automaticamente no login
- **Status visual**: Ícone colorido indica status do sistema

## Instalação

```bash
cd ~/Projects/watchdog_monitor/WatchdogMenuBar

# Compilar
./build.sh

# Instalar (inicia automaticamente)
./install.sh
```

## Uso

Após instalação, um ícone ● aparecerá na barra de menu:
- **Verde (●)**: Sistema OK
- **Laranja (●)**: Avisos
- **Vermelho (●)**: Erros críticos
- **Branco (○)**: Monitor inativo

### Menu Interativo

Clique no ícone para acessar:

**Métricas:**
- Status geral
- SMC Status
- Temperature
- Disk I/O
- System Load
- Memory
- Uptime

**Ações:**
- `⌘T` Open Terminal View
- `⌘D` Open Web Dashboard
- `⌘R` Restart Monitor
- `⌘S` Stop Monitor
- `⌘W` Disable/Enable Watchdog
- `⌘L` View Logs
- Run Diagnostics
- `⌘Q` Quit

## Desinstalação

```bash
cd ~/Projects/watchdog_monitor/WatchdogMenuBar
./uninstall.sh
```

## Vantagens sobre Übersicht

- ✅ Interatividade completa
- ✅ Atalhos de teclado nativos
- ✅ Melhor integração com o sistema
- ✅ Menor consumo de recursos
- ✅ Mais estável e confiável
- ✅ Não requer dependências externas
