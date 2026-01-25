#!/usr/bin/env bash

# IA_Core Installer
# One-liner installation: curl -fsSL https://raw.githubusercontent.com/YOUR_USER/IA_core/main/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step() { echo -e "${BLUE}[→]${NC} $1"; }

# Banner
show_banner() {
    cat << "EOF"
    ___    _       ______                
   /   |  (_)     / ____/___  _________ 
  / /| | / /_____/ /   / __ \/ ___/ _ \
 / ___ |/ /_____/ /___/ /_/ / /  /  __/
/_/  |_/_/      \____/\____/_/   \___/ 
                                        
Autonomous AI Orchestration Layer
EOF
}

# Check requirements
check_requirements() {
    log_step "Verificando requisitos..."
    
    # Check OS
    case "$(uname -s)" in
        Linux*)     OS=Linux;;
        Darwin*)    OS=Mac;;
        *)          log_error "OS no soportado: $(uname -s)"; exit 1;;
    esac
    log_info "OS detectado: $OS"
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 no encontrado. Instala Python 3.9+"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    log_info "Python $PYTHON_VERSION encontrado"
    
    # Check Git
    if ! command -v git &> /dev/null; then
        log_error "Git no encontrado. Instala Git primero."
        exit 1
    fi
    
    log_success "Todos los requisitos cumplidos"
}

# Detect project type
detect_project() {
    log_step "Detectando tipo de proyecto..."
    
    PROJECT_ROOT=$(pwd)
    PROJECT_TYPE="unknown"
    
    if [ -f "package.json" ]; then
        if grep -q '"react"' package.json 2>/dev/null; then
            PROJECT_TYPE="react"
        elif grep -q '"vue"' package.json 2>/dev/null; then
            PROJECT_TYPE="vue"
        elif grep -q '"next"' package.json 2>/dev/null; then
            PROJECT_TYPE="nextjs"
        else
            PROJECT_TYPE="node"
        fi
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        PROJECT_TYPE="python"
    elif [ -f "Cargo.toml" ]; then
        PROJECT_TYPE="rust"
    elif [ -f "go.mod" ]; then
        PROJECT_TYPE="go"
    fi
    
    log_info "Proyecto detectado: $PROJECT_TYPE"
}

# Install IA_Core
install_iacore() {
    log_step "Instalando IA_Core..."
    
    INSTALL_DIR="$HOME/.iacore"
    
    # Remove old installation
    if [ -d "$INSTALL_DIR" ]; then
        log_warning "Instalación previa encontrada. Actualizando..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Clone repository
    log_info "Descargando desde GitHub..."
    git clone --depth 1 https://github.com/YOUR_USER/IA_core.git "$INSTALL_DIR" &>/dev/null || {
        log_error "Error al clonar repositorio"
        exit 1
    }
    
    # Create virtual environment
    log_info "Creando entorno virtual..."
    python3 -m venv "$INSTALL_DIR/venv"
    source "$INSTALL_DIR/venv/bin/activate"
    
    # Install dependencies
    log_info "Instalando dependencias..."
    pip install -q --upgrade pip
    pip install -q -r "$INSTALL_DIR/requirements.txt"
    
    log_success "IA_Core instalado en $INSTALL_DIR"
}

# Configure OpenCore
configure_opencore() {
    log_step "Configurando OpenCore..."
    
    # Check if OpenCore is already installed
    if ! command -v opencore &> /dev/null; then
        log_info "OpenCore no encontrado. Instalando..."
        
        # Install OpenCore (adjust URL based on actual OpenCore install method)
        if [ "$OS" = "Mac" ]; then
            brew install opencore 2>/dev/null || {
                log_warning "No se pudo instalar via Homebrew. Instalando manualmente..."
                curl -fsSL https://opencore.dev/install.sh | bash
            }
        else
            curl -fsSL https://opencore.dev/install.sh | bash
        fi
    fi
    
    # Configure OpenCore for IA_Core
    mkdir -p "$HOME/.opencore"
    cat > "$HOME/.opencore/iacore.conf" << EOF
# OpenCore configuration for IA_Core
silent_mode: true
sandbox: true
max_execution_time: 300
allowed_commands:
  - git
  - npm
  - pip
  - python
  - node
  - pytest
  - jest
EOF
    
    log_success "OpenCore configurado"
}

