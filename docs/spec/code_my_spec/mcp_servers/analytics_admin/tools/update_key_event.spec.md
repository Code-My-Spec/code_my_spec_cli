# UpdateKeyEvent

MCP tool for updating a key event in Google Analytics Admin API. This tool provides the interface for modifying key event properties including counting method and display configuration.

## Functions

### handle/1

Handles the MCP tool request to update a key event in Google Analytics Admin.

```elixir
@spec handle(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract and validate required parameters (name, key_event) from the request map
2. Build the key event update payload from the key_event parameter
3. Call Google Analytics Admin API to update the key event
4. Transform the API response into the MCP tool response format
5. Return success with updated key event data or error with message

**Test Assertions**:
- returns error when name parameter is missing
- returns error when key_event parameter is missing
- returns error when name is not a valid string
- returns error when key_event is not a valid map
- successfully updates key event with valid parameters
- returns API error message when API call fails
- transforms API response correctly into MCP format

### build_key_event/1

Builds a key event update payload from the provided parameters.

```elixir
@spec build_key_event(map()) :: map()
```

**Process**:
1. Extract optional fields from the input map (counting_method, custom, deletable, event_name)
2. Build a map containing only the provided fields
3. Return the constructed key event payload

**Test Assertions**:
- returns empty map when no fields provided
- includes counting_method when provided
- includes custom field when provided
- includes deletable field when provided
- includes event_name when provided
- includes all fields when all are provided
- ignores unknown fields

### validate_params/1

Validates the input parameters for the update key event request.

```elixir
@spec validate_params(map()) :: :ok | {:error, String.t()}
```

**Process**:
1. Check that name parameter is present and is a non-empty string
2. Check that key_event parameter is present and is a map
3. Validate that counting_method if provided is one of the allowed values
4. Return :ok if all validations pass, or error tuple with descriptive message

**Test Assertions**:
- returns ok for valid parameters with all fields
- returns ok for valid parameters with minimal fields
- returns error when name is missing
- returns error when name is empty string
- returns error when name is not a string
- returns error when key_event is missing
- returns error when key_event is not a map
- returns error when counting_method has invalid value

## Dependencies

- CodeMySpec.MCPServers.AnalyticsAdmin.Client
- CodeMySpec.MCPServers.AnalyticsAdmin.Validators
