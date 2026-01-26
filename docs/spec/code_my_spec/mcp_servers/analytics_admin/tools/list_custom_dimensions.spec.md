# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.ListCustomDimensions

MCP tool for listing Google Analytics 4 custom dimensions for a specified property.

## Functions

### execute/1

Execute the list custom dimensions tool with the provided arguments.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Validate required arguments (property_id)
2. Extract optional parameters (page_size, page_token)
3. Build Google Analytics Admin API request
4. Call Analytics Admin API to retrieve custom dimensions list
5. Format response with custom dimensions array and pagination info
6. Return success tuple with formatted result

**Test Assertions**:
- returns error when property_id is missing
- returns error when property_id is invalid format
- successfully lists custom dimensions with valid property_id
- respects page_size parameter when provided
- handles pagination with page_token
- returns empty list when no custom dimensions exist
- handles API errors gracefully

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
- returns ok with valid property_id only
- returns ok with all valid parameters

### format_response/1

Format the raw API response into the tool's output structure.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract custom dimensions array from API response
2. Map each dimension to simplified format with key fields
3. Extract pagination metadata (next_page_token)
4. Build output map with dimensions list and pagination info
5. Return formatted response map

**Test Assertions**:
- formats empty response correctly
- formats single custom dimension correctly
- formats multiple custom dimensions correctly
- includes all required dimension fields
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
3. Add page_size to request if provided
4. Add page_token to request if provided
5. Return complete request map

**Test Assertions**:
- builds request with property_id only
- includes page_size when provided
- includes page_token when provided
- includes all parameters when all provided
- uses correct parent path format

## Dependencies

- CodeMySpec.MCPServers.AnalyticsAdmin.Client
- CodeMySpec.MCPServers.AnalyticsAdmin.Validator
