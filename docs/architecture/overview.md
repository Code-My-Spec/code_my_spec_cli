# Architecture Overview

## Root Components

### AddCriterion
**module**

MCP tool module for adding acceptance criteria to existing stories through the StoriesServer. This tool enables AI agents to add testable conditions that define when a story is complete, supporting the test-driven development workflow within the CodeMySpec platform.

Dependencies:
- CodeMySpec.McpServers.Validators


## Root Components

### AddCriterion
**module**

Tool for adding acceptance criteria to existing stories.


## Root Components

### AddSimilarComponent
**module**

Tool for marking components as architectural analogs for reference.


## Root Components

### AnalyticsAdminServer
**module**

Hermes MCP server exposing Google Analytics 4 administrative tools to AI agents. Registers 14 tools for managing custom dimensions, custom metrics, and key events.


## Root Components

### ArchitectureHealthSummary
**module**

Tool for analyzing architectural quality metrics and identifying issues.


## Root Components

### ArchiveCustomDimension
**module**

Tool for archiving custom dimensions (soft delete).


## Root Components

### ArchiveCustomMetric
**module**

Tool for archiving custom metrics (soft delete).


## Root Components

### ClearStoryComponent
**module**

Tool for removing component association from a story.


## Root Components

### Cli
**module**


## Root Components

### CodeMySpecCli
**module**

### Application
**module**

### Cli
**module**

### CliRunner
**module**

### CommandBehaviour
**module**

### Components
**module**

### Config
**module**

### EvaluateAgentTask
**module**

### Exit
**module**

### Help
**module**

### Init
**module**

### Login
**module**

### Logout
**module**

### Migrator
**module**

### OAuthClient
**module**

### PackageExtension
**module**

### PatchLauncherStep
**module**

### Registry
**module**

### RemoteClient
**module**

### Scope
**module**

### Server
**module**

### Sessions
**module**

### SlashCommandBehaviour
**module**

### StartAgentTask
**module**

### Strategy
**module**

### Sync
**module**

### TerminalPanes
**module**

### WebServer
**module**

### Whoami
**module**


## Root Components

### ComponentsMapper
**module**

Maps component domain entities to MCP response formats with JSON structures for AI agent consumption.


## Root Components

### ComponentsServer
**module**

Hermes MCP server exposing component architecture tools to AI agents. Registers 16 tools for component CRUD, dependency management, similar component tracking, and architecture analysis/design workflows.


## Root Components

### ContextStatistics
**module**

Tool for computing metrics on context size, complexity, and dependencies.


## Root Components

### CreateComponent
**module**

MCP tool module for creating a single component definition through the ComponentsServer. This tool enables AI agents to create new components within a project scope, handling validation, dependency tracking, and proper component type classification according to Phoenix architectural patterns.


## Root Components

### CreateComponent
**module**

Tool for creating architectural components (contexts, modules, schemas, etc.).


## Root Components

### CreateComponents
**module**

Batch tool for creating multiple components with dependency relationships.


## Root Components

### CreateCustomDimension
**module**

Tool for registering new custom dimensions in GA4.


## Root Components

### CreateCustomMetric
**module**

Tool for registering new custom metrics in GA4.


## Root Components

### CreateDependencies
**module**

Batch tool for establishing multiple dependency relationships.


## Root Components

### CreateDependency
**module**

Tool for establishing dependency relationships between components.


## Root Components

### CreateKeyEvent
**module**

Tool for registering new key events in GA4.


## Root Components

### CreateSpec
**module**

MCP tool module for creating component and context specification documents through the ArchitectureServer. This tool enables AI agents to generate structured specification files (.spec.md) that document component functionality, dependencies, type signatures, and test assertions according to the CodeMySpec specification format.

Dependencies:
- CodeMySpec.McpServers.Validators


## Root Components

### CreateStories
**module**

Batch tool for creating multiple user stories in a single request.


## Root Components

### CreateStory
**module**

