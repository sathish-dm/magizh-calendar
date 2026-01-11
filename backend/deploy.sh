#!/bin/bash
# Magizh Calendar API - Deployment Script for Home Server

set -e

echo "🚀 Deploying Magizh Calendar API..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "   Copy .env.example to .env and configure your API keys"
    exit 1
fi

# Pull latest code (if running from git repo)
if [ -d .git ]; then
    echo "📥 Pulling latest code..."
    git pull origin main
fi

# Build and start containers
echo "🔨 Building Docker image..."
docker compose -f docker-compose.prod.yml build

echo "🛑 Stopping existing containers..."
docker compose -f docker-compose.prod.yml down

echo "▶️  Starting containers..."
docker compose -f docker-compose.prod.yml up -d

# Wait for health check
echo "⏳ Waiting for API to be healthy..."
sleep 10

# Check health
if curl -s http://localhost:8080/api/panchangam/health | grep -q "OK"; then
    echo "✅ API is healthy!"
    echo ""
    echo "📍 Local URL: http://localhost:8080"
    echo "📍 Health:    http://localhost:8080/api/panchangam/health"
    echo ""
    echo "🔑 Test with API key:"
    echo "   curl -H 'X-API-Key: your-api-key' 'http://localhost:8080/api/panchangam/daily?date=2026-01-11'"
else
    echo "❌ Health check failed!"
    docker compose -f docker-compose.prod.yml logs
    exit 1
fi
