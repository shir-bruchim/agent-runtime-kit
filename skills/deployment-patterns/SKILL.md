---
name: deployment-patterns
description: "Deployment workflows, CI/CD pipeline patterns, health checks, rollback strategies, and production readiness checklists. Use when deploying an application, setting up CI/CD, writing GitHub Actions, or asking about rollback strategies."
---

<objective>
Production deployment best practices: strategies, CI/CD pipelines, health checks, rollback, and readiness checklists. References `rules/infrastructure.md` for Docker and environment conventions.
</objective>

<when_to_activate>
- Setting up CI/CD pipelines
- Writing GitHub Actions workflows
- Configuring health checks
- Planning deployment strategy
- Pre-production readiness review
</when_to_activate>

<deployment_strategies>

| Strategy | How | Best For | Risk |
|----------|-----|----------|------|
| **Rolling** | Replace instances gradually | Most deployments | Low |
| **Blue-Green** | Two identical environments, switch traffic | Zero-downtime, easy rollback | Medium (2x resources) |
| **Canary** | Route % of traffic to new version | High-traffic, risk-sensitive | Low (gradual) |

</deployment_strategies>

<github_actions>
```yaml
name: CI/CD
on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run lint
      - run: npm test -- --coverage
      - run: npm run build

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./scripts/deploy.sh
      - run: curl -f https://myapp.com/health || exit 1
```
</github_actions>

<health_checks>
```python
# FastAPI
@app.get("/health")
async def health():
    return {"status": "ok", "version": settings.VERSION}

@app.get("/health/ready")
async def readiness():
    # Check dependencies
    await db.execute("SELECT 1")
    return {"status": "ready"}
```

### Kubernetes Probes
```yaml
livenessProbe:
  httpGet: { path: /health, port: 8000 }
  initialDelaySeconds: 10
  periodSeconds: 30
readinessProbe:
  httpGet: { path: /health/ready, port: 8000 }
  initialDelaySeconds: 5
  periodSeconds: 10
```
</health_checks>

<rollback>
```bash
# Immediate rollback strategies
git revert HEAD && git push              # Revert last commit
kubectl rollout undo deployment/myapp    # K8s rollback
docker compose up -d --no-deps app       # Redeploy previous image
```

**Rollback checklist:**
- [ ] Health check failing? → Rollback immediately
- [ ] Data migration involved? → Ensure backward-compatible schema
- [ ] Feature flag available? → Disable flag instead of rollback
</rollback>

<production_readiness>
Before deploying to production:

**Application:**
- [ ] All tests pass (unit + integration)
- [ ] No hardcoded credentials
- [ ] Health check endpoints responding
- [ ] Structured logging configured (JSON)
- [ ] Error monitoring set up (Sentry)

**Infrastructure:**
- [ ] Environment variables configured
- [ ] Database migrations run (separate from deploy)
- [ ] Connection pooling enabled
- [ ] SSL/TLS configured

**Operations:**
- [ ] Rollback plan documented
- [ ] Monitoring dashboards set up
- [ ] Alerting configured
- [ ] On-call rotation defined
</production_readiness>

<success_criteria>
- [ ] CI pipeline passes before any deploy
- [ ] Health checks verify deployment success
- [ ] Rollback plan tested
- [ ] Zero-downtime deployment verified
</success_criteria>
