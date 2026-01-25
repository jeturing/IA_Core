"""
Autonomous Agent - Intelligent project assistant using GPT-4o-mini.

This agent:
1. Analyzes the project continuously
2. Understands context via GPT-4o-mini
3. Executes tasks via OpenCore (silent mode)
4. Learns from interactions
5. Operates transparently without user intervention
"""

import asyncio
import json
import logging
import os
import signal
import sys
from pathlib import Path
from typing import Dict, List, Optional, Any
from datetime import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileSystemEvent

from ..core.detector import ProjectDetector
from ..core.analyzer import IntelligentAnalyzer
from ..core.llm_client import LLMClient
from ..core.opencore_executor import OpenCoreExecutor
from ..utils.logger import setup_logger


logger = setup_logger(__name__)


class AutonomousAgent:
    """
    Autonomous agent that manages a project intelligently.
    
    The agent:
    - Watches file changes
    - Analyzes context with GPT-4o-mini
    - Executes commands via OpenCore (silent)
    - Learns and improves over time
    """

    def __init__(
        self,
        project_root: str | Path,
        config_path: Optional[str | Path] = None,
    ):
        self.project_root = Path(project_root).resolve()
        self.config_path = Path(config_path) if config_path else self.project_root / ".iacore" / "config.yml"
        
        # Load configuration
        self.config = self._load_config()
        
        # Initialize components
        self.detector = ProjectDetector(self.project_root)
        self.analyzer = IntelligentAnalyzer(
            llm_model=self.config.get("llm", {}).get("model", "gpt-4o-mini")
        )
        self.llm = LLMClient(
            model=self.config.get("llm", {}).get("model", "gpt-4o-mini"),
            provider=self.config.get("llm", {}).get("provider", "openai"),
        )
        self.executor = OpenCoreExecutor(
            project_root=self.project_root,
            silent_mode=True,
        )
        
        # State
        self.running = False
        self.context_cache: Dict[str, Any] = {}
        self.last_analysis: Optional[datetime] = None
        
        # File watcher
        self.observer: Optional[Observer] = None
        
        logger.info(f"AutonomousAgent initialized for: {self.project_root}")

    def _load_config(self) -> Dict:
        """Load configuration from .iacore/config.yml."""
        if not self.config_path.exists():
            return self._default_config()
        
        import yaml
        with open(self.config_path) as f:
            return yaml.safe_load(f)

    def _default_config(self) -> Dict:
        """Default configuration."""
        return {
            "agent": {
                "enabled": True,
                "auto_analyze": True,
                "auto_execute": False,
                "watch_mode": True,
            },
            "llm": {
                "provider": "openai",
                "model": "gpt-4o-mini",
            },
            "workflows": {
                "on_file_change": ["detect_impact", "analyze_context"],
                "on_git_commit": ["analyze_commit", "suggest_improvements"],
            },
        }

    async def start(self):
        """Start the autonomous agent."""
        logger.info("🚀 Starting AutonomousAgent...")
        
        self.running = True
        
        # Initial project analysis
        await self._initial_analysis()
        
        # Start file watcher if enabled
        if self.config.get("agent", {}).get("watch_mode", True):
            self._start_file_watcher()
        
        # Main loop
        try:
            await self._main_loop()
        except KeyboardInterrupt:
            logger.info("Received interrupt signal")
        finally:
            await self.stop()

    async def stop(self):
        """Stop the agent gracefully."""
        logger.info("🛑 Stopping AutonomousAgent...")
        
        self.running = False
        
        if self.observer:
            self.observer.stop()
            self.observer.join()
        
        logger.info("Agent stopped")

    async def _initial_analysis(self):
        """Perform initial project analysis."""
        logger.info("📊 Analyzing project...")
        
        # Detect project type
        detection = self.detector.detect()
        logger.info(f"Detected: {detection['type']} (confidence: {detection['confidence']:.0%})")
        
        # Store in context
        self.context_cache["project_type"] = detection["type"]
        self.context_cache["project_files"] = detection.get("files", [])
        
        # Analyze with LLM
        analysis = await self.analyzer.analyze_project(
            project_root=self.project_root,
            project_type=detection["type"],
        )
        
        self.context_cache["analysis"] = analysis
        self.last_analysis = datetime.now()
        
        logger.info(f"✓ Analysis complete: {len(analysis.get('insights', []))} insights")

    async def _main_loop(self):
        """Main agent loop - processes tasks and monitors."""
        logger.info("👁️  Monitoring project...")
        
        while self.running:
            try:
                # Check for pending tasks
                await self._process_pending_tasks()
                
                # Periodic re-analysis
                if self._should_reanalyze():
                    await self._initial_analysis()
                
                # Sleep
                await asyncio.sleep(5)
                
            except Exception as e:
                logger.error(f"Error in main loop: {e}", exc_info=True)
                await asyncio.sleep(10)

    async def _process_pending_tasks(self):
        """Process any pending tasks in the queue."""
        tasks_file = self.project_root / ".iacore" / "runtime" / "tasks.json"
        
        if not tasks_file.exists():
            return
        
        with open(tasks_file) as f:
            tasks = json.load(f)
        
        for task in tasks:
            if task.get("status") == "pending":
                await self._execute_task(task)

    async def _execute_task(self, task: Dict):
        """Execute a task using GPT-4o-mini + OpenCore."""
        logger.info(f"⚡ Executing task: {task['description']}")
        
        # Get execution plan from LLM
        prompt = self._build_execution_prompt(task)
        response = await self.llm.complete(prompt)
        
        # Parse commands from LLM response
        commands = self._parse_commands(response)
        
        # Execute via OpenCore (silent mode)
        for cmd in commands:
            result = await self.executor.execute(cmd, silent=True)
            
            if result["success"]:
                logger.info(f"✓ Command executed: {cmd[:50]}...")
            else:
                logger.error(f"✗ Command failed: {cmd}")
                
                # Ask LLM for fallback
                fallback = await self._get_fallback_strategy(cmd, result["error"])
                if fallback:
                    await self.executor.execute(fallback, silent=True)

    def _build_execution_prompt(self, task: Dict) -> str:
        """Build prompt for GPT-4o-mini to generate execution plan."""
        context = self.context_cache.get("analysis", {})
        
        return f"""You are an AI agent managing a {self.context_cache.get('project_type')} project.

PROJECT CONTEXT:
{json.dumps(context, indent=2)}

TASK:
{task['description']}

Generate a list of shell commands to complete this task.
Return ONLY the commands, one per line, with no explanation.
Commands will be executed silently via OpenCore.

COMMANDS:"""

    def _parse_commands(self, llm_response: str) -> List[str]:
        """Parse commands from LLM response."""
        lines = llm_response.strip().split("\n")
        commands = []
        
        for line in lines:
            line = line.strip()
            # Skip empty lines and comments
            if not line or line.startswith("#"):
                continue
            # Remove markdown code block markers
            if line.startswith("```"):
                continue
            commands.append(line)
        
        return commands

    async def _get_fallback_strategy(self, failed_cmd: str, error: str) -> Optional[str]:
        """Ask LLM for fallback strategy when command fails."""
        prompt = f"""The command failed:
Command: {failed_cmd}
Error: {error}

Provide ONE alternative command to achieve the same goal, or return "SKIP" if not possible.
ALTERNATIVE:"""
        
        response = await self.llm.complete(prompt)
        fallback = response.strip()
        
        return fallback if fallback != "SKIP" else None

    def _should_reanalyze(self) -> bool:
        """Determine if we should re-analyze the project."""
        if not self.last_analysis:
            return True
        
        # Re-analyze every 30 minutes
        elapsed = (datetime.now() - self.last_analysis).total_seconds()
        return elapsed > 1800

    def _start_file_watcher(self):
        """Start watching file changes."""
        event_handler = ProjectFileHandler(self)
        self.observer = Observer()
        self.observer.schedule(event_handler, str(self.project_root), recursive=True)
        self.observer.start()
        
        logger.info("📁 File watcher started")

    async def on_file_change(self, path: str, event_type: str):
        """Handle file change event."""
        logger.debug(f"File {event_type}: {path}")
        
        # Skip ignored patterns
        if self._should_ignore(path):
            return
        
        # Analyze impact
        impact = await self.analyzer.analyze_file_change(
            file_path=path,
            event_type=event_type,
            context=self.context_cache,
        )
        
        if impact.get("severity") == "high":
            logger.warning(f"⚠️  High impact change detected in {path}")
            
            # Execute configured workflow
            workflow = self.config.get("workflows", {}).get("on_file_change", [])
            for action in workflow:
                await self._execute_workflow_action(action, {"file": path, "impact": impact})

    def _should_ignore(self, path: str) -> bool:
        """Check if file should be ignored."""
        ignore_patterns = self.config.get("agent", {}).get("ignore_patterns", [
            "node_modules/**",
            ".git/**",
            "__pycache__/**",
            "*.pyc",
            ".iacore/runtime/**",
        ])
        
        from pathlib import Path
        path_obj = Path(path)
        
        for pattern in ignore_patterns:
            if path_obj.match(pattern):
                return True
        
        return False

    async def _execute_workflow_action(self, action: str, data: Dict):
        """Execute a workflow action."""
        logger.info(f"🔄 Workflow action: {action}")
        
        # Map actions to methods
        actions_map = {
            "detect_impact": self._action_detect_impact,
            "analyze_context": self._action_analyze_context,
            "analyze_commit": self._action_analyze_commit,
            "suggest_improvements": self._action_suggest_improvements,
        }
        
        handler = actions_map.get(action)
        if handler:
            await handler(data)
        else:
            logger.warning(f"Unknown action: {action}")

    async def _action_detect_impact(self, data: Dict):
        """Action: Detect impact of change."""
        # Already done in on_file_change
        pass

    async def _action_analyze_context(self, data: Dict):
        """Action: Analyze full context."""
        await self._initial_analysis()

    async def _action_analyze_commit(self, data: Dict):
        """Action: Analyze git commit."""
        # Get last commit info
        result = await self.executor.execute("git log -1 --pretty=format:'%H %s'", silent=True)
        if result["success"]:
            commit_info = result["output"]
            logger.info(f"📝 Last commit: {commit_info}")

    async def _action_suggest_improvements(self, data: Dict):
        """Action: Suggest improvements via LLM."""
        prompt = f"""Analyze this code change and suggest improvements:

File: {data.get('file')}
Impact: {json.dumps(data.get('impact', {}))}

Provide 3 concrete suggestions for improvement.
SUGGESTIONS:"""
        
        suggestions = await self.llm.complete(prompt)
        logger.info(f"💡 Suggestions:\n{suggestions}")


