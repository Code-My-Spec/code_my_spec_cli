# UpdateCustomDimension

MCP tool for updating custom dimensions in Google Analytics 4 properties via the Analytics Admin API.

This module provides an MCP (Model Context Protocol) tool that allows AI agents to update existing custom dimensions in a Google Analytics 4 property. The tool validates the dimension name format, ensures required fields are provided, and uses the authenticated user's OAuth credentials to make API calls.

## Functions

### execute/2

Executes the update custom dimension tool with provided parameters and frame context.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate that the frame contains a valid scope with active account and project
2. Validate the dimension name follows the format: properties/{property_id}/customDimensions/{dimension_id}
3. Validate the parameters and build the custom dimension map with only fields being updated
4. Get the Analytics API connection using the scoped user's OAuth integration
5. Call the Analytics API to update the custom dimension with the specified update mask
6. Format the successful response with dimension details
7. Handle errors for invalid dimension name, missing fields, or API failures
8. Return the response tuple with the frame

**Test Assertions**:
- validates frame contains active account and project
- validates dimension name matches required format
- rejects invalid dimension name format
- rejects request when no fields are provided for update (unless update_mask is "*")
- builds custom dimension map with only provided fields
- converts snake_case parameter names to camelCase for API
- successfully updates dimension with valid parameters
- returns formatted response with updated dimension details
- handles API errors gracefully
- preserves frame state in response tuple

### validate_dimension_name/1

Validates that a dimension name follows the required format.

```elixir
@spec validate_dimension_name(binary() | any()) :: {:ok, binary()} | {:error, :invalid_dimension_name}
```

**Process**:
1. Check if the name is a binary string
2. Match against regex pattern: properties/{digits}/customDimensions/{digits}
3. Return {:ok, name} if valid, {:error, :invalid_dimension_name} otherwise

**Test Assertions**:
- accepts valid dimension name format
- rejects dimension name missing properties prefix
- rejects dimension name missing customDimensions segment
- rejects dimension name with non-numeric property ID
- rejects dimension name with non-numeric dimension ID
- rejects non-binary input

### validate_params/1

Validates and transforms update parameters into API-compatible format.

```elixir
@spec validate_params(map()) :: {:ok, map()} | {:error, :no_fields_to_update}
```

**Process**:
1. Build empty custom dimension map
2. Add displayName to map if display_name parameter is present
3. Add description to map if description parameter is present
4. Add disallowAdsPersonalization to map if disallow_ads_personalization parameter is present
5. Check if resulting map is empty and update_mask is not "*"
6. Return {:error, :no_fields_to_update} if no fields provided, otherwise {:ok, custom_dimension}

**Test Assertions**:
- builds map with displayName when display_name provided
- builds map with description when description provided
- builds map with disallowAdsPersonalization when disallow_ads_personalization provided
- builds map with multiple fields when multiple parameters provided
- returns error when no fields provided and update_mask is not "*"
- allows empty map when update_mask is "*"
- converts parameter names to camelCase format

### format_response/1

Formats the API response into a user-friendly text response.

```elixir
@spec format_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create a new tool response
2. Add formatted text showing the updated dimension details
3. Include dimension name, display name, parameter name, scope, description, and ads personalization setting
4. Handle nil values with default fallbacks

**Test Assertions**:
- formats response with all dimension fields
- handles nil displayName with "Unnamed" default
- handles nil scope with "N/A" default
- handles nil description with "No description" default
- handles nil disallowAdsPersonalization with false default
- returns Hermes.Server.Response struct

### error_response/1

Formats an error message into an error response.

```elixir
@spec error_response(binary()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create a new tool response
2. Add the error message to the response
3. Return the error response

**Test Assertions**:
- creates error response with provided message
- returns Hermes.Server.Response struct
- accepts binary error messages

## Dependencies

- Hermes.Server.Component
- Hermes.Server.Response
- CodeMySpec.Google.Analytics
- CodeMySpec.McpServers.Validators
