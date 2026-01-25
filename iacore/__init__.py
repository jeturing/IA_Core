"""
IA_Core - Autonomous AI Orchestration Layer

A self-contained AI agent that integrates into any project and provides
intelligent orchestration using GPT-4o-mini and OpenCore.
"""

__version__ = "0.1.0"
__author__ = "IA_Core Team"
__license__ = "MIT"

from .core.detector import ProjectDetector
from .core.analyzer import IntelligentAnalyzer
from .agent.autonomous import AutonomousAgent
from .api.server import APIServer

__all__ = [
    "ProjectDetector",
    "IntelligentAnalyzer",
    "AutonomousAgent",
    "APIServer",
]
