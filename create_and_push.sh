#!/bin/bash

# Script para crear repositorio en GitHub y hacer push
# Requiere: gh CLI instalado y autenticado

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   🚀 CREAR REPOSITORIO EN GITHUB Y HACER PUSH - IA_CORE      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Variables
GITHUB_USER="jeturing"
REPO_NAME="IA_core"
REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
LOCAL_PATH="/Users/owner/Desktop/jcore/IA_core"

cd "$LOCAL_PATH"

echo "📍 Directorio: $(pwd)"
echo "👤 Usuario GitHub: $GITHUB_USER"
echo "📦 Repositorio: $REPO_NAME"
echo ""

# Verificar si gh CLI está instalado
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) no está instalado"
    echo ""
    echo "Instálalo con:"
    echo "  brew install gh"
    echo ""
    exit 1
fi

# Verificar autenticación
echo "🔐 Verificando autenticación de GitHub..."
if ! gh auth status &> /dev/null; then
    echo "❌ Error: No estás autenticado en GitHub"
    echo ""
    echo "Ejecuta:"
    echo "  gh auth login"
    echo ""
    exit 1
fi

echo "✅ Autenticado en GitHub"
echo ""

# Verificar si el repositorio ya existe
echo "🔍 Verificando si el repositorio ya existe..."
if gh repo view "$GITHUB_USER/$REPO_NAME" &> /dev/null; then
    echo "✅ Repositorio ya existe en GitHub"
else
    echo "📝 Creando repositorio en GitHub..."
    gh repo create "$REPO_NAME" \
        --public \
        --source=. \
        --remote=origin \
        --description "Autonomous AI agent layer - Installs into any project with deep analysis, MCP servers, and GPT-4o-mini" || {
        echo "⚠️  No se pudo crear el repositorio con gh CLI"
        echo "   Intenta crearlo manualmente en: https://github.com/new"
        echo ""
        read -p "¿Continuamos de todas formas? (s/n): " -r
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            exit 1
        fi
    }
    echo "✅ Repositorio creado"
fi

echo ""

# Actualizar remote si es necesario
echo "🔗 Configurando remote..."
CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$CURRENT_REMOTE" ]; then
    echo "   Añadiendo remote..."
    git remote add origin "$REPO_URL"
elif [[ ! "$CURRENT_REMOTE" == *"jeturing"* ]]; then
    echo "   Actualizando remote..."
    git remote set-url origin "$REPO_URL"
fi

echo "✅ Remote configurado: $REPO_URL"
echo ""

# Verificar rama
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
    echo "🔄 Cambiando a rama main..."
    git branch -M main
    echo "✅ Rama main configurada"
fi

echo ""

# Mostrar estado
echo "📊 Estado del repositorio:"
echo ""
echo "   Rama: $(git rev-parse --abbrev-ref HEAD)"
echo "   Remote: $(git remote get-url origin)"
echo "   Commits: $(git rev-list --count HEAD)"
echo ""

# Pedir confirmación
echo "════════════════════════════════════════════════════════════════"
echo "⚠️  CONFIRMACIÓN FINAL"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Se hará push a:"
echo "  URL: $REPO_URL"
echo "  Rama: main"
echo ""
read -p "¿Continuar? (s/n): " -r
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
    echo "📍 Tu repositorio:"
    echo "   $REPO_URL"
    echo ""
    echo "🌐 Ver en GitHub:"
    echo "   https://github.com/$GITHUB_USER/$REPO_NAME"
    echo ""
    echo "📥 One-liner de instalación:"
    echo "   curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/main/install.sh | bash"
    echo ""
else
    echo ""
    echo "❌ Error al hacer push"
    echo ""
    echo "Soluciones:"
    echo "  1. Verifica tu conexión a internet"
    echo "  2. Intenta crear el repo manualmente: https://github.com/new"
    echo "  3. Verifica tu autenticación: gh auth login"
    echo ""
    exit 1
fi
