---
name: project-analyzer
description: Deep project analysis skill that detects frameworks, languages, dependencies, and recommends optimal configurations. Use when you need to understand a new codebase or analyze project structure.
version: 0.1.0
author: jeturing
triggers:
  - analyze project
  - detect framework
  - what technology
  - project structure
  - codebase analysis
---

# Project Analyzer Skill

Analyzes any project to provide comprehensive understanding of its structure, technologies, and dependencies.

## What It Detects

### Frameworks
- **Frontend**: React, Vue, Angular, Svelte, Next.js, Nuxt.js
- **Backend**: Django, FastAPI, Flask, Express, NestJS, Spring
- **Mobile**: React Native, Flutter, Swift, Kotlin

### Languages
- Python, JavaScript, TypeScript, Go, Rust, Java, C#, Ruby, PHP

### Build Tools
- npm, yarn, pnpm, pip, poetry, cargo, go modules, gradle, maven

### Project Patterns
- Monorepo detection
- Microservices architecture
- API-first design
- Component-based structure

## Usage

### Basic Analysis
```
Analyze this project and tell me what technologies it uses.
```

### Deep Analysis
```
Give me a detailed breakdown of this project including:
- All frameworks and their versions
- Dependency tree
- Code structure patterns
- Potential improvements
```

### Comparison
```
Compare this project's technology stack with modern best practices.
```

## Output Format

The analyzer returns:

```json
{
  "project_type": "python",
  "frameworks": ["fastapi", "sqlalchemy"],
  "languages": ["python"],
  "package_managers": ["pip"],
  "dependencies": {
    "production": ["fastapi", "uvicorn", "pydantic"],
    "development": ["pytest", "black", "mypy"]
  },
  "structure": {
    "has_tests": true,
    "has_docs": true,
    "has_ci": true
  },
  "recommendations": [
    "Consider adding type hints",
    "Add pre-commit hooks"
  ]
}
```

## Guidelines

1. Always run analysis before making changes to unfamiliar projects
2. Check for existing configuration files first
3. Respect the project's existing patterns
4. Report findings clearly and actionably
