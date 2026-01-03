#!/bin/bash

# Stop all Magizh Calendar services
# Usage: ./stop-all.sh

echo "🛑 Stopping Magizh Calendar services..."

# Stop Spring Boot
pkill -f 'spring-boot:run' 2>/dev/null && echo "✅ Backend stopped" || echo "ℹ️  Backend was not running"

# Stop Docker if running
cd "$(dirname "${BASH_SOURCE[0]}")/../backend" 2>/dev/null
docker-compose down 2>/dev/null && echo "✅ Docker stopped" || true

# Shutdown simulator app (optional)
# xcrun simctl terminate booted com.sats.magizh-calendar-ios 2>/dev/null

echo ""
echo "✅ All services stopped"
