---
name: implement-context
description: Generate tests and implementations for a context and its child components
user-invocable: true
allowed-tools: Bash(mix cli *), Read, Task
argument-hint: [ContextModuleName]
---

!`PROJECT_DIR=$(pwd) && cd ${CLAUDE_PLUGIN_ROOT}/.. && mix cli start-agent-task -e ${CLAUDE_SESSION_ID} -t implement_context -m $ARGUMENTS -w $PROJECT_DIR`
