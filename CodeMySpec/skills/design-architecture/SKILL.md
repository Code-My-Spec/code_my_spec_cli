---
name: design-architecture
description: Start a guided architecture design session. Maps user stories to surface components and identifies needed bounded contexts.
user-invocable: true
allowed-tools: Bash(mix cli *), Read, mcp__plugin_codemyspec_architecture-server__*
argument-hint: []
---

!`PROJECT_DIR=$(pwd) && cd ${CLAUDE_PLUGIN_ROOT}/.. && mix cli start-agent-task -e ${CLAUDE_SESSION_ID} -t architecture_design -w $PROJECT_DIR`
