---
name: ia-core
description: Autonomous AI agent orchestration layer that installs into any project. Provides deep project analysis, intelligent configuration, MCP servers (memory, context, tools), and silent command execution via OpenCore. Use this skill when you need to analyze a project structure, execute commands autonomously, manage persistent memory across sessions, or orchestrate AI agents.
version: 0.1.0
author: jeturing
repository: https://github.com/jeturing/IA_core
tags:
  - automation
  - orchestration
  - mcp
  - agents
  - project-analysis
triggers:
  - analyze project
  - autonomous agent
  - orchestrate
  - mcp server
  - execute command silently
  - project memory
  - intelligent analysis
---

# IA_Core - Autonomous AI Orchestration

IA_Core is an invisible AI orchestration layer that can be installed in any project to provide autonomous agent capabilities.

## Capabilities

### 1. Project Analysis
Deeply analyze any project to detect:
- **Frameworks**: React, Vue, Angular, Next.js, Django, FastAPI, Flask, Express, etc.
- **Languages**: Python, JavaScript, TypeScript, Go, Rust, Java
- **Dependencies**: Reads package.json, requirements.txt, go.mod, Cargo.toml
- **Structure**: Components, modules, configuration files
- **Recommended agents**: Based on detected technologies

### 2. MCP Servers
Three built-in Model Context Protocol servers:

#### Memory Server
Persistent memory across sessions:
```
memory/store_fact - Store facts with timestamps
memory/retrieve_fact - Retrieve stored facts
memory/store_decision - Record decisions with reasoning
memory/store_learning - Save learnings from experience
memory/get_learnings - Get relevant learnings by context
```

#### Context Server
Code understanding and navigation:
```
context/search_files - Search files by pattern
context/read_file - Read file content with line ranges
context/find_definition - Find symbol definitions
context/get_structure - Get file structure (functions, classes, imports)
context/project_summary - High-level project summary
```

#### Tools Server
Safe command execution:
```
tools/execute_command - Execute commands safely (dangerous ones blocked)
tools/write_file - Write content to files
tools/search_code - Search code with grep
tools/analyze_dependencies - Analyze project dependencies
```

### 3. Silent Execution
Execute commands via OpenCore without user intervention:
- Sandboxed environment
- Timeout protection
- Dangerous command blacklist (rm -rf, sudo, etc.)
- Audit logging

### 4. Autonomous Agent
Background agent that:
- Watches file changes with watchdog
- Analyzes impact of changes
- Executes configured workflows
- Learns and improves over time

## Installation

One-liner installation:
```bash
curl -fsSL https://raw.githubusercontent.com/jeturing/IA_core/main/install.sh | bash
```

## Usage Examples

### Analyze a Project
```
Use IA_Core to analyze this project and tell me what frameworks and languages it uses.
```

### Store Memory
```
Use the IA_Core memory server to store this decision: We chose FastAPI over Flask because of async support.
```

### Execute Command Silently
```
Use IA_Core to run the tests in the background and report any failures.
```

### Search Code
```
Use IA_Core context server to find all definitions of the UserService class.
```

## Configuration

IA_Core creates `.iacore/config.yml` in your project:

```yaml
project:
  type: python
  frameworks: [fastapi, sqlalchemy]

agent:
  enabled: true
  auto_analyze: true
  watch_mode: true

mcp:
  enabled: true
  servers:
    - memory
    - context
    - tools

api:
  port: 8788
```

## API Endpoints

REST API available at `http://127.0.0.1:8788`:

- `GET /health` - Health check
- `GET /status` - Agent status
- `POST /analyze` - Analyze project
- `POST /agent/pause` - Pause agent
- `POST /agent/resume` - Resume agent

## Guidelines

1. **Always analyze first**: Before making changes, use the context server to understand the project structure.

2. **Use memory for decisions**: Store important decisions in the memory server for future reference.

3. **Safe execution**: The tools server blocks dangerous commands automatically, but still be careful with file modifications.

4. **Check learnings**: Before solving a problem, check if there are relevant learnings from past experiences.

5. **Respect project type**: IA_Core auto-configures based on project type - use the detected workflows.

## Integration with Other Skills

IA_Core works well with:
- **Document skills**: Use context server to analyze code, then document skills to create docs
- **Testing skills**: Use tools server to run tests and memory to track results
- **Code generation**: Use project analysis to understand patterns before generating code

## Troubleshooting

### Agent not responding
```bash
iacore status
iacore logs
```

### Restart agent
```bash
iacore pause
iacore resume
```

### Re-analyze project
```bash
iacore analyze
```
