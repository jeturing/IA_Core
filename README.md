# IA_Core 🤖

**Capa de orquestación autónoma con IA** - Se instala en cualquier proyecto y lo gestiona automáticamente usando GPT-4o-mini (gratuito) y OpenCore.

## 🚀 Instalación One-Liner

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/IA_core/main/install.sh | bash
```

O con wget:

```bash
wget -qO- https://raw.githubusercontent.com/YOUR_USER/IA_core/main/install.sh | bash
```

**¡Eso es todo!** El instalador:
1. ✅ Detecta automáticamente el tipo de proyecto
2. ✅ Instala y configura OpenCore
3. ✅ Configura GPT-4o-mini (gratuito)
4. ✅ Despliega la API de orquestación
5. ✅ Arranca el agente autónomo en background
6. ✅ No requiere intervención del usuario

## 🎯 ¿Qué hace IA_Core?

IA_Core es una **capa invisible de inteligencia** que:

- 🔍 **Analiza** tu proyecto completo de forma inteligente
- 🧠 **Entiende** el contexto usando GPT-4o-mini
- ⚡ **Ejecuta** tareas automáticamente vía OpenCore
- 🔄 **Se mantiene** actualizado con los cambios
- 🚫 **No interfiere** con tu desarrollo normal

## 📖 Uso

Una vez instalado, simplemente trabaja en tu proyecto normalmente. IA_Core observa y asiste de forma transparente:

```bash
# Tú trabajas normalmente:
git commit -m "add new feature"

# IA_Core automáticamente:
# - Detecta cambios
# - Analiza el impacto
# - Ejecuta tests
# - Genera documentación
# - Sugiere mejoras
```

### Comandos Disponibles

```bash
# Ver estado de IA_Core
iacore status

# Ver logs del agente
iacore logs

# Pausar/reanudar
iacore pause
iacore resume

# Configuración
iacore config

# Desinstalar
iacore uninstall
```

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────┐
│         Tu Proyecto (cualquiera)        │
├─────────────────────────────────────────┤
│           IA_Core (invisible)           │
│  ┌────────────┐      ┌───────────────┐ │
│  │  Detector  │─────▶│  GPT-4o-mini  │ │
│  └────────────┘      └───────────────┘ │
│         │                     │         │
│         ▼                     ▼         │
│  ┌────────────┐      ┌───────────────┐ │
│  │ OpenCore   │◀────▶│  API Server   │ │
│  └────────────┘      └───────────────┘ │
└─────────────────────────────────────────┘
```

## 🔧 Características Técnicas

### Consumo Inteligente del Proyecto
- **Auto-detección**: React, Vue, Python, Node, etc.
- **Análisis contextual**: Entiende estructura y dependencias
- **Procesamiento incremental**: Solo analiza cambios

### LLM Gratuito (GPT-4o-mini)
- **Sin costos**: Usa el endpoint gratuito de OpenAI
- **Rápido**: Latencia <500ms
- **Inteligente**: Suficiente para tareas de desarrollo

### OpenCore Integration
- **Ejecución silenciosa**: Los comandos no se muestran al usuario
- **Aislado**: No interfiere con tu workflow
- **Seguro**: Sandbox de ejecución

### API de Orquestación
- **FastAPI**: API REST de alta performance
- **Auto-deploy**: Se levanta automáticamente
- **Health checks**: Monitoreo continuo

## 🔒 Seguridad

- ✅ **Sandbox**: Ejecución aislada de comandos
- ✅ **Permisos**: Solo accede a archivos del proyecto
- ✅ **Sin telemetría**: Cero datos enviados a terceros
- ✅ **Open source**: Código 100% auditable

## 📊 Requisitos

- **OS**: Linux, macOS (Windows via WSL)
- **Python**: 3.9+
- **Disk**: ~100MB
- **RAM**: ~200MB en background

## 🛠️ Desarrollo

```bash
# Clonar repo
git clone https://github.com/YOUR_USER/IA_core.git
cd IA_core

# Instalar dependencias de desarrollo
pip install -r requirements-dev.txt

# Ejecutar tests
pytest tests/

# Contribuir
# Ver CONTRIBUTING.md
```

## 📝 Configuración Avanzada

Crea `.iacore.yml` en tu proyecto para personalizar:

```yaml
# .iacore.yml
version: 1

# Modelo LLM
llm:
  provider: openai
  model: gpt-4o-mini
  endpoint: https://api.openai.com/v1
  api_key: ${OPENAI_API_KEY}  # o usa clave gratuita

# OpenCore
opencore:
  runtime: local
  max_parallel: 4
  timeout: 300

# Agente
agent:
  auto_analyze: true
  auto_execute: false  # requiere aprobación manual
  watch_patterns:
    - "src/**/*.py"
    - "src/**/*.js"
  ignore_patterns:
    - "node_modules/**"
    - ".git/**"

# API
api:
  host: 127.0.0.1
  port: 8788
  auto_start: true

# Workflows personalizados
workflows:
  on_commit:
    - analyze_changes
    - run_tests
    - update_docs
  on_push:
    - full_analysis
    - generate_report
```

## 🤝 Contribuir

¡Contribuciones son bienvenidas! Ver [CONTRIBUTING.md](CONTRIBUTING.md)

## 📄 Licencia

MIT License - Ver [LICENSE](LICENSE)

## 🌟 Roadmap

- [ ] Soporte para más LLMs (Anthropic, Mistral, local)
- [ ] UI web para monitoreo
- [ ] Integración con GitHub Actions
- [ ] Plugins para IDEs (VSCode, JetBrains)
- [ ] Agentes especializados por lenguaje
- [ ] Modo colaborativo multi-agente

## 💬 Soporte

- **Issues**: [GitHub Issues](https://github.com/YOUR_USER/IA_core/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USER/IA_core/discussions)
- **Twitter**: [@IA_core](https://twitter.com/IA_core)

---

**Hecho con ❤️ por la comunidad open source**
