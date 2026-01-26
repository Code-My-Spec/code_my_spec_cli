# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.DeleteKeyEvent

MCP tool for removing key events from Google Analytics 4 (GA4) properties. Provides a structured interface for AI agents to delete key events through the Analytics Admin API.

## Functions

### execute/1

Executes the delete key event operation for a specified GA4 property and event.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Validate required parameters (property name and event name)
2. Extract property and event identifiers from the input map
3. Construct the GA4 Analytics Admin API delete request
4. Execute the delete operation via API client
5. Return formatted success response or error

**Test Assertions**:
- returns error when property name is missing
- returns error when event name is missing
- returns error when property does not exist
- returns error when event does not exist
- successfully deletes existing key event
- returns formatted success response with deleted event details
- handles API authentication failures
- handles API rate limiting errors
- handles network timeouts

### validate_params/1

Validates the input parameters for the delete key event operation.

```elixir
@spec validate_params(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Check for required property parameter
2. Check for required event_name parameter
3. Validate property format (properties/PROPERTY_ID)
4. Validate event_name is non-empty string
5. Return validated params or error message

**Test Assertions**:
- returns error when params is empty map
- returns error when property is nil
- returns error when property is empty string
- returns error when event_name is nil
- returns error when event_name is empty string
- returns error when property format is invalid
- returns ok tuple with validated params when all inputs are valid

### build_resource_name/2

Constructs the full resource name for the key event to be deleted.

```elixir
@spec build_resource_name(String.t(), String.t()) :: String.t()
```

**Process**:
1. Take property name (e.g., "properties/123456")
2. Take event name (e.g., "purchase")
3. Combine into full resource path: "properties/PROPERTY_ID/keyEvents/EVENT_NAME"
4. Return formatted resource name string

**Test Assertions**:
- builds correct resource name with valid inputs
- handles property names with and without trailing slashes
- preserves event name exactly as provided
- returns properly formatted string for API consumption

### format_response/1

Formats the API response into a structured result for the MCP tool.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract relevant fields from API response
2. Build standardized response map with status and details
3. Include property and event identifiers
4. Add timestamp of deletion
5. Return formatted response map

**Test Assertions**:
- returns map with success status
- includes property identifier in response
- includes event name in response
- includes deletion timestamp
- handles empty API responses gracefully
- preserves additional metadata from API response

## Dependencies

- CodeMySpec.MCPServers.AnalyticsAdmin.Client
- CodeMySpec.MCPServers.AnalyticsAdmin.Validator
