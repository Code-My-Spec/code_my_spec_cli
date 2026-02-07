---
name: review-context
description: Review a context design and its child components for architecture issues
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Edit, Glob, Grep
argument-hint: [ContextModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task context_design_review ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