class ProjectFileHandler(FileSystemEventHandler):
    """Handler for file system events."""

    def __init__(self, agent: AutonomousAgent):
        self.agent = agent

    def on_modified(self, event: FileSystemEvent):
        if not event.is_directory:
            asyncio.create_task(
                self.agent.on_file_change(event.src_path, "modified")
            )

    def on_created(self, event: FileSystemEvent):
        if not event.is_directory:
            asyncio.create_task(
                self.agent.on_file_change(event.src_path, "created")
            )

    def on_deleted(self, event: FileSystemEvent):
        if not event.is_directory:
            asyncio.create_task(
                self.agent.on_file_change(event.src_path, "deleted")
            )


# CLI entry point
async def main():
    """Main entry point for autonomous agent."""
    import argparse
    
    parser = argparse.ArgumentParser(description="IA_Core Autonomous Agent")
    parser.add_argument("--project-root", required=True, help="Project root directory")
    parser.add_argument("--config", help="Config file path")
    args = parser.parse_args()
    
    agent = AutonomousAgent(
        project_root=args.project_root,
        config_path=args.config,
    )
    
    # Handle signals
    loop = asyncio.get_event_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, lambda: asyncio.create_task(agent.stop()))
    
    # Start agent
    await agent.start()


if __name__ == "__main__":
    asyncio.run(main())
