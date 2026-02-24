# web - Phoenix LiveView Support

Source: https://github.com/chrismccord/web

## Why LiveView Requires Special Handling

Phoenix LiveView pages are not static HTML. They:

1. Render a minimal static HTML shell on initial load
2. Establish a WebSocket connection to the server
3. Receive a diff-patched DOM from the server over the socket
4. React to user interactions by sending events over the socket and re-rendering

A naive scraper that reads HTML immediately after page load sees the unconnected shell, not the rendered content. `web` handles this automatically.

## Auto-Detection

`web` detects a Phoenix LiveView page by looking for the `[data-phx-session]` attribute on the DOM, which LiveView always adds to its root elements. No configuration is needed — detection is automatic.

When a LiveView page is detected, the tool logs:

```
Detected Phoenix LiveView page
```

## Connection Waiting

After detecting LiveView, `web` waits for the `.phx-connected` CSS class to appear on the LiveView root element. This class is applied by LiveView's JavaScript client once the WebSocket handshake completes and the server has pushed the initial rendered state.

This means the markdown output reflects what the user would actually see in a browser, not the server-rendered shell.

## Loading State Handling

For form submissions and change events, LiveView applies loading classes during the round-trip to the server:

- `.phx-change-loading` — applied while a `phx-change` event is in-flight
- `.phx-submit-loading` — applied while a `phx-submit` event is in-flight

`web` waits for both of these classes to disappear before capturing output. This prevents reading the page while a form submission is still being processed.

## JavaScript Navigation in LiveView

When `--js` triggers a navigation (`window.location.href = ...`) on a LiveView page, `web` recognizes this as a LiveView navigation and applies the same connection-waiting logic on the new page. The tool logs:

```
Waiting for Phoenix LiveView navigation
```

For navigation on non-LiveView pages, it logs:

```
Waiting for page navigation
```

## Form Submission with LiveView

The `--form` / `--input` / `--value` flags support LiveView forms. LiveView forms use `phx-submit` for form submission, which sends the data over WebSocket rather than as a standard HTTP POST. `web` handles this transparently.

Example — logging into a Phoenix app that uses LiveView for the sign-in page:

```bash
web http://localhost:4000/users/log-in \
  --form "login_form" \
  --input "user[email]" --value "alice@example.com" \
  --input "user[password]" --value "hunter2" \
  --after-submit "http://localhost:4000/dashboard"
```

The form ID (`login_form`) corresponds to the `id` attribute on the `<form>` element, which in Phoenix is set by `<.form id="login_form" ...>` or the `for={...}` assigns in the component.

## Identifying Form IDs and Input Names

Use `--raw` on the login page to see the actual HTML and find the form `id` and input `name` attributes:

```bash
web http://localhost:4000/users/log-in --raw
```

Look for:
```html
<form id="login_form" ...>
  <input name="user[email]" ...>
  <input name="user[password]" ...>
</form>
```

## Practical QA Patterns for Phoenix LiveView

### Visit and read a LiveView page

```bash
# Automatically waits for LiveView to connect before returning output
web http://localhost:4000/dashboard --profile "qa-session"
```

### Check rendered content after LiveView mount

```bash
web http://localhost:4000/items \
  --profile "qa-session" \
  --truncate-after 15000
```

### Trigger a LiveView event via JavaScript

```bash
# Click a phx-click button
web http://localhost:4000/items \
  --profile "qa-session" \
  --js "document.querySelector('[phx-click=delete][data-id=\"123\"]').click()"
```

### Check a LiveView stream or list count

```bash
web http://localhost:4000/items \
  --profile "qa-session" \
  --js "console.log('item count: ' + document.querySelectorAll('[data-phx-id]').length)"
```

### Navigate to a live route and take a screenshot

```bash
web http://localhost:4000/reports \
  --profile "qa-session" \
  --screenshot /tmp/reports.png \
  --truncate-after 10000
```
