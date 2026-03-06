# CodeMySpec CLI

The local CLI and Claude Code plugin for [CodeMySpec](https://github.com/Code-My-Spec/code_my_spec) — specification-driven development for Phoenix applications.

## Getting Started

This walks you through running the Math Test Project demo end-to-end.

### Prerequisites

- Elixir 1.18+, Phoenix 1.8+, PostgreSQL
- Claude Code CLI (`claude`)
- Both repos cloned as siblings:
  - `code_my_spec` (the server)
  - `code_my_spec_cli` (this repo)
  - `math_test_project` (the demo project)

### 1. Start the CodeMySpec server

In the `code_my_spec` directory:

```bash
cd code_my_spec
mix setup
mix run priv/repo/seeds/math_test_project.exs
mix phx.server
```

This seeds an account ("Code My Spec"), a project ("Math Test Project"), 2 stories, and 6 acceptance criteria.

### 2. Start the CLI server

In a separate terminal, in the `code_my_spec_cli` directory:

```bash
cd code_my_spec_cli
mix deps.get
mix run -- server run
```

This starts the local MCP server on port 8314 that Claude Code connects to.

### 3. Log in

In another terminal:

```bash
cd code_my_spec_cli
mix run -- login
```

Enter `johns10@gmail.com` when prompted. Then open the dev mailbox at [localhost:4000/dev/mailbox](http://localhost:4000/dev/mailbox) and click the magic link to complete login.

### 4. Initialize the demo project

```bash
cd math_test_project
../code_my_spec_cli/bin/cms init
```

Or if running from source:

```bash
cd math_test_project
cd ../code_my_spec_cli && mix run -- init -w ../math_test_project
```

Select the "Code My Spec" account and "Math Test Project" when prompted.

### 5. Launch Claude Code with the plugin

```bash
cd math_test_project
claude --plugin-dir ../code_my_spec_cli/CodeMySpec
```

### 6. Start implementation

Inside Claude Code, run:

```
/start-implementation
```

This kicks off the agentic loop: it finds the next incomplete user story, writes BDD specs, generates tests, and implements the code — all driven by the specifications and acceptance criteria you seeded.

## Development

### Building from source

```bash
mix deps.get
mix compile
```

### Running tests

```bash
mix test
```

### Building a release

See [RELEASING.md](RELEASING.md) for the full release process.
