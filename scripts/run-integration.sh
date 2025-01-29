docker compose -f docker-compose.yml up -d

echo  '🟡 - Waiting for database to be ready...'
./scripts/wait-for-it.sh "postgresql://postgres:mysecretpassword@localhost:5432/testIntegration" -- echo '🟢 - Database is ready!'

# Set the correct database URL for integration testing
export DATABASE_URL="postgresql://postgres:mysecretpassword@localhost:5432/testIntegration"

npx prisma migrate dev --name init
npm run test

docker compose -f docker-compose.yml down