---
name: implement-jira-ticket
description: Implements Jira tickets end-to-end with git setup, planning, coding, and testing. Use when given a Jira ticket ID (e.g., PBAT-123) or when asked to implement a ticket/feature/bug from Jira.
---

<essential_principles>

- **No ping-pong** — batch all changes, present for ONE approval. Do not ask questions mid-implementation.
- **Approval gates** — only 3 stops require user input: plan (with test specs), test stubs written (Red), implementation complete (Green).
- **Follow existing patterns** — study similar features end-to-end before writing a single line.
- **Study sister services** — when a ticket references another repo (e.g., `ams-api-service`), grep its routes/conftest/compose for the canonical pattern. Match it exactly: header names, search-via-POST shape, page envelope, conftest schema init, ECR images. See `references/coding-conventions.md`.
- **Single responsibility** — 1 DB repository per table, no cross-table logic in repos.
- **Naming follows context** — if a repo/module is already context-scoped (e.g., `customers_device`), do NOT repeat the context in method names (`get_by_id`, not `get_by_id_for_customer`). Inside the same module, rename ORM aliases to drop the qualifier (`DeviceOrm`, not `CustomersDeviceOrm`). Drop ticket-only descriptors from code (a ticket saying "flat object" doesn't put `flat` in filenames).
- **Env vars live in `app/core/config.py`** — every new env var goes through `Settings` in UPPER_SNAKE_CASE. Don't `os.environ.get(...)` directly in business code, and don't set up env vars in test files — use `pytest.ini` `env =`. For multi-DB libraries (e.g., `sensi_postgres`), use the library's `client_name` parameter rather than manually mirroring env vars.
- **DRY pagination/filters** — extract page-token + filter resolution into reusable helpers (`BaseFilterPager`, `resolve_search_filter`) that any future search endpoint can pick up. When `page_token` is provided, prior filters (incl. `sort_by`) come from the token, so `sort_by` is Optional in the schema and validated at endpoint level.
- **One middleware does one job — and one only** — if two middlewares both log or both touch context, consolidate. Contextualize tracing headers + log request body + response status + duration in one place. Keep skip-paths in a module-level set (`SKIP_LOG_PATHS = {'/health', '/metrics'}`).
- **SQL query logging in every CRUD method** — log compiled SQL with literal binds at DEBUG (mirror sister-service `log_query` pattern). Tests assert filter wiring; logs make production debugging tractable.
- **Reuse canonical headers** — if `X-Context-Id` already exists in the project, don't introduce `x-request-id` for the same purpose.
- **Docs → tests → code (in that order)** — when a deliverable changes behavior, update docs first (README / docstrings / API spec), then write the failing tests, then the minimal code that turns them green. Docs naming the contract before tests encode it stops tests from drifting toward the implementation you happen to picture. Red → Green → Refactor follows from there. See `workflows/testing.md`.
- **API changes → integration tests are infra, not just a file** — if the ticket changes API behavior, you MUST also wire docker-compose services, conftest schema init, env vars on web/test containers, separate seed SQL files, and Dockerfile-test copies. The test file alone is not enough. See `workflows/testing.md`.
- **Real objects, not MagicMock for domain types** — instantiate real `ams_schema.*`, ORM rows (`sensi_ams_db_orm.models.*`), and internal models (`app.models.*`) with real values. Mock only at system boundaries (DB session, HTTP, S3, Kafka, scraper, logger). MagicMock for a pydantic schema or ORM row silently accepts wrong attribute access and papers over schema breaks. Imports at the top of the test file — never `from foo import Bar` inside a test body.
- **Test factories in conftest** — when a test needs a real model/schema/ORM object, add a `make_*` factory fixture to `tests/conftest.py`, not a private `_make_*` helper inside a single test file. Match the existing pattern (`make_person_schedule`, `make_ams_config`, `make_customer`). Use via dependency injection: `def test_x(make_main_table_client): ...`.
- **Self-review during implementation** — before marking the implementation phase complete, run the pr-review project-specific lens on your own diff. Real duplication, magic-string topics, redundant DB fetches, ticket-prefixed comments, trailing-newline misses — all fixable on the first pass. The "I'll let pr-review catch it" loop is avoidable churn.
- **Enumerate docs before editing** — when a behaviour changes, don't grab the first matching doc file. Scan `CLAUDE.md`, `README.md`, `docs/*.md` to find every place that references the changed behaviour, identify the canonical source-of-truth (often `README.md`, others link to it), edit that one, and prune duplicates if any.
- **Big change → update docs in the same PR** — `CLAUDE.md`, `README.md`, `docs/api.md`, `docs/architecture.md`. New env vars, new endpoints, new middleware behavior all need to land in docs.
- **Use MCP tools** — if Atlassian MCP is connected, use it. If groundcover MCP is connected, use it for logs.
- **No defensive abstractions for hypothetical cases** — don't add a helper / wrapper / sentinel / try-except to defend against an input the underlying library will already raise on (and with the same exception class). If the user asks "is this even needed?", check empirically before defending it. Recurring user feedback: "stop doing complex stuf" / "no no don't do this check just parse to int." Three call sites without an abstraction beats one call site with a thin one — revisit when a third real caller lands.

</essential_principles>

<intake>
Provide a Jira ticket ID (e.g., `PBAT-123`) or paste the ticket details directly.

**Wait for ticket ID before proceeding.**

**Before filing a new ticket under an epic, grep the epic for already-shipped work that matches the description.** When the user says "create a ticket under epic X to do Y", run `searchJiraIssuesUsingJql` with the epic key + a labels/summary filter (`parent = X AND (text ~ "Y" OR labels in ("Y-keyword"))`) and read the matches. If something is already Closed/Done with overlapping scope, surface it BEFORE creating — offer to (a) add a comment to that ticket, (b) re-open it, or (c) create the new one anyway with a clear delta. Recurring failure mode: confidently filing PBAT-NNN-duplicate under the same epic where the work has already shipped; the user pays the cost of catching it. The grep is two tool calls; the duplicate is wasted reviewer attention and a cancelled-ticket trail. Same rule for incident response: if the user asks for a fix ticket, scan the epic's recent Closed work first — the "fix" may already exist and the right action is a comment explaining why it didn't close the incident.
</intake>

<routing>

| Input | Action |
|-------|--------|
| Jira ID (e.g., PBAT-123) | Fetch via Atlassian MCP → follow `workflows/implement-ticket.md` |
| Pasted ticket details | Parse details → follow `workflows/implement-ticket.md` |
| Testing question | → `workflows/testing.md` |
| Coding-convention question | → `references/coding-conventions.md` |
| Review / done check | → `workflows/review.md` |

**Detailed steps are in the workflow files. Read the relevant workflow before proceeding.**

</routing>

<success_criteria>

- [ ] Branch created from develop with correct naming (`feature/{JIRA-ID}`)
- [ ] Sister services studied for canonical patterns (when ticket references one)
- [ ] Implementation plan (with test specs) approved
- [ ] Tests written FIRST and verified failing (Red phase)
- [ ] All code implemented in one batch — tests now pass (Green phase)
- [ ] Code refactored if needed (Refactor phase)
- [ ] Existing patterns followed (header names, search shape, page envelope)
- [ ] Naming follows context (no redundant qualifiers, no ticket-only descriptors)
- [ ] New env vars added to `app/core/config.py` in UPPER_SNAKE_CASE
- [ ] Test env vars added to `pytest.ini`
- [ ] Reusable pagination/filter helpers extracted (when adding a search endpoint)
- [ ] SQL query logging added to every new CRUD method
- [ ] Middleware consolidated (no duplicate logging/context middlewares)
- [ ] Integration/localstack tests fully wired (compose service + conftest + seed SQL + Dockerfile-test) if API behavior changed
- [ ] ECR mirror used for Docker base images (when project convention)
- [ ] Docs updated: CLAUDE.md, README.md, docs/api.md, docs/architecture.md
- [ ] Ticket re-checked against acceptance criteria — see `workflows/review.md`

</success_criteria>