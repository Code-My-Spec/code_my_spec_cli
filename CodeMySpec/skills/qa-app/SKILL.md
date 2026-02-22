---
name: qa-app
description: QA the app by browsing with the web tool. Visits routes, tests forms, files issues for bugs found.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Bash(web *), Bash(lsof *), Bash(mix phx.*), Read, Write, Glob, Grep, Task
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task qa_app ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
