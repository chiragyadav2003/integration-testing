#!/bin/bash

# Exit on error and prevent unset variable usage
set -e
set -u

# Default values
DB_NAME="testIntegration"
DB_USER="postgres"
DB_PASSWORD="mysecretpassword"
DB_PORT="5432"
DB_HOST="localhost"
COMPOSE_FILE="docker-compose.yml"
WAIT_TIMEOUT=15

# Construct database URL once
DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=public"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Register the cleanup function to run on script exit
trap cleanup EXIT
trap 'handle_error $LINENO' ERR

echo -e "${YELLOW}🚀 Starting integration test environment...${NC}"

# Start the database
docker compose -f ${COMPOSE_FILE} up -d

# Wait for database to be ready using wait-for-it script
echo -e "${YELLOW}🟡 Waiting for database to be ready...${NC}"

# Use wait-for-it to check database connection with timeout If the database isn't reachable within 15 seconds, it prints an error and exits the script.
if ! ./scripts/wait-for-it.sh "${DATABASE_URL}" -t ${WAIT_TIMEOUT} -- echo -e "\n${GREEN}🟢 Database is ready!${NC}"; then
    echo -e "${RED}Failed to connect to database after ${WAIT_TIMEOUT} seconds${NC}"
    exit 1
fi

# Export database URL for other commands
export DATABASE_URL

# Run migrations
echo -e "${YELLOW}📦 Running database migrations...${NC}"
npx prisma migrate dev --name init

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
npm run test

echo -e "${GREEN}✨ Tests completed successfully!${NC}"