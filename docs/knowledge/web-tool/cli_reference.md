# web CLI - Complete Flag Reference

Source: https://github.com/chrismccord/web

## Synopsis

```
web <url> [options]
```

The URL is a positional argument (first non-flag argument). All flags use `--` prefix.

## All Flags

| Flag | Argument | Default | Description |
|------|----------|---------|-------------|
| `--help` | — | — | Print usage and exit |
| `--raw` | — | off | Output raw HTML instead of converting to markdown |
| `--truncate-after` | `<number>` | `100000` | Truncate output at this character count and append a truncation notice |
| `--screenshot` | `<filepath>` | — | Save a full-page screenshot PNG to the given path |
| `--form` | `<id>` | — | The `id` attribute of the form element to target for input filling |
| `--input` | `<name>` | — | The `name` attribute of a form input field to fill; must follow `--form` |
| `--value` | `<value>` | — | The value to place in the preceding `--input` field |
| `--after-submit` | `<url>` | — | After form submission completes, navigate to this URL before returning output |
| `--js` | `<code>` | — | JavaScript code to execute on the page after it loads |
| `--profile` | `<name>` | `"default"` | Named session profile to use; creates if it does not exist |

## Flag Details

### `--raw`

By default, `web` converts the page HTML to markdown. Use `--raw` to get the raw HTML DOM instead. Useful when you need to inspect specific HTML attributes, element IDs, or form structure that markdown would strip.

```bash
web http://localhost:4000/users/log-in --raw
```

### `--truncate-after <number>`

Limits the length of stdout output. After `<number>` characters, output is cut and a notice is appended: `[output truncated after N chars]`. The default of 100000 characters (100KB) is usually sufficient for most pages. Reduce it when feeding output to a context window.

```bash
web http://localhost:4000 --truncate-after 5000
```

### `--screenshot <filepath>`

Takes a full-page screenshot and saves it as a PNG to the given path. The path can be absolute or relative to cwd. The screenshot is taken after JavaScript execution and LiveView connection (if applicable).

```bash
web http://localhost:4000/dashboard --screenshot /tmp/dashboard.png
```

### `--form <id>`, `--input <name>`, `--value <value>`

These three flags work together to fill and submit a form.

- `--form <id>` — specifies which form to target by its `id` HTML attribute
- `--input <name>` -- specifies a field within that form by its `name` attribute
- `--value <value>` — provides the value for the immediately preceding `--input`

Multiple `--input`/`--value` pairs can be chained. The form is submitted automatically after all inputs are filled.

```bash
web http://localhost:4000/users/log-in \
  --form "login_form" \
  --input "user[email]" --value "alice@example.com" \
  --input "user[password]" --value "hunter2"
```

### `--after-submit <url>`

After the form is submitted, `web` navigates to this URL before converting the page to markdown. Use this to verify the post-login destination or to land on an authenticated page.

```bash
web http://localhost:4000/users/log-in \
  --form "login_form" \
  --input "user[email]" --value "alice@example.com" \
  --input "user[password]" --value "hunter2" \
  --after-submit "http://localhost:4000/dashboard"
```

### `--js <code>`

Executes arbitrary JavaScript after the page loads (and after LiveView connection if on a LiveView page). Console output is captured and included in the tool output, tagged by level:

- `[LOG]` — `console.log()`
- `[WARNING]` — `console.warn()`
- `[ERROR]` — `console.error()`
- Browser errors and network failures also appear in output

```bash
# Click a button
web http://localhost:4000/items --js "document.querySelector('[data-action=delete]').click()"

# Read DOM state
web http://localhost:4000/items --js "console.log(document.querySelectorAll('li').length)"

# Navigate programmatically
web http://localhost:4000/items --js "window.location.href = '/items/new'"

# Read localStorage
web http://localhost:4000 --js "console.log(localStorage.getItem('session_key'))"
```

### `--profile <name>`

Uses an isolated Firefox profile stored at `~/.web-firefox/profiles/<name>/`. Cookies, localStorage, and session data persist across invocations using the same profile name. Different profile names have completely independent storage — data set in profile A is not visible in profile B.

The default profile name is `"default"`.

```bash
# Log in once, saving session to profile "myapp"
web http://localhost:4000/users/log-in \
  --profile "myapp" \
  --form "login_form" \
  --input "user[email]" --value "alice@example.com" \
  --input "user[password]" --value "hunter2" \
  --after-submit "http://localhost:4000/dashboard"

# Subsequent calls reuse the authenticated session
web http://localhost:4000/admin --profile "myapp"
```

## Combining Flags

Flags can be combined freely. Common combinations:

```bash
# Visit page, take screenshot, limit output length
web http://localhost:4000 \
  --screenshot /tmp/page.png \
  --truncate-after 10000

# Log in, then navigate to an authenticated page
web http://localhost:4000/users/log-in \
  --profile "qa-session" \
  --form "login_form" \
  --input "user[email]" --value "test@example.com" \
  --input "user[password]" --value "password" \
  --after-submit "http://localhost:4000/dashboard"

# Execute JS and take screenshot together
web http://localhost:4000/items \
  --profile "qa-session" \
  --js "console.log(document.title)" \
  --screenshot /tmp/items.png \
  --truncate-after 8000
```
