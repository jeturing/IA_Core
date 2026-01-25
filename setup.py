from setuptools import setup, find_packages
from pathlib import Path

# Read README
readme = Path("README.md").read_text(encoding="utf-8")

# Read requirements
requirements = Path("requirements.txt").read_text().splitlines()
requirements = [r for r in requirements if r and not r.startswith("#")]

setup(
    name="iacore",
    version="0.1.0",
    author="IA_Core Team",
    author_email="team@iacore.dev",
    description="Autonomous AI Orchestration Layer for any project",
    long_description=readme,
    long_description_content_type="text/markdown",
    url="https://github.com/YOUR_USER/IA_core",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Libraries :: Application Frameworks",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    python_requires=">=3.9",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "iacore=iacore.cli.main:app",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)
