# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.GetCustomMetric

MCP tool for retrieving detailed custom metric configuration from Google Analytics Admin API.

## Functions

### tool_name/0

Returns the unique identifier for this MCP tool.

```elixir
@spec tool_name() :: String.t()
```

**Process**:
1. Return the string "get_custom_metric"

**Test Assertions**:
- returns "get_custom_metric" string

### description/0

Provides a human-readable description of what this tool does.

```elixir
@spec description() :: String.t()
```

**Process**:
1. Return a description explaining that this tool retrieves custom metric configuration

**Test Assertions**:
- returns a non-empty string
- description mentions custom metric retrieval

### input_schema/0

Defines the JSON schema for the tool's input parameters.

```elixir
@spec input_schema() :: map()
```

**Process**:
1. Return a map containing JSON schema definition
2. Schema requires "name" parameter (string) - the resource name of the custom metric
3. Schema is of type "object" with required properties

**Test Assertions**:
- returns a map with "type" key set to "object"
- includes "properties" key with "name" field definition
- includes "required" key containing "name"
- name property is of type "string"

### execute/1

Executes the tool with provided arguments to retrieve custom metric details.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract the "name" parameter from input arguments
2. Validate that name parameter is present
3. Call Google Analytics Admin API to get custom metric by name
4. Handle API response and errors
5. Return success tuple with custom metric data or error tuple with message

**Test Assertions**:
- returns error when name parameter is missing
- returns error when name parameter is empty
- returns error when API call fails
- returns ok tuple with custom metric data when successful
- returned data includes standard custom metric fields (name, parameter_name, display_name, description, scope, measurement_unit)
- handles network errors gracefully
- handles invalid resource name format

## Dependencies

- GoogleApi.AnalyticsAdmin.V1alpha.Api.Properties
- GoogleApi.AnalyticsAdmin.V1alpha.Connection
