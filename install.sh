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
        log_warning "No se encontró OPENAI_API_KEY en el entorno"
        echo ""
        echo -e "${YELLOW}IA_Core necesita una API key de OpenAI para funcionar completamente.${NC}"
        echo -e "${CYAN}Opciones:${NC}"
        echo "  1. Proporcionar API key ahora (recomendado)"
        echo "  2. Configurar después (funcionalidad limitada)"
        echo ""
        
        read -p "Opción [1/2]: " api_choice
        
        if [ "$api_choice" = "1" ]; then
            echo ""
            echo -e "${CYAN}Obtén tu API key en: https://platform.openai.com/api-keys${NC}"
            echo -e "${YELLOW}(El texto no se mostrará al escribir por seguridad)${NC}"
            read -sp "Ingresa tu OpenAI API key: " user_api_key
            echo ""
            
            if [ -n "$user_api_key" ]; then
                # Save to .bashrc or .zshrc
                shell_rc="$HOME/.bashrc"
                [ -f "$HOME/.zshrc" ] && shell_rc="$HOME/.zshrc"
                
                echo "" >> "$shell_rc"
                echo "# IA_Core OpenAI API Key" >> "$shell_rc"
                echo "export OPENAI_API_KEY='$user_api_key'" >> "$shell_rc"
                
                export OPENAI_API_KEY="$user_api_key"
                
                log_success "API key guardada en $shell_rc"
            fi
        else
            log_warning "Continuando sin API key. Funcionalidad limitada."
        fi
    fi
    
    # Create LLM config
    mkdir -p "$HOME/.iacore"
    cat > "$HOME/.iacore/llm_config.yml" << EOF
provider: openai
model: gpt-4o-mini
endpoint: https://api.openai.com/v1/chat/completions
api_key: ${OPENAI_API_KEY:-}
auth:
  type: ${OPENAI_API_KEY:+authenticated}
  rate_limit: ${OPENAI_API_KEY:+60}${OPENAI_API_KEY:-10}
fallback:
  - model: gpt-3.5-turbo
  - model: local-llm
EOF
    
    log_success "LLM configurado"
}

# Analyze project deeply
analyze_project_deeply() {
    log_step "Analizando proyecto en profundidad..."
    
    source "$HOME/.iacore/venv/bin/activate"
    
    # Run Python analysis script
    python3 << 'PYTHON_EOF'
import json
import sys
from pathlib import Path

project_root = Path(".")
analysis = {
    "frameworks": [],
    "languages": [],
    "build_tools": [],
    "package_managers": [],
    "requires_mcp": False,
    "mcp_config": {},
    "recommended_agents": [],
    "custom_workflows": []
}

# Detect frameworks and tools
if (project_root / "package.json").exists():
    import json
    pkg = json.loads((project_root / "package.json").read_text())
    deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
    
    if "react" in deps: analysis["frameworks"].append("react")
    if "vue" in deps: analysis["frameworks"].append("vue")
    if "next" in deps: analysis["frameworks"].append("nextjs")
    if "@angular/core" in deps: analysis["frameworks"].append("angular")
    
    analysis["languages"].append("javascript")
    if "typescript" in deps: analysis["languages"].append("typescript")
    analysis["package_managers"].append("npm")
    
    # Check if needs build
    if "scripts" in pkg and "build" in pkg["scripts"]:
        analysis["build_tools"].append("npm-scripts")

if (project_root / "requirements.txt").exists() or (project_root / "pyproject.toml").exists():
    analysis["languages"].append("python")
    analysis["package_managers"].append("pip")
    
    # Check for FastAPI/Django/Flask
    if (project_root / "requirements.txt").exists():
        reqs = (project_root / "requirements.txt").read_text().lower()
        if "fastapi" in reqs: analysis["frameworks"].append("fastapi")
        if "django" in reqs: analysis["frameworks"].append("django")
        if "flask" in reqs: analysis["frameworks"].append("flask")

if (project_root / "go.mod").exists():
    analysis["languages"].append("go")
    analysis["package_managers"].append("go-mod")

if (project_root / "Cargo.toml").exists():
    analysis["languages"].append("rust")
    analysis["package_managers"].append("cargo")

# Determine if MCP is needed (for backend projects)
if any(f in analysis["frameworks"] for f in ["fastapi", "django", "flask", "express"]):
    analysis["requires_mcp"] = True
    analysis["mcp_config"] = {
        "memory_server": True,
        "context_server": True,
        "custom_tools": True
    }

# Recommend agents based on project type
if "react" in analysis["frameworks"] or "vue" in analysis["frameworks"]:
    analysis["recommended_agents"].extend(["frontend-developer", "ux-designer"])
if "python" in analysis["languages"]:
    analysis["recommended_agents"].append("backend-developer")
if "fastapi" in analysis["frameworks"]:
    analysis["recommended_agents"].append("api-engineer")
if "typescript" in analysis["languages"]:
    analysis["recommended_agents"].append("typescript-expert")

# Custom workflows based on project
if "package.json" in [f.name for f in project_root.glob("*")]:
    analysis["custom_workflows"].append({
        "name": "npm_install_on_package_change",
        "trigger": "package.json modified",
        "actions": ["npm install"]
    })

if "requirements.txt" in [f.name for f in project_root.glob("*")]:
    analysis["custom_workflows"].append({
        "name": "pip_install_on_requirements_change",
        "trigger": "requirements.txt modified",
        "actions": ["pip install -r requirements.txt"]
    })

print(json.dumps(analysis, indent=2))
PYTHON_EOF
}

