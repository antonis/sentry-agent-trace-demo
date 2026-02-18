# Testing Agent Trace on Vercel with Secure MCP Server

This guide explains how to securely expose your local MCP server to test the Agent Trace feature on Vercel deployment.

## Prerequisites

- MCP server running locally with API key authentication
- ngrok installed (`brew install ngrok` or download from https://ngrok.com)
- **ngrok paid plan** (required to avoid browser warning that blocks requests)
- Vercel deployment of Sentry with Agent Trace feature

## Security Setup

### 1. API Key Authentication

The MCP server requires API key authentication for all endpoints except `/health`.

**Current API Key** (from `.env`):
```
mwu18CWSSa7jSGHi53ZkcyoG9Z9s3S6B2uCX7FPPRy4
```

### 2. Start MCP Server

```bash
cd mcp-server
python3 server.py
```

Server will load the API key from `.env` file automatically.

### 3. Configure ngrok Authentication

First time setup (one-time):
```bash
ngrok config add-authtoken YOUR_NGROK_TOKEN
```

### 4. Expose with ngrok

```bash
ngrok http 8080
```

You'll get output like:
```
Forwarding  https://unpargeted-superextreme-kenna.ngrok-free.dev -> http://localhost:8080
```

**Note:** With ngrok paid plan, browser requests work without the warning page that blocks JSON responses.

### 5. Test the Tunnel

Test without API key (should fail):
```bash
curl https://unpargeted-superextreme-kenna.ngrok-free.dev/v2/traces/by-commit/bce8250b6cfd0a8933e280bf34e5b9913c144b6c/conversation
# Returns: {"error": "Missing API key"}
```

Test with API key (should work):
```bash
curl -H "X-API-Key: mwu18CWSSa7jSGHi53ZkcyoG9Z9s3S6B2uCX7FPPRy4" \
  https://unpargeted-superextreme-kenna.ngrok-free.dev/v2/traces/by-commit/bce8250b6cfd0a8933e280bf34e5b9913c144b6c/conversation
# Returns: conversation data
```

Test in browser (should work with paid plan):
```bash
# Open browser console and run:
fetch('https://unpargeted-superextreme-kenna.ngrok-free.dev/v2/traces/by-commit/bce8250b6cfd0a8933e280bf34e5b9913c144b6c/conversation', {
  headers: {'X-API-Key': 'mwu18CWSSa7jSGHi53ZkcyoG9Z9s3S6B2uCX7FPPRy4'}
}).then(r => r.json()).then(console.log)
```

### 6. Update Sentry Code for Vercel

Update the Sentry Agent Trace component to use the ngrok URL:

```typescript
// In static/app/views/issueDetails/aiTrace/index.tsx
const MCP_SERVER_URL = 'https://unpargeted-superextreme-kenna.ngrok-free.dev';
const MCP_API_KEY = 'mwu18CWSSa7jSGHi53ZkcyoG9Z9s3S6B2uCX7FPPRy4';
const USE_DEMO_DATA = false;
```

Commit and push to trigger Vercel deployment.

### 7. Test on Vercel

1. Open the browser test page: `open simple-web-test/index.html`
2. Click "🔥 Send Error to Sentry" button
3. View the issue on Vercel deployment: https://sentry-qwc5mjgvb.sentry.dev/
4. Agent Trace section should load real data from your MCP server
5. Verify conversation is displayed (should show full conversation turns)

**Verified working:** Successfully tested with commit `bce8250b6cfd0a8933e280bf34e5b9913c144b6c` and session `2e3cc9ef-539a-44ca-a6b2-1fb0613d896e`, displaying **1761 conversation turns**.

### 8. Stop Exposure (IMPORTANT!)

**After testing**, stop ngrok to close the tunnel:
```bash
# Press Ctrl+C in the ngrok terminal
```

This ensures your conversation data is no longer publicly accessible.

## Security Notes

✅ **API key required** - All endpoints (except /health) require authentication
✅ **HTTPS encryption** - ngrok provides TLS/SSL automatically
✅ **Temporary URL** - ngrok URL expires when tunnel closes
✅ **ngrok paid plan** - Removes browser warning page that blocks JSON responses
⚠️ **API key in frontend** - The key is visible in browser dev tools (acceptable for testing)
⚠️ **Rate limiting** - Not currently implemented (could add if needed)
⚠️ **Temporary exposure** - Remember to stop ngrok after testing

## Common Issues

### Browser Warning on Free ngrok Plan

**Problem:** ngrok free tier shows a browser warning page before allowing requests, which breaks fetch() calls from browser.

**Solution:** Upgrade to ngrok paid plan (removes the warning page entirely). With paid plan, browser requests work seamlessly.

**Debug steps:**
```bash
# Test with curl (works on free tier):
curl -H "X-API-Key: YOUR_KEY" https://your-url.ngrok-free.dev/endpoint

# Test with browser User-Agent (fails on free tier, works on paid):
curl -H "User-Agent: Mozilla/5.0" -H "X-API-Key: YOUR_KEY" https://your-url.ngrok-free.dev/endpoint
```

## Alternative: Demo Data

For safer testing without exposing your MCP server:

```typescript
const USE_DEMO_DATA = true;  // Use hardcoded demo data
```

This shows the UI without requiring any backend connection.

## Production Considerations

For production deployment, consider:
- Deploy MCP server to a secure hosting provider
- Add rate limiting
- Add IP whitelisting (restrict to Sentry/Vercel IPs only)
- Use environment variables for API keys (not hardcoded)
- Implement key rotation
- Add request logging and monitoring
