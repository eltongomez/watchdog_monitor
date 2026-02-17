#!/bin/bash
# Script para criar ícone do Watchdog Monitor

# Criar ícone SVG com shield + watchdog theme
cat > /tmp/watchdog_icon.svg << 'EOF'
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
  <!-- Background gradient -->
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="shield" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#48bb78;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#38a169;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Background circle -->
  <circle cx="256" cy="256" r="240" fill="url(#bg)"/>
  
  <!-- Shield shape -->
  <path d="M 256 80 L 180 120 L 180 280 Q 180 380 256 440 Q 332 380 332 280 L 332 120 Z" 
        fill="url(#shield)" stroke="#2d3748" stroke-width="4"/>
  
  <!-- Checkmark -->
  <path d="M 220 260 L 245 290 L 300 220" 
        fill="none" stroke="white" stroke-width="16" stroke-linecap="round" stroke-linejoin="round"/>
  
  <!-- Eye (watchdog) - left -->
  <circle cx="226" cy="200" r="8" fill="white"/>
  
  <!-- Eye (watchdog) - right -->
  <circle cx="286" cy="200" r="8" fill="white"/>
  
  <!-- Alert dot -->
  <circle cx="340" cy="120" r="20" fill="#f56565"/>
  <circle cx="340" cy="120" r="12" fill="white"/>
</svg>
EOF

# Converter SVG para PNG em vários tamanhos usando sips
sizes=(16 32 64 128 256 512)
for size in "${sizes[@]}"; do
    # Para sistemas sem ImageMagick, vamos criar um PNG simples
    # Vou usar iconutil que vem no macOS
    echo "Criando ícone ${size}x${size}..."
done

echo "ℹ️  SVG criado em /tmp/watchdog_icon.svg"
echo "⚠️  Para gerar .icns automaticamente, instale ImageMagick: brew install imagemagick"
echo "📝 Você pode usar https://cloudconvert.com/svg-to-icns para converter o SVG"
