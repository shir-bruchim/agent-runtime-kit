# Docker Compose Testing Infrastructure

> Docker Compose patterns for test infrastructure, container management, and test execution.

## Docker Compose Patterns

### Health Checks with Proper Timing

```yaml
healthcheck:
  test: ["CMD", "service-specific-health-check"]
  interval: 10s      # How often to check
  timeout: 5s        # Max time for health check to complete
  retries: 5         # Number of failures before unhealthy
  start_period: 30s  # Grace period before checking (critical for slow-starting services)
```

`start_period` prevents race conditions during startup. Critical for services like LocalStack that take time to initialize.

### Service Dependencies

```yaml
service-a:
  depends_on:
    service-b:
      condition: service_healthy  # Wait for health check to pass
    service-c:
      condition: service_started  # Just wait for start (no health check)
```

Ensures correct startup order and prevents failures from services starting before dependencies are ready.

### Shared Networks for Inter-Service Communication

```yaml
services:
  localstack:
    networks:
      - test_nw
  app:
    networks:
      - test_nw

networks:
  test_nw:
    external: false
    driver: bridge
```

All services on the same network can communicate using service names as DNS hostnames (e.g., `http://localstack:4566`).

### Volume Mounts for Configuration and Persistence

```yaml
localstack:
  volumes:
    - "./localstack_data:/var/lib/localstack"          # Persistence
    - "./run.sh:/etc/localstack/init/ready.d/run.sh"   # Init script
    - "./config:/tmp/config"                            # Shared config
```

- Persistence volume preserves state across restarts
- Init scripts in `/etc/localstack/init/ready.d/` run when LocalStack is ready
- Shared config volumes allow multiple services to access the same files (e.g., kubeconfig)

### Environment Variable Files

```yaml
env_file:
  - ./config/local_stack_env
environment:
  - SPECIFIC_VAR=value  # Service-specific overrides
```

Keeps docker-compose.yaml clean and allows sharing common variables across services.

### Platform-Specific Images

```yaml
platform: linux/arm64  # For M1/M2 Macs
build:
  context: ../
  dockerfile: Dockerfile
```

Ensures compatibility across different architectures (Intel vs ARM).

## Test Execution Patterns

### Complete Docker Environment Reset (Canonical)

```bash
# ALWAYS do this before running full test suite
docker compose down --rmi all --volumes --remove-orphans
docker compose up -v --force-recreate --build --remove-orphans
```

- `--rmi all`: Removes ALL images (forces rebuild from scratch)
- `--volumes`: Removes all volumes (clears database state, cache, etc.)
- `--remove-orphans`: Removes containers not defined in current docker-compose.yaml
- `--force-recreate`: Forces recreation even if configuration/image hasn't changed
- `--build`: Rebuilds images from Dockerfile

**When to use:**
- Before running full integration test suite
- When tests fail mysteriously and you suspect stale state
- After changing Dockerfile or docker-compose.yaml
- When switching branches with different database schemas
- Before debugging flaky tests

### Quick Test Run

```bash
docker compose down --rmi all --volumes --remove-orphans
docker compose up -v --force-recreate --build --remove-orphans

# Once services are up
docker compose exec test pytest local_stack/ -v
```

### Run Specific Test

```bash
docker compose down --rmi all --volumes --remove-orphans
docker compose up -v --force-recreate --build --remove-orphans

docker compose exec test pytest local_stack/test_file.py::test_name -v -s
```

## Cleanup Patterns

### Selective Service Restart

```bash
docker compose restart localstack
docker compose logs -f localstack
```

Faster than full restart when debugging single service issues.

### Clean Test Data Between Runs (Without Docker Restart)

```python
@pytest.fixture(scope="function", autouse=True)
def cleanup_test_data(redis_client, s3_client, secrets_client):
    """Auto-cleanup test data after each test"""
    yield

    # Clear Redis test keys
    redis_client.delete(*redis_client.keys('test:*'))

    # Clear S3 test objects
    for obj in s3_client.list_objects_v2(Bucket='test-bucket', Prefix='test/')['Contents']:
        s3_client.delete_object(Bucket='test-bucket', Key=obj['Key'])

    # Delete test secrets
    for secret in secrets_client.list_secrets()['SecretList']:
        if secret['Name'].startswith('test/temp/'):
            secrets_client.delete_secret(
                SecretId=secret['Name'],
                ForceDeleteWithoutRecovery=True
            )
```

Ensures clean state between tests without full Docker restart. Faster test iterations.

### Remove Orphaned K8s Resources

```bash
kubectl get cronjobs --kubeconfig=/tmp/config/kubeconfig
kubectl delete cronjobs -l test=true --kubeconfig=/tmp/config/kubeconfig
kubectl delete jobs -l test=true --kubeconfig=/tmp/config/kubeconfig
```

### Prune Docker Resources

```bash
docker container prune -f    # Remove stopped containers
docker volume prune -f       # Remove unused volumes
docker image prune -f        # Remove unused images
docker system prune -a -f --volumes  # Remove everything unused (careful!)
```

## General Debugging Commands

```bash
# Full cleanup and restart
docker compose down -v
docker compose up --build -d
docker compose logs -f

# Check service health
docker compose ps
docker compose exec localstack curl -s http://localhost:4566/_localstack/health | jq

# Enter container for debugging
docker compose exec service-name bash

# Check LocalStack service status
docker compose exec localstack awslocal eks describe-cluster --name test-cluster
docker compose exec localstack awslocal secretsmanager list-secrets

# Run specific test with verbose output
docker compose exec test pytest local_stack/test_file.py::test_name -v -s

# Check network connectivity
docker compose exec app-service ping localstack
docker compose exec app-service curl http://localstack:4566/_localstack/health

# Check mounted volumes
docker compose exec app-service ls -la /tmp/config
docker compose exec localstack ls -la /var/lib/localstack
```

## Troubleshooting

### Docker Compose Build Fails

```bash
# Build with verbose output
docker compose build --no-cache --progress=plain
docker compose config  # Check syntax
```

Common causes:
- Build context too large: Add `.dockerignore`
- Dependency installation fails: Check package names, verify network
- Multi-stage build issues: Ensure COPY commands reference correct stage
- Platform mismatch: Add `platform: linux/arm64` or `linux/amd64`

### Tests Pass Locally but Fail in CI

- **Timing**: CI has less resources, increase timeouts in retry logic
- **Environment**: Ensure CI has all required env vars
- **Resource limits**: Optimize test resource usage or increase CI limits
- **Parallel execution**: Use unique identifiers per test, improve isolation
