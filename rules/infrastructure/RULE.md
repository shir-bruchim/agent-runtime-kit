---
name: infrastructure
description: Infrastructure and deployment conventions covering Docker, env management, deployment checklists, and CI/CD patterns.
---

# Infrastructure & Deployment

Core principles for containerization, environment management, and CI/CD. Deep-dives moved to `references/`.

## Environment Management

```
.env.example    → Committed: shows required variables with placeholder values
.env            → Never committed: actual values
.env.test       → Test environment (safe to commit if no secrets)
.env.production → Never committed, managed via secrets manager
```

## Docker — Core Rules

- Pin base image versions (not `latest`)
- Non-root user for production
- `.dockerignore` to exclude node_modules, .env, .git
- One process per container
- Health checks defined
- Multi-stage builds: separate builder from runtime image

For Dockerfile + Compose examples, see [references/docker.md](references/docker.md).

## Deployment — Core Rules

- Never deploy without passing tests
- Deploy frequently (small, reversible changes)
- Automated rollback on health check failure
- Blue-green or canary for zero-downtime deploys
- Database migrations run as a separate step BEFORE app deploy
- Health check endpoint must respond before traffic is shifted

For the full pre-deploy checklist, see [references/deployment-checklist.md](references/deployment-checklist.md).

For the canonical CI pipeline shape, see [references/github-actions.md](references/github-actions.md).