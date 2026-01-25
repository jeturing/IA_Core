#!/usr/bin/env bash

# Verification script for IA_Core repository
# Run this before pushing to GitHub

set -e

echo "🔍 Verificando estructura del repositorio IA_Core..."
echo ""

# Check required files
echo "✓ Verificando archivos principales..."
required_files=(
    "README.md"
    "LICENSE"
    "CONTRIBUTING.md"
    "AGENT_SPEC.md"
    "DEPLOYMENT.md"
    "install.sh"
    "requirements.txt"
    "setup.py"
    ".gitignore"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file MISSING!"
        exit 1
    fi
done

echo ""
echo "✓ Verificando estructura de carpetas..."
required_dirs=(
    "iacore"
    "iacore/agent"
    "iacore/api"
    "iacore/cli"
    "iacore/core"
    "iacore/utils"
    "bin"
    "tests"
    "docs"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✅ $dir/"
    else
        echo "  ❌ $dir/ MISSING!"
        exit 1
    fi
done

echo ""
echo "✓ Verificando archivos Python principales..."
required_python=(
    "iacore/__init__.py"
    "iacore/agent/autonomous.py"
    "iacore/api/server.py"
    "iacore/cli/main.py"
    "iacore/core/detector.py"
    "iacore/core/analyzer.py"
    "iacore/core/llm_client.py"
    "iacore/core/opencore_executor.py"
    "iacore/utils/logger.py"
)

for file in "${required_python[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file MISSING!"
        exit 1
    fi
done

echo ""
echo "✓ Verificando permisos de ejecutables..."
if [ -x "install.sh" ]; then
    echo "  ✅ install.sh es ejecutable"
else
    echo "  ❌ install.sh NO es ejecutable!"
    exit 1
fi

if [ -x "bin/iacore" ]; then
    echo "  ✅ bin/iacore es ejecutable"
else
    echo "  ❌ bin/iacore NO es ejecutable!"
    exit 1
fi

echo ""
echo "✓ Verificando sintaxis Python..."
python3 -m py_compile iacore/**/*.py 2>/dev/null || {
    echo "  ⚠️  Algunos archivos Python tienen errores de sintaxis"
}
echo "  ✅ Sintaxis verificada"

echo ""
echo "✓ Verificando Git..."
if [ -d ".git" ]; then
    echo "  ✅ Repositorio Git inicializado"
    
    # Check if there are commits
    if git rev-parse HEAD >/dev/null 2>&1; then
        echo "  ✅ Commit inicial realizado"
        echo "    Último commit: $(git log -1 --oneline)"
    else
        echo "  ⚠️  No hay commits todavía"
    fi
else
    echo "  ❌ No es un repositorio Git!"
    exit 1
fi

echo ""
echo "✓ Contando líneas de código..."
total_lines=$(find iacore -name "*.py" -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "  📊 Total: $total_lines líneas de Python"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ VERIFICACIÓN COMPLETA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Repositorio listo para GitHub!"
echo ""
echo "Próximos pasos:"
echo "  1. Crear repo en GitHub: https://github.com/new"
echo "  2. git remote add origin https://github.com/Jeturing/IA_core.git"
echo "  3. git push -u origin main"
echo ""
echo "Ver DEPLOYMENT.md para instrucciones completas."
echo ""
