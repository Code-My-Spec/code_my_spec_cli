# CodeMySpec.McpServers.Architecture.Tools.CreateSpec

MCP tool module for creating component and context specification documents through the ArchitectureServer. This tool enables AI agents to generate structured specification files (.spec.md) that document component functionality, dependencies, type signatures, and test assertions according to the CodeMySpec specification format.

## Functions

### execute/2

Execute the create_spec tool with provided arguments and MCP frame context.

```elixir
@spec execute(map(), map()) :: {:reply, map(), map()}
```

**Process**:
1. Validate the MCP frame has valid scope (active account and project) using Validators.validate_scope/1
2. Extract spec parameters from arguments (component_id, spec_type, content)
3. Validate required fields (component_id, content)
4. Retrieve component using Components.get_component/2 with scope
5. Determine output file path based on component module name and spec_type (component vs context)
6. Parse and validate spec content follows required format (has Functions, Dependencies sections)
7. Create spec document in the file system at docs/spec/[module_path].spec.md
8. Update component record with spec metadata (spec_path, synced_at timestamp)
9. Format success response with spec file path and component information
10. Handle component not found by returning not_found_error
11. Handle validation errors by returning validation_error with details
12. Handle file system errors by returning error with message
13. Return {:reply, response, frame} tuple for MCP protocol

**Test Assertions**:
- creates spec file with valid component_id and content
- validates scope has active account and project before proceeding
- returns not_found_error when component_id does not exist
- returns validation_error when content is missing or empty
- returns validation_error when content lacks required Functions section
- returns validation_error when content lacks required Dependencies section
- creates spec file at correct path based on component module name
- updates component record with spec_path after creation
- updates component synced_at timestamp
- returns error when component belongs to different account
- includes spec file path and component data in success response
- handles file system permission errors gracefully
- broadcasts spec creation event to PubSub subscribers
- maintains frame context in reply tuple

### schema/0

Return the JSON schema definition for the create_spec tool.

```elixir
@spec schema() :: map()
```

**Process**:
1. Define input schema with required and optional parameters
2. Specify component_id as required integer field
3. Specify content as required string field containing spec markdown
4. Specify spec_type as optional enum (component, context) defaulting to auto-detect
5. Include description field for spec summary as optional string
6. Return schema in MCP tool format with inputSchema and description

**Test Assertions**:
- returns map with required schema keys (name, description, inputSchema)
- includes component_id field as required integer
- includes content field as required string
- includes spec_type field as optional enum with component and context values
- includes description field as optional string
- schema validates successfully against MCP tool schema format

### validate_spec_content/1

Validate that spec content follows the required document format.

```elixir
@spec validate_spec_content(String.t()) :: {:ok, String.t()} | {:error, String.t()}
```

**Process**:
1. Check content is non-empty string
2. Parse markdown to verify it contains H2 section headers
3. Validate presence of required ## Functions section
4. Validate presence of required ## Dependencies section
5. Check Functions section contains at least one H3 function header
6. Verify Dependencies section contains bullet list items
7. Return ok tuple with content if valid
8. Return error tuple with descriptive validation message if invalid

**Test Assertions**:
- returns ok for content with Functions and Dependencies sections
- returns error for empty content
- returns error for content missing Functions section
- returns error for content missing Dependencies section
- returns error for Functions section with no function definitions
- returns error for Dependencies section with no items
- validates Functions section has H3 headers
- validates Dependencies section has bullet list format

### determine_spec_path/2

Determine the file system path for the spec document based on component module name.

```elixir
@spec determine_spec_path(Component.t(), atom()) :: String.t()
```

**Process**:
1. Extract module name from component (e.g., "CodeMySpec.Components.Sync")
2. Convert module name to file path segments
3. Split on dots and convert to snake_case
4. Determine spec_type (component or context) if not explicitly provided
5. Build path as docs/spec/[module_path].spec.md
6. Return absolute or relative path string

**Test Assertions**:
- converts CodeMySpec.Components.Sync to docs/spec/code_my_spec/components/sync.spec.md
- converts MyApp.Accounts to docs/spec/my_app/accounts.spec.md
- handles single segment module names correctly
- creates nested directory structure for multi-segment names
- uses .spec.md extension for all spec files
- handles module names with acronyms correctly

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Agents.Scope
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- File
- Path
