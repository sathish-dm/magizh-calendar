#!/bin/bash

# Start Magizh Calendar Backend API
# Usage: ./start-backend.sh [--docker]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../backend"

cd "$BACKEND_DIR" || exit 1

echo "🚀 Starting Magizh Calendar API..."
echo "📁 Directory: $BACKEND_DIR"

if [ "$1" == "--docker" ]; then
    echo "🐳 Using Docker..."
    docker-compose up -d
    echo ""
    echo "✅ Backend started in Docker"
    echo "📖 Swagger UI: http://localhost:8080/swagger-ui/index.html"
    echo "🔍 Logs: docker-compose logs -f api"
else
    echo "☕ Using Maven..."
    ./mvnw spring-boot:run &

    # Wait for startup
    echo "⏳ Waiting for server to start..."
    sleep 10

    # Check health
    if curl -s http://localhost:8080/api/panchangam/health > /dev/null; then
        echo ""
        echo "✅ Backend started successfully!"
        echo "📖 Swagger UI: http://localhost:8080/swagger-ui/index.html"
        echo "🔗 API Base: http://localhost:8080/api/panchangam"
    else
        echo "❌ Backend failed to start. Check logs."
    fi
fi
