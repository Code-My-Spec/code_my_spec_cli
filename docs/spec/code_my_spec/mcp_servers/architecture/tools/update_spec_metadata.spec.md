# CodeMySpec.MCPServers.Architecture.Tools.UpdateSpecMetadata

MCP tool for updating metadata fields of component and context specifications in the architecture design system. This tool enables AI agents to modify non-structural metadata such as descriptions, tags, status, and other metadata fields without altering the core functional specification or dependencies.

## Functions

### execute/1

Updates the metadata of an existing specification.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Extract spec_id from params and validate it is present
2. Validate input parameters for required fields and correct types
3. Fetch the existing specification by ID from the Components context
4. Verify that the specification exists
5. Merge new metadata fields with existing specification data
6. Validate the updated specification structure maintains integrity
7. Persist the updated specification to the database
8. Return success tuple with the updated specification or error tuple with reason

**Test Assertions**:
- successfully updates specification description
- successfully updates specification status
- successfully updates specification tags
- successfully updates multiple metadata fields at once
- returns error when spec_id is not found
- returns error when spec_id parameter is missing
- preserves existing metadata fields not specified in update
- validates status field against allowed values
- handles concurrent updates gracefully
- returns updated specification with all metadata fields

### validate_params/1

Validate input parameters for the update operation.

```elixir
@spec validate_params(map()) :: :ok | {:error, String.t()}
```

**Process**:
1. Check that spec_id parameter exists and is a non-empty string
2. Validate description is a string if provided
3. Validate status is one of allowed values if provided
4. Validate tags is a list of strings if provided
5. Validate metadata is a map if provided
6. Ensure at least one updateable field is present
7. Return :ok if all validations pass, or error tuple with validation message

**Test Assertions**:
- returns ok for valid parameters with spec_id and description
- returns ok for valid parameters with spec_id and status
- returns ok for valid parameters with spec_id and tags
- returns ok for valid parameters with multiple update fields
- returns error when spec_id is missing
- returns error when spec_id is empty string
- returns error when description is not a string
- returns error when status is not a valid value
- returns error when tags is not a list
- returns error when tags contains non-string values
- returns error when metadata is not a map
- returns error when no updateable fields are provided

### format_response/1

Format the updated specification into a standardized response map.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract specification fields (id, name, description, module_name)
2. Extract metadata fields (status, tags, metadata)
3. Extract timestamps (inserted_at, updated_at)
4. Build standardized response map with all relevant fields
5. Include component type and project associations
6. Return formatted response map for MCP client consumption

**Test Assertions**:
- extracts spec id from specification
- extracts spec name from specification
- extracts description from specification
- extracts status from specification
- extracts tags from specification
- extracts metadata map from specification
- includes timestamps in formatted response
- handles missing optional fields gracefully
- returns map with expected keys
- preserves all updated metadata fields

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Agents.Scope
