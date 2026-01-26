# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.ArchiveCustomDimension

Tool module for archiving Google Analytics 4 custom dimensions via the Admin API. Archives (soft deletes) a custom dimension by marking it as archived, making it unavailable for new data collection while preserving historical data.

## Functions

### execute/1

Execute the archive custom dimension tool with provided parameters.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract property ID and custom dimension name from input parameters
2. Validate that required parameters (property and name) are present
3. Call Google Analytics Admin API to archive the custom dimension
4. Format the API response into a standardized result map
5. Return success tuple with archived dimension details or error tuple with message

**Test Assertions**:
- returns error when property parameter is missing
- returns error when name parameter is missing
- returns success with dimension details when archiving succeeds
- returns error with API error message when API call fails
- validates property ID format
- validates dimension name format

### build_request/1

Build the Google Analytics Admin API request for archiving a custom dimension.

```elixir
@spec build_request(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract property ID and custom dimension name from parameters
2. Construct the dimension resource name in format: properties/{property}/customDimensions/{dimension}
3. Build the API request map with update mask for archive_state field
4. Return request map with resource name and update parameters

**Test Assertions**:
- constructs valid resource name with property and dimension IDs
- includes archive_state in update mask
- returns error for invalid property ID format
- returns error for invalid dimension name

### validate_params/1

Validate input parameters for the archive custom dimension tool.

```elixir
@spec validate_params(map()) :: :ok | {:error, String.t()}
```

**Process**:
1. Check that property parameter exists and is a non-empty string
2. Check that name parameter exists and is a non-empty string
3. Validate property ID matches expected format (numeric or properties/xxx)
4. Validate dimension name is valid identifier
5. Return :ok if all validations pass, or error tuple with validation message

**Test Assertions**:
- returns ok for valid parameters
- returns error when property is missing
- returns error when property is empty string
- returns error when name is missing
- returns error when name is empty string
- returns error for invalid property ID format
- returns error for invalid dimension name format

### format_response/1

Format the Google Analytics Admin API response into a standardized result map.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract dimension details from API response (name, display_name, description)
2. Extract archive state and timestamp information
3. Build standardized response map with dimension metadata
4. Include relevant fields for client consumption
5. Return formatted response map

**Test Assertions**:
- extracts dimension name from response
- extracts display name from response
- extracts description from response
- includes archive state in formatted response
- handles missing optional fields gracefully
- returns map with expected keys

## Dependencies

- CodeMySpec.MCPServers.AnalyticsAdmin.Client
- CodeMySpec.MCPServers.AnalyticsAdmin.Validator
