# Publicação no Homebrew - Guia Completo

## 📋 Checklist de Preparação

- [x] Release v3.0.0 criado no GitHub
- [x] Asset WatchdogMonitor-v3.0.0.zip publicado
- [x] SHA256 calculado: `3c001ac7dc7ddf606b4de26706f0c99a5a2bfc4207b9419e8246e7075efee456`
- [x] Fórmula criada: `homebrew/watchdog-monitor.rb`
- [ ] Criar tap homebrew-watchdog
- [ ] Publicar fórmula no tap
- [ ] Testar instalação
- [ ] Submeter ao homebrew-core (opcional)

## 🚀 Passo a Passo

### 1. Criar Tap Homebrew (Amanhã)

```bash
# No GitHub, criar novo repositório público:
# Nome: homebrew-watchdog
# URL: https://github.com/eltongomez/homebrew-watchdog

# Clonar localmente
git clone https://github.com/eltongomez/homebrew-watchdog.git
cd homebrew-watchdog

# Criar estrutura
mkdir -p Formula
cp ~/Projects/watchdog_monitor/homebrew/watchdog-monitor.rb Formula/

# Commit e push
git add Formula/watchdog-monitor.rb
git commit -m "Add watchdog-monitor formula v3.0.0"
git push origin main
```

### 2. Testar a Fórmula

```bash
# Adicionar o tap
brew tap eltongomez/watchdog

# Instalar
brew install watchdog-monitor

# Testar
watchdog-monitor  # Deve abrir o app
open /usr/local/Cellar/watchdog-monitor/3.0.0/WatchdogMonitor.app

# Desinstalar (para testar novamente)
brew uninstall watchdog-monitor
brew untap eltongomez/watchdog
```

### 3. Verificar Fórmula com Audit

```bash
# Auditar a fórmula
brew audit --strict --online watchdog-monitor

# Testar instalação
brew install --verbose --debug watchdog-monitor

# Testar teste da fórmula
brew test watchdog-monitor
```

### 4. Submeter ao homebrew-core (Opcional, Futuro)

Após ganhar tração, pode submeter ao homebrew-core oficial:

```bash
# Fork do homebrew-core
# https://github.com/Homebrew/homebrew-core

# Clonar seu fork
git clone https://github.com/eltongomez/homebrew-core.git
cd homebrew-core

# Criar branch
git checkout -b watchdog-monitor

# Copiar fórmula
cp ~/Projects/watchdog_monitor/homebrew/watchdog-monitor.rb Formula/

# Auditar
brew audit --strict --online watchdog-monitor

# Testar
brew install --build-from-source watchdog-monitor
brew test watchdog-monitor

# Commit e PR
git add Formula/watchdog-monitor.rb
git commit -m "watchdog-monitor 3.0.0 (new formula)

macOS Kernel Panic Prevention with Automatic Recovery System"
git push origin watchdog-monitor

# Abrir PR no GitHub
# https://github.com/Homebrew/homebrew-core/compare
```

## 📝 Requisitos do homebrew-core

Para submissão ao homebrew-core, a fórmula deve:

- [ ] Ter documentação clara
- [ ] Ter tests funcionando
- [ ] Seguir style guide do Homebrew
- [ ] Não ter warnings no `brew audit`
- [ ] Ser software open source popular
- [ ] Ter versão estável (não beta/alpha)
- [ ] Build determinístico
- [ ] Licença OSI-approved (MIT ✓)

## 🔧 Troubleshooting

### Erro: SHA256 mismatch
```bash
# Recalcular SHA256
shasum -a 256 WatchdogMonitor-v3.0.0.zip
# Atualizar na fórmula
```

### Erro: App não abre
```bash
# Verificar permissões
chmod +x /path/to/WatchdogMonitor.app/Contents/MacOS/WatchdogMenuBar

# Verificar codesign (futuro)
codesign --sign - --force --deep WatchdogMonitor.app
```

### Erro: Command not found
```bash
# Verificar symlink
ls -la $(brew --prefix)/bin/watchdog-monitor
```

## 📚 Referências

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Acceptable Formulae](https://docs.brew.sh/Acceptable-Formulae)
- [Creating Taps](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Formula Style Guide](https://docs.brew.sh/Formula-Cookbook#style-guide)

## 📅 Timeline

**Hoje (2026-02-17):**
- ✅ Release v3.0.0 publicado
- ✅ Fórmula criada
- ✅ Documentação preparada

**Amanhã (2026-02-18):**
- [ ] Criar repositório homebrew-watchdog
- [ ] Publicar fórmula no tap
- [ ] Testar instalação
- [ ] Atualizar README com instruções brew

**Futuro:**
- [ ] Ganhar usuários e feedback
- [ ] Adicionar codesign ao app
- [ ] Considerar submissão ao homebrew-core

---

**Versão:** 3.0.0  
**Data:** 2026-02-17  
**Autor:** Elton Gomez
