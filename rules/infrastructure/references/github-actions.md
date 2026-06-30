# CI/CD Pipeline Shape

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

## Principles

- Never deploy without passing tests
- Deploy frequently (small, reversible changes)
- Automated rollback on health check failure
- Blue-green or canary for zero-downtime deploys