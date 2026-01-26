# CodeMySpec.MCPServers.Stories.Tools.UpdateStory

MCP tool module for updating existing user story metadata through the StoriesServer. This tool enables AI agents to modify story fields including title, description, acceptance criteria, and status, supporting iterative refinement of requirements within the CodeMySpec platform.

## Functions

### execute/2

Execute the update_story tool with provided parameters and MCP frame context.

```elixir
@spec execute(map(), map()) :: {:reply, map(), map()}
```

**Process**:
1. Validate the MCP frame has valid scope (active account and project) using Validators.validate_scope/1
2. Extract story_id and update attributes from the input arguments
3. Retrieve the story using Stories.get_story/2 with the provided story_id and scope
4. Verify the story exists and belongs to the current account's project
5. Call Stories.update_story/3 with scope, story struct, and attributes map
6. If update succeeds, format success response using StoriesMapper.story_updated_response/1
7. Handle nil story by returning StoriesMapper.not_found_error/0
8. Handle Ecto.Changeset validation errors by returning StoriesMapper.validation_error/1
9. Handle other errors by returning StoriesMapper.error/1
10. Return {:reply, response, frame} tuple for MCP protocol

**Test Assertions**:
- updates story title successfully with valid story_id
- updates story description successfully with valid story_id
- updates story status successfully with valid story_id
- updates acceptance_criteria array successfully with valid story_id
- updates multiple fields simultaneously with valid story_id
- validates scope has active account before proceeding
- validates scope has active project before proceeding
- returns not_found_error when story_id does not exist
- returns validation_error when title is empty or nil
- returns validation_error when title exceeds maximum length
- returns validation_error when status is invalid enum value
- returns validation_error when acceptance_criteria is not a list
- returns error when story belongs to different account
- includes updated story data in success response
- broadcasts story update event to PubSub subscribers
- maintains frame context in reply tuple
- handles partial updates without overwriting unchanged fields

### build_definition/0

Build the MCP tool definition for the update_story tool.

```elixir
@spec build_definition() :: map()
```

**Process**:
1. Create tool definition map with name "update_story"
2. Define input schema with required story_id parameter
3. Define optional update parameters (title, description, acceptance_criteria, status)
4. Add parameter descriptions and type constraints
5. Add tool description explaining the update functionality
6. Return the complete tool definition structure following MCP protocol

**Test Assertions**:
- returns map with correct tool name "update_story"
- includes story_id in input schema as required integer parameter
- includes title in input schema as optional string parameter
- includes description in input schema as optional string parameter
- includes acceptance_criteria in input schema as optional array parameter
- includes status in input schema as optional enum parameter
- includes clear description of tool purpose
- follows MCP tool definition format
- specifies valid status enum values (draft, in_progress, completed, cancelled)

### validate_params/1

Validate the input parameters for the update story request.

```elixir
@spec validate_params(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Check that story_id parameter is present and is a positive integer
2. Verify at least one update field is provided (title, description, acceptance_criteria, or status)
3. Validate title is a string if provided
4. Validate description is a string if provided
5. Validate acceptance_criteria is a list of strings if provided
6. Validate status is one of the allowed enum values if provided
7. Return {:ok, params} if all validations pass
8. Return {:error, message} with descriptive error for first validation failure

**Test Assertions**:
- returns ok for valid story_id with title update
- returns ok for valid story_id with description update
- returns ok for valid story_id with status update
- returns ok for valid story_id with acceptance_criteria update
- returns ok for valid story_id with multiple field updates
- returns error when story_id is missing
- returns error when story_id is not an integer
- returns error when story_id is zero or negative
- returns error when no update fields are provided
- returns error when title is not a string
- returns error when title is empty string
- returns error when description is not a string
- returns error when acceptance_criteria is not a list
- returns error when acceptance_criteria contains non-string elements
- returns error when status is not a valid enum value

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Stories.Story
- CodeMySpec.MCPServers.Stories.StoriesMapper
- CodeMySpec.MCPServers.Validators
- CodeMySpec.Agents.Scope
- Hermes.Server.Component
