# Architecture.Tools.UpdateSpecMetadata

Tool for updating metadata fields of component and context specifications in the architecture design system.

## Purpose

This tool allows updating non-structural metadata of architectural specifications such as descriptions, tags, status, and other metadata fields without modifying the core functional specification or dependencies.

## Functions

### execute/1

Updates the metadata of an existing specification.

```elixir
@spec execute(params :: map()) :: {:ok, map()} | {:error, term()}
```

**Parameters:**
- `params` - Map containing:
  - `spec_id` (required, string): Identifier of the specification to update
  - `description` (optional, string): Updated description of the component/context
  - `status` (optional, string): Status of the specification (e.g., "draft", "review", "approved")
  - `tags` (optional, list(string)): Tags for categorization
  - `metadata` (optional, map()): Additional custom metadata fields

**Returns:**
- `{:ok, updated_spec}` - Successfully updated specification with metadata
- `{:error, :not_found}` - Specification with given ID not found
- `{:error, :invalid_params}` - Invalid parameters provided
- `{:error, reason}` - Other errors during update

**Process:**
1. Validate input parameters
2. Fetch the existing specification by ID
3. Validate that spec exists
4. Merge new metadata with existing specification
5. Validate updated specification structure
6. Persist the updated specification
7. Return the updated specification

**Examples:**

```elixir
# Update description and status
Architecture.Tools.UpdateSpecMetadata.execute(%{
  spec_id: "auth_context",
  description: "Updated authentication and authorization context",
  status: "approved"
})
# => {:ok, %{id: "auth_context", description: "Updated...", status: "approved", ...}}

# Update tags
Architecture.Tools.UpdateSpecMetadata.execute(%{
  spec_id: "user_module",
  tags: ["core", "authentication", "users"]
})
# => {:ok, %{id: "user_module", tags: ["core", "authentication", "users"], ...}}

# Spec not found
Architecture.Tools.UpdateSpecMetadata.execute(%{spec_id: "nonexistent"})
# => {:error, :not_found}
```

## Dependencies

### Internal
- `CodeMySpec.Components` - For accessing and updating component specifications
- `CodeMySpec.Validators` - For validating specification structure and metadata

### External
- None

## Configuration

None required.

## Error Handling

- Returns `{:error, :not_found}` when specification ID doesn't exist
- Returns `{:error, :invalid_params}` when required parameters are missing or invalid
- Returns `{:error, :validation_failed}` when updated metadata doesn't pass validation
- Logs all errors for debugging purposes

## Test Assertions

1. Successfully updates specification description
2. Successfully updates specification status
3. Successfully updates specification tags
4. Successfully updates multiple metadata fields at once
5. Returns error when spec_id is not found
6. Returns error when spec_id parameter is missing
7. Preserves existing metadata fields not specified in update
8. Validates status field against allowed values
9. Handles concurrent updates gracefully
10. Returns updated specification with all metadata fields
