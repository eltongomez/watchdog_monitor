#!/bin/bash

# Criar iconset temporário com emoji/texto
mkdir -p WatchdogIcon.iconset

# Criar um PNG base usando Python (disponível no macOS)
python3 << 'EOFPYTHON'
from PIL import Image, ImageDraw, ImageFont
import sys

try:
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    for size in sizes:
        # Criar imagem com gradiente
        img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Círculo de fundo (gradiente simulado com azul/roxo)
        color = (102, 126, 234, 255)  # #667eea
        draw.ellipse([0, 0, size-1, size-1], fill=color)
        
        # Shield (forma simplificada)
        shield_color = (72, 187, 120, 255)  # #48bb78
        margin = size // 6
        shield_width = size - 2*margin
        shield_height = int(shield_width * 1.3)
        
        # Desenhar shield como polígono
        shield_points = [
            (size//2, margin),  # topo
            (margin, margin + shield_height//4),  # esq
            (margin, margin + shield_height//2),  # esq baixo
            (size//2, margin + shield_height),  # ponta
            (size-margin, margin + shield_height//2),  # dir baixo
            (size-margin, margin + shield_height//4),  # dir
        ]
        draw.polygon(shield_points, fill=shield_color, outline=(45, 55, 72, 255))
        
        # Checkmark (branco)
        check_size = size // 8
        cx, cy = size//2, size//2 + size//12
        draw.line([cx-check_size, cy, cx-check_size//3, cy+check_size], fill='white', width=max(2, size//64))
        draw.line([cx-check_size//3, cy+check_size, cx+check_size, cy-check_size//2], fill='white', width=max(2, size//64))
        
        # Salvar
        if size == 1024:
            img.save(f'WatchdogIcon.iconset/icon_512x512@2x.png')
        else:
            img.save(f'WatchdogIcon.iconset/icon_{size}x{size}.png')
            if size <= 512:
                # Criar versão @2x
                img.save(f'WatchdogIcon.iconset/icon_{size//2}x{size//2}@2x.png')
    
    print("✓ Ícones PNG criados")
    
except ImportError:
    print("❌ PIL não disponível. Usando solução alternativa...")
    sys.exit(1)
EOFPYTHON

if [ $? -eq 0 ]; then
    # Converter para .icns
    iconutil -c icns WatchdogIcon.iconset -o WatchdogIcon.icns
    echo "✓ WatchdogIcon.icns criado!"
    
    # Copiar para o .app
    mkdir -p WatchdogMonitor.app/Contents/Resources
    cp WatchdogIcon.icns WatchdogMonitor.app/Contents/Resources/AppIcon.icns
    echo "✓ Ícone copiado para o app"
else
    echo "⚠️  Usando solução sem PIL..."
    # Criar um ícone simples de texto
    for size in 16 32 64 128 256 512 1024; do
        sips -z $size $size /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns --out WatchdogIcon.iconset/temp_$size.png 2>/dev/null
    done
    echo "ℹ️  Ícone temporário criado. Recomendo criar um ícone personalizado depois."
fi
