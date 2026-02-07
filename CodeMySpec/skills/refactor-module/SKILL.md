---
name: refactor-module
description: Start an interactive refactoring session for a component or context
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Edit, Glob, Grep
argument-hint: [ModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task refactor_module ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
