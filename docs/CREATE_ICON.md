# Criar Ícone Personalizado para Watchdog Monitor

## 🎨 Opção 1: Online (Mais Fácil)

### Usando Figma/Canva
1. Acesse: https://www.figma.com ou https://www.canva.com
2. Crie um design 1024x1024px
3. Use estas cores:
   - Fundo: Gradiente #667eea → #764ba2
   - Shield: #48bb78 (verde)
   - Detalhes: Branco e #2d3748 (cinza escuro)
4. Elementos sugeridos:
   - Shield (escudo) no centro
   - Checkmark ✓ dentro do shield
   - Olhos (watchdog) 👀
   - Ponto de alerta vermelho #f56565 no canto
5. Exporte como PNG 1024x1024

### Converter PNG para ICNS
```bash
# Criar iconset
mkdir WatchdogIcon.iconset

# Gerar tamanhos (usando sips)
sips -z 16 16     icon_1024.png --out WatchdogIcon.iconset/icon_16x16.png
sips -z 32 32     icon_1024.png --out WatchdogIcon.iconset/icon_16x16@2x.png
sips -z 32 32     icon_1024.png --out WatchdogIcon.iconset/icon_32x32.png
sips -z 64 64     icon_1024.png --out WatchdogIcon.iconset/icon_32x32@2x.png
sips -z 128 128   icon_1024.png --out WatchdogIcon.iconset/icon_128x128.png
sips -z 256 256   icon_1024.png --out WatchdogIcon.iconset/icon_128x128@2x.png
sips -z 256 256   icon_1024.png --out WatchdogIcon.iconset/icon_256x256.png
sips -z 512 512   icon_1024.png --out WatchdogIcon.iconset/icon_256x256@2x.png
sips -z 512 512   icon_1024.png --out WatchdogIcon.iconset/icon_512x512.png
cp icon_1024.png WatchdogIcon.iconset/icon_512x512@2x.png

# Converter para .icns
iconutil -c icns WatchdogIcon.iconset

# Instalar no app
cp WatchdogIcon.icns ~/Projects/watchdog_monitor/WatchdogMonitor.app/Contents/Resources/AppIcon.icns
cp WatchdogIcon.icns ~/Applications/WatchdogMonitor.app/Contents/Resources/AppIcon.icns

# Limpar cache de ícones
touch ~/Applications/WatchdogMonitor.app
killall Dock Finder
```

## 🎨 Opção 2: Usando ImageMagick

```bash
# Instalar ImageMagick
brew install imagemagick

# Criar ícone com script
cat > create_icon.sh << 'EOF'
#!/bin/bash
convert -size 1024x1024 gradient:"#667eea"-"#764ba2" \
    \( +clone -fill "#48bb78" -draw "path 'M 512,160 L 360,240 L 360,560 Q 360,760 512,880 Q 664,760 664,560 L 664,240 Z'" \) \
    -composite \
    \( -size 1024x1024 xc:none -fill white -stroke none \
       -draw "path 'M 440,520 L 490,580 L 600,440'" \
       -stroke white -strokewidth 32 -fill none \
       -draw "path 'M 440,520 L 490,580 L 600,440'" \) \
    -composite \
    icon_1024.png
EOF

chmod +x create_icon.sh
./create_icon.sh
```

## 🎨 Opção 3: Usar SF Symbols (Nativo do macOS)

```bash
# Exportar SF Symbol como ícone
# 1. Abra "SF Symbols.app" (/System/Applications/Utilities/)
# 2. Procure por "shield.checkered" ou "shield"
# 3. Exporte como PNG ou SVG
# 4. Ajuste cores no Preview ou Figma
# 5. Siga passos de conversão acima
```

## 🎨 Opção 4: Usar o SVG que já criei

```bash
# O arquivo SVG está em: /tmp/watchdog_icon.svg
# Para converter:

# Método 1: Online
open https://cloudconvert.com/svg-to-png
# Upload /tmp/watchdog_icon.svg
# Configurar: 1024x1024px
# Download e siga passos de conversão

# Método 2: Com rsvg-convert (brew install librsvg)
brew install librsvg
rsvg-convert -w 1024 -h 1024 /tmp/watchdog_icon.svg > icon_1024.png
# Siga passos de conversão acima
```

## 📐 Especificações do Ícone

### Tamanhos Necessários
- 16x16 (1x)
- 32x32 (16@2x e 1x)
- 64x64 (32@2x)
- 128x128 (1x)
- 256x256 (128@2x e 1x)
- 512x512 (256@2x e 1x)
- 1024x1024 (512@2x)

### Paleta de Cores Sugerida
```
Fundo:     #667eea → #764ba2 (gradiente azul/roxo)
Shield:    #48bb78 (verde)
Accent:    #f56565 (vermelho alerta)
Detalhes:  #FFFFFF (branco)
Sombra:    #2d3748 (cinza escuro)
```

### Design Sugerido
```
┌─────────────────┐
│   🌅 Gradiente  │
│                 │
│    🛡️ Shield    │
│      ✓ Check    │
│      👀 Eyes    │
│                 │
│     🔴 Alert    │
└─────────────────┘
```

## 🔄 Atualizar Ícone no App

Depois de criar o ícone:

```bash
cd ~/Projects/watchdog_monitor

# 1. Copiar ícone
cp WatchdogIcon.icns WatchdogMonitor.app/Contents/Resources/AppIcon.icns

# 2. Verificar Info.plist (já tem CFBundleIconFile)
plutil -lint WatchdogMonitor.app/Contents/Info.plist

# 3. Atualizar em ~/Applications/
cp -R WatchdogMonitor.app ~/Applications/

# 4. Limpar cache
touch ~/Applications/WatchdogMonitor.app
killall Dock Finder

# 5. Reabrir app
open ~/Applications/WatchdogMonitor.app
```

## ✅ Verificar

- [ ] Ícone aparece no Finder em ~/Applications/
- [ ] Ícone aparece na barra de menu
- [ ] Ícone aparece no Dock quando app está ativo
- [ ] Ícone mantém qualidade em resoluções Retina

## 📝 Notas

- **Ícone atual**: Temporário do sistema (AlertCautionIcon)
- **Localização atual**: `~/Applications/WatchdogMonitor.app/Contents/Resources/AppIcon.icns`
- **Referência no Info.plist**: `CFBundleIconFile = AppIcon`

---

**Recomendação**: Use a Opção 1 (Figma/Canva) para design rápido e profissional!
