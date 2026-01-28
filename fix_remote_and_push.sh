#!/bin/bash

# Corregir remote y hacer push a la cuenta correcta

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           🔧 CORREGIR REMOTE Y HACER PUSH                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

cd /Users/owner/Desktop/jcore/IA_core

echo "📍 Directorio: $(pwd)"
echo ""

# El repositorio se creó en jcarvajalantigua pero queremos que esté en jeturing
# Tenemos 2 opciones:

echo "⚠️  PROBLEMA DETECTADO:"
echo ""
echo "El repositorio fue creado en: jcarvajalantigua/IA_core"
echo "Pero queremos que esté en: jeturing/IA_core"
echo ""
echo "SOLUCIONES:"
echo ""
echo "1️⃣  OPCIÓN A: Usar el repositorio en jcarvajalantigua (donde está)"
echo "   • Es el que ya existe y está funcionando"
echo "   • Solo necesitamos cambiar el remote"
echo ""
echo "2️⃣  OPCIÓN B: Crear nuevo repositorio en jeturing"
echo "   • Crear uno nuevo en jeturing manualmente"
echo "   • Luego hacer push"
echo ""

read -p "¿Cuál prefieres? (A/B): " -r
echo ""

if [[ $REPLY =~ ^[Aa]$ ]]; then
    echo "📝 OPCIÓN A: Usar jcarvajalantigua/IA_core"
    echo ""
    echo "🔗 Cambiando remote a jcarvajalantigua..."
    
    git remote set-url origin https://github.com/jcarvajalantigua/IA_core.git
    
    echo "✅ Remote actualizado"
    echo ""
    
    echo "🚀 Haciendo push a GitHub..."
    echo ""
    
    if git push -u origin main; then
        echo ""
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║           ✅ ¡PUSH COMPLETADO EXITOSAMENTE!                  ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "🌐 Tu repositorio:"
        echo "   https://github.com/jcarvajalantigua/IA_core"
        echo ""
        echo "📥 One-liner:"
        echo "   curl -fsSL https://raw.githubusercontent.com/jcarvajalantigua/IA_core/main/install.sh | bash"
        echo ""
    else
        echo "❌ Error al hacer push"
        exit 1
    fi
    
elif [[ $REPLY =~ ^[Bb]$ ]]; then
    echo "📝 OPCIÓN B: Crear repositorio nuevo en jeturing"
    echo ""
    echo "Pasos:"
    echo "1. Abre: https://github.com/new"
    echo "2. Repository name: IA_core"
    echo "3. Visibility: Public"
    echo "4. NO inicialices (sin README, .gitignore, LICENSE)"
    echo "5. Haz clic en: Create repository"
    echo ""
    
    read -p "¿Ya creaste el repositorio en jeturing? (s/n): " -r
    echo ""
    
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "🔗 Cambiando remote a jeturing..."
        git remote set-url origin https://github.com/jeturing/IA_core.git
        
        echo "✅ Remote actualizado"
        echo ""
        
        echo "🚀 Haciendo push a GitHub..."
        echo ""
        
        if git push -u origin main; then
            echo ""
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║           ✅ ¡PUSH COMPLETADO EXITOSAMENTE!                  ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
            echo ""
            echo "🌐 Tu repositorio:"
            echo "   https://github.com/jeturing/IA_core"
            echo ""
            echo "📥 One-liner:"
            echo "   curl -fsSL https://raw.githubusercontent.com/jeturing/IA_core/main/install.sh | bash"
            echo ""
        else
            echo "❌ Error al hacer push"
            exit 1
        fi
    else
        echo "⏸️  Por favor crea el repositorio en GitHub"
        echo "   https://github.com/new"
    fi
else
    echo "❌ Opción no válida"
    exit 1
fi
