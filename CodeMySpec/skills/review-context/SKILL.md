---
name: review-context
description: Review a context design and its child components for architecture issues
user-invocable: true
allowed-tools: Bash(mix cli *), Read, Edit
argument-hint: [ContextModuleName]
---

!`PROJECT_DIR=$(pwd) && cd ${CLAUDE_PLUGIN_ROOT}/.. && mix cli start-agent-task -e ${CLAUDE_SESSION_ID} -t context_design_review -m $ARGUMENTS -w $PROJECT_DIR`
