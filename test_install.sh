#!/bin/bash
# Test installer locally

echo "🧪 Testing IA_Core installer locally..."
echo ""

# Create test project
TEST_DIR="/tmp/test_iacore_$(date +%s)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📁 Test directory: $TEST_DIR"
echo ""

# Create a simple Python project
cat > requirements.txt << 'PYREQS'
fastapi==0.109.0
uvicorn==0.27.0
pydantic==2.5.3
PYREQS

cat > main.py << 'PYMAIN'
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello World"}
PYMAIN

echo "✅ Created test FastAPI project"
echo ""

# Run installer (with skip for API key)
echo "🚀 Running installer..."
echo ""

# Copy installer to test dir for local testing
cp /Users/owner/Desktop/jcore/IA_core/install.sh ./install_test.sh

# Modify to skip interactive prompts for automated testing
sed -i '' 's/read -p "Opci/echo "Skipping"; #read -p "Opci/g' ./install_test.sh
sed -i '' 's/read -sp "Ingresa tu/echo ""; #read -sp "Ingresa tu/g' ./install_test.sh
sed -i '' 's/read -p "Respuesta:/echo "n"; #read -p "Respuesta:/g' ./install_test.sh

echo "📝 Running installer in test mode (non-interactive)..."
echo ""

bash ./install_test.sh

echo ""
echo "✅ Installation test completed!"
echo "📊 Check results in: $TEST_DIR"
echo "🗑️  Clean up with: rm -rf $TEST_DIR"
