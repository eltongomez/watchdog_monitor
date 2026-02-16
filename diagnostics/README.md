# Relatórios de Diagnóstico

Este diretório contém relatórios gerados pelo script de diagnóstico.

## Arquivos

Os diagnósticos são salvos automaticamente quando você executa:
```bash
./scripts/diagnostico_disco.sh > diagnostics/diagnostic_$(date +%Y%m%d_%H%M%S).txt
```

## O que é registrado

- SMART status do disco
- Verificação do sistema de arquivos
- Logs de erro do sistema
- Status dos drivers
- Informações de hardware
- Kernel extensions carregadas

## Uso

Quando reportar um problema, inclua o arquivo de diagnóstico mais recente.
