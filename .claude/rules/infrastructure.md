# Infrastructure & Deployment

## Docker Best Practices

**Multi-stage builds:**
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

**Rules:**
- Pin base image versions (not `latest`)
- Non-root user for production
- `.dockerignore` to exclude node_modules, .env, .git
- One process per container
- Health checks defined

**Docker Compose for local development:**
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

## Environment Management

```
.env.example    → Committed: shows required variables with placeholder values
.env            → Never committed: actual values
.env.test       → Test environment (safe to commit if no secrets)
.env.production → Never committed, managed via secrets manager
```

## Deployment Checklist

Before deploying to production:
- [ ] All tests pass (unit + integration)
- [ ] No hardcoded credentials
- [ ] Environment variables configured in deployment target
- [ ] Database migrations run (separate step before app deploy)
- [ ] Health check endpoint responding
- [ ] Logging configured (structured JSON logs)
- [ ] Error monitoring set up (Sentry, etc.)
- [ ] Rollback plan ready

## CI/CD Patterns

```yaml
# Minimal CI pipeline
on: [push, pull_request]
jobs:
  test:
    steps:
      - checkout
      - setup dependencies
      - run linter
      - run tests
      - build (verify it compiles)
  
  deploy:
    needs: test
    if: branch == 'main'
    steps:
      - run migrations
      - deploy application
      - verify health check
```

**Principles:**
- Never deploy without passing tests
- Deploy frequently (small, reversible changes)
- Automated rollback on health check failure
- Blue-green or canary for zero-downtime deploys
