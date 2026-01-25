#!/usr/bin/env python3
"""
Context MCP Server - Project context and code understanding
Provides semantic search and code analysis capabilities
"""

import asyncio
import json
import logging
from pathlib import Path
from typing import Dict, List, Any, Optional
import subprocess
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ContextServer:
    """MCP server for project context and code understanding"""
    
    def __init__(self, project_root: Optional[Path] = None):
        self.project_root = Path(project_root or os.getenv("PROJECT_ROOT", "."))
        self.index_cache: Dict[str, Any] = {}
        logger.info(f"Context server initialized for: {self.project_root}")
    
    async def search_files(self, pattern: str, file_types: Optional[List[str]] = None) -> List[Dict]:
        """Search for files matching pattern"""
        results = []
        
        # Use git ls-files if available
        try:
            cmd = ["git", "ls-files"]
            output = subprocess.check_output(
                cmd, 
                cwd=self.project_root,
                text=True,
                stderr=subprocess.DEVNULL
            )
            files = output.strip().split("\n")
        except:
            # Fallback to pathlib
            files = [str(f.relative_to(self.project_root)) 
                    for f in self.project_root.rglob("*") if f.is_file()]
        
        # Filter by pattern and type
        for file_path in files:
            if pattern.lower() in file_path.lower():
                if file_types is None or any(file_path.endswith(ext) for ext in file_types):
                    full_path = self.project_root / file_path
                    if full_path.exists():
                        results.append({
                            "path": file_path,
                            "size": full_path.stat().st_size,
                            "type": full_path.suffix
                        })
        
        return results[:50]  # Limit results
    
    async def read_file_content(self, file_path: str, start_line: int = 0, end_line: int = -1) -> Dict:
        """Read file content with optional line range"""
        full_path = self.project_root / file_path
        
        if not full_path.exists():
            return {"error": "File not found"}
        
        try:
            content = full_path.read_text()
            lines = content.split("\n")
            
            if end_line == -1:
                end_line = len(lines)
            
            selected_lines = lines[start_line:end_line]
            
            return {
                "path": file_path,
                "content": "\n".join(selected_lines),
                "total_lines": len(lines),
                "range": [start_line, min(end_line, len(lines))]
            }
        except Exception as e:
            return {"error": str(e)}
    
    async def find_definition(self, symbol: str, file_type: Optional[str] = None) -> List[Dict]:
        """Find definition of a symbol (function, class, variable)"""
        results = []
        
        # Simple grep-based search (can be enhanced with AST parsing)
        patterns = [
            f"def {symbol}",  # Python function
            f"class {symbol}",  # Python/JS class
            f"function {symbol}",  # JS function
            f"const {symbol} =",  # JS const
            f"let {symbol} =",  # JS let
        ]
        
        for pattern in patterns:
            try:
                cmd = ["grep", "-rn", pattern, str(self.project_root)]
                output = subprocess.check_output(
                    cmd,
                    text=True,
                    stderr=subprocess.DEVNULL
                )
                
                for line in output.strip().split("\n")[:10]:  # Limit results
                    if ":" in line:
                        parts = line.split(":", 2)
                        if len(parts) >= 3:
                            results.append({
                                "file": parts[0].replace(str(self.project_root) + "/", ""),
                                "line": int(parts[1]),
                                "content": parts[2].strip()
                            })
            except:
                continue
        
        return results
    
    async def get_file_structure(self, file_path: str) -> Dict:
        """Get structure of a file (functions, classes, etc.)"""
        full_path = self.project_root / file_path
        
        if not full_path.exists():
            return {"error": "File not found"}
        
        structure = {
            "path": file_path,
            "functions": [],
            "classes": [],
            "imports": []
        }
        
        try:
            content = full_path.read_text()
            lines = content.split("\n")
            
            for i, line in enumerate(lines):
                stripped = line.strip()
                
                # Python
                if stripped.startswith("def "):
                    func_name = stripped.split("(")[0].replace("def ", "")
                    structure["functions"].append({"name": func_name, "line": i + 1})
                elif stripped.startswith("class "):
                    class_name = stripped.split("(")[0].split(":")[0].replace("class ", "")
                    structure["classes"].append({"name": class_name, "line": i + 1})
                elif stripped.startswith("import ") or stripped.startswith("from "):
                    structure["imports"].append({"statement": stripped, "line": i + 1})
                
                # JavaScript/TypeScript
                elif "function " in stripped:
                    parts = stripped.split("function ")
                    if len(parts) > 1:
                        func_name = parts[1].split("(")[0].strip()
                        structure["functions"].append({"name": func_name, "line": i + 1})
            
            return structure
            
        except Exception as e:
            return {"error": str(e)}
    
    async def get_project_summary(self) -> Dict:
        """Get high-level project summary"""
        summary = {
            "root": str(self.project_root),
            "file_counts": {},
            "total_files": 0,
            "total_size": 0
        }
        
        for file_path in self.project_root.rglob("*"):
            if file_path.is_file():
                ext = file_path.suffix or "no_extension"
                summary["file_counts"][ext] = summary["file_counts"].get(ext, 0) + 1
                summary["total_files"] += 1
                summary["total_size"] += file_path.stat().st_size
        
        return summary
    
    async def handle_request(self, method: str, params: Dict) -> Dict:
        """Handle MCP JSON-RPC request"""
        
        handlers = {
            "context/search_files": lambda p: self.search_files(
                p["pattern"], p.get("file_types")
            ),
            "context/read_file": lambda p: self.read_file_content(
                p["file_path"], p.get("start_line", 0), p.get("end_line", -1)
            ),
            "context/find_definition": lambda p: self.find_definition(
                p["symbol"], p.get("file_type")
            ),
            "context/get_structure": lambda p: self.get_file_structure(p["file_path"]),
            "context/project_summary": lambda p: self.get_project_summary(),
        }
        
        handler = handlers.get(method)
        if not handler:
            return {"error": f"Unknown method: {method}"}
        
        try:
            result = await handler(params)
            return {"result": result}
        except Exception as e:
            logger.error(f"Error handling {method}: {e}")
            return {"error": str(e)}


async def run_server():
    """Run the MCP context server"""
    project_root = os.getenv("PROJECT_ROOT", ".")
    server = ContextServer(project_root)
    logger.info(f"Context MCP Server started for: {project_root}")
    
    # Simple stdin/stdout JSON-RPC protocol
    while True:
        try:
            line = await asyncio.get_event_loop().run_in_executor(None, input)
            if not line:
                continue
            
            request = json.loads(line)
            method = request.get("method")
            params = request.get("params", {})
            request_id = request.get("id")
            
            response = await server.handle_request(method, params)
            response["id"] = request_id
            response["jsonrpc"] = "2.0"
            
            print(json.dumps(response), flush=True)
            
        except EOFError:
            break
        except Exception as e:
            logger.error(f"Server error: {e}")


if __name__ == "__main__":
    asyncio.run(run_server())