Tool for creating user stories with title, description, and acceptance criteria.


## Root Components

### DeleteComponent
**module**

Tool for removing components from the architecture.


## Root Components

### DeleteCriterion
**module**

Tool for removing acceptance criteria from stories.


## Root Components

### DeleteDependency
**module**

Tool for removing dependency relationships between components.


## Root Components

### DeleteKeyEvent
**module**

Tool for removing key events from GA4.


## Root Components

### DeleteStory
**module**

Tool for removing user stories from the system.


## Root Components

### Formatters
**module**

Response formatting utilities for MCP servers providing hybrid human-readable + JSON responses with changeset error formatting and contextual guidance.


## Root Components

### GetComponent
**module**

Tool for retrieving detailed component information including dependencies.


## Root Components

### GetCustomDimension
**module**

Tool for retrieving detailed custom dimension configuration.


## Root Components

### GetCustomMetric
**module**

Tool for retrieving detailed custom metric configuration.


## Root Components

### GetStory
**module**

Tool for retrieving detailed story information including criteria.


## Root Components

### ListComponents
**module**

Tool for listing all components in the project architecture.


## Root Components

### ListCustomDimensions
**module**

Tool for listing Google Analytics 4 custom dimensions.


## Root Components

### ListCustomMetrics
**module**

Tool for listing Google Analytics 4 custom metrics.


## Root Components

### ListKeyEvents
**module**

Tool for listing Google Analytics 4 key events.


## Root Components

### ListStories
**module**

Tool for listing stories with pagination support.


## Root Components

### ListStoryTitles
**module**

Tool for retrieving story titles and IDs only (lightweight list).


## Root Components

### OrphanedContexts
**module**

Tool for identifying components without parent relationships or stories.


## Root Components

### RemoveSimilarComponent
**module**

Tool for removing similar component relationships.


## Root Components

### ReviewContextDesign
**module**

Tool for initiating design review and validation workflow sessions.


## Root Components

### SetStoryComponent
**module**

Tool for associating a story with a component.


## Root Components

### ShowArchitecture
**module**

Tool for visualizing the component dependency graph and structure.


## Root Components

### StartContextDesign
**module**

Tool for initiating structured context design workflow sessions.


## Root Components

### StartStoryInterview
**module**

Tool for initiating structured story refinement workflow sessions.


## Root Components

### StartStoryReview
**module**

Tool for initiating story validation and approval workflow sessions.


## Root Components

### StoriesMapper
**module**

Maps story domain entities to MCP response formats with hybrid text summaries and JSON data structures for both human and programmatic consumption.


## Root Components

### StoriesServer
**module**

Hermes MCP server exposing user story management tools to AI agents. Registers 13 tools for CRUD operations on stories and acceptance criteria, plus workflow tools for story interviews and reviews.


## Root Components

### TestLocation
**module**

Testing file location fix


## Root Components

### UpdateComponent
**module**

Tool for modifying component metadata and relationships.


## Root Components

### UpdateCriterion
**module**

Tool for modifying acceptance criterion text or verification status.


## Root Components

### UpdateCustomDimension
**module**

Tool for modifying custom dimension metadata.


## Root Components

### UpdateCustomMetric
**module**

Tool for modifying custom metric metadata.


## Root Components

### UpdateKeyEvent
**module**

Tool for modifying key event configuration.


## Root Components

### UpdateSpecMetadata
**module**

Tool for updating metadata fields of component and context specifications in the architecture design system.


## Root Components

### UpdateStory
**module**

Tool for updating existing user story fields.


## Root Components

### Validators
**module**

Validation functions for MCP servers. Provides scope validation to ensure that MCP server requests have the required account and project context before executing operations.


## Root Components

### Validators
**module**

Validation utilities for MCP server requests ensuring proper scope (account and project) context.


## Root Components

### Verification
**module**

Handles verification workflows and photo validation

### Transaction
**module**

A fuel transaction requiring verification

