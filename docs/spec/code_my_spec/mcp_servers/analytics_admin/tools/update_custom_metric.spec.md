# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.UpdateCustomMetric

MCP tool for updating custom metric configuration in Google Analytics Admin API. This tool provides the interface for modifying custom metric properties including display name, description, and measurement unit.

## Functions

### execute/1

Execute the update custom metric tool with provided arguments.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract and validate required parameters (name, custom_metric) from input arguments
2. Validate that name parameter is a non-empty string
3. Validate that custom_metric parameter is a map with valid fields
4. Build the custom metric update payload from the custom_metric parameter
5. Call Google Analytics Admin API to update the custom metric
6. Format the API response into a standardized result map
7. Return success tuple with updated metric details or error tuple with message

**Test Assertions**:
- returns error when name parameter is missing
- returns error when custom_metric parameter is missing
- returns error when name is not a valid string
- returns error when name is empty string
- returns error when custom_metric is not a valid map
- successfully updates custom metric with valid parameters
- returns API error message when API call fails
- transforms API response correctly into MCP format
- handles partial updates with only some fields provided

### build_custom_metric/1

Build a custom metric update payload from the provided parameters.

```elixir
@spec build_custom_metric(map()) :: map()
```

**Process**:
1. Extract optional fields from the input map (display_name, description, measurement_unit)
2. Build a map containing only the provided fields
3. Filter out nil or empty values
4. Return the constructed custom metric payload

**Test Assertions**:
- returns empty map when no fields provided
- includes display_name when provided
- includes description when provided
- includes measurement_unit when provided
- includes all fields when all are provided
- ignores unknown fields
- filters out nil values
- filters out empty strings

### validate_params/1

Validate the input parameters for the update custom metric request.

```elixir
@spec validate_params(map()) :: :ok | {:error, String.t()}
```

**Process**:
1. Check that name parameter is present and is a non-empty string
2. Check that custom_metric parameter is present and is a map
3. Validate that measurement_unit if provided is one of the allowed values
4. Validate that display_name if provided is a non-empty string
5. Return :ok if all validations pass, or error tuple with descriptive message

**Test Assertions**:
- returns ok for valid parameters with all fields
- returns ok for valid parameters with minimal fields
- returns ok for valid parameters with only name
- returns error when name is missing
- returns error when name is empty string
- returns error when name is not a string
- returns error when custom_metric is missing
- returns error when custom_metric is not a map
- returns error when measurement_unit has invalid value
- returns error when display_name is empty string

### format_response/1

Format the Google Analytics Admin API response into a standardized result map.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract metric details from API response (name, display_name, description)
2. Extract measurement_unit and scope information
3. Extract parameter_name and restricted_metric_type if present
4. Build standardized response map with metric metadata
5. Include relevant fields for client consumption
6. Return formatted response map

**Test Assertions**:
- extracts metric name from response
- extracts display name from response
- extracts description from response
- extracts measurement_unit from response
- extracts scope from response
- extracts parameter_name from response
- handles missing optional fields gracefully
- returns map with expected keys
- preserves all returned API fields

## Dependencies

- CodeMySpec.MCPServers.AnalyticsAdmin.Client
- CodeMySpec.MCPServers.AnalyticsAdmin.Validator
