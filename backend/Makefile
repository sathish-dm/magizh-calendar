.PHONY: help build run test clean docker-build docker-run docker-stop logs

# Default target
help:
	@echo "Magizh Calendar API - Available Commands"
	@echo "========================================="
	@echo ""
	@echo "Development:"
	@echo "  make run          - Run the application locally"
	@echo "  make build        - Build the application"
	@echo "  make test         - Run tests"
	@echo "  make clean        - Clean build artifacts"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-run   - Run with Docker Compose"
	@echo "  make docker-stop  - Stop Docker containers"
	@echo "  make logs         - View Docker logs"
	@echo ""
	@echo "Utilities:"
	@echo "  make swagger      - Open Swagger UI in browser"
	@echo "  make health       - Check API health"
	@echo "  make daily        - Test daily endpoint"

# Development commands
run:
	./mvnw spring-boot:run

build:
	./mvnw clean package -DskipTests

test:
	./mvnw test

clean:
	./mvnw clean
	rm -rf target/

# Docker commands
docker-build:
	docker build -t magizh-calendar-api:latest .

docker-run:
	docker-compose up -d

docker-stop:
	docker-compose down

logs:
	docker-compose logs -f api

# Utility commands
swagger:
	open http://localhost:8080/swagger-ui/index.html

health:
	@curl -s http://localhost:8080/api/panchangam/health && echo ""

daily:
	@curl -s "http://localhost:8080/api/panchangam/daily?date=$$(date +%Y-%m-%d)" | python3 -m json.tool
