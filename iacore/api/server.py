"""
FastAPI Server - REST API for IA_Core orchestration.

Provides endpoints to control the agent and query status.
"""

import asyncio
import logging
from pathlib import Path
from typing import Dict, List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from ..agent.autonomous import AutonomousAgent
from ..core.detector import ProjectDetector
from ..utils.logger import setup_logger

logger = setup_logger(__name__)

# Create FastAPI app
app = FastAPI(
    title="IA_Core API",
    description="Autonomous AI Orchestration Layer",
    version="0.1.0",
)

# Global agent instance
agent_instance: Optional[AutonomousAgent] = None


# Request/Response models
class AgentStatus(BaseModel):
    running: bool
    project_root: str
    project_type: str
    last_analysis: Optional[str]


class TaskRequest(BaseModel):
    description: str
    auto_execute: bool = False


class TaskResponse(BaseModel):
    task_id: str
    status: str


# Endpoints
@app.get("/health")
async def health():
    """Health check."""
    return {"status": "ok", "service": "IA_Core API"}


@app.get("/status", response_model=AgentStatus)
async def get_status():
    """Get agent status."""
    if not agent_instance:
        raise HTTPException(status_code=503, detail="Agent not initialized")
    
    return AgentStatus(
        running=agent_instance.running,
        project_root=str(agent_instance.project_root),
        project_type=agent_instance.context_cache.get("project_type", "unknown"),
        last_analysis=agent_instance.last_analysis.isoformat() if agent_instance.last_analysis else None,
    )


@app.post("/tasks", response_model=TaskResponse)
async def create_task(task: TaskRequest):
    """Create a new task for the agent."""
    import uuid
    
    task_id = str(uuid.uuid4())[:8]
    
    # Save task to queue
    tasks_file = Path(agent_instance.project_root) / ".iacore" / "runtime" / "tasks.json"
    tasks_file.parent.mkdir(parents=True, exist_ok=True)
    
    import json
    tasks = []
    if tasks_file.exists():
        tasks = json.loads(tasks_file.read_text())
    
    tasks.append({
        "id": task_id,
        "description": task.description,
        "status": "pending",
        "auto_execute": task.auto_execute,
        "created_at": str(asyncio.get_event_loop().time()),
    })
    
    tasks_file.write_text(json.dumps(tasks, indent=2))
    
    logger.info(f"Task created: {task_id}")
    
    return TaskResponse(task_id=task_id, status="pending")


@app.get("/tasks/{task_id}")
async def get_task(task_id: str):
    """Get task status."""
    tasks_file = Path(agent_instance.project_root) / ".iacore" / "runtime" / "tasks.json"
    
    if not tasks_file.exists():
        raise HTTPException(status_code=404, detail="Task not found")
    
    import json
    tasks = json.loads(tasks_file.read_text())
    
    task = next((t for t in tasks if t["id"] == task_id), None)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return task


@app.get("/analysis")
async def get_analysis():
    """Get latest project analysis."""
    if not agent_instance:
        raise HTTPException(status_code=503, detail="Agent not initialized")
    
    return agent_instance.context_cache.get("analysis", {})


@app.post("/analyze")
async def trigger_analysis():
    """Trigger manual project analysis."""
    if not agent_instance:
        raise HTTPException(status_code=503, detail="Agent not initialized")
    
    await agent_instance._initial_analysis()
    
    return {"status": "completed", "timestamp": agent_instance.last_analysis.isoformat()}


@app.post("/agent/pause")
async def pause_agent():
    """Pause the agent."""
    if not agent_instance:
        raise HTTPException(status_code=503, detail="Agent not initialized")
    
    agent_instance.running = False
    
    return {"status": "paused"}


@app.post("/agent/resume")
async def resume_agent():
    """Resume the agent."""
    if not agent_instance:
        raise HTTPException(status_code=503, detail="Agent not initialized")
    
    agent_instance.running = True
    
    return {"status": "resumed"}


# Startup/Shutdown
@app.on_event("startup")
async def startup():
    """Initialize the agent on startup."""
    global agent_instance
    
    import os
    project_root = os.getenv("IA_CORE_PROJECT_ROOT", ".")
    config_path = os.getenv("IA_CORE_CONFIG")
    
    logger.info(f"Starting IA_Core API for project: {project_root}")
    
    agent_instance = AutonomousAgent(
        project_root=project_root,
        config_path=config_path,
    )
    
    # Start agent in background
    asyncio.create_task(agent_instance.start())


@app.on_event("shutdown")
async def shutdown():
    """Shutdown the agent gracefully."""
    if agent_instance:
        await agent_instance.stop()


# CLI entry point
def main():
    """Run the API server."""
    import argparse
    import uvicorn
    
    parser = argparse.ArgumentParser(description="IA_Core API Server")
    parser.add_argument("--host", default="127.0.0.1", help="Host to bind")
    parser.add_argument("--port", type=int, default=8788, help="Port to bind")
    parser.add_argument("--project-root", required=True, help="Project root directory")
    parser.add_argument("--config", help="Config file path")
    args = parser.parse_args()
    
    # Set environment variables for startup event
    import os
    os.environ["IA_CORE_PROJECT_ROOT"] = args.project_root
    if args.config:
        os.environ["IA_CORE_CONFIG"] = args.config
    
    # Run server
    uvicorn.run(
        app,
        host=args.host,
        port=args.port,
        log_level="info",
    )


if __name__ == "__main__":
    main()
