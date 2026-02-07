---
name: setup-project
description: Guide through Phoenix project setup for CodeMySpec integration
user-invocable: true
allowed-tools: Bash(*/agent-task *), Bash(mix *), Bash(elixir *), Bash(mkdir *), Bash(echo *), Read, Write, Glob, Grep
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task project_setup ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
