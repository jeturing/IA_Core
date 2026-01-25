"""
Intelligent Analyzer - Uses LLM to understand project context.
"""

import asyncio
import logging
from pathlib import Path
from typing import Dict, Any, Optional

from .llm_client import LLMClient
from .detector import ProjectDetector

logger = logging.getLogger(__name__)


class IntelligentAnalyzer:
    """Analyzes projects using LLM intelligence."""

    def __init__(self, llm_model: str = "gpt-4o-mini"):
        self.llm = LLMClient(model=llm_model)

    async def analyze_project(
        self,
        project_root: Path,
        project_type: str,
    ) -> Dict[str, Any]:
        """
        Perform deep analysis of the project.
        
        Returns insights, suggestions, and action items.
        """
        detector = ProjectDetector(project_root)
        file_tree = detector.get_file_tree(max_depth=2)
        
        prompt = f"""Analyze this {project_type} project:

PROJECT STRUCTURE:
{chr(10).join(file_tree[:50])}

Provide analysis in JSON format:
{{
  "insights": ["insight1", "insight2", ...],
  "suggestions": ["suggestion1", ...],
  "priorities": ["high priority task1", ...],
  "risks": ["potential risk1", ...]
}}

JSON:"""
        
        response = await self.llm.complete(prompt, max_tokens=400, temperature=0.5)
        
        try:
            import json
            json_start = response.find("{")
            json_end = response.rfind("}") + 1
            if json_start >= 0 and json_end > json_start:
                return json.loads(response[json_start:json_end])
        except Exception as e:
            logger.error(f"Failed to parse LLM response: {e}")
        
        return {
            "insights": [],
            "suggestions": [],
            "priorities": [],
            "risks": [],
        }

    async def analyze_file_change(
        self,
        file_path: str,
        event_type: str,
        context: Dict,
    ) -> Dict[str, Any]:
        """Analyze impact of a file change."""
        prompt = f"""A file was {event_type}:

File: {file_path}
Project: {context.get('project_type', 'unknown')}

Assess the impact (JSON):
{{
  "severity": "low|medium|high",
  "affected_components": [...],
  "required_actions": [...]
}}

JSON:"""
        
        response = await self.llm.complete(prompt, max_tokens=200, temperature=0.3)
        
        try:
            import json
            json_start = response.find("{")
            json_end = response.rfind("}") + 1
            if json_start >= 0:
                return json.loads(response[json_start:json_end])
        except:
            pass
        
        return {
            "severity": "low",
            "affected_components": [],
            "required_actions": [],
        }
