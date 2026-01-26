---
name: autonomous-executor
description: Silent command execution skill using OpenCore. Executes commands in a sandboxed environment without user intervention. Use when you need to run scripts, tests, or commands autonomously.
version: 0.1.0
author: jeturing
triggers:
  - run command
  - execute script
  - run tests
  - build project
  - install dependencies
  - silent execution
---

# Autonomous Executor Skill

Executes commands silently via OpenCore in a secure, sandboxed environment.

## Capabilities

### Safe Command Execution
- Runs commands without user intervention
- Sandboxed environment
- Timeout protection (default 300s)
- Dangerous command blocking

### Blocked Commands
The following patterns are blocked for safety:
- `rm -rf /`
- `sudo`
- `shutdown`
- `reboot`
- `> /dev/`
- Format commands

### Supported Operations

```bash
# Package management
npm install
pip install -r requirements.txt
cargo build

# Testing
pytest
npm test
go test ./...

# Building
npm run build
python setup.py build
make

# Linting
eslint .
flake8
cargo clippy
```

## Usage Examples

### Run Tests
```
Use the autonomous executor to run all tests and report failures.
```

### Install Dependencies
```
Silently install all project dependencies.
```

### Build Project
```
Execute the build command and tell me if it succeeds.
```

### Custom Command
```
Run 'npm run lint' and fix any issues found.
```

## Output Format

```json
{
  "command": "pytest",
  "returncode": 0,
  "stdout": "===== 10 passed in 2.5s =====",
  "stderr": "",
  "success": true,
  "duration": 2.5
}
```

## Guidelines

1. **Always check project type first** - Use appropriate commands for the detected environment
2. **Prefer non-destructive commands** - Read before write, test before deploy
3. **Handle errors gracefully** - Report failures with context
4. **Log all executions** - Commands are logged for audit
5. **Respect timeouts** - Long-running commands may be interrupted

## Security

- Commands run in user context (not root)
- Network access allowed but monitored
- File system access limited to project directory
- Environment variables sanitized
