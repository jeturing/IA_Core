#!/bin/bash

# Script para corregir install.sh con el usuario correcto (jeturing)

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          🔧 CORREGIR install.sh CON USUARIO JETURING         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

cd /Users/owner/Desktop/jcore/IA_core

echo "📝 Corrigiendo install.sh..."
echo ""

# Reemplazar YOUR_USER por jeturing en install.sh
sed -i '' 's|YOUR_USER|jeturing|g' install.sh

if [ $? -eq 0 ]; then
    echo "✅ install.sh actualizado con usuario: jeturing"
else
    echo "❌ Error al actualizar install.sh"
    exit 1
fi

echo ""

# Verificar que se reemplazó correctamente
echo "🔍 Verificando cambios..."
echo ""

if grep -q "jeturing/IA_core" install.sh; then
    echo "✅ URL correcta encontrada: jeturing/IA_core"
    echo ""
    # Mostrar las líneas que contienen la URL
    grep -n "jeturing/IA_core" install.sh | head -5
else
    echo "⚠️  No se encontró la URL actualizada"
fi

echo ""
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   ✅ install.sh CORREGIDO - Ahora puedes hacer push a GitHub  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "📥 El one-liner ahora funcionará:"
echo ""
echo "   curl -fsSL https://raw.githubusercontent.com/jeturing/IA_core/main/install.sh | bash"
echo ""

# Hacer commit del cambio
echo "📝 Haciendo commit del cambio..."
git add install.sh
git commit -m "fix: Reemplazar YOUR_USER por jeturing en install.sh" || echo "⚠️  Sin cambios para commitear"

echo ""
echo "🚀 Listo para hacer push a GitHub"
echo ""
