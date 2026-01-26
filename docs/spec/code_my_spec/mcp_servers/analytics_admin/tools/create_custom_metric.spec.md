# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.CreateCustomMetric

MCP tool for creating new custom metrics in Google Analytics 4 (GA4) properties. Provides a structured interface for AI agents to register custom metrics through the Analytics Admin API.

## Functions

### execute/1

Execute the create custom metric tool with provided parameters.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract property ID and custom metric parameters from input map
2. Validate that required parameters (property, display_name, measurement_unit, scope) are present
3. Build the custom metric creation payload with all provided fields
4. Call Google Analytics Admin API to create the custom metric
5. Format the API response into a standardized result map
6. Return success tuple with created metric details or error tuple with message

**Test Assertions**:
- returns error when property parameter is missing
- returns error when display_name parameter is missing
- returns error when measurement_unit parameter is missing
- returns error when scope parameter is missing
- returns success with metric details when creation succeeds
- returns error with API error message when API call fails
- validates property ID format
- validates measurement_unit is valid enum value
- validates scope is valid enum value
- includes optional description when provided
- includes optional parameter_name when provided

### build_custom_metric/1

Build the custom metric creation payload from provided parameters.

```elixir
@spec build_custom_metric(map()) :: map()
```

**Process**:
1. Extract required fields (display_name, measurement_unit, scope) from input map
2. Extract optional fields (description, parameter_name) if provided
3. Build the custom metric map with all provided fields
4. Return the constructed custom metric payload

**Test Assertions**:
- includes display_name in payload
- includes measurement_unit in payload
- includes scope in payload
- includes description when provided
- includes parameter_name when provided
- omits description when not provided
- omits parameter_name when not provided
- preserves all field values exactly as provided

### validate_params/1

Validate input parameters for the create custom metric tool.

```elixir
@spec validate_params(map()) :: :ok | {:error, String.t()}
```

**Process**:
1. Check that property parameter exists and is a non-empty string
2. Check that display_name parameter exists and is a non-empty string
3. Check that measurement_unit parameter exists and is valid enum value
4. Check that scope parameter exists and is valid enum value
5. Validate property ID matches expected format (properties/PROPERTY_ID)
6. Validate optional description is string if provided
7. Validate optional parameter_name is valid identifier if provided
8. Return :ok if all validations pass, or error tuple with validation message

**Test Assertions**:
- returns ok for valid parameters with required fields only
- returns ok for valid parameters with all fields
- returns error when property is missing
- returns error when property is empty string
- returns error when property format is invalid
- returns error when display_name is missing
- returns error when display_name is empty string
- returns error when measurement_unit is missing
- returns error when measurement_unit is invalid value
- returns error when scope is missing
- returns error when scope is invalid value
- returns error when description is not a string
- returns error when parameter_name has invalid format

### build_request/1

Build the Google Analytics Admin API request for creating a custom metric.

```elixir
@spec build_request(map()) :: map()
```

**Process**:
1. Extract property ID from parameters
2. Build the parent property path in format: properties/{property}
3. Construct the custom metric payload using build_custom_metric/1
4. Build the API request map with parent path and custom metric data
5. Return complete request map for API client

**Test Assertions**:
- builds request with correct parent path
- includes custom metric payload in request
- constructs valid parent path from property ID
- includes all required custom metric fields
- includes optional fields when provided
- handles property ID with or without properties prefix

### format_response/1

Format the Google Analytics Admin API response into a standardized result map.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract metric details from API response (name, display_name, description)
2. Extract measurement configuration (measurement_unit, scope)
3. Extract parameter name and resource identifiers
4. Build standardized response map with metric metadata
5. Include relevant fields for client consumption
6. Return formatted response map

**Test Assertions**:
- extracts metric name from response
- extracts display_name from response
- extracts measurement_unit from response
- extracts scope from response
- extracts description when present
- extracts parameter_name when present
- includes resource name in formatted response
- handles missing optional fields gracefully
- returns map with expected keys

## Dependencies

- CodeMySpec.MCPServers.AnalyticsAdmin.Client
- CodeMySpec.MCPServers.AnalyticsAdmin.Validator
