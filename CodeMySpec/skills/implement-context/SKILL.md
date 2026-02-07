---
name: implement-context
description: Generate tests and implementations for a context and its child components
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, Task
argument-hint: [ContextModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task implement_context ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
