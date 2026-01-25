# IA_Core 🤖

**Autonomous AI agent layer** - Installs into any project and manages it intelligently using GPT-4o-mini (free tier) and OpenCore.

## 🚀 One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/IA_core/main/install.sh | bash
```

**That's it!** IA_Core will:
- **Deeply analyze your project** - Detect frameworks, languages, dependencies
- **Request necessary credentials** - OpenAI API key (recommended), MCP configuration
- **Auto-configure** - Generate project-specific workflows and settings  
- **Deploy MCP servers** - Memory, context, and tools for advanced capabilities
- **Start monitoring** - Agent runs in background watching your project
- **Add CLI tools** - `iacore` command available globally

### 📋 Requirements

- **Python 3.9+** (required)
- **OpenAI API Key** (recommended for full functionality)
  - Get one at: https://platform.openai.com/api-keys
  - Free tier with GPT-4o-mini works perfectly
  - Without API key: limited functionality with fallbacks

### 🔧 Interactive Configuration

During installation, you'll be prompted for:

1. **OpenAI API Key** (optional but recommended)
   - Used for intelligent analysis
   - GPT-4o-mini free tier is sufficient
   - Configure later: `iacore config`

2. **MCP Configuration** (for backend/API projects)  
   - Enables memory, context, and tools servers
   - Auto-detected for Django, FastAPI, Flask, Express
   - Can skip if not needed

The installer **analyzes your project** and configures itself optimally!

## 🎯 Key Features

- 🤖 **Fully Autonomous** - Works independently after installation
- 🧠 **GPT-4o-mini Powered** - Free-tier LLM for intelligent analysis
- 👻 **Invisible Execution** - Commands via OpenCore (silent)
- 📊 **Project-Aware** - Understands 20+ project types automatically
- 🔄 **Real-time Monitoring** - Watches file changes intelligently
- ⚙️ **Smart Configuration** - Auto-configures based on project analysis
- 🔌 **MCP Protocol** - Memory, context, tools servers for advanced features
- 🎨 **Rich CLI** - Beautiful terminal UI with status and controls
- 🌐 **REST API** - HTTP API on port 8788 for integrations
- 💾 **Persistent Learning** - Remembers and improves over time
- 🔒 **Secure** - Credentials stored safely, dangerous commands blocked

## 📖 Usage

Once installed, simply work on your project normally. IA_Core observes and assists transparently.

### CLI Commands

```bash
# View status and project analysis
iacore status

# See agent logs in real-time
iacore logs

# Pause/resume the agent
iacore pause
iacore resume

# Configure settings (API keys, workflows)
iacore config

# Re-analyze project after major changes
iacore analyze

# Check version
iacore version

# Uninstall completely
iacore uninstall
```

### 🔍 What Gets Analyzed

IA_Core performs deep project analysis during installation:

- **Frameworks**: React, Vue, Angular, Next.js, Django, FastAPI, Flask, Express
- **Languages**: Python, JavaScript, TypeScript, Go, Rust, Java
- **Build Tools**: npm, pip, cargo, go modules, gradle
- **Dependencies**: package.json, requirements.txt, go.mod, Cargo.toml
- **Structure**: Components, modules, configuration
- **Recommended Agents**: Based on detected technologies

**Example analysis output:**
```
📊 Project Analysis:
  • Type: Python
  • Frameworks: fastapi, sqlalchemy
  • Languages: python
  • Recommended Agents: backend-developer, api-engineer
  • MCP: ✅ Configured (memory + context + tools)
