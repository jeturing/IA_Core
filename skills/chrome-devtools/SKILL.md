---
name: chrome-devtools
description: Chrome DevTools MCP integration for browser automation, debugging, and web development. Use when you need to inspect web pages, debug JavaScript, analyze network requests, or automate browser interactions.
version: 0.1.0
author: jeturing
triggers:
  - browser debug
  - inspect page
  - chrome devtools
  - network requests
  - javascript debug
  - web automation
  - screenshot
---

# Chrome DevTools Skill

Browser automation and debugging via Chrome DevTools Protocol MCP server.

## Setup

Ensure Chrome DevTools MCP is configured in `mcp.json`:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

## Capabilities

### Page Inspection
- Get page HTML/DOM
- Query selectors
- Get computed styles
- Accessibility tree

### JavaScript Debugging
- Execute JavaScript in page context
- Set breakpoints
- Evaluate expressions
- Console logging

### Network Analysis
- Monitor network requests
- Inspect headers and payloads
- Performance timing
- Resource loading

### Screenshots
- Full page screenshots
- Element screenshots
- Viewport captures

### Browser Automation
- Navigate to URLs
- Click elements
- Fill forms
- Scroll pages

## Usage Examples

### Inspect a Page
```
Use Chrome DevTools to inspect the homepage and tell me about its structure.
```

### Debug JavaScript Error
```
Open the browser console and check for any JavaScript errors on this page.
```

### Analyze Network
```
Monitor the network requests when the page loads and identify any slow or failing requests.
```

### Take Screenshot
```
Take a screenshot of the current page state.
```

### Execute JavaScript
```
Run document.querySelectorAll('a').length in the browser to count all links.
```

### Form Automation
```
Fill in the login form with test credentials and submit it.
```

## Integration with IA_Core

Chrome DevTools works seamlessly with other IA_Core skills:

### With Project Analyzer
```
Analyze this web project, then use Chrome DevTools to verify the built output works correctly.
```

### With Memory Manager
```
Test the login flow, then store the test results in memory for future reference.
```

### With Autonomous Executor
```
Run the dev server, then use Chrome DevTools to test the API endpoints.
```

## Guidelines

1. **Start browser first** - Ensure Chrome is running with remote debugging enabled
2. **Use selectors wisely** - Prefer specific selectors over generic ones
3. **Handle async** - Wait for elements/network before interacting
4. **Clean up** - Close tabs/connections when done
5. **Security** - Don't expose sensitive data in screenshots

## Starting Chrome with Remote Debugging

```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Linux
google-chrome --remote-debugging-port=9222

# Windows
chrome.exe --remote-debugging-port=9222
```

## Common Operations

### Navigate
```javascript
// Go to URL
await page.goto('https://example.com');
```

### Query DOM
```javascript
// Get element text
const title = await page.$eval('h1', el => el.textContent);
```

### Network Intercept
```javascript
// Log all requests
page.on('request', req => console.log(req.url()));
```

### Screenshot
```javascript
// Full page
await page.screenshot({ path: 'page.png', fullPage: true });
```
