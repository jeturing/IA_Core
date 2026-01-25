#!/usr/bin/env python3
"""
IA_Core CLI - Command-line interface for managing the agent.

Commands:
  iacore status    - Show agent status
  iacore logs      - View agent logs  
  iacore config    - Configure settings
  iacore pause     - Pause agent
  iacore resume    - Resume agent
  iacore uninstall - Remove IA_Core
"""

import json
import sys
from pathlib import Path
from typing import Optional

import requests
import typer
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

app = typer.Typer(help="IA_Core - Autonomous AI Orchestration")
console = Console()

# Configuration
API_URL = "http://127.0.0.1:8788"
HOME_DIR = Path.home() / ".iacore"


@app.command()
def status():
    """Show agent and system status."""
    console.print("\n[bold cyan]IA_Core Status[/bold cyan]\n")
    
    # Check if agent is running
    try:
        r = requests.get(f"{API_URL}/status", timeout=2)
        data = r.json()
        
        # Create status table
        table = Table(show_header=False)
        table.add_column("Property", style="cyan")
        table.add_column("Value")
        
        running_icon = "✅" if data["running"] else "⏸️"
        table.add_row("Status", f"{running_icon} {'Running' if data['running'] else 'Paused'}")
        table.add_row("Project", data["project_root"])
        table.add_row("Type", data["project_type"])
        table.add_row("Last Analysis", data["last_analysis"] or "Never")
        
        console.print(table)
        
    except requests.exceptions.ConnectionError:
        console.print("[red]❌ Agent not running[/red]")
        console.print("\n[yellow]Start the agent with:[/yellow]")
        console.print("  cd your-project && iacore start")
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")


@app.command()
def logs(
    follow: bool = typer.Option(False, "--follow", "-f", help="Follow log output"),
    lines: int = typer.Option(50, "--lines", "-n", help="Number of lines to show"),
):
    """View agent logs."""
    log_file = HOME_DIR / "runtime" / "agent.log"
    
    if not log_file.exists():
        console.print("[yellow]No logs found[/yellow]")
        return
    
    if follow:
        # Follow logs (tail -f)
        import subprocess
        subprocess.run(["tail", "-f", str(log_file)])
    else:
        # Show last N lines
        with open(log_file) as f:
            all_lines = f.readlines()
            for line in all_lines[-lines:]:
                console.print(line.rstrip())


@app.command()
def pause():
    """Pause the agent."""
    try:
        r = requests.post(f"{API_URL}/agent/pause")
        console.print("[yellow]⏸️  Agent paused[/yellow]")
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")


@app.command()
def resume():
    """Resume the agent."""
    try:
        r = requests.post(f"{API_URL}/agent/resume")
        console.print("[green]▶️  Agent resumed[/green]")
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")


@app.command()
def config():
    """Show and edit configuration."""
    config_file = Path(".iacore/config.yml")
    
    if not config_file.exists():
        console.print("[yellow]No config file found in this project[/yellow]")
        return
    
    console.print(f"\n[cyan]Config:[/cyan] {config_file}\n")
    
    with open(config_file) as f:
        console.print(f.read())
    
    if typer.confirm("\nEdit config?"):
        import subprocess
        editor = os.getenv("EDITOR", "nano")
        subprocess.run([editor, str(config_file)])


@app.command()
def analyze():
    """Trigger manual project analysis."""
    console.print("[cyan]Analyzing project...[/cyan]")
    
    try:
        r = requests.post(f"{API_URL}/analyze")
        data = r.json()
        console.print(f"[green]✓ Analysis complete[/green]")
        console.print(f"Timestamp: {data['timestamp']}")
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")


@app.command()
def uninstall():
    """Uninstall IA_Core."""
    if not typer.confirm("⚠️  Remove IA_Core from this project?"):
        return
    
    # Stop agent
    try:
        requests.post(f"{API_URL}/agent/pause")
    except:
        pass
    
    # Remove .iacore directory
    import shutil
    iacore_dir = Path(".iacore")
    if iacore_dir.exists():
        shutil.rmtree(iacore_dir)
        console.print("[green]✓ Removed .iacore directory[/green]")
    
    # Remove from .gitignore
    gitignore = Path(".gitignore")
    if gitignore.exists():
        lines = gitignore.read_text().split("\n")
        lines = [l for l in lines if ".iacore" not in l]
        gitignore.write_text("\n".join(lines))
        console.print("[green]✓ Updated .gitignore[/green]")
    
    console.print("\n[yellow]To completely remove IA_Core, also run:[/yellow]")
    console.print(f"  rm -rf {HOME_DIR}")


@app.command()
def version():
    """Show IA_Core version."""
    from iacore import __version__
    console.print(f"IA_Core version {__version__}")


if __name__ == "__main__":
    import os
    app()
