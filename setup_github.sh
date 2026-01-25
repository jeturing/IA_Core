#!/bin/bash

echo "🔧 Configurando GitHub para IA_Core..."
echo ""

# Get GitHub username
read -p "Tu nombre de usuario en GitHub: " GITHUB_USER

# Add remote
REPO_URL="https://github.com/${GITHUB_USER}/IA_core.git"
git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"

echo "✅ Remote configurado: $REPO_URL"
echo ""
echo "📝 Sigue estos pasos para completar la configuración:"
echo ""
echo "1. Ve a: https://github.com/new"
echo "2. Nombre del repositorio: IA_core"
echo "3. Descripción: Autonomous AI agent layer - Installs into any project"
echo "4. Selecciona: Public"
echo "5. NO inicialices con README, .gitignore o LICENSE"
echo "6. Haz clic en 'Create repository'"
echo ""
echo "7. Luego ejecuta:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""

read -p "¿Ya creaste el repositorio en GitHub? (s/n): " created

if [[ "$created" =~ ^[Ss]$ ]]; then
    echo ""
    echo "🚀 Haciendo push a GitHub..."
    git branch -M main
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ ¡Repositorio cargado exitosamente!"
        echo ""
        echo "📍 URL: $REPO_URL"
        echo "📥 One-liner de instalación:"
        echo "   curl -fsSL https://raw.githubusercontent.com/${GITHUB_USER}/IA_core/main/install.sh | bash"
    else
        echo ""
        echo "❌ Error al hacer push. Verifica:"
        echo "   - Tu contraseña de GitHub o token"
        echo "   - Que el repositorio existe"
        echo "   - Tu conexión a internet"
    fi
else
    echo "⏸️  Creando el repositorio primero:"
    echo "   https://github.com/new"
fi
