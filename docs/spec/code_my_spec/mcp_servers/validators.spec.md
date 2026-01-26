# CodeMySpec.McpServers.Validators

Validation functions for MCP servers. Provides scope validation to ensure that MCP server requests have the required account and project context before executing operations.

## Functions

### require_active_account/1

Validates that the current scope has an active account set.

```elixir
@spec require_active_account(map()) :: {:ok, map()} | {:error, :missing_active_account}
```

**Process**:
1. Extract the current_scope from frame.assigns
2. If scope exists, extract the active_account field
3. Return {:ok, frame} if account exists, otherwise return {:error, :missing_active_account}

**Test Assertions**:
- returns {:ok, frame} when frame has current_scope with active_account
- returns {:error, :missing_active_account} when frame has no current_scope
- returns {:error, :missing_active_account} when current_scope has no active_account
- returns {:error, :missing_active_account} when current_scope.active_account is nil

### require_active_project/1

Validates that the current scope has an active project set.

```elixir
@spec require_active_project(map()) :: {:ok, map()} | {:error, :missing_active_project}
```

**Process**:
1. Extract the current_scope from frame.assigns
2. If scope exists, extract the active_project field
3. Return {:ok, frame} if project exists, otherwise return {:error, :missing_active_project}

**Test Assertions**:
- returns {:ok, frame} when frame has current_scope with active_project
- returns {:error, :missing_active_project} when frame has no current_scope
- returns {:error, :missing_active_project} when current_scope has no active_project
- returns {:error, :missing_active_project} when current_scope.active_project is nil

### validate_scope/1

Validates that the current scope has both an active account and active project set.

```elixir
@spec validate_scope(map()) :: {:ok, map()} | {:error, :missing_active_account | :missing_active_project}
```

**Process**:
1. Call require_active_account/1 to validate account presence
2. If successful, call require_active_project/1 to validate project presence
3. If both validations pass, return {:ok, current_scope}
4. Return error tuple from first failed validation

**Test Assertions**:
- returns {:ok, scope} when both account and project are present
- returns {:error, :missing_active_account} when account is missing
- returns {:error, :missing_active_project} when account exists but project is missing
- extracts and returns the current_scope from frame.assigns on success

## Dependencies

This module has no external dependencies within the CodeMySpec application.
