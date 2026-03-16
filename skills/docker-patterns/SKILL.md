---
name: docker-patterns
description: "Docker and Docker Compose patterns for local development, container security, networking, volume strategies, and multi-service orchestration. Use when writing a Dockerfile, setting up docker-compose, containerizing an app, or asking about container security."
---

<objective>
Docker and Docker Compose best practices for development and production: multi-stage builds, security hardening, networking, and volume strategies.
</objective>

<when_to_activate>
- Writing or reviewing Dockerfiles
- Setting up docker-compose for local dev
- Containerizing an application
- Container security review
</when_to_activate>

<multi_stage_build>
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
USER node
CMD ["node", "dist/server.js"]
```

### Python multi-stage
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN pip install uv && uv sync --frozen --no-dev
COPY . .

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /app /app
USER nobody
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0"]
```
</multi_stage_build>

<compose_dev>
```yaml
services:
  app:
    build: .
    volumes:
      - .:/app          # Hot reload
      - /app/node_modules
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "3000:3000"

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready"]
      interval: 5s
      timeout: 3s

  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]

volumes:
  pgdata:
```
</compose_dev>

<security>
- Pin base image versions (not `latest`)
- Run as non-root user (`USER node` / `USER nobody`)
- Use `.dockerignore` (exclude .env, .git, node_modules)
- One process per container
- No secrets in image layers (use runtime env vars)
- Scan images: `docker scout cves <image>`
</security>

<volume_strategies>

| Type | Use For |
|------|---------|
| Named volume | Persistent data (databases) |
| Bind mount | Source code hot reload (dev only) |
| Anonymous volume | Preserve container-managed dirs (node_modules) |

</volume_strategies>

<anti_patterns>
- Using `latest` tag in production
- Running as root
- Copying `.env` files into image
- Installing dev dependencies in production image
- Not using health checks
- Large images (use `-alpine` or `-slim`)
</anti_patterns>

<success_criteria>
- [ ] Multi-stage build (separate build/production stages)
- [ ] Non-root user in production
- [ ] Health checks defined
- [ ] `.dockerignore` excludes sensitive files
- [ ] Base images pinned to specific versions
</success_criteria>
