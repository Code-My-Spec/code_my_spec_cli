# Browser Tool for AI Agent QA Workflows

## Status

Accepted

## Context

The `qa-app` skill delegates a QA session to an AI agent (Claude). The agent needs to interact with the running Phoenix LiveView application as a real user would — visiting routes, logging in, submitting forms, reading rendered content, and detecting errors. This requires a browser that:

- Returns LLM-readable output (not raw HTML by default)
- Handles Phoenix LiveView's WebSocket-based rendering correctly
- Maintains authenticated sessions across multiple page visits
- Can be driven entirely from the command line with no configuration files
- Captures JavaScript console output and browser errors automatically

The alternative approaches were standard curl/wget, Playwright/Puppeteer via Node, or a Python-based scraping library.

## Options Considered

### Option A: `chrismccord/web`

A Go binary that wraps headless Firefox via geckodriver. Built specifically for LLM agent use by the creator of Phoenix Framework.

- **Pros:**
  - First-class Phoenix LiveView support: auto-detects LiveView pages, waits for WebSocket connection before capturing output, handles loading states during form submission
  - Output is markdown by default — compact and immediately consumable by the agent
  - Single binary, zero configuration — no `playwright install`, no npm, no config files
  - Session profiles (`--profile`) persist cookies across CLI invocations without any manual cookie management
  - Console log capture (`[LOG]`, `[WARNING]`, `[ERROR]`) surfaces JavaScript errors automatically
  - Form filling is built-in (`--form`, `--input`, `--value`, `--after-submit`)
  - Screenshot support built-in (`--screenshot`)
  - Already referenced in the `qa-app` SKILL.md allowed tools (`Bash(web *)`)
  - Created and maintained by Chris McCord (Phoenix author) — LiveView compatibility is a first-class concern

- **Cons:**
  - Requires ~102MB disk space for Firefox download on first run
  - Linux users need system packages (gtk, dbus, x11 libs) installed separately
  - Only one `--js` block per invocation; complex multi-step interactions require chaining invocations
  - No built-in retry or wait mechanism beyond LiveView's connection wait
  - Limited to Firefox (no Chromium option)

### Option B: curl / wget

Simple HTTP clients.

- **Pros:** Zero dependencies, universally available
- **Cons:** Cannot execute JavaScript at all; LiveView pages return unrendered shell HTML; no session management beyond manual cookie files; completely unsuitable for LiveView QA

### Option C: Playwright (Node.js)

Headless browser automation via npm package.

- **Pros:** Full browser automation capabilities, multi-browser support, rich assertion API
- **Cons:** Requires Node.js runtime and npm; `playwright install` downloads browsers separately; output is not markdown — agent would need to convert or query DOM explicitly; no built-in LiveView awareness; significantly more setup complexity for the agent to use correctly; the `qa-app` SKILL.md allowed tools do not include Node-based commands

### Option D: Python Selenium / requests-html

Python-based browser automation.

- **Pros:** Flexible, widely documented
- **Cons:** Requires Python runtime; no LiveView awareness; output is not markdown; additional dependency management; not referenced in existing skill configuration

## Decision

Use `chrismccord/web` as the exclusive browser tool for the `qa-app` agent skill.

The decision is straightforward: the tool was purpose-built for exactly this use case (LLM agents browsing Phoenix LiveView apps), is already named in the `qa-app` SKILL.md allowed tools list (`Bash(web *)`), and eliminates entire categories of complexity that other tools impose:

- LiveView connection timing is handled automatically
- Authentication sessions persist with `--profile` — no cookie file management
- Output arrives as markdown — no DOM querying or HTML parsing required
- Zero runtime configuration — the agent does not need to write config files or set up a test harness

The main trade-off accepted is the ~102MB first-run Firefox download and Linux system package requirements. Both are one-time setup costs that do not affect the agent's per-invocation workflow.

## Consequences

- The `qa-app` agent must have `web` installed and on `PATH` before the skill can be invoked. This is an operator concern (the developer running the skill).
- On first run in a new environment, the agent should expect a delay while Firefox downloads.
- For multi-step authenticated workflows, the agent must use a consistent `--profile` name across all invocations in a single QA session.
- When form `id` or input `name` values are unknown, the agent should first call `web <url> --raw` to inspect the HTML before attempting form submission.
- Complex interactions requiring multiple DOM events (e.g., open a dropdown, then click an option) must be expressed as a single `--js` block or spread across sequential `web` invocations, since each invocation opens a fresh page load (but retains session state via `--profile`).
- Knowledge documentation lives at `docs/knowledge/web-tool/`.
