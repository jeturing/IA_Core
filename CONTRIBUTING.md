# Contributing to IA_Core

Thank you for your interest in contributing to IA_Core! 🎉

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/YOUR_USER/IA_core/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - System info (OS, Python version)
   - Relevant logs

### Suggesting Features

1. Open a [Discussion](https://github.com/YOUR_USER/IA_core/discussions)
2. Describe the feature and use case
3. Explain why it would be useful

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass (`pytest tests/`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to your fork (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USER/IA_core.git
cd IA_core

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dev dependencies
pip install -r requirements-dev.txt
pip install -e .

# Run tests
pytest tests/

# Run linters
black iacore/
flake8 iacore/
mypy iacore/
```

## Code Style

- Follow PEP 8
- Use type hints
- Write docstrings for public APIs
- Keep functions focused and small
- Add comments for complex logic

## Testing

- Write tests for new features
- Maintain > 80% code coverage
- Use pytest for testing
- Mock external dependencies

## Commit Messages

Use conventional commits:

```
feat: add support for local LLMs
fix: resolve rate limiting issue
docs: update installation guide
test: add tests for detector
refactor: simplify analyzer logic
```

## Code of Conduct

Be respectful, inclusive, and professional. We're building something awesome together! ✨

## Questions?

Open a [Discussion](https://github.com/YOUR_USER/IA_core/discussions) or reach out on [Twitter](https://twitter.com/IA_core).
