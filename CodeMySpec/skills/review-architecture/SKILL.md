---
name: review-architecture
description: Review current architecture design against best practices. Checks surface-to-domain separation, dependency flow, and story coverage.
user-invocable: true
allowed-tools: Bash(mix cli *), Read, mcp__plugin_codemyspec_architecture-server__*
argument-hint: []
---

!`PROJECT_DIR=$(pwd) && cd ${CLAUDE_PLUGIN_ROOT}/.. && mix cli start-agent-task -e ${CLAUDE_SESSION_ID} -t architecture_review -w $PROJECT_DIR`
