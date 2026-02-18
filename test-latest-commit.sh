#!/bin/bash

# Helper script to test the latest git commit
# Usage: ./test-latest-commit.sh

# Get the latest commit hash
COMMIT=$(git rev-parse HEAD)
SHORT_COMMIT=$(git rev-parse --short HEAD)

echo "🔍 Latest commit: $SHORT_COMMIT"
echo "📋 Full hash: $COMMIT"
echo ""

# Check if server is running
if ! lsof -i:8000 > /dev/null 2>&1; then
    echo "⚠️  Dev server not running. Starting it now..."
    echo ""
    python3 serve.py &
    SERVER_PID=$!
    sleep 2
    echo "✅ Server started (PID: $SERVER_PID)"
    echo ""
else
    echo "✅ Dev server already running"
    echo ""
fi

echo "🚀 Opening test page with commit parameter..."
echo ""
echo "   URL: http://localhost:8000/simple-web-test/index.html?commit=$COMMIT"
echo ""

# Open in default browser with commit parameter
open "http://localhost:8000/simple-web-test/index.html?commit=$COMMIT"

echo "✅ Test page opened!"
echo ""
echo "Next steps:"
echo "  1. Click '🔥 Send Error to Sentry' button"
echo "  2. Go to https://antonis-b7.sentry.io/issues/"
echo "  3. Find error with commit $SHORT_COMMIT"
echo "  4. Verify Agent Trace section shows your conversation"
echo ""
echo "📝 Note: Dev server will keep running. To stop it: ps aux | grep serve.py"
