"""
Project Detector - Auto-detects project type and structure.

Reuses the AutoDetector from ai-workforce but simplified for IA_Core.
"""

import json
from pathlib import Path
from typing import Dict, List, Optional
import logging

logger = logging.getLogger(__name__)


class ProjectDetector:
    """Detects project type and structure."""

    def __init__(self, project_root: Path | str):
        self.project_root = Path(project_root).resolve()

    def detect(self) -> Dict:
        """
        Detect project type and key files.
        
        Returns:
            {
                "type": "react" | "python" | "node" | etc.,
                "confidence": 0.0-1.0,
                "files": ["key", "files", "list"],
                "dependencies": {...},
            }
        """
        project_type = "unknown"
        confidence = 0.0
        files = []
        dependencies = {}

        # Check for package.json (Node/React/Vue/etc)
        if (self.project_root / "package.json").exists():
            pkg_json = json.loads((self.project_root / "package.json").read_text())
            dependencies = pkg_json.get("dependencies", {})
            
            if "react" in dependencies:
                project_type = "react"
                confidence = 0.9
            elif "vue" in dependencies:
                project_type = "vue"
                confidence = 0.9
            elif "next" in dependencies:
                project_type = "nextjs"
                confidence = 0.95
            elif "express" in dependencies:
                project_type = "express"
                confidence = 0.85
            else:
                project_type = "node"
                confidence = 0.7
            
            files.append("package.json")

        # Check for Python
        elif (self.project_root / "requirements.txt").exists() or \
             (self.project_root / "setup.py").exists() or \
             (self.project_root / "pyproject.toml").exists():
            
            project_type = "python"
            confidence = 0.8
            
            # Check for specific frameworks
            if (self.project_root / "manage.py").exists():
                project_type = "django"
                confidence = 0.95
            elif any((self.project_root / "app").glob("*.py")) or \
                 any((self.project_root / "main.py").exists() for _ in [1]):
                # Check if FastAPI
                try:
                    req_file = self.project_root / "requirements.txt"
                    if req_file.exists() and "fastapi" in req_file.read_text().lower():
                        project_type = "fastapi"
                        confidence = 0.9
                except:
                    pass
            
            files.extend([
                f for f in ["requirements.txt", "setup.py", "pyproject.toml"]
                if (self.project_root / f).exists()
            ])

        # Check for Go
        elif (self.project_root / "go.mod").exists():
            project_type = "go"
            confidence = 0.9
            files.append("go.mod")

        # Check for Rust
        elif (self.project_root / "Cargo.toml").exists():
            project_type = "rust"
            confidence = 0.9
            files.append("Cargo.toml")

        # Check for HTML/Static
        elif list(self.project_root.glob("*.html")):
            project_type = "html_static"
            confidence = 0.6
            files.extend([str(f.name) for f in self.project_root.glob("*.html")][:5])

        return {
            "type": project_type,
            "confidence": confidence,
            "files": files,
            "dependencies": dependencies,
            "root": str(self.project_root),
        }

    def get_file_tree(self, max_depth: int = 3) -> List[str]:
        """Get file tree of project."""
        files = []
        
        def walk(path: Path, depth: int = 0):
            if depth > max_depth:
                return
            
            try:
                for item in path.iterdir():
                    # Skip hidden and common ignore patterns
                    if item.name.startswith(".") or \
                       item.name in ["node_modules", "__pycache__", "venv", "env"]:
                        continue
                    
                    rel_path = item.relative_to(self.project_root)
                    files.append(str(rel_path))
                    
                    if item.is_dir():
                        walk(item, depth + 1)
            except PermissionError:
                pass
        
        walk(self.project_root)
        return sorted(files)[:100]  # Limit to 100 files
