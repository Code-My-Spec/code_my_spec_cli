# Releasing the CodeMySpec Claude Code Extension

This document covers how to release a new version of the CodeMySpec Claude Code extension to [Code-My-Spec/code_my_spec_claude_code_extension](https://github.com/Code-My-Spec/code_my_spec_claude_code_extension).

## Overview

The release process builds a native binary with Burrito, packages it with the extension files, and publishes to GitHub Releases. The install script in the extension repo downloads the binary for the user's platform.

## Prerequisites

- Elixir 1.19+ and Erlang/OTP 28+ (see `.tool-versions`)
- `gh` CLI authenticated with access to `Code-My-Spec/code_my_spec_claude_code_extension`
- The `code_my_spec` dependency available at `../code_my_spec` (sibling directory)

## Steps

### 1. Bump the version

Update the version in **both** plugin.json files:

```
CodeMySpec/.claude-plugin/plugin.json           # source (used during build)
release/codemyspec-extension/.claude-plugin/plugin.json  # built output
```

Follow [semver](https://semver.org/):
- **Patch** (1.2.x): bug fixes, minor tweaks
- **Minor** (1.x.0): new skills, features, or capabilities
- **Major** (x.0.0): breaking changes to extension structure or CLI interface

### 2. Commit the version bump

```bash
git add CodeMySpec/.claude-plugin/plugin.json release/codemyspec-extension/.claude-plugin/plugin.json
git commit -m "Bump plugin version to <version>"
```

### 3. Build the binary and publish

Run the production release with `PUBLISH_RELEASE=true`:

```bash
PUBLISH_RELEASE=true MIX_ENV=prod mix release
```

This triggers the Burrito build pipeline which:
1. Compiles the Elixir release into a standalone binary
2. Runs `PackageExtension` post-build step which:
   - Copies extension files from `CodeMySpec/` to `release/codemyspec-extension/`
   - Copies the binary to `release/binaries/`
   - Generates `install.sh` and `README.md`
   - Pushes the extension to `Code-My-Spec/code_my_spec_claude_code_extension`
   - Creates a GitHub release with the binary attached

### 4. Verify the release

```bash
# Check the release was created
gh release view v<version> --repo Code-My-Spec/code_my_spec_claude_code_extension

# Verify the binary asset is attached
gh release view v<version> --repo Code-My-Spec/code_my_spec_claude_code_extension --json assets
```

### 5. Update release notes (optional)

The automated release creates minimal notes. To add detailed release notes:

```bash
gh release edit v<version> \
  --repo Code-My-Spec/code_my_spec_claude_code_extension \
  --notes "$(cat <<'EOF'
## What's new
- Feature 1
- Feature 2

## Bug fixes
- Fix 1

## Install
Download the binary for your platform and run `./install.sh` to install.
EOF
)"
```

## Build targets

Currently only macOS ARM64 is enabled in `mix.exs`. To add platforms, uncomment targets in the `releases` config:

```elixir
# mix.exs -> releases -> burrito -> targets
macos_m1: [os: :darwin, cpu: :aarch64]
# macos: [os: :darwin, cpu: :x86_64],
# linux: [os: :linux, cpu: :x86_64],
# linux_aarch64: [os: :linux, cpu: :aarch64],
# windows: [os: :windows, cpu: :x86_64]
```

Each enabled target produces a separate binary (`cms-darwin-arm64`, `cms-linux-x64`, etc.).

## Manual release (without PUBLISH_RELEASE)

If you need to build without auto-publishing:

```bash
# Build only
MIX_ENV=prod mix release

# Copy binary to local dev extension
cp burrito_out/code_my_spec_cli_macos_m1 CodeMySpec/bin/cms

# Or use the convenience script
scripts/rebuild-cli
```

Then manually push and create a release:

```bash
cd release/codemyspec-extension
gh release create v<version> ../binaries/cms-darwin-arm64 \
  --repo Code-My-Spec/code_my_spec_claude_code_extension \
  --title "Release v<version>" \
  --notes "Release notes here"
```

## File layout

| Path | Purpose |
|------|---------|
| `CodeMySpec/` | Extension source files (skills, agents, hooks, knowledge) |
| `release/codemyspec-extension/` | Packaged extension (rebuilt on each release) |
| `release/binaries/` | Built binaries for GitHub upload |
| `lib/code_my_spec_cli/release/package_extension.ex` | Build + publish automation |
| `scripts/rebuild-cli` | Quick local build (no publish) |
