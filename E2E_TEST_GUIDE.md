# End-to-End Testing Guide

This guide walks you through testing the complete Agent Trace flow from a fresh Claude Code session.

## 🎯 Goal

Demonstrate the full flow: AI writes buggy code → commit → runtime crash → Sentry error → Agent Trace shows AI conversation

## 📋 Prerequisites

1. **MCP Server running:**
   ```bash
   cd /Users/antonis/git/vibetrace/mcp-server
   python3 server.py
   ```

2. **ngrok tunnel (for Vercel testing):**
   ```bash
   ngrok http 8080
   ```

3. **Sentry Vercel deployment** updated with ngrok URL

## 🚀 E2E Test Steps

### Step 1: Start Fresh Session

**IMPORTANT:** Close this Claude Code session and open a NEW one in this repo:

```bash
# From your terminal (outside Claude Code)
cd /Users/antonis/git/sentry-agent-trace-demo
code .  # Or your preferred way to open Claude Code
```

This ensures you're testing a real conversation capture, not the current mega-session.

### Step 2: Add Buggy Code with AI

In your new session, tell Claude Code:

```
Add a button to simple-web-test/index.html that triggers a real JavaScript
error when clicked. Make it crash by accessing a property on undefined.
```

Claude Code will help you add something like:

```html
<button onclick="triggerRealCrash()">💥 Trigger Real Crash</button>

<script>
function triggerRealCrash() {
    // This will cause: Cannot read property 'value' of undefined
    const user = undefined;
    console.log(user.profile.name);
}
</script>
```

### Step 3: Commit the Changes

```bash
git add simple-web-test/index.html
git commit -m "Add crash button for testing Agent Trace"
```

### Step 4: Capture the Session

In Claude Code, run:

```
/vibetrace
```

This captures your conversation and links it to the commit you just made.

You should see output like:

```
✅ Vibe Trace export successful!

📦 Trace ID: 12345678-1234-1234-1234-123456789abc
🔗 Commit: abc123def456
📝 Files attributed: 1
🎯 Attributions created: 3

Your conversation is now linked to this commit and will appear in Sentry error reports.
```

### Step 5: Test the Crash

```bash
# Open the test page with your commit
./test-latest-commit.sh
```

In the browser:
1. Click the **"💥 Trigger Real Crash"** button
2. Error occurs naturally (not a fake button)
3. Sentry captures it automatically

### Step 6: Verify in Sentry

1. Go to https://sentry-qwc5mjgvb.sentry.dev/ (or your Sentry dashboard)
2. Find the new error issue
3. Look for the **"Agent Trace"** section
4. Click to expand - should show YOUR conversation from the new session!
5. Click **"Open in Claude Code"** to verify deep link works

## ✅ Success Criteria

- [ ] Error appears in Sentry within seconds
- [ ] Agent Trace section is visible
- [ ] Conversation shows YOUR messages about adding the crash button
- [ ] Session ID matches the one from `/vibetrace` output
- [ ] Deep link opens the correct session in Claude Code

## 🔍 Troubleshooting

### Agent Trace section not showing

**Check 1: Sentry detected the commit**
- Open issue in Sentry
- Look for "Suspect Commits" section
- Verify your commit is listed

**Check 2: MCP server has the trace**
```bash
curl "http://localhost:8080/v2/traces/by-commit/YOUR_COMMIT_HASH"
```

Should return `{"found": true, ...}`

**Check 3: Vercel has access to MCP**
```bash
# Test from browser console on Vercel page
fetch('https://your-ngrok-url.ngrok-free.dev/v2/traces/by-commit/YOUR_COMMIT', {
  headers: {'X-API-Key': 'YOUR_KEY'}
}).then(r => r.json()).then(console.log)
```

### /vibetrace skill not found

Make sure you're in a NEW session (not this one). Skills are loaded when the session starts.

### Wrong conversation showing

This means the old commit hash is being used. Make sure:
1. You ran `./test-latest-commit.sh` (not opening HTML directly)
2. Or you passed `?commit=YOUR_NEW_COMMIT` in URL

## 🎓 What This Demonstrates

1. **Real AI-assisted development** - Claude Code helps write code
2. **Natural error capture** - Real crash, not fake button
3. **Automatic commit linking** - Sentry's suspect commits feature
4. **Conversation persistence** - MCP server stores AI context
5. **Debugging context** - Developers see WHY code was written that way

This is the killer feature: linking runtime errors back to the AI conversation that generated the code!
