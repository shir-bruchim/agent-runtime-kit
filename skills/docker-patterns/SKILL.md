---
name: docker-patterns
description: "Docker + Compose patterns for dev, security, networking, volumes. Use when writing a Dockerfile or docker-compose."
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
Universal Docker security rules (pin base, non-root, no secrets in image, .dockerignore, minimal base, drop capabilities) live in `~/.claude/rules/infrastructure/RULE.md` §"Docker — Core Rules" (with examples in `~/.claude/rules/infrastructure/references/docker.md`). Compose-specific operational guidance is in `<compose_dev>` / `<volume_strategies>` below.
</security>

<volume_strategies>

| Type | Use For |
|------|---------|
| Named volume | Persistent data (databases) |
| Bind mount | Source code hot reload (dev only) |
| Anonymous volume | Preserve container-managed dirs (node_modules) |

</volume_strategies>

<anti_patterns>
See `~/.claude/rules/infrastructure/references/docker.md` for the canonical anti-patterns list (and `~/.claude/rules/infrastructure/RULE.md` §"Docker — Core Rules" for the summary).
</anti_patterns>

<success_criteria>
- [ ] Multi-stage build (separate build/production stages)
- [ ] Non-root user in production
- [ ] Health checks defined
- [ ] `.dockerignore` excludes sensitive files
- [ ] Base images pinned to specific versions
</success_criteria>
