---
name: deployment-patterns
description: "CI/CD, health checks, and rollback patterns. Use when deploying, setting up CI/CD, or writing GitHub Actions."
---

<objective>
Production deployment best practices: strategies, CI/CD pipelines, health checks, rollback, and readiness checklists. References `~/.claude/rules/infrastructure/RULE.md` for Docker and environment conventions.
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

### CI/CD anti-patterns to catch in review

- **Don't pass secrets across job boundaries.** CI systems strip masked values when they cross jobs (GitHub Actions logs `Skip output '<X>' since it may contain secret` and the downstream job receives an empty string with no error). Resolve the secret inside the job that uses it, even if that duplicates a setup step. Cross-job outputs are fine for non-sensitive values only.
- **Pick the runner that can actually reach the target.** Before writing CI tests against a deployed service, check whether the service has a public ingress. If it doesn't, the runner must live inside the same network (self-hosted, in-cluster, VPC-attached) — the default cloud-vendor runner can't resolve cluster-internal DNS. Don't add a public route just to make CI reachable; move CI to the network instead.
- **Confirm the deployed image SHA before drawing conclusions from a post-deploy test.** When a workflow runs a load test, perf benchmark, or smoke test after a deploy job in the same pipeline, the deploy rollout may still be in progress when the test starts. The test then runs against the previous image while the artifact is labeled "post-merge" — false confidence that the change had no effect. Before any post-deploy assertion, confirm the rollout is complete: `kubectl rollout status deploy/<name> --timeout=5m`, OR assert that the deployed image tag matches the head SHA (`kubectl get deploy <name> -o jsonpath='{.spec.template.spec.containers[0].image}'`), OR pull the running image from observability (Groundcover/Datadog/k8s API) and assert it matches. Either gate the test on rollout-status or fail the test if the image SHA doesn't match. Skipping the confirmation collapses half the test's value into a meaningless number.
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
Universal Application + Infrastructure readiness items live in `~/.claude/rules/infrastructure/references/deployment-checklist.md` (entry: `~/.claude/rules/infrastructure/RULE.md` §"Deployment — Core Rules"). Operations items kept here because they're org-process, not infra-pattern:

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
