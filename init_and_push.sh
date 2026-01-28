#!/bin/bash

# Script para crear repositorio en jeturing/IA_Core siguiendo los pasos de GitHub

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        🚀 CREAR REPOSITORIO EN JETURING - IA_CORE            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

cd /Users/owner/Desktop/jcore/IA_core

echo "📍 Directorio: $(pwd)"
echo ""

# 1. Verificar si el repositorio ya existe
if [ -d ".git" ]; then
    echo "⚠️  Git ya está inicializado en este directorio"
    echo ""
    echo "Pasos para continuar:"
    echo ""
    echo "1. Limpia el repositorio actual:"
    echo "   rm -rf .git"
    echo ""
    echo "2. Luego ejecuta este script de nuevo"
    echo ""
    exit 0
fi

echo "🔧 Ejecutando pasos de GitHub..."
echo ""

# 1. Crear/Actualizar README.md
echo "1️⃣  Verificando README.md..."
if [ ! -f "README.md" ]; then
    echo "   Añadiendo README.md..."
    echo "# IA_Core" > README.md
    echo "✅ README.md creado"
else
    echo "   ✅ README.md ya existe"
fi
echo ""

# 2. Inicializar git
echo "2️⃣  Inicializando git..."
git init
echo "✅ Git inicializado"
echo ""

# 3. Añadir README.md
echo "3️⃣  Añadiendo README.md..."
git add README.md
echo "✅ README.md añadido"
echo ""

# 4. Primer commit
echo "4️⃣  Creando primer commit..."
git commit -m "first commit"
echo "✅ Primer commit creado"
echo ""

# 5. Cambiar rama a main
echo "5️⃣  Configurando rama main..."
git branch -M main
echo "✅ Rama main configurada"
echo ""

# 6. Añadir remote
echo "6️⃣  Añadiendo remote origin..."
git remote add origin https://github.com/jeturing/IA_Core.git
echo "✅ Remote origin añadido"
echo ""

# Verificar estado
echo "📊 Estado actual:"
echo "   Rama: $(git rev-parse --abbrev-ref HEAD)"
echo "   Remote: $(git remote get-url origin)"
echo "   Commits: $(git rev-list --count HEAD)"
echo ""

# 7. Hacer push
echo "7️⃣  Haciendo push a GitHub..."
echo ""

read -p "¿Estás listo para hacer push? (s/n): " -r
echo ""

if [[ $REPLY =~ ^[Ss]$ ]]; then
    if git push -u origin main; then
        echo ""
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║           ✅ ¡PUSH COMPLETADO EXITOSAMENTE!                  ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "🌐 Tu repositorio:"
        echo "   https://github.com/jeturing/IA_Core"
        echo ""
        echo "📥 One-liner:"
        echo "   curl -fsSL https://raw.githubusercontent.com/jeturing/IA_Core/main/install.sh | bash"
        echo ""
    else
        echo "❌ Error al hacer push"
        echo ""
        echo "Soluciones:"
        echo "  1. Verifica que creaste el repo en: https://github.com/new"
        echo "  2. Repo debe ser: jeturing/IA_Core"
        echo "  3. Visibilidad: Public"
        echo "  4. SIN inicializar (sin README, .gitignore, LICENSE)"
        echo ""
        exit 1
    fi
else
    echo "⏸️  Operación cancelada"
    echo ""
    echo "Cuando estés listo, ejecuta:"
    echo "   git push -u origin main"
    echo ""
fi
