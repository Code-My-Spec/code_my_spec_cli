---
name: review-architecture
description: Review current architecture design against best practices. Checks surface-to-domain separation, dependency flow, and story coverage.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, mcp__plugin_codemyspec_architecture-server__*
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task architecture_review ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
