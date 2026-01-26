# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.CreateKeyEvent

MCP tool for creating new key events in Google Analytics 4 (GA4) properties. Provides a structured interface for AI agents to register key events through the Analytics Admin API.

## Functions

### execute/1

Executes the create key event operation for a specified GA4 property.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Validate required parameters (property and key_event data)
2. Extract property identifier and key event configuration from input map
3. Build the key event payload from the provided configuration
4. Construct the GA4 Analytics Admin API create request
5. Execute the create operation via API client
6. Format the response with created key event details
7. Return success tuple with key event data or error

**Test Assertions**:
- returns error when property parameter is missing
- returns error when key_event parameter is missing
- returns error when property does not exist
- returns error when event_name is missing from key_event
- returns error when event_name already exists as a key event
- successfully creates key event with valid parameters
- returns formatted response with created key event details including name and resource path
- handles API authentication failures
- handles API rate limiting errors
- handles network timeouts
- validates counting_method if provided

### validate_params/1

Validates the input parameters for the create key event operation.

```elixir
@spec validate_params(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Check for required property parameter
2. Check for required key_event parameter (map)
3. Validate property format (properties/PROPERTY_ID)
4. Validate key_event contains required event_name field
5. Validate event_name is non-empty string
6. Validate counting_method if provided is one of allowed values
7. Return validated params or error message

**Test Assertions**:
- returns error when params is empty map
- returns error when property is nil
- returns error when property is empty string
- returns error when property format is invalid
- returns error when key_event is nil
- returns error when key_event is not a map
- returns error when event_name is missing from key_event
- returns error when event_name is empty string
- returns error when counting_method has invalid value
- returns ok tuple with validated params when all inputs are valid
- accepts valid counting_method values

### build_key_event/1

Builds a key event creation payload from the provided parameters.

```elixir
@spec build_key_event(map()) :: map()
```

**Process**:
1. Extract required event_name field from input map
2. Extract optional counting_method field
3. Extract optional default_value field
4. Build GoogleAnalyticsAdminV1alphaKeyEvent struct
5. Include only provided fields in the payload
6. Return the constructed key event payload

**Test Assertions**:
- builds key event with event_name only
- includes counting_method when provided
- includes default_value when provided
- includes all fields when all are provided
- ignores unknown fields
- uses correct field names for API compatibility

### build_resource_parent/1

Constructs the parent resource path for the key event creation request.

```elixir
@spec build_resource_parent(String.t()) :: String.t()
```

**Process**:
1. Take property identifier (e.g., "properties/123456")
2. Validate format matches expected pattern
3. Return properly formatted parent path for API request

**Test Assertions**:
- returns correct parent path for valid property ID
- handles property identifiers with and without properties/ prefix
- preserves property ID format exactly as provided

### format_response/1

Formats the API response into a structured result for the MCP tool.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract key event details from API response
2. Build standardized response map with key event metadata
3. Include resource name, event_name, counting_method
4. Include creation timestamp
5. Include custom and deletable flags
6. Return formatted response map

**Test Assertions**:
- returns map with success status
- includes resource name in response
- includes event_name in response
- includes counting_method in response
- includes create_time timestamp
- includes custom boolean flag
- includes deletable boolean flag
- handles missing optional fields gracefully
- preserves all relevant metadata from API response

## Dependencies

- CodeMySpec.MCPServers.AnalyticsAdmin.Client
- CodeMySpec.MCPServers.AnalyticsAdmin.Validator
- GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaKeyEvent
