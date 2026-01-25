"""
LLM Client - Interface to GPT-4o-mini and other LLMs.

Supports:
- OpenAI GPT-4o-mini (free tier)
- Fallback to other models
- Rate limiting
- Context caching
"""

import asyncio
import hashlib
import json
import logging
import os
from pathlib import Path
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


class LLMClient:
    """
    Client for interacting with LLMs.
    
    Primary model: GPT-4o-mini (free tier via OpenAI)
    """

    def __init__(
        self,
        model: str = "gpt-4o-mini",
        provider: str = "openai",
        api_key: Optional[str] = None,
        cache_dir: Optional[Path] = None,
    ):
        self.model = model
        self.provider = provider
        self.api_key = api_key or os.getenv("OPENAI_API_KEY")
        self.cache_dir = cache_dir or Path.home() / ".iacore" / "llm_cache"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        # Rate limiting (free tier: 10 req/min)
        self.rate_limit = 10
        self.rate_window = 60  # seconds
        self.request_times: List[datetime] = []
        
        logger.info(f"LLMClient initialized: {provider}/{model}")

    async def complete(
        self,
        prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
        use_cache: bool = True,
    ) -> str:
        """
        Generate completion from LLM.
        
        Args:
            prompt: Input prompt
            max_tokens: Maximum tokens to generate
            temperature: Sampling temperature
            use_cache: Whether to use cached responses
            
        Returns:
            Generated text
        """
        # Check cache
        if use_cache:
            cached = self._get_cached(prompt)
            if cached:
                logger.debug("Using cached response")
                return cached
        
        # Rate limiting
        await self._check_rate_limit()
        
        # Generate completion
        try:
            if self.provider == "openai":
                response = await self._openai_complete(prompt, max_tokens, temperature)
            else:
                raise ValueError(f"Unsupported provider: {self.provider}")
            
            # Cache response
            if use_cache:
                self._cache_response(prompt, response)
            
            return response
            
        except Exception as e:
            logger.error(f"LLM completion error: {e}")
            return self._fallback_response(prompt)

    async def _openai_complete(
        self,
        prompt: str,
        max_tokens: int,
        temperature: float,
    ) -> str:
        """Complete using OpenAI API."""
        try:
            import openai
        except ImportError:
            logger.error("openai package not installed. Run: pip install openai")
            return ""
        
        # Set API key
        openai.api_key = self.api_key
        
        try:
            response = await asyncio.to_thread(
                openai.ChatCompletion.create,
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=max_tokens,
                temperature=temperature,
            )
            
            return response.choices[0].message.content
            
        except openai.error.RateLimitError:
            logger.warning("Rate limit exceeded, waiting...")
            await asyncio.sleep(60)
            return await self._openai_complete(prompt, max_tokens, temperature)
        
        except openai.error.AuthenticationError:
            logger.error("Invalid API key. Set OPENAI_API_KEY environment variable.")
            return ""

    async def _check_rate_limit(self):
        """Check and enforce rate limiting."""
        now = datetime.now()
        
        # Remove old requests outside window
        self.request_times = [
            t for t in self.request_times
            if now - t < timedelta(seconds=self.rate_window)
        ]
        
        # Check if at limit
        if len(self.request_times) >= self.rate_limit:
            oldest = self.request_times[0]
            wait_time = (oldest + timedelta(seconds=self.rate_window) - now).total_seconds()
            
            if wait_time > 0:
                logger.warning(f"Rate limit reached, waiting {wait_time:.1f}s...")
                await asyncio.sleep(wait_time)
        
        # Record this request
        self.request_times.append(now)

    def _get_cached(self, prompt: str) -> Optional[str]:
        """Get cached response for prompt."""
        cache_key = hashlib.md5(prompt.encode()).hexdigest()
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        if cache_file.exists():
            try:
                data = json.loads(cache_file.read_text())
                
                # Check if cache is recent (24 hours)
                cached_at = datetime.fromisoformat(data["timestamp"])
                if datetime.now() - cached_at < timedelta(hours=24):
                    return data["response"]
            except:
                pass
        
        return None

    def _cache_response(self, prompt: str, response: str):
        """Cache LLM response."""
        cache_key = hashlib.md5(prompt.encode()).hexdigest()
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        data = {
            "prompt": prompt[:200],  # Store truncated prompt
            "response": response,
            "timestamp": datetime.now().isoformat(),
            "model": self.model,
        }
        
        cache_file.write_text(json.dumps(data, indent=2))

    def _fallback_response(self, prompt: str) -> str:
        """Fallback response when LLM fails."""
        logger.warning("Using fallback response")
        
        # Simple rule-based fallback for common cases
        if "commands" in prompt.lower():
            return "# Unable to generate commands at this time\necho 'LLM unavailable'"
        
        return "Unable to process request. LLM service unavailable."

    async def analyze_code(self, code: str, language: str) -> Dict[str, Any]:
        """Analyze code and return insights."""
        prompt = f"""Analyze this {language} code and provide insights:

```{language}
{code[:2000]}
```

Provide a JSON response with:
- "quality": score 1-10
- "issues": list of potential issues
- "suggestions": list of improvement suggestions
- "complexity": "low"|"medium"|"high"

JSON:"""
        
        response = await self.complete(prompt, max_tokens=300, temperature=0.3)
        
        try:
            # Extract JSON from response
            json_start = response.find("{")
            json_end = response.rfind("}") + 1
            if json_start >= 0 and json_end > json_start:
                return json.loads(response[json_start:json_end])
        except:
            pass
        
        return {
            "quality": 5,
            "issues": [],
            "suggestions": [],
            "complexity": "medium",
        }
