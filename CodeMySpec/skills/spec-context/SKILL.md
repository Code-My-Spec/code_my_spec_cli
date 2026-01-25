---
name: spec-context
description: Generate specifications for all child components of a context
user-invocable: true
allowed-tools: Bash(mix cli *), Read, Task
argument-hint: [ContextModuleName]
---

!`PROJECT_DIR=$(pwd) && cd ${CLAUDE_PLUGIN_ROOT}/.. && mix cli start-agent-task -e ${CLAUDE_SESSION_ID} -t context_component_specs -m $ARGUMENTS -w $PROJECT_DIR`
