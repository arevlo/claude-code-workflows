---
description: Inspect network requests on the current page using Chrome DevTools
allowed-tools: Bash
---

# Inspect Network Requests

Monitor and analyze network requests (XHR, Fetch, resources) made by the current web page.

## Instructions

### 1. Check Chrome Integration

First, verify that Claude Code Chrome integration is available:

```bash
# Check if /chrome is enabled by attempting to check tab context
# (this is a safe no-op check)
echo "Checking Chrome integration..."
```

**If Chrome integration is not enabled:**

Tell the user:
```
Chrome integration required for network inspection.

To enable:
1. Run: /chrome
2. Select "Enabled by default"

Or start Claude Code with: claude --chrome
```

Exit gracefully if Chrome is not available.

### 2. Get Tab Context

Use the `mcp__claude-in-chrome__tabs_context_mcp` tool to get the current tab ID.

**If no tabs available:**
- Inform user: "No Chrome tabs available. Please navigate to a page first."
- Exit

### 3. Read Network Requests

Use the `mcp__claude-in-chrome__read_network_requests` tool with the tab ID:

Parameters:
- `tabId`: From step 2
- `urlPattern`: Optional filter (e.g., "/api/" to show only API calls)
- `limit`: Default 100

### 4. Parse and Display Results

Format the network requests into a readable table:

```markdown
## Network Requests for [URL]

| Method | URL | Status | Type | Size |
|--------|-----|--------|------|------|
| GET | /api/users | 200 | xhr | 1.2 KB |
| POST | /api/login | 201 | fetch | 456 B |
| GET | /styles.css | 200 | stylesheet | 12.5 KB |
| GET | /logo.png | 200 | image | 45 KB |

**Total:** 15 requests
**Failed:** 0
**Pending:** 2

### Request Details

**API Calls (filtered):**
- GET /api/users → 200 OK (1.2 KB)
- POST /api/login → 201 Created (456 B)

**Resources:**
- 5 stylesheets
- 8 images
- 2 scripts
```

### 5. Filtering Support

Accept optional arguments for filtering:

**Examples:**
```bash
# Show only API calls
/clawd-eyes:inspect-network api

# Show only failed requests
/clawd-eyes:inspect-network error

# Show specific endpoint
/clawd-eyes:inspect-network /users
```

Use the filter as the `urlPattern` parameter.

## Output Format

### Summary Table
- Method, URL (truncated if long), Status, Type, Size
- Highlight failed requests (4xx, 5xx status codes)
- Group by request type if many requests

### Statistics
- Total request count
- Failed request count
- Pending request count
- Total data transferred (if available)

### Detailed Breakdown (Optional)
For failed requests or when specifically requested:
- Full URL
- Request headers (relevant ones)
- Response status and message
- Timing information

## Error Handling

**Chrome not enabled:**
```
❌ Chrome integration not available.

Enable with: /chrome

This command requires Claude Code's Chrome integration to read network requests.
```

**No tab context:**
```
❌ No active Chrome tab found.

Please:
1. Open Chrome
2. Navigate to a web page
3. Run this command again
```

**No requests found:**
```
✓ Network monitoring active

No requests captured yet. This could mean:
- Page hasn't made any requests
- Requests completed before monitoring started
- Try refreshing the page while monitoring is active
```

**Pattern yields no matches:**
```
No requests match pattern: [pattern]

Total requests captured: [count]

Try a broader search or remove the filter.
```

## Integration with clawd-eyes

**Workflow:**
1. User selects an element in clawd-eyes UI
2. User wants to see what API calls that element makes
3. Run `/clawd-eyes:inspect-network` to see network activity
4. Use pattern filtering to focus on relevant requests
5. Combine with console logs (`/clawd-eyes:read-console`) for debugging

**Useful Patterns:**
- `/api/` - Show only API endpoints
- `.json` - Show JSON responses
- `error` - Show failed requests
- Specific domain - Filter by backend service

## Notes

- Network requests are only captured **after** monitoring starts
- Refresh the page if you want to capture all initial load requests
- Requests are scoped to the **current domain** by default
- Cross-origin requests may have limited information due to CORS
- Pending requests show as "in progress"
- This tool is read-only - it doesn't modify or intercept requests

## Example Usage

**User:** "Check what API calls this page is making"

**Command:** `/clawd-eyes:inspect-network`

**Output:**
```markdown
## Network Requests for https://example.com

| Method | URL | Status | Type | Size |
|--------|-----|--------|------|------|
| GET | /api/v1/users | 200 | xhr | 2.4 KB |
| POST | /api/v1/analytics | 200 | fetch | 156 B |
| GET | /api/v1/config | 200 | xhr | 890 B |

**Total:** 3 API requests
**All requests successful**

### API Calls
1. GET /api/v1/users → 200 OK
   - Response size: 2.4 KB
   - Type: xhr

2. POST /api/v1/analytics → 200 OK
   - Response size: 156 B
   - Type: fetch

3. GET /api/v1/config → 200 OK
   - Response size: 890 B
   - Type: xhr
```
