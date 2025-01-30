#!/bin/bash

# Exit on error and prevent unset variable usage
set -e
set -u

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Load environment variables from .env.test
if [ -f ".env.test" ]; then
    export $(grep -v '^#' .env.test | xargs)
    echo -e "${GREEN}✅ Loaded environment variables from .env.test${NC}"
else
    echo -e "${RED}❌ .env.test file not found!${NC}"
    exit 1
fi

# Ensure DATABASE_URL is set
if [[ -z "${DATABASE_URL:-}" ]]; then
    echo -e "${RED}❌ DATABASE_URL is not set in .env.test!${NC}"
    exit 1
fi

# Extract DB host and port from DATABASE_URL
DB_HOST=$(echo "$DATABASE_URL" | sed -E 's|.*://([^:/]+):([0-9]+)/.*|\1|')
DB_PORT=$(echo "$DATABASE_URL" | sed -E 's|.*://[^:/]+:([0-9]+)/.*|\1|')

# Default values
COMPOSE_FILE="docker-compose.yml"
WAIT_TIMEOUT=15

# Function to cleanup on script exit
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up...${NC}"
    docker compose -f ${COMPOSE_FILE} down
}

# Function to handle errors
handle_error() {
    echo -e "${RED}❌ Error occurred in script at line $1${NC}"
    cleanup
    exit 1
}

# Register cleanup function on script exit
trap cleanup EXIT
trap 'handle_error $LINENO' ERR

echo -e "${YELLOW}🚀 Starting integration test environment...${NC}"

# Start the database
docker compose -f ${COMPOSE_FILE} up -d

# Wait for database to be ready using wait-for-it script
echo -e "${YELLOW}🟡 Waiting for database to be ready...${NC}"
if ! ./scripts/wait-for-it.sh "${DB_HOST}:${DB_PORT}" -t ${WAIT_TIMEOUT} -- echo -e "\n${GREEN}🟢 Database is ready!${NC}"; then
    echo -e "${RED}❌ Failed to connect to database after ${WAIT_TIMEOUT} seconds${NC}"
    exit 1
fi

# Run migrations
echo -e "${YELLOW}📦 Running database migrations...${NC}"
npx prisma migrate dev --name init

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
npm run test

echo -e "${GREEN}✨ Tests completed successfully!${NC}"
