# web - AI Agent Workflow Patterns

Source: https://github.com/chrismccord/web

## Why `web` Is Well-Suited for Agent Use

- Output is markdown, which is compact and LLM-readable
- Console output is captured inline (tagged `[LOG]`, `[WARNING]`, `[ERROR]`)
- Browser errors and network failures surface in stdout
- Sessions persist across invocations via `--profile`, allowing multi-step flows
- Phoenix LiveView connection is handled automatically — no timing hacks needed
- Truncation keeps output within context window limits

## The QA App Workflow

The canonical agent flow for QA-ing a Phoenix LiveView app:

### Step 1: Verify the server is running

```bash
lsof -i :4000
```

If nothing is listening, start it:

```bash
mix phx.server
```

### Step 2: Establish a session by logging in

```bash
web http://localhost:4000/users/log-in \
  --profile "qa-session" \
  --form "login_form" \
  --input "user[email]" --value "test@example.com" \
  --input "user[password]" --value "password123" \
  --after-submit "http://localhost:4000/dashboard"
```

The `--after-submit` URL confirms successful authentication. If the output shows the login page again, login failed.

### Step 3: Visit routes and read content

```bash
web http://localhost:4000/dashboard --profile "qa-session" --truncate-after 10000
web http://localhost:4000/items --profile "qa-session" --truncate-after 10000
web http://localhost:4000/settings --profile "qa-session" --truncate-after 10000
```

Read the markdown output and check that:
- The page title and headings are correct
- Expected data appears
- Navigation links are present
- No error messages or stack traces are visible

### Step 4: Inspect page structure when needed

Use `--raw` to get the HTML and inspect form IDs, element attributes, and DOM structure:

```bash
web http://localhost:4000/items/new --profile "qa-session" --raw --truncate-after 20000
```

### Step 5: Take screenshots for visual verification

```bash
web http://localhost:4000/dashboard \
  --profile "qa-session" \
  --screenshot /tmp/qa-dashboard.png \
  --truncate-after 5000
```

### Step 6: Test form interactions

```bash
# Create an item via form
web http://localhost:4000/items/new \
  --profile "qa-session" \
  --form "item_form" \
  --input "item[title]" --value "Test Item" \
  --input "item[description]" --value "Created by QA agent" \
  --after-submit "http://localhost:4000/items"
```

Check the output to confirm the new item appears in the list.

### Step 7: Test JavaScript interactions

```bash
# Trigger a delete button click
web http://localhost:4000/items \
  --profile "qa-session" \
  --js "document.querySelector('[data-action=delete]:first-of-type').click()" \
  --truncate-after 10000
```

## Discovering Form IDs Without Prior Knowledge

When you do not know the form `id` or input `name` values:

```bash
# Get raw HTML to inspect form structure
web http://localhost:4000/users/log-in --raw --truncate-after 20000
```

Search the output for `<form id=` and `<input name=` to find the values needed for `--form` and `--input`.

## Session Profile Strategy

Use distinct profile names to represent distinct user sessions. This allows testing with multiple users without logging out:

```bash
# Admin session
web http://localhost:4000/users/log-in \
  --profile "admin" \
  --form "login_form" \
  --input "user[email]" --value "admin@example.com" \
  --input "user[password]" --value "adminpass" \
  --after-submit "http://localhost:4000/admin"

# Regular user session
web http://localhost:4000/users/log-in \
  --profile "user1" \
  --form "login_form" \
  --input "user[email]" --value "user@example.com" \
  --input "user[password]" --value "userpass" \
  --after-submit "http://localhost:4000/dashboard"

# Now test both perspectives without interference
web http://localhost:4000/admin --profile "admin"
web http://localhost:4000/admin --profile "user1"  # should show 403 or redirect
```

## Reading Console Output for Debugging

JavaScript console output is included in the `web` tool's stdout. Use this to extract state from the page:

```bash
web http://localhost:4000/items \
  --profile "qa-session" \
  --js "
    const items = document.querySelectorAll('[data-item-id]');
    console.log('Total items: ' + items.length);
    items.forEach(el => console.log('Item: ' + el.dataset.itemId));
  "
```

## Checking for Errors

Browser console errors and network failures surface automatically in the output:

```
[ERROR] Failed to load resource: 404 /missing-asset.js
[ERROR] Uncaught TypeError: Cannot read property 'foo' of undefined
```

Review the output for any `[ERROR]` lines as part of QA checks.

## Truncation and Context Window Management

The default truncation of 100000 characters is generous. For agent workflows where output feeds into further reasoning, use a lower `--truncate-after` value to keep outputs compact:

```bash
# Quick status check — small limit
web http://localhost:4000/items --profile "qa-session" --truncate-after 5000

# Detailed page review — medium limit
web http://localhost:4000/items/123 --profile "qa-session" --truncate-after 15000

# Raw HTML inspection — higher limit needed
web http://localhost:4000/items/new --profile "qa-session" --raw --truncate-after 30000
```

When output is truncated, the text ends with a notice like:
```
[output truncated after 5000 chars]
```

If you see this and need more content, either increase `--truncate-after` or use `--js` to extract only the specific data you need.

## Reporting Bugs Found During QA

When issues are found, capture evidence before reporting:

```bash
# Screenshot of the broken state
web http://localhost:4000/broken-page \
  --profile "qa-session" \
  --screenshot /tmp/bug-$(date +%s).png \
  --js "console.log('URL: ' + window.location.href)" \
  --truncate-after 10000
```

Document the full reproduction steps (which URLs, which form inputs, which profile) along with the actual vs. expected behavior.
