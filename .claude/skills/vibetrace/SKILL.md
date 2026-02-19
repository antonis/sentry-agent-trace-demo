---
name: vibetrace
description: Commit changes and export session to Vibe Trace in one step
argument-hint: [-m "commit message"]
---

# Vibe Trace Export Skill

This skill automatically commits your changes and exports the current Claude Code session in agent-trace format to the Vibe Trace MCP server.

## Usage

```
/vibetrace -m "Your commit message"
```

or simply:

```
/vibetrace
```

- If `-m "message"` is provided, uses that commit message
- If omitted, uses default message: "Update from Claude Code session"
- Automatically stages all changes, commits, and exports the session

## Workflow

You must execute the following steps in order:

### 1. Check for Uncommitted Changes

```bash
# Check if there are changes to commit
git status --porcelain
```

If no changes, inform the user and exit. Otherwise, proceed.

### 2. Parse Commit Message Argument

Extract commit message from arguments:
- If user provided `-m "message"`, use that
- Otherwise, use default: "Update from Claude Code session"

### 3. Stage and Commit Changes

```bash
# Stage all changes
git add -A

# Commit with message
git commit -m "Your commit message here

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Get the commit hash that was just created
COMMIT_HASH=$(git rev-parse HEAD)
echo "📝 Created commit: $COMMIT_HASH"
```

### 4. Determine Session ID

The current session ID is available in the environment. Extract it from the context or detect it from the project path.

Project path format: `~/.claude/projects/<safe-path>/<session-id>.jsonl`

Where `<safe-path>` is the project directory with slashes replaced by dashes.

### 5. Locate Session JSONL File

Use the Bash tool to find the session file:

```bash
# Get project root
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Convert to Claude safe-path format
# Example: /Users/antonis/git/vibetrace → -Users-antonis-git-vibetrace
SAFE_PATH=$(echo "$PROJECT_ROOT" | sed 's/^/-/' | tr '/' '-')

# List session files (most recent first)
ls -lt ~/.claude/projects/$SAFE_PATH/*.jsonl | head -5
```

If the current session ID is known, use it directly. Otherwise, use the most recently modified JSONL file.

### 6. Get Files Changed in Commit

```bash
git diff --name-only $COMMIT_HASH^..$COMMIT_HASH
```

### 7. Convert to Agent-trace Format

Use the Python conversion script with the Bash tool:

```bash
cd /Users/antonis/git/vibetrace/mcp-server

python3 - <<'PYTHON_SCRIPT'
import sys
import json
from schema import claude_jsonl_to_agent_trace, extract_conversation_data

# Read session JSONL path and commit hash from arguments
session_jsonl_path = sys.argv[1]
commit_hash = sys.argv[2]
project_path = sys.argv[3] if len(sys.argv) > 3 else None

# Convert to agent-trace format
agent_trace = claude_jsonl_to_agent_trace(
    session_jsonl_path,
    commit_hash,
    project_path
)

# Extract conversation data
with open(session_jsonl_path, 'r') as f:
    session_data = [json.loads(line) for line in f if line.strip()]

conversation_data = extract_conversation_data(session_data)

# Output JSON
output = {
    'trace': agent_trace,
    'conversation': conversation_data
}

print(json.dumps(output, indent=2))
PYTHON_SCRIPT
```

Pass arguments: `<session-jsonl-path> <commit-hash> <project-root>`

### 8. Upload to MCP Server

Use the Bash tool to POST the data:

```bash
curl -X POST http://localhost:8080/v2/traces \
  -H "Content-Type: application/json" \
  -d @- <<'JSON_DATA'
{
  "trace": { ... agent-trace data ... },
  "conversation": [ ... conversation data ... ]
}
JSON_DATA
```

Or use Python to make the request:

```bash
python3 - <<'PYTHON_SCRIPT'
import requests
import json
import sys

# Read JSON from stdin
trace_data = json.loads(sys.stdin.read())

# POST to MCP server
response = requests.post(
    'http://localhost:8080/v2/traces',
    json=trace_data,
    headers={'Content-Type': 'application/json'}
)

print(f"Status: {response.status_code}")
print(response.json())
PYTHON_SCRIPT
```

### 9. Output Confirmation and Open Demo App

Display a success message to the user with:
- Commit hash (with short version)
- Commit message
- Files changed
- Trace ID
- Number of attributions created

Then automatically open the demo app with the commit hash.

Example workflow:

```bash
# Get the commit hash (already have from step 3)
COMMIT_HASH=$(git rev-parse HEAD)
SHORT_HASH=$(git rev-parse --short HEAD)

# Construct demo app URL with commit parameter
DEMO_URL="file://$(pwd)/simple-web-test/index.html?commit=$COMMIT_HASH"

# Open in browser
open "$DEMO_URL"
```

Example output:

```
✅ Changes committed and exported to Vibe Trace!

📝 Commit: abc123d "Add crash button for testing"
📁 Files changed: 2
   - simple-web-test/index.html
   - README.md

📦 Trace ID: 12345678-1234-1234-1234-123456789abc
🎯 Attributions created: 5

🌐 Opening demo app with commit abc123d...
   URL: file:///Users/antonis/git/sentry-agent-trace-demo/simple-web-test/index.html?commit=abc123d...

Your conversation is now linked to commit abc123d.

Next steps:
1. The demo app is now open in your browser
2. Click any error button to trigger a crash
3. Go to Sentry to see the Agent Trace with your conversation!
```

## Error Handling

- **No changes to commit:** Inform user that there are no uncommitted changes
- **Git commit fails:** Display the error (e.g., merge conflict, hooks failing)
- **Session JSONL not found:** Inform user and suggest checking project path
- **MCP server not running:** Provide clear instructions:
  ```
  cd /Users/antonis/git/vibetrace/mcp-server
  python3 server.py
  ```
- **Conversion fails:** Display the error message and suggest checking JSONL format
- **Upload fails:** Check if MCP server is accessible and API key is configured

## Notes

- **Automatic workflow:** This skill commits AND exports in one step
- **Git integration:** Automatically stages all changes with `git add -A`
- **Co-authorship:** Commits include `Co-Authored-By: Claude Sonnet 4.5` tag
- **MCP server required:** Must be running on `http://localhost:8080`
- **Agent-trace format:** Ensures compatibility with standard tracing tools
- **Session linking:** The commit hash links your code to this conversation

## Benefits

✅ **One command** instead of commit → export → link
✅ **Never forget** to export after committing
✅ **Automatic linking** ensures commits always have conversation context
✅ **Clean workflow** for AI-assisted development
