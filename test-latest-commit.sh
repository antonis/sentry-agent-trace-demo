#!/bin/bash

# Helper script to test the latest git commit
# Usage: ./test-latest-commit.sh

# Get the latest commit hash
COMMIT=$(git rev-parse HEAD)
SHORT_COMMIT=$(git rev-parse --short HEAD)

echo "🔍 Latest commit: $SHORT_COMMIT"
echo "📋 Full hash: $COMMIT"
echo ""
echo "🚀 Opening test page with commit parameter..."
echo ""
echo "   URL: file://$(pwd)/simple-web-test/index.html?commit=$COMMIT"
echo ""

# Open in default browser with commit parameter
open "simple-web-test/index.html?commit=$COMMIT"

echo "✅ Test page opened!"
echo ""
echo "Next steps:"
echo "  1. Click '🔥 Send Error to Sentry' button"
echo "  2. Go to https://antonis-b7.sentry.io/issues/"
echo "  3. Find error with commit $SHORT_COMMIT"
echo "  4. Verify Agent Trace section shows your conversation"
