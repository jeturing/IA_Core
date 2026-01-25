# GitHub Deployment Guide

## Quick Setup (5 minutes)

### 1. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `IA_core`
3. Description: "Autonomous AI Orchestration Layer - Invisible intelligence for any project"
4. **Public** (important for one-liner install)
5. Do NOT initialize with README (we already have one)
6. Click "Create repository"

### 2. Push to GitHub

```bash
cd /Users/owner/Desktop/jcore/IA_core

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/Jeturing/IA_core.git

# Push
git branch -M main
git push -u origin main
```

### 3. Update README.md

After pushing, update the installation URLs in README.md:

```bash
# Find and replace
# FROM: YOUR_USER/IA_core
# TO:   your-actual-username/IA_core
```

Commit and push the change:

```bash
git commit -am "Update GitHub username in install URLs"
git push
```

### 4. Test Installation

From any project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/Jeturing/IA_core/main/install.sh | bash
```

## Post-Deployment

### Configure Repository Settings

1. **Topics**: Add topics for discoverability
   - `ai-agent`
   - `autonomous-ai`
   - `gpt-4o-mini`
   - `opencore`
   - `orchestration`
   - `developer-tools`
   - `automation`

2. **About**: Set description and website
   - Description: "🤖 Autonomous AI agent that integrates into any project. Uses GPT-4o-mini (free) + OpenCore for invisible intelligent orchestration."
   - Website: (optional, add docs site later)

3. **GitHub Pages** (optional):
   - Settings → Pages
   - Source: Deploy from main branch / docs folder
   - Can host documentation

### Create GitHub Actions (optional)

Create `.github/workflows/test.yml` for CI:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.9, "3.10", 3.11, 3.12]
    
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-cov
    - name: Run tests
      run: pytest tests/ -v --cov=iacore
```

### Add Badges to README

Add these badges at the top of README.md:

```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![GitHub stars](https://img.shields.io/github/stars/Jeturing/IA_core)](https://github.com/Jeturing/IA_core/stargazers)
```

### Create Release

1. Go to repository → Releases → "Create a new release"
2. Tag version: `v0.1.0`
3. Release title: "IA_Core v0.1.0 - Initial Release"
4. Description:

```markdown
## 🎉 Initial Release

IA_Core is an autonomous AI agent that integrates invisibly into any project, providing intelligent orchestration using GPT-4o-mini (free tier) and OpenCore.

### ✨ Features

- 🤖 **Autonomous Agent**: Runs continuously in background
- 🔍 **Auto-Detection**: Recognizes React, Python, Node, and 20+ project types
- 🧠 **GPT-4o-mini**: Uses free tier for intelligent analysis
- ⚡ **Silent Execution**: Commands run via OpenCore without user visibility
- 📊 **REST API**: FastAPI server for programmatic control
- 💻 **CLI**: Simple commands (status, logs, pause/resume)
- 🚀 **One-Liner Install**: `curl ... | bash`

### 📦 Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Jeturing/IA_core/main/install.sh | bash
```

### 🎯 Quick Start

Once installed, the agent runs automatically. Use these commands:

```bash
iacore status   # Check agent status
iacore logs     # View logs
iacore pause    # Pause agent
iacore resume   # Resume agent
```

### 🔧 Requirements

- Python 3.9+
- Git
- Linux or macOS (Windows via WSL)

### 📖 Documentation

See [README.md](README.md) for full documentation.

### 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).
```

5. Click "Publish release"

## Promotion

### Share on Social Media

**Twitter/X:**
```
🚀 Launching IA_Core v0.1.0!

An autonomous AI agent that integrates into ANY project and provides invisible intelligent orchestration.

✨ Uses GPT-4o-mini (FREE)
⚡ Silent execution via OpenCore
🔧 One-liner install

Install: curl https://raw.githubusercontent.com/Jeturing/IA_core/main/install.sh | bash

#AI #Automation #DevTools
```

**Reddit (r/programming, r/MachineLearning):**
```
Title: [Project] IA_Core - Autonomous AI agent for any codebase

I built an autonomous AI agent that you can drop into any project with a one-liner. It uses GPT-4o-mini (free tier) to understand your codebase and orchestrate tasks silently via OpenCore.

Installation:
curl -fsSL https://raw.githubusercontent.com/Jeturing/IA_core/main/install.sh | bash

Key features:
- Auto-detects 20+ project types (React, Python, etc.)
- Runs continuously in background
- Silent command execution
- REST API + CLI
- 100% open source (MIT)

GitHub: https://github.com/Jeturing/IA_core

Would love feedback!
```

**Hacker News (Show HN):**
```
Title: Show HN: IA_Core – Autonomous AI agent for any project using GPT-4o-mini

https://github.com/Jeturing/IA_core

IA_Core is an autonomous AI agent that integrates into any project via a one-liner install. It uses GPT-4o-mini (free tier) to understand your codebase and execute tasks silently via OpenCore.

Key points:
- Works with any project type (auto-detection)
- Runs invisibly in background
- Silent execution (no terminal spam)
- REST API for control
- MIT licensed

It's basically "add AI to any project instantly" without changing your workflow.

Installation:
curl -fsSL https://raw.githubusercontent.com/Jeturing/IA_core/main/install.sh | bash
```

### Dev.to Article

Create a blog post explaining:
1. Why you built it
2. How it works
3. Example use cases
4. Technical architecture
5. Future roadmap

## Maintenance

### Weekly Tasks

- Respond to issues
- Review PRs
- Update dependencies
- Fix bugs

### Monthly Tasks

- Add new features from roadmap
- Improve documentation
- Write tutorials
- Engage with community

## Success Metrics

- GitHub stars: Target 100 in first month
- Installations: Track via GitHub insights
- Contributors: Encourage PRs
- Issues: Active discussions

---

**Ready to deploy!** 🚀

Follow the steps above and your project will be live on GitHub in minutes.
