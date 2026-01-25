#!/usr/bin/env python3
"""
Memory MCP Server - Persistent memory for agents
Stores and retrieves information across sessions
"""

import asyncio
import json
import logging
from pathlib import Path
from typing import Dict, List, Any, Optional
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class MemoryServer:
    """MCP server for agent memory management"""
    
    def __init__(self, storage_path: Optional[Path] = None):
        self.storage_path = storage_path or Path.home() / ".iacore" / "memory"
        self.storage_path.mkdir(parents=True, exist_ok=True)
        self.memory_file = self.storage_path / "agent_memory.json"
        self.memory: Dict[str, Any] = self._load_memory()
        
    def _load_memory(self) -> Dict[str, Any]:
        """Load memory from disk"""
        if self.memory_file.exists():
            try:
                return json.loads(self.memory_file.read_text())
            except Exception as e:
                logger.error(f"Failed to load memory: {e}")
        
        return {
            "facts": {},
            "decisions": [],
            "learnings": [],
            "project_context": {},
            "created_at": datetime.now().isoformat()
        }
    
    def _save_memory(self):
        """Persist memory to disk"""
        try:
            self.memory_file.write_text(json.dumps(self.memory, indent=2))
        except Exception as e:
            logger.error(f"Failed to save memory: {e}")
    
    async def store_fact(self, key: str, value: Any) -> Dict[str, str]:
        """Store a fact in memory"""
        self.memory["facts"][key] = {
            "value": value,
            "timestamp": datetime.now().isoformat()
        }
        self._save_memory()
        return {"status": "stored", "key": key}
    
    async def retrieve_fact(self, key: str) -> Optional[Any]:
        """Retrieve a fact from memory"""
        fact = self.memory["facts"].get(key)
        return fact["value"] if fact else None
    
    async def store_decision(self, decision: str, reasoning: str, outcome: Optional[str] = None):
        """Store a decision made by the agent"""
        self.memory["decisions"].append({
            "decision": decision,
            "reasoning": reasoning,
            "outcome": outcome,
            "timestamp": datetime.now().isoformat()
        })
        self._save_memory()
        return {"status": "decision_recorded"}
    
    async def store_learning(self, lesson: str, context: str):
        """Store a learning from experience"""
        self.memory["learnings"].append({
            "lesson": lesson,
            "context": context,
            "timestamp": datetime.now().isoformat()
        })
        self._save_memory()
        return {"status": "learning_recorded"}
    
    async def get_relevant_learnings(self, context: str) -> List[Dict]:
        """Get learnings relevant to current context"""
        # Simple keyword matching for now
        keywords = set(context.lower().split())
        relevant = []
        
        for learning in self.memory["learnings"]:
            learning_keywords = set(learning["context"].lower().split())
            if keywords & learning_keywords:  # Intersection
                relevant.append(learning)
        
        return relevant[-10:]  # Last 10 relevant learnings
    
    async def update_project_context(self, key: str, value: Any):
        """Update project-specific context"""
        self.memory["project_context"][key] = {
            "value": value,
            "updated_at": datetime.now().isoformat()
        }
        self._save_memory()
        return {"status": "context_updated"}
    
    async def get_project_context(self) -> Dict[str, Any]:
        """Get all project context"""
        return self.memory["project_context"]
    
    async def handle_request(self, method: str, params: Dict) -> Dict:
        """Handle MCP JSON-RPC request"""
        
        handlers = {
            "memory/store_fact": lambda p: self.store_fact(p["key"], p["value"]),
            "memory/retrieve_fact": lambda p: self.retrieve_fact(p["key"]),
            "memory/store_decision": lambda p: self.store_decision(
                p["decision"], p["reasoning"], p.get("outcome")
            ),
            "memory/store_learning": lambda p: self.store_learning(
                p["lesson"], p["context"]
            ),
            "memory/get_learnings": lambda p: self.get_relevant_learnings(p["context"]),
            "memory/update_context": lambda p: self.update_project_context(
                p["key"], p["value"]
            ),
            "memory/get_context": lambda p: self.get_project_context(),
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
    """Run the MCP memory server"""
    server = MemoryServer()
    logger.info("Memory MCP Server started")
    
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