```

## 🏗️ Architecture

```
┌──────────────────────────────────────────┐
│       Your Project (any type)            │
├──────────────────────────────────────────┤
│         IA_Core (invisible layer)        │
│  ┌────────────┐      ┌────────────────┐ │
│  │  Detector  │─────▶│ IntelligentAI  │ │
│  └────────────┘      └────────────────┘ │
│  ┌────────────┐      ┌────────────────┐ │
│  │ GPT-4o-mini│◀─────│AutonomousAgent │ │
│  └────────────┘      └────────────────┘ │
│         │                    │           │
│         ▼                    ▼           │
│  ┌────────────┐      ┌────────────────┐ │
│  │   Memory   │      │   OpenCore     │ │
│  │   (MCP)    │      │   Executor     │ │
│  └────────────┘      └────────────────┘ │
└──────────────────────────────────────────┘
```

**Components:**

- **ProjectDetector**: Analyzes project type, frameworks, dependencies
- **IntelligentAnalyzer**: LLM-powered deep understanding of codebase
- **AutonomousAgent**: Main loop monitoring files and executing workflows
- **LLMClient**: GPT-4o-mini integration with rate limiting and caching
- **OpenCoreExecutor**: Silent command execution in sandboxed environment
- **MCP Servers**: Memory, context, and tools for advanced agent capabilities
- **FastAPI Server**: REST API for external integrations
- **Typer CLI**: Rich command-line interface for user control

## 🔌 MCP (Model Context Protocol)

IA_Core includes three MCP servers that enhance agent capabilities:

### Memory Server
Persistent memory across sessions:
```python
# Stores facts, decisions, learnings
memory/store_fact
memory/retrieve_fact
memory/store_decision
memory/store_learning
memory/get_learnings
```

### Context Server  
Project understanding and code navigation:
```python
# Search, read, analyze code
context/search_files
context/read_file
context/find_definition
context/get_structure
context/project_summary
```

### Tools Server
Safe command execution:
```python
# Execute commands, modify files
tools/execute_command
tools/write_file
tools/search_code
tools/analyze_dependencies
```

MCP servers are **automatically configured** during installation for projects that need them (detected backend/API frameworks).

## 📊 Project Support Matrix

| Type | Auto-Detection | Workflows | MCP |
|------|----------------|-----------|-----|
| React | ✅ | Component analysis, build optimization | Optional |
| Vue | ✅ | Component analysis, state management | Optional |
| Angular | ✅ | Module analysis, dependency check | Optional |
| Next.js | ✅ | SSR optimization, route analysis | Optional |
| Python | ✅ | Code quality, type checking, tests | ✅ |
| Django | ✅ | API analysis, migrations, admin | ✅ |
| FastAPI | ✅ | Endpoint analysis, validation | ✅ |
| Flask | ✅ | Route analysis, blueprints | ✅ |
| Node.js | ✅ | Dependency audits, package updates | Optional |
| Express | ✅ | API endpoints, middleware analysis | ✅ |
| Go | ✅ | Module analysis, formatting | Optional |
| Rust | ✅ | Cargo check, clippy suggestions | Optional |

## 🛠️ Advanced Configuration

### Manual Configuration

Edit `.iacore/config.yml` in your project:

```yaml
version: 1

project:
  type: python
  root: /path/to/project
  frameworks: [fastapi, sqlalchemy]

agent:
  enabled: true
  auto_analyze: true
  auto_execute: false  # Set true for full autonomy
  watch_mode: true

llm:
  provider: openai
  model: gpt-4o-mini
  config_file: ~/.iacore/llm_config.yml

mcp:
  enabled: true
  config_path: .iacore/mcp/config.yml
  auto_start: true

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
```

### Environment Variables

```bash
# OpenAI API Key
export OPENAI_API_KEY='sk-...'

# Custom project root for MCP servers
export PROJECT_ROOT='/path/to/project'

# Custom IA_Core home directory
export IACORE_HOME='~/.iacore'
```

## 📡 REST API

IA_Core exposes a REST API on `http://127.0.0.1:8788`:

```bash
# Check health
curl http://127.0.0.1:8788/health

# Get agent status
curl http://127.0.0.1:8788/status

# Analyze project
curl -X POST http://127.0.0.1:8788/analyze \
  -H "Content-Type: application/json" \
  -d '{"path": "."}'

# Pause/resume agent
curl -X POST http://127.0.0.1:8788/agent/pause
curl -X POST http://127.0.0.1:8788/agent/resume
```

See full API documentation: [API_REFERENCE.md](docs/API_REFERENCE.md)

## 🔒 Security

IA_Core is designed with security in mind:

- ✅ **Sandboxed execution** - Commands run in controlled environment
- ✅ **Dangerous command blocking** - rm -rf, sudo, shutdown blocked
- ✅ **Credential encryption** - API keys stored securely with proper permissions
- ✅ **Rate limiting** - Prevents API abuse (10 req/min on free tier)
- ✅ **Audit logging** - All actions logged for review
- ✅ **No external data** - Project data stays local

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

## 🔗 Links

- **Documentation**: [docs/](docs/)
- **Agent Spec**: [AGENT_SPEC.md](AGENT_SPEC.md)
- **Deployment Guide**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

## 💬 Support

Need help?

1. Check the [documentation](docs/)
2. Review [AGENT_SPEC.md](AGENT_SPEC.md) for technical details
3. Search existing [GitHub Issues](https://github.com/YOUR_USERNAME/IA_core/issues)
4. Create a new issue with details

---

**Built with ❤️ for autonomous AI development**
