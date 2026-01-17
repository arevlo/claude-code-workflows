---
description: Interactive setup wizard for clawd-eyes browser configuration
allowed-tools: Bash,Read,AskUserQuestion
---

# Clawd-Eyes Setup Wizard

Guide users through choosing and configuring their browser option for clawd-eyes.

## Instructions

1. **Welcome the user** and explain that clawd-eyes needs a browser to capture pages.

2. **Ask which browser option they want to use:**

   Use the AskUserQuestion tool with these options:

   ```
   question: "How would you like clawd-eyes to connect to a browser?"
   header: "Browser"
   options:
     - label: "Built-in Browser (Recommended)"
       description: "clawd-eyes launches its own Chromium. Simplest setup, works out of the box."
     - label: "My Own Chrome/Browser"
       description: "Connect to your existing Chrome with your profile, extensions, and bookmarks."
     - label: "Claude in Chrome"
       description: "Use alongside the Claude in Chrome extension for browser automation."
     - label: "Playwright MCP"
       description: "Share a browser instance with other tools via Playwright MCP server."
   ```

3. **Based on their choice, provide setup instructions:**

   ### If "Built-in Browser":
   - Explain: "No extra setup needed! Just run `/clawd-eyes:start` and a Chromium browser will launch automatically."
   - Note: This uses an isolated browser profile (no extensions/bookmarks from your main Chrome).

   ### If "My Own Chrome/Browser":
   - Explain they need to launch Chrome with remote debugging enabled:
     ```bash
     # macOS
     /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

     # Linux
     google-chrome --remote-debugging-port=9222

     # Windows
     chrome.exe --remote-debugging-port=9222
     ```
   - Ask if they want to create a shell alias for convenience:
     ```bash
     alias chrome-debug='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222'
     ```
   - Explain: "Once Chrome is running with debugging enabled, run `/clawd-eyes:start`"

   ### If "Claude in Chrome":
   - Explain: "Claude in Chrome and clawd-eyes serve different purposes:"
     - **Claude in Chrome**: Browser automation (clicking, typing, navigating)
     - **clawd-eyes**: Visual inspection (selecting elements, viewing CSS, sending design context)
   - Setup:
     1. Use Claude in Chrome for navigation and interaction
     2. Run `/clawd-eyes:start` to launch the inspector UI
     3. Select elements in the clawd-eyes UI, send context to Claude Code
   - Note: These tools complement each other - Claude in Chrome for automation, clawd-eyes for design inspection.

   ### If "Playwright MCP":
   - Explain: "This option shares a browser with other Playwright-based tools."
   - They need the Playwright MCP server configured in their Claude settings
   - clawd-eyes will connect to the browser on port 9222
   - Ensure their Playwright setup includes `--remote-debugging-port=9222` in browser args

4. **Verify their setup:**

   Check if a browser with CDP is already available:
   ```bash
   curl -s http://localhost:9222/json/version 2>/dev/null && echo "Browser with CDP detected on port 9222" || echo "No browser detected on port 9222 yet"
   ```

5. **Offer to start clawd-eyes:**

   Ask if they want to run `/clawd-eyes:start` now.

## Summary Table

| Option | Pros | Cons |
|--------|------|------|
| Built-in | Zero config, isolated | No extensions, separate browser |
| Own Chrome | Your profile, extensions | Must launch with flag |
| Claude in Chrome | Automation + inspection | Two systems running |
| Playwright MCP | Shared browser | More complex setup |
