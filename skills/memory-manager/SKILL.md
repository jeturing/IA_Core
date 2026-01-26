---
name: memory-manager
description: Persistent memory management skill using MCP Memory Server. Stores facts, decisions, and learnings that persist across sessions. Use when you need to remember context, track decisions, or learn from experience.
version: 0.1.0
author: jeturing
triggers:
  - remember this
  - store memory
  - recall
  - what did we decide
  - learn from
  - save decision
---

# Memory Manager Skill

Manages persistent memory for AI agents using the IA_Core Memory MCP Server.

## Memory Types

### Facts
Key-value pairs with timestamps:
```
Store fact: The API uses JWT authentication
Retrieve fact: How does the API authenticate?
```

### Decisions
Records of choices made with reasoning:
```
Store decision: We chose PostgreSQL over MySQL because of JSON support and better performance with complex queries.
```

### Learnings
Lessons from experience:
```
Store learning: When deploying to production, always run migrations before starting the new version.
Context: Deployment failed because migrations weren't applied first.
```

### Project Context
Project-specific information:
```
Update context: The main entry point is src/main.py
Get context: What's the project structure?
```

## Usage Examples

### Store a Fact
```
Remember that the database connection string is stored in .env as DATABASE_URL
```

### Record a Decision
```
Record this decision: We're using FastAPI instead of Flask because we need async support for the websocket features.
```

### Save a Learning
```
Save this learning: The CI pipeline fails if you don't update the version in setup.py before releasing.
```

### Recall Information
```
What did we decide about the database?
```

### Get Relevant Learnings
```
What should I know about deploying this project?
```

## API

### Store Fact
```json
{
  "method": "memory/store_fact",
  "params": {
    "key": "auth_method",
    "value": "JWT with refresh tokens"
  }
}
```

### Store Decision
```json
{
  "method": "memory/store_decision",
  "params": {
    "decision": "Use PostgreSQL",
    "reasoning": "Better JSON support, more scalable",
    "outcome": "Successfully deployed"
  }
}
```

### Get Learnings
```json
{
  "method": "memory/get_learnings",
  "params": {
    "context": "deployment production"
  }
}
```

## Storage

Memory is persisted to `~/.iacore/memory/agent_memory.json`:

```json
{
  "facts": {
    "auth_method": {
      "value": "JWT",
      "timestamp": "2025-01-25T10:00:00"
    }
  },
  "decisions": [...],
  "learnings": [...],
  "project_context": {...}
}
```

## Guidelines

1. **Be specific** - Store concrete, actionable information
2. **Include context** - Add reasoning to decisions
3. **Query before acting** - Check for relevant learnings
4. **Update outcomes** - Record what happened after decisions
5. **Clean periodically** - Remove outdated facts
