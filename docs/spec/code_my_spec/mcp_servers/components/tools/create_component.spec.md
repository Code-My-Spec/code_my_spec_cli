# CodeMySpec.McpServers.Components.Tools.CreateComponent

MCP tool module for creating a single component definition through the ComponentsServer. This tool enables AI agents to create new components within a project scope, handling validation, dependency tracking, and proper component type classification according to Phoenix architectural patterns.

## Functions

### execute/2

Execute the create_component tool with provided arguments and scope.

```elixir
@spec execute(map(), CodeMySpec.Agents.Scope.t()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Validate the scope has an active account and project
2. Extract component parameters from the arguments map (name, type, description, dependencies, parent_component_id)
3. Validate required fields are present (name, type)
4. Validate component type against allowed types (context, repository, schema, liveview, component, live_component, channel, controller, etc.)
5. Build module_name from component name according to project conventions
6. Call Components context to create the component with validated parameters and scope
7. Handle success by formatting component data (id, name, module_name, type, description, dependencies) for MCP response
8. Handle Ecto.Changeset errors by extracting and formatting validation errors
9. Handle other errors by returning formatted error messages
10. Return result tuple with formatted response

**Test Assertions**:
- creates component with valid name and type
- validates scope has active account
- validates scope has active project
- validates required field name is present
- validates required field type is present
- validates component type is in allowed list
- generates correct module_name from component name
- scopes creation to current project from scope
- returns formatted component data on success with all fields
- returns error message for missing name
- returns error message for missing type
- returns error message for invalid component type
- returns error message for duplicate module_name in project
- handles parent_component_id when provided
- handles dependencies array when provided
- returns validation errors for invalid name format

### schema/0

Return the JSON schema definition for the create_component tool.

```elixir
@spec schema() :: map()
```

**Process**:
1. Define tool schema map with name "create_component"
2. Add description explaining the tool creates a single component
3. Define input_schema with type "object"
4. Specify properties: name (string), type (string with enum), description (string), dependencies (array of strings), parent_component_id (string)
5. Mark name and type as required in required array
6. Include enum values for type field listing all allowed component types
7. Add additionalProperties: false to prevent extra fields
8. Return complete schema map

**Test Assertions**:
- returns map with name key set to "create_component"
- includes description explaining tool purpose
- includes input_schema with type object
- includes name property as required string
- includes type property as required string with enum values
- includes description property as optional string
- includes dependencies property as optional array
- includes parent_component_id property as optional string
- lists all valid component types in enum
- marks only name and type as required
- sets additionalProperties to false

### validate_component_type/1

Validate that the component type is in the allowed list.

```elixir
@spec validate_component_type(String.t()) :: {:ok, String.t()} | {:error, String.t()}
```

**Process**:
1. Define list of allowed component types (context, repository, schema, liveview, component, live_component, channel, controller, view, plug, behaviour, module)
2. Check if provided type is in the allowed list
3. Return {:ok, type} if valid
4. Return {:error, message} with list of allowed types if invalid

**Test Assertions**:
- returns ok for "context" type
- returns ok for "repository" type
- returns ok for "schema" type
- returns ok for "liveview" type
- returns ok for "component" type
- returns ok for "live_component" type
- returns ok for "channel" type
- returns ok for "controller" type
- returns ok for "view" type
- returns ok for "plug" type
- returns ok for "behaviour" type
- returns ok for "module" type
- returns error for invalid type
- error message includes list of allowed types

### build_module_name/1

Build a proper Elixir module name from the component name.

```elixir
@spec build_module_name(String.t()) :: String.t()
```

**Process**:
1. Split component name by underscores
2. Capitalize each word segment
3. Join segments together without separators
4. Return PascalCase module name

**Test Assertions**:
- converts "user_repository" to "UserRepository"
- converts "account_context" to "AccountContext"
- converts "live_view" to "LiveView"
- handles single word names correctly
- handles already capitalized names

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Agents.Scope
- CodeMySpec.McpServers.ComponentsServer
