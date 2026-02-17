# Configuração de Permissões Sudo

## 📋 Setup Automático Criado

Foi criado um script que configura automaticamente as permissões sudo necessárias para o recovery system funcionar.

### 🚀 Como Executar

```bash
~/Projects/watchdog_monitor/scripts/setup_sudo.sh
```

### 🛡️ Segurança

O script:
- ✅ **Valida sintaxe** antes de instalar (previne erros que poderiam quebrar sudo)
- ✅ **Solicita confirmação** antes de aplicar mudanças
- ✅ **Testa funcionamento** após instalação
- ✅ **Reverte automaticamente** se detectar problemas
- ✅ **Permissões mínimas** (apenas purge, sync, reboot)

### 📝 O Que Será Configurado

Arquivo: `/etc/sudoers.d/watchdog`

```
# Watchdog Monitor - Recovery Permissions
elima ALL=(ALL) NOPASSWD: /usr/sbin/purge
elima ALL=(ALL) NOPASSWD: /sbin/reboot
elima ALL=(ALL) NOPASSWD: /bin/sync
```

### ✅ Após Configuração

O monitor poderá executar automaticamente:

1. **`sudo purge`** - Liberar memória cache quando memória baixa
2. **`sudo sync`** - Sincronizar disco quando I/O alto
3. **`sudo reboot`** - Reinicialização de emergência (apenas se configurado e aprovado)

### 🧪 Teste

Após executar o script:
1. Teste manual: `sudo -n purge` (não deve pedir senha)
2. Abra VSCode com projeto compre_certo
3. Monitor detectará memória baixa
4. Executará `sudo purge` automaticamente
5. Sistema deve estabilizar sem crash

### 🔄 Remover Configuração

Se quiser remover as permissões no futuro:

```bash
sudo rm /etc/sudoers.d/watchdog
```

### ⚠️ Importante

- **Escopo limitado**: Apenas 3 comandos específicos
- **Usuário específico**: Apenas para `elima`
- **Sem impacto** em outras configurações sudo
- **Seguro**: Validação automática previne erros

---

**Arquivo do script:** `~/Projects/watchdog_monitor/scripts/setup_sudo.sh`
