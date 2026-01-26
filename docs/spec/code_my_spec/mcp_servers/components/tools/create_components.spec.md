# CreateComponents

MCP tool module for creating component definitions through the ComponentsServer. This tool enables AI agents to create new components within a project scope, handling validation, dependency tracking, and proper component type classification according to Phoenix architectural patterns.

## Functions

### execute/2

Execute the create_components tool with provided arguments and scope.

```elixir
@spec execute(map(), CodeMySpec.Agents.Scope.t()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract component parameters from the arguments map
2. Validate required fields (name, type, project_id)
3. Validate component type against allowed types (context, repository, schema, liveview, etc.)
4. Call Components context to create the component with scope
5. Handle success by formatting component data for MCP response
6. Handle errors by returning formatted error messages

**Test Assertions**:
- creates component with valid parameters
- validates required fields presence
- validates component type is allowed
- scopes creation to current project
- returns formatted component data on success
- returns error message for missing required fields
- returns error message for invalid component type
- returns error message for duplicate component name

### schema/0

Return the JSON schema definition for the create_components tool.

```elixir
@spec schema() :: map()
```

**Process**:
1. Define input schema with required and optional parameters
2. Specify component name, description, type, and dependencies fields
3. Mark name, type, and project_id as required
4. Include enum values for component type field
5. Return schema in MCP tool format

**Test Assertions**:
- returns map with required schema keys
- includes name field as required string
- includes type field with enum values
- includes description field as optional string
- includes dependencies field as optional array
- includes project_id field as required integer

### validate_params/1

Validate component creation parameters.

```elixir
@spec validate_params(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Check for required fields (name, type)
2. Validate component type against allowed values
3. Validate name format (alphanumeric with underscores)
4. Validate dependencies is a list if provided
5. Return ok tuple with params or error tuple with message

**Test Assertions**:
- returns ok for valid parameters
- returns error for missing name
- returns error for missing type
- returns error for invalid component type
- returns error for invalid name format
- returns error for invalid dependencies format

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Agents.Scope
- CodeMySpec.MCPServers.ComponentsServer
