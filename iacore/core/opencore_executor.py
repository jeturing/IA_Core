"""
OpenCore Executor - Executes commands silently via OpenCore.

Provides isolated, sandboxed execution without showing output to user.
"""

import asyncio
import logging
import shlex
import subprocess
from pathlib import Path
from typing import Dict, List, Optional

logger = logging.getLogger(__name__)


class OpenCoreExecutor:
    """
    Executes commands via OpenCore in silent mode.
    
    Commands run in a sandbox and output is captured but not displayed.
    """

    def __init__(
        self,
        project_root: Path | str,
        silent_mode: bool = True,
        timeout: int = 300,
    ):
        self.project_root = Path(project_root).resolve()
        self.silent_mode = silent_mode
        self.timeout = timeout
        
        logger.info(f"OpenCoreExecutor initialized (silent={silent_mode})")

    async def execute(
        self,
        command: str,
        silent: bool = None,
        cwd: Optional[Path] = None,
    ) -> Dict:
        """
        Execute a command.
        
        Args:
            command: Shell command to execute
            silent: Override silent_mode for this command
            cwd: Working directory (defaults to project_root)
            
        Returns:
            {
                "success": bool,
                "output": str,
                "error": str,
                "exit_code": int,
            }
        """
        silent = silent if silent is not None else self.silent_mode
        cwd = cwd or self.project_root
        
        if silent:
            logger.debug(f"Executing (silent): {command[:50]}...")
        else:
            logger.info(f"Executing: {command}")
        
        try:
            # Use OpenCore if available, otherwise fallback to subprocess
            if await self._opencore_available():
                return await self._execute_via_opencore(command, cwd)
            else:
                return await self._execute_via_subprocess(command, cwd)
                
        except Exception as e:
            logger.error(f"Execution error: {e}")
            return {
                "success": False,
                "output": "",
                "error": str(e),
                "exit_code": -1,
            }

    async def _opencore_available(self) -> bool:
        """Check if OpenCore is available."""
        try:
            result = await asyncio.create_subprocess_exec(
                "which", "opencore",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            await result.wait()
            return result.returncode == 0
        except:
            return False

    async def _execute_via_opencore(self, command: str, cwd: Path) -> Dict:
        """Execute via OpenCore (preferred method)."""
        # OpenCore syntax: opencore exec --silent --sandbox <command>
        args = ["opencore", "exec", "--silent", "--sandbox", "--cwd", str(cwd), "--", command]
        
        process = await asyncio.create_subprocess_exec(
            *args,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        
        try:
            stdout, stderr = await asyncio.wait_for(
                process.communicate(),
                timeout=self.timeout,
            )
            
            return {
                "success": process.returncode == 0,
                "output": stdout.decode("utf-8", errors="ignore"),
                "error": stderr.decode("utf-8", errors="ignore"),
                "exit_code": process.returncode,
            }
            
        except asyncio.TimeoutError:
            process.kill()
            return {
                "success": False,
                "output": "",
                "error": f"Command timed out after {self.timeout}s",
                "exit_code": -1,
            }

    async def _execute_via_subprocess(self, command: str, cwd: Path) -> Dict:
        """Fallback: Execute via subprocess."""
        logger.debug("OpenCore not available, using subprocess fallback")
        
        process = await asyncio.create_subprocess_shell(
            command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd=str(cwd),
        )
        
        try:
            stdout, stderr = await asyncio.wait_for(
                process.communicate(),
                timeout=self.timeout,
            )
            
            return {
                "success": process.returncode == 0,
                "output": stdout.decode("utf-8", errors="ignore"),
                "error": stderr.decode("utf-8", errors="ignore"),
                "exit_code": process.returncode,
            }
            
        except asyncio.TimeoutError:
            process.kill()
            return {
                "success": False,
                "output": "",
                "error": f"Command timed out after {self.timeout}s",
                "exit_code": -1,
            }

    async def execute_batch(
        self,
        commands: List[str],
        stop_on_error: bool = True,
    ) -> List[Dict]:
        """Execute multiple commands."""
        results = []
        
        for cmd in commands:
            result = await self.execute(cmd)
            results.append(result)
            
            if stop_on_error and not result["success"]:
                logger.error(f"Command failed, stopping batch: {cmd}")
                break
        
        return results

    def is_safe_command(self, command: str) -> bool:
        """Check if command is safe to execute."""
        # Blacklist dangerous commands
        dangerous = [
            "rm -rf /",
            "dd if=",
            "mkfs",
            ":(){ :|:& };:",  # Fork bomb
            "curl | sh",
            "wget | sh",
        ]
        
        cmd_lower = command.lower()
        for dangerous_pattern in dangerous:
            if dangerous_pattern in cmd_lower:
                logger.error(f"Blocked dangerous command: {command}")
                return False
        
        return True
