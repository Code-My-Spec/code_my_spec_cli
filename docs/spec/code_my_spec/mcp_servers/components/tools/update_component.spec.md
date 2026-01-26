# UpdateComponent

MCP tool that updates an existing component's properties. Validates scope (active account and project), retrieves the component by ID, applies the updates, and broadcasts the update event. Implements the Hermes MCP tool protocol for integration with AI agents via Claude Code/Desktop.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component

## Functions

### execute/2

Executes the update component tool with scope validation, component retrieval, and error handling.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Extract and validate scope from frame using Validators.validate_scope/1
2. Retrieve component by ID using find_component/2 helper (returns {:error, :not_found} if missing)
3. Update component using Components.update_component/3 with scope, component, and params (excluding ID field)
4. Map successful result to tool response using ComponentsMapper.component_response/1
5. Handle Ecto.Changeset errors with ComponentsMapper.validation_error/1
6. Handle :not_found errors with ComponentsMapper.not_found_error/0
7. Handle atom errors with ComponentsMapper.error/1

**Test Assertions**:
- executes with valid params and scope, returns success response with updated component data
- updates only specified fields (name, description) while preserving others
- returns error response for non-existent component ID
- returns validation error for invalid field values (e.g., blank name)
- returns error response for invalid scope (missing active account or project)

### find_component/2

Helper function that retrieves a component and wraps nil result as error tuple.

```elixir
@spec find_component(CodeMySpec.Users.Scope.t(), String.t() | integer()) :: {:ok, CodeMySpec.Components.Component.t()} | {:error, :not_found}
```

**Process**:
1. Call Components.get_component/2 with scope and component ID
2. If nil, return {:error, :not_found}
3. If component found, return {:ok, component}

**Test Assertions**:
- returns {:ok, component} when component exists
- returns {:error, :not_found} when component does not exist
