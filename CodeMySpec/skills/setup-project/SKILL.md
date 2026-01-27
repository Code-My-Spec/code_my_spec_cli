---
name: setup-project
description: Guide through Phoenix project setup for CodeMySpec integration
user-invocable: true
allowed-tools: Bash(*/scripts/code_my_spec *), Bash(mix cli *), Bash(mix *), Bash(elixir *), Bash(mkdir *), Bash(echo *), Read, Write
argument-hint: []
hooks:
  PostToolUse:
    - command: echo "hook running" && exit 1
---

!`${CLAUDE_PLUGIN_ROOT}/../scripts/code_my_spec start-agent-task -e ${CLAUDE_SESSION_ID} -t project_setup -w $PWD`
