#!/usr/bin/env python3
"""
Tools MCP Server - Executable tools for agents
Provides safe command execution and code modification capabilities
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


class ToolsServer:
    """MCP server for executable tools"""
    
    def __init__(self, project_root: Optional[Path] = None):
        self.project_root = Path(project_root or os.getenv("PROJECT_ROOT", "."))
        self.command_history: List[Dict] = []
        logger.info(f"Tools server initialized for: {self.project_root}")
    
    async def execute_command(
        self, 
        command: str, 
        cwd: Optional[str] = None,
        timeout: int = 30
    ) -> Dict:
        """Execute a shell command safely"""
        
        # Blacklist dangerous commands
        dangerous = ["rm -rf", "sudo", "shutdown", "reboot", "> /dev/"]
        if any(d in command for d in dangerous):
            return {"error": "Command blocked for safety", "command": command}
        
        work_dir = self.project_root / cwd if cwd else self.project_root
        
        try:
            result = subprocess.run(
                command,
                shell=True,
                cwd=work_dir,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            
            output = {
                "command": command,
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "success": result.returncode == 0
            }
            
            self.command_history.append(output)
            return output
            
        except subprocess.TimeoutExpired:
            return {"error": "Command timed out", "command": command}
        except Exception as e:
            return {"error": str(e), "command": command}
    
    async def write_file(self, file_path: str, content: str, mode: str = "w") -> Dict:
        """Write content to a file"""
        full_path = self.project_root / file_path
        
        try:
            # Create parent directories
            full_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Write file
            with open(full_path, mode) as f:
                f.write(content)
            
            return {
                "success": True,
                "path": file_path,
                "size": len(content)
            }
        except Exception as e:
            return {"error": str(e), "path": file_path}
    
    async def search_code(self, pattern: str, file_pattern: str = "*") -> Dict:
        """Search code for a pattern"""
        try:
            cmd = ["grep", "-rn", pattern, str(self.project_root)]
            output = subprocess.check_output(
                cmd,
                text=True,
                stderr=subprocess.DEVNULL
            )
            
            results = []
            for line in output.strip().split("\n")[:50]:  # Limit results
                if ":" in line:
                    parts = line.split(":", 2)
                    if len(parts) >= 3:
                        results.append({
                            "file": parts[0].replace(str(self.project_root) + "/", ""),
                            "line": int(parts[1]),
                            "content": parts[2].strip()
                        })
            
            return {"results": results, "count": len(results)}
            
        except subprocess.CalledProcessError:
            return {"results": [], "count": 0}
        except Exception as e:
            return {"error": str(e)}
    
    async def analyze_dependencies(self) -> Dict:
        """Analyze project dependencies"""
        deps = {
            "package_managers": [],
            "dependencies": {},
            "dev_dependencies": {}
        }
        
        # Check for package.json (npm/yarn)
        package_json = self.project_root / "package.json"
        if package_json.exists():
            deps["package_managers"].append("npm")
            try:
                pkg_data = json.loads(package_json.read_text())
                deps["dependencies"]["npm"] = list(pkg_data.get("dependencies", {}).keys())
                deps["dev_dependencies"]["npm"] = list(pkg_data.get("devDependencies", {}).keys())
            except:
                pass
        
        # Check for requirements.txt (pip)
        requirements = self.project_root / "requirements.txt"
        if requirements.exists():
            deps["package_managers"].append("pip")
            try:
                reqs = requirements.read_text().strip().split("\n")
                deps["dependencies"]["pip"] = [r.split("==")[0].split(">=")[0] for r in reqs if r]
            except:
                pass
        
        # Check for Cargo.toml (Rust)
        cargo = self.project_root / "Cargo.toml"
        if cargo.exists():
            deps["package_managers"].append("cargo")
        
        # Check for go.mod (Go)
        go_mod = self.project_root / "go.mod"
        if go_mod.exists():
            deps["package_managers"].append("go")
        
        return deps
    
    async def get_command_history(self, limit: int = 10) -> List[Dict]:
        """Get recent command history"""
        return self.command_history[-limit:]
    
    async def handle_request(self, method: str, params: Dict) -> Dict:
        """Handle MCP JSON-RPC request"""
        
        handlers = {
            "tools/execute_command": lambda p: self.execute_command(
                p["command"], p.get("cwd"), p.get("timeout", 30)
            ),
            "tools/write_file": lambda p: self.write_file(
                p["file_path"], p["content"], p.get("mode", "w")
            ),
            "tools/search_code": lambda p: self.search_code(
                p["pattern"], p.get("file_pattern", "*")
            ),
            "tools/analyze_dependencies": lambda p: self.analyze_dependencies(),
            "tools/command_history": lambda p: self.get_command_history(p.get("limit", 10)),
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
    """Run the MCP tools server"""
    project_root = os.getenv("PROJECT_ROOT", ".")
    server = ToolsServer(project_root)
    logger.info(f"Tools MCP Server started for: {project_root}")
    
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
