# CodeMySpec.MCPServers.Architecture.Tools.DeleteSpec

MCP tool for removing component or context specification files from the architecture design system. Provides a structured interface for AI agents to delete specification documents through the Architecture MCP server.

## Functions

### execute/1

Executes the delete specification operation for a specified component or context.

```elixir
@spec execute(map()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Validate required parameters (spec identifier or module name)
2. Extract specification identifier from the input map
3. Resolve the specification file path from the identifier
4. Verify the specification file exists
5. Check for dependencies that reference this specification
6. Execute the file deletion operation
7. Update any related component or context records
8. Return formatted success response or error

**Test Assertions**:
- returns error when spec identifier is missing
- returns error when spec identifier is empty string
- returns error when specification file does not exist
- returns error when specification has dependent components
- successfully deletes specification file with valid identifier
- returns formatted success response with deleted spec details
- removes specification file from filesystem
- updates component record to reflect spec deletion
- handles file system permission errors
- handles concurrent deletion attempts gracefully

### validate_params/1

Validates the input parameters for the delete specification operation.

```elixir
@spec validate_params(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Check for required spec identifier parameter (spec_id or module_name)
2. Validate identifier format is non-empty string
3. Validate identifier matches expected pattern
4. Check for optional force flag to bypass dependency checks
5. Return validated params or error message

**Test Assertions**:
- returns error when params is empty map
- returns error when spec_id is nil
- returns error when spec_id is empty string
- returns error when module_name is nil
- returns error when module_name is empty string
- accepts valid spec_id format
- accepts valid module_name format
- returns ok tuple with validated params when inputs are valid
- accepts optional force parameter as boolean
- defaults force to false when not provided

### resolve_spec_path/1

Resolves the file system path to the specification file from the identifier.

```elixir
@spec resolve_spec_path(String.t()) :: {:ok, String.t()} | {:error, String.t()}
```

**Process**:
1. Take specification identifier (module_name or spec_id)
2. Convert module name to file path format if needed
3. Construct expected specification file path
4. Check if file exists at the resolved path
5. Return resolved path or error if not found

**Test Assertions**:
- resolves path from valid module name
- resolves path from valid spec_id
- converts module name to correct file path format
- handles nested module paths correctly
- returns error when file does not exist at resolved path
- returns absolute path to specification file
- handles both Unix and Windows path separators

### check_dependencies/1

Checks if other specifications depend on the specification being deleted.

```elixir
@spec check_dependencies(String.t()) :: {:ok, []} | {:error, list(String.t())}
```

**Process**:
1. Take specification identifier
2. Query component dependency records for references
3. Search specification files for dependency declarations
4. Build list of dependent specification identifiers
5. Return empty list if no dependencies or error with dependents list

**Test Assertions**:
- returns empty list when no dependencies exist
- returns list of dependent module names when dependencies exist
- checks both database records and file content
- identifies components that list spec in Dependencies section
- identifies components with delegate references
- handles circular dependencies gracefully
- ignores test file references

### delete_spec_file/1

Removes the specification file from the file system.

```elixir
@spec delete_spec_file(String.t()) :: :ok | {:error, term()}
```

**Process**:
1. Take the resolved specification file path
2. Verify file exists before deletion
3. Execute file deletion operation
4. Verify file was successfully removed
5. Return success or error with reason

**Test Assertions**:
- successfully deletes existing specification file
- returns error when file does not exist
- returns error when lacking file system permissions
- verifies file removal after deletion
- handles read-only file system errors
- handles file locked by another process

### format_response/1

Formats the deletion result into a structured response for the MCP tool.

```elixir
@spec format_response(map()) :: map()
```

**Process**:
1. Extract specification details from deletion result
2. Build standardized response map with status
3. Include specification identifier and file path
4. Add deletion timestamp
5. Include any warnings about related components
6. Return formatted response map

**Test Assertions**:
- returns map with success status
- includes spec identifier in response
- includes file path in response
- includes deletion timestamp
- includes list of affected components if any
- handles empty result gracefully
- preserves all relevant metadata from operation

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- File
- Path
