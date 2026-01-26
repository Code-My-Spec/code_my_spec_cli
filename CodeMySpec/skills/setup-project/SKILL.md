---
name: setup-project
description: Guide through Phoenix project setup for CodeMySpec integration
user-invocable: true
allowed-tools: Bash(mix cli *), Bash(mix *), Bash(elixir *), Bash(mkdir *), Bash(echo *), Read, Write
argument-hint: []
---

!`cd ${CLAUDE_PLUGIN_ROOT}/.. && mix cli start-agent-task -e ${CLAUDE_SESSION_ID} -t project_setup -w $PWD`
