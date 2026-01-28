#!/bin/bash

# Script de Push Automático a GitHub para IA_Core
# Uso: bash push_to_github.sh

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        🚀 PUSH AUTOMÁTICO A GITHUB - IA_CORE                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Cambiar al directorio del repositorio
cd /Users/owner/Desktop/jcore/IA_core

# Verificar que estamos en un repositorio git
if [ ! -d ".git" ]; then
    echo "❌ Error: No se encontró un repositorio git en $(pwd)"
    exit 1
fi

echo "📍 Directorio: $(pwd)"
echo ""

# Verificar estado
echo "📊 Estado actual del repositorio:"
echo ""
git status --short | head -10 || echo "   ✅ Working tree clean"
echo ""

# Verificar remote
echo "🔗 Remote configurado:"
REMOTE=$(git remote get-url origin)
echo "   $REMOTE"
echo ""

if [[ ! "$REMOTE" == *"jeturing"* ]]; then
    echo "⚠️  Advertencia: El remote no parece ser de 'jeturing'"
    echo "   Remote actual: $REMOTE"
    echo "   Esperado: https://github.com/jeturing/IA_core.git"
    read -p "¿Continuar de todas formas? (s/n): " -r
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "❌ Operación cancelada"
        exit 1
    fi
fi

# Verificar rama
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "🌿 Rama actual: $BRANCH"
echo ""

if [ "$BRANCH" != "main" ]; then
    echo "⚠️  Advertencia: No estás en la rama 'main'"
    echo "   Rama actual: $BRANCH"
    read -p "¿Cambiar a main antes de hacer push? (s/n): " -r
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "🔄 Cambiando a main..."
        git checkout main
        echo "✅ Cambio completado"
    fi
fi

# Verificar commits
echo ""
echo "📋 Últimos commits:"
git log --oneline -5
echo ""

# Pedir confirmación
echo "════════════════════════════════════════════════════════════════"
echo "⚠️  CONFIRMACIÓN FINAL"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Se hará push a:"
echo "  Remote: $REMOTE"
echo "  Rama: $BRANCH"
echo ""
read -p "¿Estás seguro de que deseas continuar? (s/n): " -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "❌ Operación cancelada"
    exit 1
fi

# Hacer push
echo "🚀 Haciendo push a GitHub..."
echo ""

if git push -u origin main; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           ✅ ¡PUSH COMPLETADO EXITOSAMENTE!                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📍 Tu repositorio está disponible en:"
    echo "   $REMOTE"
    echo ""
    echo "📥 One-liner de instalación:"
    echo "   curl -fsSL https://raw.githubusercontent.com/jeturing/IA_core/main/install.sh | bash"
    echo ""
    echo "📊 Verifica en GitHub:"
    echo "   https://github.com/jeturing/IA_core"
    echo ""
else
    echo ""
    echo "❌ Error al hacer push"
    echo ""
    echo "Soluciones:"
    echo "  1. Verifica tu conexión a internet"
    echo "  2. Verifica que el repositorio existe en GitHub: https://github.com/new"
    echo "  3. Verifica tus credenciales de GitHub"
    echo "  4. Si usas SSH, configúralo correctamente"
    echo ""
    exit 1
fi
