# Logs do Watchdog Monitor

Este diretório contém os logs gerados pelo sistema de monitoramento.

## Arquivos de Log

- `watchdog_monitor.log` - Log principal do monitor preventivo
- `diagnostic_*.log` - Logs de diagnósticos executados

## Rotação de Logs

Os logs são mantidos indefinidamente. Para limpar logs antigos:

```bash
# Limpar logs com mais de 30 dias
find ~/Projects/watchdog_monitor/logs -name "*.log" -mtime +30 -delete
```

## Análise de Logs

Para monitorar em tempo real:
```bash
tail -f ~/Projects/watchdog_monitor/logs/watchdog_monitor.log
```

Para buscar eventos específicos:
```bash
grep "PROBLEMA" ~/Projects/watchdog_monitor/logs/watchdog_monitor.log
grep "ACTION" ~/Projects/watchdog_monitor/logs/watchdog_monitor.log
```
