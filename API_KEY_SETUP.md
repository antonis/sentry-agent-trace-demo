# API Key Authentication Setup

✅ **Status**: API key authentication successfully implemented for MCP server

## What Changed

### MCP Server (`mcp-server/server.py`)
- Added `require_api_key` decorator
- All endpoints except `/health` now require authentication
- API key checked via `X-API-Key` header or `api_key` query parameter
- Loads key from `VIBE_TRACE_API_KEY` environment variable

### Git Hook (`scripts/extract_claude_conversation.py`)
- Loads API key from `mcp-server/.env` file
- Sends key in `X-API-Key` header when storing traces

### Sentry Frontend (`static/app/views/issueDetails/aiTrace/index.tsx`)
- Sends API key in `X-API-Key` header when fetching traces
- Configurable via `MCP_API_KEY` constant

## Current API Key

Stored in `mcp-server/.env`:
```
VIBE_TRACE_API_KEY=mwu18CWSSa7jSGHi53ZkcyoG9Z9s3S6B2uCX7FPPRy4
```

⚠️ **Note**: This key is for local development only. Do NOT commit `.env` to git.

## Testing Locally

1. **Start MCP server**:
   ```bash
   cd mcp-server
   python3 server.py
   ```

2. **Test authentication**:
   ```bash
   # Without key (should fail)
   curl http://localhost:8080/v2/traces/by-commit/ba20aad/conversation
   # Returns: {"error": "Missing API key"}
   
   # With key (should work)
   curl -H "X-API-Key: mwu18CWSSa7jSGHi53ZkcyoG9Z9s3S6B2uCX7FPPRy4" \
     http://localhost:8080/v2/traces/by-commit/ba20aad/conversation
   # Returns: conversation data
   ```

3. **Test git hook**:
   ```bash
   git commit -m "Test commit"
   # Should show: ✅ Trace stored in MCP server v2
   ```

4. **Test Sentry integration**:
   - Start Sentry dev server: `cd /Users/antonis/git/sentry && pnpm dev-ui`
   - Open http://localhost:7999
   - View an issue with matching commit hash
   - Agent Trace section should load with real data

## Testing on Vercel

See `VERCEL_TESTING.md` for instructions on securely exposing the MCP server via ngrok for Vercel testing.

## Security Features

✅ API key required for all data endpoints
✅ Environment variable configuration
✅ `.env` file excluded from git
✅ Simple to rotate keys (just update `.env`)
⚠️ No rate limiting (could add if needed)
⚠️ No IP whitelisting (could add for production)
⚠️ API key visible in Sentry frontend (acceptable for internal/demo use)

## Next Steps for Production

1. Deploy MCP server to secure hosting
2. Use environment variables (not hardcoded keys)
3. Add rate limiting middleware
4. Add IP whitelisting for Sentry/Vercel IPs
5. Implement key rotation policy
6. Add request logging and monitoring
