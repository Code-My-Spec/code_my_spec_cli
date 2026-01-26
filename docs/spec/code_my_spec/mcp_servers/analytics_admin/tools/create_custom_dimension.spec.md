# CodeMySpec.MCPServers.AnalyticsAdmin.Tools.CreateCustomDimension

MCP tool for creating new custom dimensions in Google Analytics 4 properties. Creates a custom dimension with specified configuration including display name, parameter name, scope, and optional settings like description and ads personalization exclusion.

## Functions

### execute/1

Execute the create custom dimension tool with provided parameters.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Validate input parameters using validate_params/1
2. Build custom dimension object from input parameters
3. Extract parent property ID from parameters
4. Call Google Analytics Admin API to create the custom dimension
5. Format the API response into standardized result map
6. Return success tuple with created dimension details or error tuple with message

**Test Assertions**:
- returns error when property parameter is missing
- returns error when display_name parameter is missing
- returns error when parameter_name parameter is missing
- returns error when scope parameter is missing
- returns success with dimension details when creation succeeds
- returns error with API error message when API call fails
- validates property ID format
- validates parameter_name format and length based on scope
- validates display_name length constraints
- validates description length constraints when provided
- handles optional disallow_ads_personalization parameter
- returns created dimension with auto-generated name field

### validate_params/1

Validate input parameters for the create custom dimension tool.

```elixir
@spec validate_params(map()) :: :ok | {:error, String.t()}
```

**Process**:
1. Check that property parameter exists and is a non-empty string
2. Check that display_name parameter exists and is a non-empty string
3. Validate display_name length is at most 82 characters
4. Validate display_name format (alphanumeric plus space and underscore, starting with letter)
5. Check that parameter_name parameter exists and is a non-empty string
6. Validate parameter_name format (alphanumeric and underscore, starting with letter)
7. Check that scope parameter exists and is valid (USER, EVENT, or ITEM)
8. Validate parameter_name length based on scope (24 chars for USER, 40 for EVENT/ITEM)
9. If description provided, validate length is at most 150 characters
10. If disallow_ads_personalization provided, validate it is boolean
11. Return :ok if all validations pass, or error tuple with validation message

**Test Assertions**:
- returns ok for valid minimal parameters
- returns ok for valid parameters with all optional fields
- returns error when property is missing
- returns error when property is empty string
- returns error when display_name is missing
- returns error when display_name is empty string
- returns error when display_name exceeds 82 characters
- returns error when display_name has invalid format
- returns error when parameter_name is missing
- returns error when parameter_name is empty string
- returns error when parameter_name has invalid format
- returns error when parameter_name exceeds length limit for USER scope
- returns error when parameter_name exceeds length limit for EVENT scope
- returns error when scope is missing
- returns error when scope is invalid value
- returns error when description exceeds 150 characters
- returns error when disallow_ads_personalization is not boolean
- allows disallow_ads_personalization for USER scope
- validates property ID format

### build_custom_dimension/1

Build the custom dimension object from validated input parameters.

```elixir
@spec build_custom_dimension(map()) :: map()
```

**Process**:
1. Extract required fields (display_name, parameter_name, scope) from parameters
2. Create base custom dimension map with required fields
3. Add optional description field if provided
4. Add optional disallow_ads_personalization field if provided
5. Return complete custom dimension object map

**Test Assertions**:
- builds dimension with required fields only
- includes display_name in output
- includes parameter_name in output with correct casing
- includes scope in output
- includes description when provided
- includes disallow_ads_personalization when provided
- omits description when not provided
- omits disallow_ads_personalization when not provided
- preserves all field values correctly

### format_response/1

Format the Google Analytics Admin API response into a standardized result map.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract dimension details from API response (name, display_name, parameter_name, scope)
2. Extract optional fields (description, disallow_ads_personalization)
3. Build standardized response map with dimension metadata
4. Include all relevant fields for client consumption
5. Return formatted response map

**Test Assertions**:
- extracts dimension name from response
- extracts display_name from response
- extracts parameter_name from response
- extracts scope from response
- extracts description from response when present
- extracts disallow_ads_personalization from response when present
- handles missing optional fields gracefully
- returns map with expected keys
- preserves field values correctly

## Dependencies

- GoogleApi.AnalyticsAdmin.V1alpha.Api.Properties
- GoogleApi.AnalyticsAdmin.V1alpha.Connection
- GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaCustomDimension
