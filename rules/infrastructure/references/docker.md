# Docker — Patterns and Examples

## Multi-stage Builds

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --production=false
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
USER node
CMD ["node", "dist/server.js"]
```

## Rules Recap

- Pin base image versions (not `latest`)
- Non-root user for production
- `.dockerignore` to exclude node_modules, .env, .git
- One process per container
- Health checks defined

## Docker Compose for Local Development

```yaml
services:
  app:
    build: .
    volumes:
      - .:/app          # Hot reload
      - /app/node_modules  # Preserve container modules
    environment:
      - DATABASE_URL=postgresql://...
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    healthcheck:
      test: ["CMD", "pg_isready"]
```