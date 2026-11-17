# Documentation of IA_Core

Master index of this repository's documentation. Every closed story adds its record and links it here; a document without an index entry is a lost document.

## Documents

Most of this repository's documentation lives at the repository root — two of those files are referenced by that exact path from `verify.sh`, so they are indexed here instead of moved.

| Document | What it is |
|---|---|
| [README of the repository](../README.md) | Presentation, capabilities with their state, architecture, security and installation of IA_Core |
| [AGENT_SPEC.md](../AGENT_SPEC.md) | Agent specification: what the autonomous agent is and how it is expected to behave |
| [DEPLOYMENT.md](../DEPLOYMENT.md) | Deployment guide for an IA_Core installation |
| [INSTALLATION_FEATURES.md](../INSTALLATION_FEATURES.md) | What the installer does, feature by feature |
| [GITHUB_SETUP.md](../GITHUB_SETUP.md) | GitHub setup for the repo creation/push helper scripts |
| [EXECUTE_PUSH.md](../EXECUTE_PUSH.md) | How to run the push helpers |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | Contribution guidelines |
| [SKILL.md](../SKILL.md) | The IA_Core skill definition |
| [skills/project-analyzer/SKILL.md](../skills/project-analyzer/SKILL.md) | Bundled skill: project analysis |
| [skills/memory-manager/SKILL.md](../skills/memory-manager/SKILL.md) | Bundled skill: memory management |
| [skills/chrome-devtools/SKILL.md](../skills/chrome-devtools/SKILL.md) | Bundled skill: Chrome DevTools |
| [skills/autonomous-executor/SKILL.md](../skills/autonomous-executor/SKILL.md) | Bundled skill: autonomous execution |
| [This index](README.md) | Master index of the `docs/` folder |

## How this folder is kept

- Every document of the repository is linked from this index with one honest line about what it contains, wherever the document lives.
- New design, installation or operation documents are filed under their topic subfolder (`arquitectura-y-diseno/`, `instalacion-y-despliegue/`, `operacion/`) and linked here in the same commit.
- State discipline: **Built** · **In development** · **Designed** · **Concept** — states are never mixed.
