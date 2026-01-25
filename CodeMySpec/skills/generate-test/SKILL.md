---
name: generate-test
description: Generate component tests from spec using agent task session
user-invocable: true
allowed-tools: Bash(mix cli *), Read
argument-hint: [ModuleName]
---

!`PROJECT_DIR=$(pwd) && cd ${CLAUDE_PLUGIN_ROOT}/.. && mix cli start-agent-task -e ${CLAUDE_SESSION_ID} -t component_test -m $ARGUMENTS -w $PROJECT_DIR`
