# IA_Core Agent Specification

## Overview

**IA_Core** es un agente autónomo de IA que se integra en cualquier proyecto y proporciona orquestación inteligente usando GPT-4o-mini (gratuito) y OpenCore.

## Capabilities

### 1. Intelligent Project Analysis
- **Auto-detección** del tipo de proyecto (React, Python, Node, etc.)
- **Análisis profundo** usando GPT-4o-mini para entender estructura y contexto
- **Detección continua** de cambios en archivos relevantes

### 2. Autonomous Orchestration
- **Ejecución silenciosa** vía OpenCore (comandos no visibles al usuario)
- **Generación de planes** de acción basados en el contexto del proyecto
- **Ejecución automática** de tareas con aprobación opcional

### 3. LLM Integration
- **GPT-4o-mini** como modelo principal (endpoint gratuito)
- **Rate limiting** inteligente (10 req/min para tier gratuito)
- **Caché de respuestas** para reducir llamadas repetidas
- **Fallback** a modelos alternativos cuando sea necesario

### 4. Background Monitoring
- **File watcher** que detecta cambios en tiempo real
- **Análisis de impacto** para cada modificación
- **Workflows automáticos** según eventos (commit, file change, etc.)

### 5. REST API
- **FastAPI server** para control programático
- **Endpoints** para status, tasks, analysis, etc.
- **Auto-deploy** en instalación

### 6. CLI Commands
- `iacore status` - Ver estado del agente
- `iacore logs` - Ver logs en tiempo real
- `iacore pause/resume` - Control del agente
- `iacore config` - Configuración
- `iacore uninstall` - Desinstalación limpia

## Architecture

```
┌─────────────────────────────────────────┐
│         User Project (any type)         │
│                                          │
│  ┌─────────────────────────────────┐   │
│  │      .iacore/ (invisible)       │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │  AutonomousAgent         │   │   │
│  │  │  - File Watcher          │   │   │
│  │  │  - Context Manager       │   │   │
│  │  │  - Task Queue            │   │   │
│  │  └──────────────────────────┘   │   │
│  │            ↕                     │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │  IntelligentAnalyzer     │   │   │
│  │  │  - LLMClient             │   │   │
│  │  │  - ProjectDetector       │   │   │
│  │  └──────────────────────────┘   │   │
│  │            ↕                     │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │  OpenCoreExecutor        │   │   │
│  │  │  - Silent Mode           │   │   │
│  │  │  - Sandbox               │   │   │
│  │  └──────────────────────────┘   │   │
│  │            ↕                     │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │  FastAPI Server          │   │   │
│  │  │  :8788                   │   │   │
│  │  └──────────────────────────┘   │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
         ↕ (external control)
    ┌─────────────┐
    │   iacore    │
    │     CLI     │
    └─────────────┘
```

## Installation Flow

1. **User executes one-liner:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/YOUR_USER/IA_core/main/install.sh | bash
   ```

2. **Installer (`install.sh`):**
   - Checks requirements (Python 3.9+, Git)
   - Auto-detects project type
   - Clones IA_core to `~/.iacore`
   - Creates virtual environment
   - Installs dependencies
   - Configures OpenCore (installs if needed)
   - Sets up GPT-4o-mini (uses free endpoint)
   - Creates `.iacore/` in project root
   - Generates `config.yml` based on detection
   - Starts API server in background
   - Starts autonomous agent in background
   - Installs CLI symlink (`iacore` command)

3. **Post-installation:**
   - Agent is running invisibly
   - API available at http://127.0.0.1:8788
   - User can use `iacore` commands
   - No configuration needed (works out of the box)

## Configuration

Default `.iacore/config.yml`:

```yaml
version: 1

project:
  type: <auto-detected>
  root: <project-root>
  auto_detected: true

agent:
  enabled: true
  auto_analyze: true
  auto_execute: false  # Require manual approval
  watch_mode: true

llm:
  provider: openai
  model: gpt-4o-mini
  endpoint: https://api.openai.com/v1/chat/completions
  api_key: ${OPENAI_API_KEY}  # Optional, uses free tier if not set

opencore:
  runtime: local
  silent_mode: true
  max_parallel: 4
  timeout: 300

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
```

## Security

- **Sandbox execution**: OpenCore runs commands in isolated environment
- **Command whitelist**: Dangerous commands are blocked
- **No external telemetry**: Zero data sent outside the project
- **Rate limiting**: Prevents abuse of free LLM tier
- **Local-first**: All data stays on the user's machine

## Workflows

### File Change Workflow
1. Watchdog detects file modification
2. Agent determines if file is relevant (not in ignore list)
3. LLM analyzes impact of change
4. If high impact:
   - Execute workflow actions (analyze_context, etc.)
   - Optionally create tasks for user approval

### Git Commit Workflow
1. Agent detects git commit (via hook or polling)
2. LLM analyzes commit message and changes
3. Provides suggestions for improvements
4. Optionally runs tests automatically

### Task Execution Workflow
1. User creates task via CLI or API
2. Task added to queue in `.iacore/runtime/tasks.json`
3. Agent picks up task from queue
4. LLM generates execution plan (list of commands)
5. OpenCore executes commands silently
6. Results logged, user notified if needed

## Transparency

IA_Core is designed to be **invisible but observable**:

- **Silent execution**: Commands run without terminal output
- **Logs available**: `iacore logs` shows everything
- **Status visible**: `iacore status` shows current state
- **Can be paused**: `iacore pause` stops all automation
- **Fully auditable**: All actions logged to `.iacore/runtime/`

## Use Cases

1. **Continuous Code Analysis**
   - Agent detects code changes
   - Analyzes quality and suggests improvements
   - No user action required

2. **Automated Testing**
   - On save, runs relevant tests
   - Reports failures silently
   - Only alerts if critical

3. **Documentation Generation**
   - Detects new functions/classes
   - Generates/updates docstrings
   - Commits changes automatically (if enabled)

4. **Dependency Management**
   - Monitors for outdated packages
   - Suggests updates
   - Can update automatically with approval

5. **Git Workflow Assistant**
   - Analyzes commits for quality
   - Suggests better commit messages
   - Checks for common mistakes

## Future Enhancements

- **Multi-LLM support**: Anthropic Claude, local models
- **Team collaboration**: Shared learning across team members
- **IDE plugins**: VSCode, JetBrains integration
- **Custom agents**: User-defined specialized agents
- **Cloud sync**: Optional cloud backup of learnings

---

**Status**: ✅ Fully implemented and ready for GitHub deployment
**Version**: 0.1.0
**License**: MIT
