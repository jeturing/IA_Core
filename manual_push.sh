#!/bin/bash

# Script manual para crear repositorio y hacer push
# Si gh CLI no funciona, usa este método

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║      📝 CREAR REPOSITORIO MANUALMENTE EN GITHUB              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "🔗 PASOS PARA CREAR EL REPOSITORIO:"
echo ""
echo "1️⃣  Abre tu navegador y ve a: https://github.com/new"
echo ""
echo "2️⃣  Completa los campos:"
echo "   • Repository name: IA_core"
echo "   • Description: Autonomous AI agent layer - Installs into any project"
echo "   • Visibility: Public"
echo "   • Initialize: NO marques nada (sin README, .gitignore, LICENSE)"
echo ""
echo "3️⃣  Haz clic en: Create repository"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""

read -p "¿Ya creaste el repositorio en GitHub? (s/n): " -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "⏸️  Por favor, crea el repositorio en GitHub:"
    echo "   https://github.com/new"
    echo ""
    echo "Luego ejecuta este script de nuevo."
    exit 0
fi

# Navegar al directorio
cd /Users/owner/Desktop/jcore/IA_core

echo "📍 Directorio: $(pwd)"
echo ""

# Configurar remote
echo "🔗 Configurando remote..."
git remote set-url origin https://github.com/jeturing/IA_core.git || \
git remote add origin https://github.com/jeturing/IA_core.git

echo "✅ Remote configurado"
echo ""

# Asegurar que estamos en main
echo "🌿 Configurando rama main..."
git branch -M main
echo "✅ Rama main configurada"
echo ""

# Mostrar estado
echo "📊 Estado actual:"
git log --oneline -3
echo ""

# Hacer push
echo "🚀 Haciendo push a GitHub..."
echo ""

if git push -u origin main; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           ✅ ¡PUSH COMPLETADO EXITOSAMENTE!                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🌐 Tu repositorio está en:"
    echo "   https://github.com/jeturing/IA_core"
    echo ""
    echo "📥 One-liner de instalación:"
    echo "   curl -fsSL https://raw.githubusercontent.com/jeturing/IA_core/main/install.sh | bash"
    echo ""
else
    echo ""
    echo "❌ Error al hacer push"
    echo ""
    echo "Verifica:"
    echo "  • Conexión a internet"
    echo "  • El repositorio fue creado en GitHub"
    echo "  • Tus credenciales de GitHub"
    echo ""
    exit 1
fi
