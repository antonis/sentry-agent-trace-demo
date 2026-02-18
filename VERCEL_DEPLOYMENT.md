# Deploying to Vercel with Real Data

✅ **Changes Applied**:
- Vercel now uses **real data** (not demo mode)
- MCP server has **IP whitelisting** for `*.sentry.dev` domains
- API key authentication required

## Quick Start

### 1. Expose MCP Server via ngrok

```bash
# In terminal 1: Keep MCP server running
cd mcp-server
python3 server.py

# In terminal 2: Expose with ngrok
ngrok http 8080
```

You'll get:
```
Forwarding  https://abc123.ngrok-free.app -> http://localhost:8080
```

### 2. Update Sentry Code

Edit `static/app/views/issueDetails/aiTrace/index.tsx`:

```typescript
// Change this line:
const MCP_SERVER_URL = 'http://localhost:8080';

// To your ngrok URL:
const MCP_SERVER_URL = 'https://abc123.ngrok-free.app';
```

### 3. Deploy to Vercel

```bash
cd /Users/antonis/git/sentry
git add static/app/views/issueDetails/aiTrace/index.tsx
git commit -m "Update MCP server URL for Vercel testing"
git push origin antonis/vibe-trace
```

Vercel will auto-deploy in ~2 minutes.

### 4. Test on Vercel

1. Create test error (use simple-web-test or any Sentry project)
2. Add git commit tag matching a trace in your MCP server
3. View issue on Vercel deployment URL
4. Agent Trace section should load with real conversation data

### 5. Close ngrok (IMPORTANT!)

```bash
# Press Ctrl+C in ngrok terminal
```

This closes public access to your conversation data.

## Security Features

✅ **API Key Required** - All requests need valid API key
✅ **IP Whitelist** - Only `*.sentry.dev` and `localhost` allowed
✅ **HTTPS** - ngrok provides TLS encryption
✅ **Temporary URL** - ngrok URL expires when closed

## IP Whitelist Configuration

Current whitelist (in `mcp-server/.env`):
```bash
VIBE_TRACE_ALLOWED_HOSTS=*.sentry.dev,localhost
```

This allows:
- ✅ Local requests (127.0.0.1, ::1, localhost)
- ✅ Vercel Sentry deployments (*.sentry.dev)
- ❌ All other IPs blocked

To add more domains:
```bash
VIBE_TRACE_ALLOWED_HOSTS=*.sentry.dev,*.vercel.app,localhost
```

To disable IP whitelisting (API key still required):
```bash
VIBE_TRACE_ALLOWED_HOSTS=
```

## Troubleshooting

### "Access denied" error
- Check your IP is whitelisted
- Verify X-Forwarded-Host header contains whitelisted domain
- Try disabling whitelist temporarily for testing

### "Missing API key" error
- Verify API key in Sentry code matches `.env`
- Check request headers include `X-API-Key`

### No data showing
- Verify trace exists: `curl -H "X-API-Key: YOUR_KEY" YOUR_NGROK_URL/v2/traces/by-commit/COMMIT_HASH`
- Check commit hash matches exactly
- Verify MCP server is running

## Alternative: Mock Data

If ngrok doesn't work, you can temporarily enable demo mode:

```typescript
const USE_DEMO_DATA = true;  // In aiTrace/index.tsx
```

This shows hardcoded conversation data without needing MCP server.
