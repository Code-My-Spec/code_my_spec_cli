# ClearStoryComponent

MCP tool that removes a component association from a user story. This tool is exposed through the StoriesServer MCP interface to allow AI agents to manage story-component relationships by clearing component references.

## Functions

### call/1

Execute the clear story component tool with the provided arguments.

```elixir
@spec call(map()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Extract story_id and component_id from the input arguments
2. Validate that both IDs are present and valid
3. Retrieve the story using the story_id with proper scoping
4. Verify the story exists and the user has permission to modify it
5. Remove the component association from the story
6. Return success response with updated story information

**Test Assertions**:
- returns error when story_id is missing
- returns error when component_id is missing
- returns error when story does not exist
- returns error when user lacks permission to modify story
- successfully removes component association from story
- returns success response with updated story data
- handles non-existent component_id gracefully

### build_definition/0

Build the MCP tool definition for this tool.

```elixir
@spec build_definition() :: map()
```

**Process**:
1. Create tool definition map with name "clear_story_component"
2. Define input schema with required story_id and component_id parameters
3. Add description explaining the tool's purpose
4. Return the complete tool definition structure

**Test Assertions**:
- returns map with correct tool name
- includes story_id in input schema as required parameter
- includes component_id in input schema as required parameter
- includes clear description of tool purpose
- follows MCP tool definition format

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Stories.StoryRepository
- CodeMySpec.Components
- CodeMySpec.Agents.Scope
