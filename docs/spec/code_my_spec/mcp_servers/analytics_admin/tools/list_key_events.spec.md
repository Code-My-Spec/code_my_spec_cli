# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.ListKeyEvents

MCP tool for listing Google Analytics 4 key events for a specified property. Returns all key events configured for a GA4 property with support for pagination.

## Functions

### execute/1

Execute the list key events tool with the provided arguments.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Validate required arguments (property_id)
2. Extract optional parameters (page_size, page_token)
3. Build Google Analytics Admin API request
4. Call Analytics Admin API to retrieve key events list
5. Format response with key events array and pagination info
6. Return success tuple with formatted result

**Test Assertions**:
- returns error when property_id is missing
- returns error when property_id is invalid format
- successfully lists key events with valid property_id
- respects page_size parameter when provided
- handles pagination with page_token
- returns empty list when no key events exist
- handles API errors gracefully
- handles API authentication failures
- handles network timeouts

### validate_args/1

Validate the arguments passed to the tool.

```elixir
@spec validate_args(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Check for required property_id field
2. Validate property_id format (properties/PROPERTY_ID)
3. Validate optional page_size is positive integer if present
4. Validate optional page_token is string if present
5. Return validated arguments map or error

**Test Assertions**:
- returns error when args is empty map
- returns error when property_id is nil
- returns error when property_id is empty string
- returns error when property_id has invalid format
- returns error when page_size is negative
- returns error when page_size is zero
- returns error when page_size is not an integer
- returns error when page_size exceeds maximum (200)
- returns ok with valid property_id only
- returns ok with all valid parameters

### format_response/1

Format the raw API response into the tool's output structure.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract key events array from API response
2. Map each key event to simplified format with key fields
3. Extract pagination metadata (next_page_token)
4. Build output map with key events list and pagination info
5. Return formatted response map

**Test Assertions**:
- formats empty response correctly
- formats single key event correctly
- formats multiple key events correctly
- includes all required key event fields (name, event_name, counting_method)
- includes optional fields when present (custom, create_time)
- includes next_page_token when present
- omits next_page_token when not present
- handles missing optional fields gracefully

### build_request/1

Build the Google Analytics Admin API request from validated arguments.

```elixir
@spec build_request(map()) :: map()
```

**Process**:
1. Extract property_id from arguments
2. Build base request with parent property path
3. Add page_size to request if provided (default: 50, max: 200)
4. Add page_token to request if provided
5. Return complete request map

**Test Assertions**:
- builds request with property_id only
- includes page_size when provided
- includes page_token when provided
- includes all parameters when all provided
- uses correct parent path format (properties/PROPERTY_ID)
- defaults to 50 items per page when page_size not specified

## Dependencies

- CodeMySpec.MCPServers.AnalyticsAdmin.Client
- CodeMySpec.MCPServers.AnalyticsAdmin.Validator
