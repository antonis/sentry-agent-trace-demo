# Sentry Agent Trace Demo

A browser-based demo for testing the **Agent Trace** feature in Sentry - linking AI-generated code errors back to the AI conversation that created them.

## 🎯 What This Demo Does

Shows how errors in production can be traced back to the AI conversation (Claude Code, Cursor, etc.) that generated the code.

## 🚀 Quick Start

### Option A: Test Latest Commit (Recommended)

```bash
# After making changes and committing
./test-latest-commit.sh
```

This automatically opens the test page with your latest commit hash.

### Option B: Manual Testing

```bash
# Test with specific commit
open "simple-web-test/index.html?commit=$(git rev-parse HEAD)"

# Or use default commit
open simple-web-test/index.html
```

### Test the Flow

1. **Click "🔥 Send Error to Sentry"** - Sends test error to your Sentry project
2. **View in Sentry** - Open your Sentry dashboard
3. **See Agent Trace Section** - Shows the AI conversation that led to this code

## 📋 What You'll See

```
▼ Agent Trace

  Session ID    2e3cc9ef-539a-44ca-a6b2-1fb0613d896e  [📋 copy]
  Model         anthropic/claude-sonnet-4-5
  Summary       Current conversation summary

  [🚀 Open in Claude Code]

  ▶ View Conversation (1761 turns)
    👤 User: I want to implement feature X...
    🤖 Assistant: I'll help you build that...
    ...
```

## 🔍 How Commit Detection Works

The Agent Trace feature uses **Sentry's Suspect Commits** to automatically link errors to code:

1. **Priority 1: Suspect Commits (Automatic)**
   - Sentry's GitHub integration analyzes stack traces
   - Determines which commit likely caused the error
   - Agent Trace fetches conversation for that commit

2. **Priority 2: Release Field (Fallback)**
   - Standard format: `app@version+commithash`
   - Used by production apps worldwide
   - No GitHub integration required

## 🧪 End-to-End Testing

Want to test the full flow with your own code changes?

### E2E Workflow

1. **Start infrastructure:**
   ```bash
   # Terminal 1: Start MCP server
   cd /path/to/vibetrace/mcp-server
   python3 server.py

   # Terminal 2: Expose with ngrok (if testing on Vercel)
   ngrok http 8080
   ```

2. **Make changes in Claude Code:**
   ```bash
   # Add your feature, fix a bug, whatever
   # Commit the changes
   git add . && git commit -m "Add feature X"
   ```

3. **Capture the session:**
   ```bash
   # In Claude Code, run:
   /vibetrace

   # Or manually specify commit:
   /vibetrace $(git rev-parse HEAD)
   ```

4. **Test the commit:**
   ```bash
   ./test-latest-commit.sh
   # Opens browser with your commit → click error button
   ```

5. **Verify in Sentry:**
   - Go to your Sentry dashboard
   - Find the new error
   - Agent Trace section shows YOUR conversation!

### No Git Hook Needed!

The `/vibetrace` skill is sufficient for testing. Git hooks are only needed for automatic capture on every commit.

## 🔧 Configuration

### Sentry Setup

Edit `simple-web-test/index.html` to configure:

```javascript
// Your Sentry DSN
const DSN = 'https://YOUR_KEY@YOUR_ORG.ingest.sentry.io/YOUR_PROJECT';

// MCP server URL
const MCP_SERVER = 'http://localhost:8080';
```

### Enable Suspect Commits (Optional but Recommended)

For automatic commit detection without manual tagging:

1. Go to **Sentry → Settings → Integrations**
2. Install **GitHub** integration
3. Connect your repository
4. Sentry will automatically detect suspect commits from stack traces

**Benefits:**
- ✅ No manual commit hash injection needed
- ✅ Works for all errors automatically
- ✅ More accurate blame tracking
- ✅ Links directly to GitHub commits

**Without GitHub integration:** Falls back to release field (still works!)

## 📚 Documentation

- **[VERCEL_TESTING.md](./VERCEL_TESTING.md)** - Deploy to Vercel with ngrok
- **[VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md)** - Production deployment guide
- **[API_KEY_SETUP.md](./API_KEY_SETUP.md)** - MCP server authentication setup

## 🏗️ Architecture

```
Browser (Demo Page)
    ↓ Sends error
Sentry (Issue Details)
    ↓ Fetches trace data
MCP Server (Local/ngrok/Deployed)
    ↓ Returns conversation
Agent Trace UI
    ✓ Shows AI conversation
    ✓ Deep links to IDE
    ✓ Session metadata
```

## 🔐 Security

- **API Key Authentication** - MCP server requires `X-API-Key` header
- **Optional IP Whitelisting** - Restrict to specific domains/IPs
- **Temporary Exposure** - Use ngrok for testing, deploy properly for production

## ✨ Features

✅ **Session ID with copy button** - Easy to share and reference
✅ **Model information** - Shows which AI model generated the code
✅ **Conversation preview** - See the AI discussion that led to this code
✅ **Deep links** - Click to open conversation in Claude Code/Cursor
✅ **No demo data** - Works with real AI conversations

## 🎓 Use Cases

- **Debug AI-generated code** - See the context that created the bug
- **Code review** - Understand the reasoning behind implementation choices
- **Team collaboration** - Share AI conversation context with teammates
- **Learning** - Study how AI solved similar problems before

## 📝 Requirements

- Sentry account (free tier works)
- MCP server running (for conversation storage)
- Claude Code or Cursor (for conversation capture)

## 🤝 Contributing

This is a demo project. For the full implementation, see the main Vibe Trace repository.

## 📄 License

MIT License - See main repository for details

---

**Built with** [Claude Code](https://claude.com/claude-code) 🤖