# Configure GPT-4o-mini
configure_llm() {
    log_step "Configurando GPT-4o-mini..."
    
    # Check for existing API key
    if [ -n "$OPENAI_API_KEY" ]; then
        log_info "Usando OPENAI_API_KEY existente"
    else
        log_warning "No se encontró OPENAI_API_KEY"
        log_info "IA_Core funcionará con el endpoint gratuito (con límites)"
        
        # Create config with free endpoint
        cat > "$HOME/.iacore/llm_config.yml" << EOF
provider: openai
model: gpt-4o-mini
endpoint: https://api.openai.com/v1/chat/completions
auth:
  type: free
  rate_limit: 10  # requests per minute
fallback:
  - model: gpt-3.5-turbo
  - model: local-llm
EOF
    fi
    
    log_success "LLM configurado"
}

# Setup project integration
setup_project_integration() {
    log_step "Integrando con proyecto..."
    
    # Create .iacore directory in project
    mkdir -p ".iacore"
    
    # Generate default config
    cat > ".iacore/config.yml" << EOF
version: 1

project:
  type: $PROJECT_TYPE
  root: $PROJECT_ROOT
  auto_detected: true

agent:
  enabled: true
  auto_analyze: true
  auto_execute: false
  watch_mode: true

llm:
  provider: openai
  model: gpt-4o-mini

api:
  host: 127.0.0.1
  port: 8788
  auto_start: true

workflows:
  on_file_change:
    - detect_impact
    - analyze_context
  on_git_commit:
    - analyze_commit
    - suggest_improvements
EOF
    
    # Add to .gitignore
    if [ ! -f ".gitignore" ]; then
        echo ".iacore/runtime/" > .gitignore
    elif ! grep -q ".iacore/runtime" .gitignore; then
        echo ".iacore/runtime/" >> .gitignore
    fi
    
    log_success "Proyecto integrado"
}

# Deploy API server
deploy_api() {
    log_step "Desplegando API de orquestación..."
    
    source "$HOME/.iacore/venv/bin/activate"
    
    # Start API in background
    cd "$HOME/.iacore"
    nohup python -m iacore.api.server \
        --host 127.0.0.1 \
        --port 8788 \
        --project-root "$PROJECT_ROOT" \
        > .iacore/runtime/api.log 2>&1 &
    
    API_PID=$!
    echo $API_PID > "$HOME/.iacore/api.pid"
    
    # Wait for API to be ready
    log_info "Esperando a que la API esté lista..."
    for i in {1..10}; do
        if curl -s http://127.0.0.1:8788/health > /dev/null 2>&1; then
            log_success "API desplegada en http://127.0.0.1:8788"
            return 0
        fi
        sleep 1
    done
    
    log_warning "La API tardó en iniciar, pero continúa en background"
}

# Start autonomous agent
start_agent() {
    log_step "Iniciando agente autónomo..."
    
    source "$HOME/.iacore/venv/bin/activate"
    
    cd "$HOME/.iacore"
    nohup python -m iacore.agent.autonomous \
        --project-root "$PROJECT_ROOT" \
        --config "$PROJECT_ROOT/.iacore/config.yml" \
        > "$PROJECT_ROOT/.iacore/runtime/agent.log" 2>&1 &
    
    AGENT_PID=$!
    echo $AGENT_PID > "$HOME/.iacore/agent.pid"
    
    log_success "Agente iniciado (PID: $AGENT_PID)"
}

# Install CLI
install_cli() {
    log_step "Instalando CLI..."
    
    # Create symlink for easy access
    sudo ln -sf "$HOME/.iacore/bin/iacore" /usr/local/bin/iacore 2>/dev/null || {
        log_warning "No se pudo instalar globalmente. Usa: $HOME/.iacore/bin/iacore"
    }
    
    log_success "CLI instalado"
}

# Show summary
show_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}║       ✓ IA_Core instalado exitosamente        ║${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Estado:${NC}"
    echo "  • Proyecto: $PROJECT_TYPE"
    echo "  • API: http://127.0.0.1:8788"
    echo "  • Agente: En ejecución (background)"
    echo "  • Logs: .iacore/runtime/"
    echo ""
    echo -e "${CYAN}Comandos disponibles:${NC}"
    echo "  iacore status    - Ver estado del sistema"
    echo "  iacore logs      - Ver logs del agente"
    echo "  iacore config    - Configurar opciones"
    echo "  iacore pause     - Pausar agente"
    echo "  iacore resume    - Reanudar agente"
    echo ""
    echo -e "${YELLOW}💡 Tip:${NC} El agente está observando tu proyecto."
    echo "   Trabaja normalmente y IA_Core asistirá de forma transparente."
    echo ""
}

# Main installation flow
main() {
    clear
    show_banner
    echo ""
    
    check_requirements
    detect_project
    install_iacore
    configure_opencore
    configure_llm
    setup_project_integration
    deploy_api
    start_agent
    install_cli
    
    show_summary
}

# Run installer
main
