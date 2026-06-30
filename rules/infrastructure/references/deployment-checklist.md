# Deployment Checklist

Before deploying to production:

- [ ] All tests pass (unit + integration)
- [ ] No hardcoded credentials
- [ ] Environment variables configured in deployment target
- [ ] Database migrations run (separate step before app deploy)
- [ ] Health check endpoint responding
- [ ] Logging configured (structured JSON logs)
- [ ] Error monitoring set up (Sentry, etc.)
- [ ] Rollback plan ready