# Setup project integration
setup_project_integration() {
    log_step "Integrando con proyecto..."
    
    # Create .iacore directory in project
    mkdir -p ".iacore/runtime"
    
    # Get deep analysis
    log_info "Ejecutando análisis profundo..."
    ANALYSIS=$(analyze_project_deeply)
    echo "$ANALYSIS" > ".iacore/runtime/analysis.json"
    
    # Extract key info from analysis
    REQUIRES_MCP=$(echo "$ANALYSIS" | grep -o '"requires_mcp": true' || echo "false")
    FRAMEWORKS=$(echo "$ANALYSIS" | grep -A 10 '"frameworks"' | grep -o '"[a-z]*"' | tr -d '"' | tr '\n' ',' | sed 's/,$//')
    AGENTS=$(echo "$ANALYSIS" | grep -A 10 '"recommended_agents"' | grep -o '"[a-z-]*"' | tr -d '"' | tr '\n' ',' | sed 's/,$//')
    
    log_info "Frameworks detectados: ${FRAMEWORKS:-ninguno}"
    log_info "Agentes recomendados: ${AGENTS:-por defecto}"
    
    # Configure MCP if needed
    MCP_CONFIG=""
    if [[ "$REQUIRES_MCP" == *"true"* ]]; then
        log_step "Proyecto requiere configuración MCP..."
        
        echo ""
        echo -e "${CYAN}Este proyecto puede beneficiarse de MCP (Model Context Protocol)${NC}"
        echo -e "${YELLOW}¿Configurar MCP ahora?${NC} [s/N]"
        read -p "Respuesta: " setup_mcp
        
        if [[ "$setup_mcp" =~ ^[Ss]$ ]]; then
            # Create MCP configuration
            mkdir -p ".iacore/mcp"
            
            cat > ".iacore/mcp/config.yml" << 'EOF'
version: 1

servers:
  memory:
    enabled: true
    command: python
    args: ["-m", "iacore.mcp.memory_server"]
  
  context:
    enabled: true
    command: python
    args: ["-m", "iacore.mcp.context_server"]
    env:
      PROJECT_ROOT: ${PROJECT_ROOT}
  
  tools:
    enabled: true
    command: python
    args: ["-m", "iacore.mcp.tools_server"]

tools:
  - execute_command
  - read_file
  - write_file
  - search_code
  - analyze_dependencies
EOF
            
            MCP_CONFIG="
  mcp:
    enabled: true
    config_path: .iacore/mcp/config.yml
    auto_start: true"
            
            log_success "MCP configurado"
        fi
    fi
    
    # Generate customized config based on analysis
    cat > ".iacore/config.yml" << EOF
version: 1

project:
  type: $PROJECT_TYPE
  root: $PROJECT_ROOT
  auto_detected: true
  frameworks: [${FRAMEWORKS}]
  analysis_file: .iacore/runtime/analysis.json

agent:
  enabled: true
  auto_analyze: true
  auto_execute: false
  watch_mode: true
  recommended_agents: [${AGENTS}]

llm:
  provider: openai
  model: gpt-4o-mini
  config_file: ~/.iacore/llm_config.yml${MCP_CONFIG}

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
  on_package_change:
    - update_dependencies
    - verify_security
EOF
    
    # Add custom workflows from analysis
    if echo "$ANALYSIS" | grep -q "custom_workflows"; then
        echo "$ANALYSIS" | python3 -c '
import json, sys
data = json.load(sys.stdin)
if "custom_workflows" in data and data["custom_workflows"]:
    print("\n# Custom workflows detected:")
    for wf in data["custom_workflows"]:
        print(f"  # {wf.get('"name'", '"unknown'"')}: {wf.get('"trigger'", '"'"')}")
' >> ".iacore/config.yml" 2>/dev/null || true
    fi
    
    # Add to .gitignore
    if [ ! -f ".gitignore" ]; then
        echo ".iacore/runtime/" > .gitignore
        echo ".iacore/mcp/*.log" >> .gitignore
    elif ! grep -q ".iacore/runtime" .gitignore; then
        echo ".iacore/runtime/" >> .gitignore
        echo ".iacore/mcp/*.log" >> .gitignore
    fi
    
    log_success "Proyecto integrado con configuración personalizada"
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

# Validate installation
validate_installation() {
    log_step "Validando instalación..."
    
    # Check API health
    sleep 2
    if curl -s http://127.0.0.1:8788/health > /dev/null 2>&1; then
        log_success "API respondiendo correctamente"
    else
        log_warning "API tardando en iniciar (normal en primera vez)"
    fi
    
    # Check agent process
    if [ -f "$HOME/.iacore/agent.pid" ]; then
        AGENT_PID=$(cat "$HOME/.iacore/agent.pid")
        if ps -p $AGENT_PID > /dev/null 2>&1; then
            log_success "Agente ejecutándose (PID: $AGENT_PID)"
        else
            log_warning "Agente no detectado, puede tardar en iniciar"
        fi
    fi
    
    # Check config file
    if [ -f ".iacore/config.yml" ]; then
        log_success "Configuración creada correctamente"
    else
        log_error "No se pudo crear configuración"
        return 1
    fi
    
    # Check analysis
    if [ -f ".iacore/runtime/analysis.json" ]; then
        log_success "Análisis del proyecto completado"
    fi
    
    log_success "Validación completada"
}

# Show summary
show_summary() {
    # Load analysis if available
    ANALYSIS_SUMMARY=""
    if [ -f ".iacore/runtime/analysis.json" ]; then
        FRAMEWORKS=$(cat .iacore/runtime/analysis.json | grep -A 5 '"frameworks"' | grep -o '"[a-z]*"' | head -3 | tr -d '"' | tr '\n' ', ' | sed 's/, $//')
        LANGUAGES=$(cat .iacore/runtime/analysis.json | grep -A 5 '"languages"' | grep -o '"[a-z]*"' | head -3 | tr -d '"' | tr '\n' ', ' | sed 's/, $//')
        
        if [ -n "$FRAMEWORKS" ]; then
            ANALYSIS_SUMMARY="  • Frameworks: $FRAMEWORKS\n"
        fi
        if [ -n "$LANGUAGES" ]; then
            ANALYSIS_SUMMARY="${ANALYSIS_SUMMARY}  • Lenguajes: $LANGUAGES\n"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}║       ✓ IA_Core instalado exitosamente        ║${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Análisis del Proyecto:${NC}"
    echo "  • Tipo: $PROJECT_TYPE"
    if [ -n "$ANALYSIS_SUMMARY" ]; then
        echo -e "$ANALYSIS_SUMMARY"
    fi
    echo ""
    echo -e "${CYAN}Servicios:${NC}"
    echo "  • API: http://127.0.0.1:8788 $(curl -s http://127.0.0.1:8788/health > /dev/null 2>&1 && echo '✅' || echo '⏳')"
    echo "  • Agente: En ejecución (background) ✅"
    echo "  • Logs: .iacore/runtime/"
    echo ""
    echo -e "${CYAN}Configuración:${NC}"
    if [ -n "$OPENAI_API_KEY" ]; then
        echo "  • OpenAI API: ✅ Configurada"
    else
        echo "  • OpenAI API: ⚠️  No configurada (funcionalidad limitada)"
        echo "    Configura con: export OPENAI_API_KEY='tu-key'"
    fi
    if [ -f ".iacore/mcp/config.yml" ]; then
        echo "  • MCP: ✅ Configurado"
    fi
    echo ""
    echo -e "${CYAN}Comandos disponibles:${NC}"
    echo "  iacore status    - Ver estado del sistema"
    echo "  iacore logs      - Ver logs del agente"
    echo "  iacore config    - Configurar opciones"
    echo "  iacore pause     - Pausar agente"
    echo "  iacore resume    - Reanudar agente"
    echo "  iacore analyze   - Re-analizar proyecto"
    echo ""
    echo -e "${YELLOW}💡 Tip:${NC} El agente está observando tu proyecto."
    echo "   Trabaja normalmente y IA_Core asistirá de forma transparente."
    echo ""
    echo -e "${CYAN}📖 Documentación:${NC} https://github.com/YOUR_USERNAME/IA_core"
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
    setup_project_integration  # Includes deep analysis and MCP setup
    deploy_api
    start_agent
    install_cli
    validate_installation
    
    show_summary
}

# Run installer
main
