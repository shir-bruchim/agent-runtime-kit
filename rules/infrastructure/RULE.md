---
name: infrastructure
description: Infrastructure and deployment guardrails — env management, Docker, and deployment ordering.
---

# Infrastructure Guardrails

- **Env:** commit `.env.example` (placeholders only); `.env` / `.env.production` never committed (secrets manager); `.env.test` OK if secret-free.
- **Docker:** pin base image versions (not `latest`); non-root user in prod; `.dockerignore` (node_modules/.env/.git); one process per container; health checks; multi-stage (builder → runtime).
- **Deploy:** never deploy without passing tests; small reversible changes; DB migrations as a separate step BEFORE app deploy; health check must respond before shifting traffic; automated rollback on failure; blue-green/canary for zero-downtime.

Dockerfile/Compose examples and CI pipeline shapes live in the lazy `docker-patterns` and `deployment-patterns` skills.
