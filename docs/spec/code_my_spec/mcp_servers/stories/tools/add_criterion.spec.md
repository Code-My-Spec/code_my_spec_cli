# CodeMySpec.McpServers.Stories.Tools.AddCriterion

MCP tool module for adding acceptance criteria to existing stories through the StoriesServer. This tool enables AI agents to add testable conditions that define when a story is complete, supporting the test-driven development workflow within the CodeMySpec platform.

## Functions

### execute/2

Execute the add_criterion tool with provided parameters and MCP frame context.

```elixir
@spec execute(map(), map()) :: {:reply, map(), map()}
```

**Process**:
1. Validate the MCP frame has valid scope (active account and project) using Validators.validate_scope/1
2. Retrieve the story using Stories.get_story/2 with the provided story_id
3. If story exists, create a new criterion using AcceptanceCriteria.create_criterion/3 with scope, story, and description
4. If creation succeeds, format success response using StoriesMapper.criterion_added_response/2
5. Handle nil story by returning StoriesMapper.not_found_error/0
6. Handle Ecto.Changeset errors by returning StoriesMapper.validation_error/1
7. Handle other errors by returning StoriesMapper.error/1
8. Return {:reply, response, frame} tuple for MCP protocol

**Test Assertions**:
- creates criterion successfully with valid story_id and description
- validates scope has active account before proceeding
- validates scope has active project before proceeding
- returns not_found_error when story_id does not exist
- returns validation_error when description is empty or nil
- returns validation_error when description exceeds maximum length
- returns error when story belongs to different account
- includes criterion id, description, and story_id in success response
- broadcasts criterion creation event to PubSub subscribers
- maintains frame context in reply tuple

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
