# AddSimilarComponent

MCP tool module for marking components as architectural analogs through the ComponentsServer. This tool enables AI agents to create similar component relationships within a project scope, allowing components to reference other components with similar architecture, design patterns, or functionality for reference during development and design workflows.

## Functions

### execute/2

Execute the add_similar_component tool with provided arguments and scope.

```elixir
@spec execute(map(), CodeMySpec.Agents.Scope.t()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract component_id and similar_component_id from the arguments map
2. Validate required fields (component_id, similar_component_id)
3. Validate that component_id and similar_component_id are different
4. Call Components context to retrieve both components with scope validation
5. Verify both components exist and belong to the current project
6. Create similar component relationship using Components.add_similar_component/3
7. Handle success by formatting response data for MCP
8. Handle errors (not found, duplicate relationship, validation errors)
9. Return ok tuple with success data or error tuple with message

**Test Assertions**:
- creates similar component relationship with valid component IDs
- validates both component_id and similar_component_id are provided
- returns error when component_id is missing
- returns error when similar_component_id is missing
- returns error when component_id equals similar_component_id
- returns error when component_id does not exist
- returns error when similar_component_id does not exist
- returns error when component belongs to different project
- returns error when similar component belongs to different project
- returns error when relationship already exists (duplicate)
- scopes operation to current project
- returns formatted success response with relationship details
- broadcasts similar component added event to PubSub subscribers

### schema/0

Return the JSON schema definition for the add_similar_component tool.

```elixir
@spec schema() :: map()
```

**Process**:
1. Define input schema with required parameters
2. Specify component_id as required string (binary_id)
3. Specify similar_component_id as required string (binary_id)
4. Include description explaining the purpose of the relationship
5. Include example usage in schema documentation
6. Return schema in MCP tool format

**Test Assertions**:
- returns map with required schema keys
- includes component_id field as required string
- includes similar_component_id field as required string
- includes description field explaining relationship purpose
- schema structure follows MCP tool format
- includes tool name and description

### validate_params/1

Validate similar component relationship parameters.

```elixir
@spec validate_params(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Check for required fields (component_id, similar_component_id)
2. Validate component_id is a valid binary_id format
3. Validate similar_component_id is a valid binary_id format
4. Validate component_id is different from similar_component_id
5. Return ok tuple with params or error tuple with message

**Test Assertions**:
- returns ok for valid parameters with different component IDs
- returns error for missing component_id
- returns error for missing similar_component_id
- returns error for invalid component_id format
- returns error for invalid similar_component_id format
- returns error when component_id equals similar_component_id
- returns error when component_id is not a string
- returns error when similar_component_id is not a string

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentsMapper
- CodeMySpec.Agents.Scope
- CodeMySpec.MCPServers.ComponentsServer
