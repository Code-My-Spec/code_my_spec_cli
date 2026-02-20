AnalyticsAdmin
└── Tools
    ├── ArchiveCustomDimension [module] Tool for archiving custom dimensions (soft delete).
    ├── ArchiveCustomMetric [module] Tool for archiving custom metrics (soft delete).
    ├── CreateCustomDimension [module] Tool for registering new custom dimensions in GA4.
    ├── CreateCustomMetric [module] Tool for registering new custom metrics in GA4.
    ├── CreateKeyEvent [module] Tool for registering new key events in GA4.
    ├── DeleteKeyEvent [module] Tool for removing key events from GA4.
    ├── GetCustomDimension [module] Tool for retrieving detailed custom dimension configuration.
    ├── GetCustomMetric [module] Tool for retrieving detailed custom metric configuration.
    ├── ListCustomDimensions [module] Tool for listing Google Analytics 4 custom dimensions.
    ├── ListCustomMetrics [module] Tool for listing Google Analytics 4 custom metrics.
    ├── ListKeyEvents [module] Tool for listing Google Analytics 4 key events.
    ├── UpdateCustomDimension [module] Tool for modifying custom dimension metadata.
    ├── UpdateCustomMetric [module] Tool for modifying custom metric metadata.
    └── UpdateKeyEvent [module] Tool for modifying key event configuration.
AnalyticsAdminServer [module] Hermes MCP server exposing Google Analytics 4 administrative tools to AI agents. Registers 14 tools for managing cust...
Architecture
└── Tools
    └── UpdateSpecMetadata [module] Tool for updating metadata fields of component and context specifications in the architecture design system.
CodeMySpec
└── McpServers
    ├── Architecture
    │   └── Tools
    │       └── CreateSpec [module] MCP tool module for creating component and context specification documents through the ArchitectureServer. This tool ...
    ├── Components
    │   └── Tools
    │       └── CreateComponent [module] MCP tool module for creating a single component definition through the ComponentsServer. This tool enables AI agents ...
    ├── Stories
    │   └── Tools
    │       └── AddCriterion [module] MCP tool module for adding acceptance criteria to existing stories through the StoriesServer. This tool enables AI ag...
    └── Validators [module] Validation functions for MCP servers. Provides scope validation to ensure that MCP server requests have the required ...
CodeMySpecCli [module]
├── Application [module]
├── Auth
│   ├── OAuthClient [module]
│   └── Strategy [module]
├── Cli [module]
├── CliRunner [module]
├── Commands
│   ├── CommandBehaviour [module]
│   ├── Components [module]
│   ├── Exit [module]
│   ├── Help [module]
│   ├── Init [module]
│   ├── Login [module]
│   ├── Logout [module]
│   ├── Registry [module]
│   ├── Server [module]
│   ├── Sessions [module]
│   └── Whoami [module]
├── Config [module]
├── Migrator [module]
├── Release
│   ├── PackageExtension [module]
│   └── PatchLauncherStep [module]
├── Scope [module]
├── SlashCommands
│   ├── EvaluateAgentTask [module]
│   ├── SlashCommandBehaviour [module]
│   ├── StartAgentTask [module]
│   └── Sync [module]
├── Stories
│   └── RemoteClient [module]
├── TerminalPanes [module]
└── WebServer [module]
    ├── Config [module]
    ├── Router [module]
    └── Telemetry [module]
Components
├── ComponentsMapper [module] Maps component domain entities to MCP response formats with JSON structures for AI agent consumption.
└── Tools
    ├── AddSimilarComponent [module] Tool for marking components as architectural analogs for reference.
    ├── ArchitectureHealthSummary [module] Tool for analyzing architectural quality metrics and identifying issues.
    ├── ContextStatistics [module] Tool for computing metrics on context size, complexity, and dependencies.
    ├── CreateComponent [module] Tool for creating architectural components (contexts, modules, schemas, etc.).
    ├── CreateComponents [module] Batch tool for creating multiple components with dependency relationships.
    ├── CreateDependencies [module] Batch tool for establishing multiple dependency relationships.
    ├── CreateDependency [module] Tool for establishing dependency relationships between components.
    ├── DeleteComponent [module] Tool for removing components from the architecture.
    ├── DeleteDependency [module] Tool for removing dependency relationships between components.
    ├── GetComponent [module] Tool for retrieving detailed component information including dependencies.
    ├── ListComponents [module] Tool for listing all components in the project architecture.
    ├── OrphanedContexts [module] Tool for identifying components without parent relationships or stories.
    ├── RemoveSimilarComponent [module] Tool for removing similar component relationships.
    ├── ReviewContextDesign [module] Tool for initiating design review and validation workflow sessions.
    ├── ShowArchitecture [module] Tool for visualizing the component dependency graph and structure.
    ├── StartContextDesign [module] Tool for initiating structured context design workflow sessions.
    └── UpdateComponent [module] Tool for modifying component metadata and relationships.
ComponentsServer [module] Hermes MCP server exposing component architecture tools to AI agents. Registers 16 tools for component CRUD, dependen...
Formatters [module] Response formatting utilities for MCP servers providing hybrid human-readable + JSON responses with changeset error f...
Fuellytics
├── TestLocation [module] Testing file location fix
└── Verification [module] Handles verification workflows and photo validation
    └── Transaction [module] A fuel transaction requiring verification
Mix
└── Tasks
    └── Cli [module]
Stories
├── StoriesMapper [module] Maps story domain entities to MCP response formats with hybrid text summaries and JSON data structures for both human...
└── Tools
    ├── AddCriterion [module] Tool for adding acceptance criteria to existing stories.
    ├── ClearStoryComponent [module] Tool for removing component association from a story.
    ├── CreateStories [module] Batch tool for creating multiple user stories in a single request.
    ├── CreateStory [module] Tool for creating user stories with title, description, and acceptance criteria.
    ├── DeleteCriterion [module] Tool for removing acceptance criteria from stories.
    ├── DeleteStory [module] Tool for removing user stories from the system.
    ├── GetStory [module] Tool for retrieving detailed story information including criteria.
    ├── ListStories [module] Tool for listing stories with pagination support.
    ├── ListStoryTitles [module] Tool for retrieving story titles and IDs only (lightweight list).
    ├── SetStoryComponent [module] Tool for associating a story with a component.
    ├── StartStoryInterview [module] Tool for initiating structured story refinement workflow sessions.
    ├── StartStoryReview [module] Tool for initiating story validation and approval workflow sessions.
    ├── UpdateCriterion [module] Tool for modifying acceptance criterion text or verification status.
    └── UpdateStory [module] Tool for updating existing user story fields.
StoriesServer [module] Hermes MCP server exposing user story management tools to AI agents. Registers 13 tools for CRUD operations on storie...
Validators [module] Validation utilities for MCP server requests ensuring proper scope (account and project) context.