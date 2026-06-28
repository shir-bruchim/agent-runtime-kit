# Coding Conventions for Jira-Ticket Implementations

This file captures patterns extracted from real ticket implementations. Apply them by default; deviate only with an explicit reason.

<naming>

## Naming

- **Don't repeat the context.** If the repository/module is already scoped to a context (e.g., `customers_device.py`), method names should NOT repeat that context. `customers_device.get_by_id(...)` not `customers_device.get_by_id_for_customer(...)`. Same for ORM aliases: `from sensi_ams_db_orm.models import Device as DeviceOrm` (not `CustomersDeviceOrm`) when the file is already `crud_customers_device.py`.
- **Don't bake the ticket's descriptive language into the code.** If the ticket says "return a flat device object", that's a description for humans — `Device` (not `FlatDevice`), `device.py` (not `device_flat.py`), `map_to_schema` (not `map_to_flat_schema`).
- **`v2_` / `v1_` prefixes are fine for clearly-versioned files** (`mappers/v2_device.py`, `schemas/v2/device.py`). The version describes the API surface, not the data shape.
- **Reuse canonical project names.** If `X-Context-Id` already exists project-wide, don't introduce `x-request-id` for the same tracing concept.

</naming>

## Configuration & Env Vars

- **Every new env var goes through `app/core/config.py`** as a `Settings` field in `UPPER_SNAKE_CASE`. Don't `os.environ.get(...)` directly in business code.
- **Multi-DB libraries:** use the library's `client_name` parameter — `sensi_postgres.PostgresSessionMaker(client_name="CUSTOMERS")` reads `CUSTOMERS_DB_*` automatically. Don't manually mirror env vars.
- **Test env vars belong in `pytest.ini`**, never in test files. `pytest.ini`:
  ```ini
  [pytest]
  testpaths = ./tests
  env =
      DB_SERVICE=test
      CUSTOMERS_DB_NAME=test
      ...
  ```
- **`testpaths`** should point at the folder (`./tests`), not enumerate every file.

## Schema Design

- **Extract a `BaseFilterPager`** for search endpoints with `page_token`, `page_index`, `page_size`, `sort_order` (all Optional). Per-resource filters extend it.
- **`sort_by` is Optional** when `page_token` is provided — the token encodes prior filters incl. `sort_by`. Endpoint-level validation rejects (`422`) when neither is present.
- **`orm_mode`** (Pydantic v1) is only needed when constructing schemas via `Device.from_orm(orm_row)`. If your mapper does explicit `Device(id=..., name=...)`, drop it.

## Repository / CRUD Layer

- **One repo per table.** Don't put cross-table logic in a repo.
- **Always log compiled SQL at DEBUG** in every CRUD method:
  ```python
  def _log_query(query):
      full_sql = str(query.statement.compile(compile_kwargs={"literal_binds": True}))
      logger.debug(f"▶ Full SQL QUERY:\n{full_sql}")
  ```
  Tests assert filter wiring; logs make production debugging tractable.
- **`page_size + 1` trick** for `has_more`: query `limit(page_size + 1)`, return `rows[:page_size]` and `has_more = len(rows) > page_size`.
- **Customer-scoped repos enforce `customer_id` server-side** — always add it to the WHERE, never trust client to pass it through filters. This is the IDOR guard.

## API Layer

- **Mandatory headers/query params validate via FastAPI typed dependencies.** Missing/invalid → 422. Reuse a single `get_tracing_headers` and `get_customer_id` dependency across every v2 route.
- **Search-via-POST** for filtered list reads (`POST /<resource>/search`), not GET with query strings. Filters in body, mandatory params (customer_id, headers) on the request envelope.
- **Page-token round-trip:** server encodes `(page_index, filters, sort_by, sort_order)` as base64 JSON. Client sends only `{"page_token": "..."}` for subsequent pages. Helper lives in a `pagination.py` so future search endpoints reuse it.

## Middleware

- **Consolidate.** If two middlewares both log or both touch context, merge them. The single middleware should:
  1. Read or generate `X-Context-Id`.
  2. Contextualize per-surface tracing headers (e.g., `x-user-id`, `x-client-name` for v2 paths).
  3. Log request body + response status + process time.
  4. Skip paths in a module-level `SKIP_LOG_PATHS = {'/health', '/metrics'}`.
  5. Echo `X-Context-Id` on the response.

## Docker / Infrastructure

- **Use the org's ECR mirror** for base images when sister services do (e.g., `443793523615.dkr.ecr.eu-west-1.amazonaws.com/python:3.11-slim`).
- **Don't hardcode CMD** if the project launches via `python main.py` / `uvicorn.run(...)` inside `main.py`.
- **Mirror sister-service Dockerfile-test layout** when adding new test files: copy them in alongside conftest and seed SQL.