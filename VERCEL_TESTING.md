# Testing Agent Trace on Vercel with Secure MCP Server

This guide explains how to securely expose your local MCP server to test the Agent Trace feature on Vercel deployment.

## Prerequisites

- MCP server running locally with API key authentication
- ngrok installed (`brew install ngrok` or download from https://ngrok.com)
- Vercel deployment of Sentry with Agent Trace feature

## Security Setup

### 1. API Key Authentication

The MCP server now requires API key authentication for all endpoints except `/health`.

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

### 3. Expose with ngrok

```bash
ngrok http 8080
```

You'll get output like:
```
Forwarding  https://abc123.ngrok-free.app -> http://localhost:8080
```

### 4. Test the Tunnel

Test without API key (should fail):
```bash
curl https://abc123.ngrok-free.app/v2/traces/by-commit/8e536955/conversation
# Returns: {"error": "Missing API key"}
```

Test with API key (should work):
```bash
curl -H "X-API-Key: mwu18CWSSa7jSGHi53ZkcyoG9Z9s3S6B2uCX7FPPRy4" \
  https://abc123.ngrok-free.app/v2/traces/by-commit/8e536955/conversation
# Returns: conversation data
```

### 5. Update Sentry Code for Vercel

Update the Sentry Agent Trace component to use the ngrok URL:

```typescript
// In static/app/views/issueDetails/aiTrace/index.tsx
const MCP_SERVER_URL = 'https://abc123.ngrok-free.app';
const MCP_API_KEY = 'mwu18CWSSa7jSGHi53ZkcyoG9Z9s3S6B2uCX7FPPRy4';
const USE_DEMO_DATA = false;
```

Commit and push to trigger Vercel deployment.

### 6. Test on Vercel

1. Create a test error in any Sentry project
2. Add git commit tag that matches a trace in your MCP server
3. View the issue on Vercel deployment
4. Agent Trace section should load real data from your MCP server

### 7. Stop Exposure (IMPORTANT!)

**Immediately after testing**, stop ngrok to close the tunnel:
```bash
# Press Ctrl+C in the ngrok terminal
```

This ensures your conversation data is no longer publicly accessible.

## Security Notes

✅ **API key required** - All endpoints (except /health) require authentication
✅ **HTTPS encryption** - ngrok provides TLS/SSL automatically
✅ **Temporary URL** - ngrok URL expires when tunnel closes
⚠️ **API key in frontend** - The key is visible in browser dev tools
⚠️ **Rate limiting** - Not currently implemented (could add if needed)
⚠️ **IP whitelisting** - Not currently implemented (could add Vercel IPs)

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
