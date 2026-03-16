# LocalStack AWS Service Patterns

> Service-specific configuration and test patterns for LocalStack AWS services (S3, SQS, DynamoDB, Secrets Manager, EKS, etc.) and external resources (Redis, Kafka, databases).

## Adding an AWS Service to LocalStack

### Steps

1. **Fetch Latest Documentation** (mandatory)
   - Main docs: `https://docs.localstack.cloud/aws/{service}/`
   - Feature coverage: `https://docs.localstack.cloud/getting-started/feature-coverage/`
   - Extract: Pro vs Community features, service-specific env vars, initialization requirements, limitations

2. **Update docker-compose.yaml**
   - Add service name to `SERVICES` environment variable
   - Add service-specific environment variables
   ```yaml
   environment:
     - SERVICES=secretsmanager,eks,s3,sqs
     - S3_SKIP_SIGNATURE_VALIDATION=1  # S3-specific
   ```

3. **Create Initialization Script** (if needed)
   - Use `awslocal` CLI for resource creation
   - Handle idempotency with `|| true`
   ```bash
   awslocal s3api create-bucket \
     --bucket test-bucket \
     --region us-east-1 || true
   ```

4. **Update Health Check** (if critical for startup)
   ```yaml
   healthcheck:
     test: >
       bash -c '
       awslocal s3api head-bucket --bucket test-bucket &&
       awslocal secretsmanager describe-secret --secret-id test/secret/name
       '
   ```

5. **Create Service Client**
   ```python
   import boto3
   import os

   client = boto3.client(
       's3',
       endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localhost:4566'),
       region_name='us-east-1'
   )
   ```

6. **Create Integration Test** using real LocalStack service (not mocked)

7. **Update Documentation** with LocalStack docs URL in comments

## S3 Patterns

**Docker Compose config:**
```yaml
environment:
  - SERVICES=secretsmanager,eks,s3
  - S3_SKIP_SIGNATURE_VALIDATION=1  # Allow unsigned requests for testing
```

**Initialization:**
```bash
echo "Creating S3 test buckets..."
awslocal s3api create-bucket --bucket test-agency-files --region us-east-1 || true
awslocal s3api create-bucket --bucket test-documents --region us-east-1 || true
```

**Test fixture:**
```python
@pytest.fixture(scope="session")
def s3_client():
    return boto3.client(
        's3',
        endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localstack:4566'),
        region_name='us-east-1'
    )
```

**Test pattern:**
```python
async def test_s3_file_lifecycle(s3_client):
    bucket = 'test-agency-files'
    key = f'test/{os.getpid()}/document.pdf'
    content = b'Test document content'

    s3_client.put_object(Bucket=bucket, Key=key, Body=content)
    response = s3_client.get_object(Bucket=bucket, Key=key)
    assert response['Body'].read() == content

    s3_client.delete_object(Bucket=bucket, Key=key)
```

**Cleanup fixture:**
```python
@pytest.fixture
def cleanup_s3_bucket(s3_client):
    yield
    response = s3_client.list_objects_v2(Bucket='test-bucket')
    for obj in response.get('Contents', []):
        s3_client.delete_object(Bucket='test-bucket', Key=obj['Key'])
```

Docs: https://docs.localstack.cloud/aws/s3/

## SQS Patterns

**Initialization:**
```bash
awslocal sqs create-queue --queue-name test-queue || true
```

**Deletion (from docker-compose SERVICES and init scripts):**
```yaml
# Remove 'sqs' from SERVICES
environment:
  - SERVICES=secretsmanager,eks  # Removed 'sqs'
```

Docs: https://docs.localstack.cloud/aws/sqs/

## Secrets Manager Patterns

**Initialization:**
```bash
awslocal secretsmanager create-secret \
  --name test/service/configs/resource/123 \
  --secret-string '{"key": "value", "nested": {"data": "here"}}' \
  --region us-east-1 || true
```

**Test fixture:**
```python
@pytest.fixture(scope="function")
def secrets_manager_client():
    return boto3.client(
        'secretsmanager',
        endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localstack:4566'),
        region_name='us-east-1'
    )
```

**Test pattern (with retry for eventual consistency):**
```python
secret_name = f"test/service/configs/agency/{ams_id}"
secret = None
for attempt in range(5):
    try:
        secret = secrets_client.describe_secret(SecretId=secret_name)
        break
    except secrets_client.exceptions.ResourceNotFoundException:
        if attempt < 4:
            time.sleep(1)
            continue
        pytest.fail(f"Secret {secret_name} not created")

secret_value = secrets_client.get_secret_value(SecretId=secret_name)
secret_data = json.loads(secret_value['SecretString'])
```

**Cleanup:**
```python
secrets_client.delete_secret(
    SecretId=secret_name,
    ForceDeleteWithoutRecovery=True
)
```

**Troubleshooting:**
- List all secrets: `awslocal secretsmanager list-secrets`
- Check specific: `awslocal secretsmanager describe-secret --secret-id <name>`
- Common issues: not created in init, wrong name/path, race condition at startup, persistence not enabled

