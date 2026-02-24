# web - CLI Browser for LLM Agents: Overview

Source: https://github.com/chrismccord/web

## What It Is

`web` is a shell-based headless web browser built specifically for LLM agent workflows. It converts web pages to markdown output for easy consumption, executes JavaScript, interacts with forms, takes screenshots, and maintains session state across invocations. It is a single native Go binary with no runtime dependencies beyond Firefox (auto-downloaded on first run).

Created by Chris McCord (creator of Phoenix Framework), it has explicit first-class support for Phoenix LiveView applications.

## Architecture

- Single Go binary — no Node, no npm, no Playwright config
- On first run, downloads Firefox and geckodriver to `~/.web-firefox/`
- Session profiles stored at `~/.web-firefox/profiles/<name>/`
- Headless Firefox drives all page interaction via WebDriver (geckodriver)
- Output goes to stdout; logs and errors go to stderr

## System Requirements

- macOS 10.12+ (Intel or Apple Silicon) or Linux x86_64 (Ubuntu 18.04+, RHEL 7+, Debian 9+, Arch)
- ~102MB free disk space for Firefox and geckodriver on first run
- Go 1.21+ only needed if building from source; pre-built binaries available

### Linux System Dependencies

```bash
# Core Firefox dependencies
sudo apt install libgtk-3-0 libdbus-glib-1-2 libx11-xcb1 libxcb1 libxcomposite1 \
  libxcursor1 libxdamage1 libxi6 libxrandr2 libxss1 libxtst6 libxext6 \
  libasound2 libatspi2.0-0 libdrm2 libxfixes3 libxrender1

# Additional multimedia and font packages
sudo apt install libpulse0 libcanberra-gtk3-module packagekit-gtk3-module \
  libdbusmenu-glib4 libdbusmenu-gtk3-4
```

## Installation

### From pre-built binary (macOS Apple Silicon)

```bash
curl -L https://github.com/chrismccord/web/releases/latest/download/web-darwin-arm64 -o web
chmod +x web
sudo cp web /usr/local/bin/web
```

### From source

```bash
git clone https://github.com/chrismccord/web
cd web
make          # builds ./web for current platform
sudo cp web /usr/local/bin/web
```

### Multi-platform build

```bash
make build
# Produces:
#   web-darwin-arm64   macOS Apple Silicon
#   web-darwin-amd64   macOS Intel
#   web-linux-amd64    Linux x86_64
```

## Verification

```bash
web --help
web https://example.com
```

On first run, Firefox and geckodriver are downloaded automatically (~102MB). Subsequent runs use the cached installation.
