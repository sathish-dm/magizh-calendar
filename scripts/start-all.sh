#!/bin/bash

# Start both Backend and iOS App
# Usage: ./start-all.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🎯 Starting Magizh Calendar Full Stack"
echo "======================================="
echo ""

# Start backend first
echo "1️⃣  Starting Backend..."
"$SCRIPT_DIR/start-backend.sh"

echo ""
echo "2️⃣  Starting iOS App..."
"$SCRIPT_DIR/start-ios.sh" --build

echo ""
echo "======================================="
echo "✅ All services started!"
echo ""
echo "📖 Swagger UI: http://localhost:8080/swagger-ui/index.html"
echo "📱 iOS App: Running in simulator"
echo ""
echo "To stop backend: pkill -f 'spring-boot:run'"