Docs: https://docs.localstack.cloud/aws/secretsmanager/

## EKS Patterns

**Initialization:**
```bash
echo "Creating EKS Cluster..."
awslocal eks create-cluster --name test-cluster || true
awslocal eks wait cluster-active --name test-cluster

# Generate kubeconfig for other containers
awslocal eks update-kubeconfig --name test-cluster --kubeconfig /tmp/config/kubeconfig
# Patch for internal container networking
sed -i 's/localhost/localstack/g' /tmp/config/kubeconfig
```

**Configuration update (adding namespace):**
```yaml
environment:
  - EKS_NAMESPACES=default,test-namespace
```
```bash
kubectl create namespace test-namespace --kubeconfig /tmp/config/kubeconfig || true
```

**Test fixture:**
```python
@pytest.fixture(scope="function")
def k8s_client():
    from kubernetes import config, client
    config.load_kube_config(config_file=os.getenv("KUBECONFIG"))
    return client.BatchV1Api()
```

**Troubleshooting:**
- Check kubeconfig exists: `ls -la /tmp/config/kubeconfig`
- Ensure kubeconfig references `localstack` not `localhost`
- Verify volume mounts for `/tmp/config`
- Disable SSL verification in K8s client if needed

Docs: https://docs.localstack.cloud/aws/eks/

## DynamoDB Patterns

Docs: https://docs.localstack.cloud/aws/dynamodb/

## Adding External Resources (Non-AWS)

For Redis, Kafka, MongoDB, Elasticsearch, RabbitMQ, mock HTTP services, or any Docker-compatible service.

### Steps

1. **Add service to docker-compose.yaml** with proper image, networking, and health check
2. **Create initialization script** if needed (schema SQL, topic creation, etc.)
3. **Configure service discovery** via Docker Compose service names and environment variables
4. **Add health check** and `depends_on` with `condition: service_healthy`
5. **Create client/connection** in app code or test fixtures
6. **Create integration test**

### Redis Example

```yaml
# docker-compose.yaml
redis:
  image: redis:7-alpine
  command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
  ports:
    - "6379:6379"
  networks:
    - localstack_nw
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 5s

app-service:
  environment:
    - REDIS_HOST=redis
    - REDIS_PORT=6379
  depends_on:
    redis:
      condition: service_healthy
```

```python
# Test fixture
@pytest.fixture(scope="session")
def redis_client():
    import redis
    client = redis.Redis(host='redis', port=6379, decode_responses=True)
    client.ping()
    yield client
    client.flushdb()
```

### Database Example (PostgreSQL)

```yaml
volumes:
  - ./config/01_init.sql:/docker-entrypoint-initdb.d/01_init.sql
```

## Updating Existing Configuration

1. Read current config (docker-compose.yaml, init scripts)
2. Fetch latest documentation if changing service behavior
3. Make changes to docker-compose.yaml, init scripts, health checks
4. Test: `docker compose down -v && docker compose up`
5. Run integration tests to verify

## Deleting a Service/Resource

1. Search codebase for service usage (check all tests, app code)
2. Remove from docker-compose.yaml (SERVICES var, service definition, env vars, depends_on)
3. Remove initialization scripts
4. Update health checks
5. Remove app clients and imports
6. Delete test files and fixtures
7. Run `docker compose down -v` to remove volumes

## Init Script Patterns

**Idempotent resource creation** (works on restart with PERSISTENCE=1):
```bash
awslocal s3api create-bucket --bucket test-bucket || true
```

**Wait for service readiness:**
```bash
awslocal eks wait cluster-active --name test-cluster

until awslocal s3api head-bucket --bucket test-bucket 2>/dev/null; do
  echo "Waiting for bucket..."
  sleep 1
done
```

**Shared configuration between containers:**
```bash
awslocal eks update-kubeconfig --name test-cluster --kubeconfig /tmp/config/kubeconfig
sed -i 's/localhost/localstack/g' /tmp/config/kubeconfig
```

**Clear progress logging:**
```bash
set -x
echo "Creating EKS Cluster..."
awslocal eks create-cluster --name test-cluster || true
echo "LocalStack Initialization Complete."
```

## Documentation Sources

**Primary LocalStack Docs** (always fetch latest):
- Main: https://docs.localstack.cloud/
- AWS Coverage: https://docs.localstack.cloud/aws/
- Pro Features: https://docs.localstack.cloud/getting-started/feature-coverage/
- Configuration: https://docs.localstack.cloud/references/configuration/
- Persistence: https://docs.localstack.cloud/references/persistence-mechanism/
- CI Integration: https://docs.localstack.cloud/user-guide/ci/

**Service docs**: `https://docs.localstack.cloud/aws/{service}/` for S3, SQS, SNS, Lambda, DynamoDB, EKS, Secrets Manager, RDS, CloudWatch, ECS, EventBridge, Step Functions, API Gateway, Kinesis, and 90+ more.
