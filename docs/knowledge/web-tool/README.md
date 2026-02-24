# web Tool - Knowledge Index

The `web` CLI tool (https://github.com/chrismccord/web) is a headless browser designed for LLM agent use. It converts web pages to markdown, executes JavaScript, fills forms, takes screenshots, and maintains sessions across invocations.

Used by the `qa-app` skill to QA Phoenix LiveView applications.

## Files in This Directory

| File | Contents |
|------|----------|
| `overview.md` | What the tool is, architecture, installation instructions |
| `cli_reference.md` | Every flag, its argument type, default value, and behavior |
| `phoenix_liveview.md` | LiveView-specific behavior: auto-detection, connection waiting, form handling |
| `agent_workflows.md` | Step-by-step QA workflows, session strategy, output management |

## Quick Reference

```bash
# Basic page visit
web <url>

# All flags
web <url> \
  --profile <name>          # named session (default: "default")
  --screenshot <path>       # save PNG screenshot
  --truncate-after <n>      # limit output chars (default: 100000)
  --raw                     # raw HTML instead of markdown
  --js "<code>"             # execute JavaScript after load
  --form <id>               # form id to target
  --input <name>            # input field name (repeatable)
  --value <value>           # value for preceding --input
  --after-submit <url>      # navigate here after form submission
  --help                    # show usage
```
