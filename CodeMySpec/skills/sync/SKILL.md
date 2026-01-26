---
name: sync
description: Sync project components and regenerate architecture views. Use before architecture design, after git pulls, or when views seem stale.
user-invocable: true
allowed-tools: Bash(mix cli *)
---

!`PROJECT_DIR=$(pwd) && cd ${CLAUDE_PLUGIN_ROOT}/.. && mix cli sync -w $PROJECT_DIR`
