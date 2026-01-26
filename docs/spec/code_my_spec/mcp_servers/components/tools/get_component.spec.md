# GetComponent

MCP tool module for retrieving detailed component information through the ComponentsServer. This tool enables AI agents to fetch a specific component by ID or module name within a project scope, returning complete component details including type, dependencies, description, and similar components for architecture analysis and design workflows.

## Functions

### execute/2

Execute the get_component tool with provided arguments and scope.

```elixir
@spec execute(map(), CodeMySpec.Agents.Scope.t()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract lookup parameter from arguments (id or module_name)
2. Validate that at least one lookup parameter is provided
3. Call Components context to retrieve the component with scope
4. Handle case where component is not found
5. Preload associated data (dependencies, similar_components, context_parent)
6. Format component data using ComponentsMapper for MCP response
7. Return ok tuple with formatted component data or error tuple with message

**Test Assertions**:
- retrieves component by ID when id parameter provided
- retrieves component by module_name when module_name parameter provided
- returns error when neither id nor module_name provided
- returns error when both id and module_name provided
- returns error when component not found with given id
- returns error when component not found with given module_name
- scopes retrieval to current project
- includes component dependencies in response
- includes similar components in response
- includes context parent information when component is not a context
- returns formatted component data on success with all required fields

### schema/0

Return the JSON schema definition for the get_component tool.

```elixir
@spec schema() :: map()
```

**Process**:
1. Define input schema with id and module_name as alternative parameters
2. Specify id as integer and module_name as string
3. Mark parameters as mutually exclusive (one required but not both)
4. Include description explaining lookup options
5. Return schema in MCP tool format

**Test Assertions**:
- returns map with required schema keys
- includes id field as optional integer
- includes module_name field as optional string
- includes description explaining parameter usage
- schema structure follows MCP tool format

### validate_params/1

Validate component retrieval parameters.

```elixir
@spec validate_params(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Check that exactly one lookup parameter is provided (id or module_name)
2. Validate id is a positive integer if provided
3. Validate module_name is a non-empty string if provided
4. Return ok tuple with params or error tuple with message

**Test Assertions**:
- returns ok when id is provided and valid
- returns ok when module_name is provided and valid
- returns error when neither id nor module_name provided
- returns error when both id and module_name provided
- returns error when id is not a positive integer
- returns error when module_name is empty string

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentsMapper
- CodeMySpec.Agents.Scope
- CodeMySpec.MCPServers.ComponentsServer
