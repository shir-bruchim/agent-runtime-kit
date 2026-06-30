---
name: pr-review
description: "Reviews a GitHub PR diff for correctness, security, tests, architecture. Use when asked to review a PR or pull request."
allowed-tools: Bash, Read, Grep, Glob
---

<objective>
Fetch a PR diff via `gh`, analyze it across 5 generic dimensions AND across project-specific architectural concerns, and output a structured review report with inline findings. Universal at the base; opinionated for SensiAI / Python+FastAPI codebases at the top.
</objective>

<when_to_activate>
- User says "review PR", "review this pull request", "check PR #123"
- User pastes a GitHub PR URL and asks for feedback
- After creating a PR with `/pr` and wanting self-review before requesting teammates
</when_to_activate>

<workflow>

### Step 0 — Ordering when both PR comments and CI failures exist

If the user's request includes BOTH unresolved bot/reviewer comments AND a CI run, address comments FIRST, then check CI:

1. Fetch and address unresolved bot/baz/copilot comments via the review platform's per-thread comments API (`gh api repos/<o>/<r>/pulls/<n>/comments` on GitHub). Triage into FIX / WONT_FIX / ALREADY_FIXED, batch all FIX edits into one focused commit, then reply per-thread linking the resolving SHA: FIX → `Addressed in <short-sha> — <one-line of what changed>`; WONT_FIX → lead with `Won't fix` and give the reasoning (cost/benefit, abstraction threshold, breaks shared pattern), don't be apologetic — a reasoned no closes the thread better than a defensive yes; ALREADY_FIXED → `Addressed in <prior-sha> — <pointer>`. Don't extract a dedup abstraction on review feedback alone if only two callers share the pattern; the abstraction threshold is three. Don't reply to spec-reviewer "met" items unless the user asks — those are informational.
2. THEN inspect CI failure logs.

Bot comments often explain or contextualize the CI failure. Reading CI first risks fixing a symptom that the bot already proposed a different fix for.

**Always fetch the canonical comment text before reasoning about it.** When the user pastes a bot comment excerpt and asks to address it, run `gh api repos/<o>/<r>/pulls/<n>/comments` and read the full body — user-pasted excerpts truncate. Arguing against a "fabricated" file reference that turns out to be in the part you didn't see is a self-inflicted credibility hit. Same applies symmetrically: bot comments can be wrong, but the burden of proof is "I read the source comment AND the relevant code, here's the disagreement," not "the user's paraphrase didn't include this so the bot must be hallucinating."

### Step 1 — Fetch PR Diff
```bash
# By PR number (current repo)
gh pr diff <number>

# Get PR metadata
gh pr view <number> --json title,body,additions,deletions,changedFiles,baseRefName,headRefName
```

### Step 2 — Categorize Changed Files
- `src/` or app code → logic review
- `tests/` → test quality review
- Config files (`*.toml`, `*.yml`, `*.env*`) → secrets + config review
- Migrations → database safety review
- Lock files, generated files → skip

### Step 3 — Analyze Across 5 Dimensions

#### A. Correctness
- Logic errors, off-by-one, null/None handling
- Edge cases not covered
- Incorrect assumptions about input types

#### B. Security (CRITICAL — flag immediately)
- Hardcoded secrets, API keys, passwords
- SQL injection (string formatting into queries)
- Unsanitized user input passed to shell/eval/exec
- Insecure deserialization
- Path traversal vulnerabilities

#### C. Best Practices (language-aware)
- Mutable default arguments (Python: `def f(x=[])`)
- Bare `except:` / empty `catch` clauses
- Missing type annotations on public functions
- Functions >50 lines, files >800 lines
- Magic numbers / hardcoded values

#### D. Test Coverage
- Are new functions covered by tests?
- Are edge cases tested?
- Are exception paths tested?
- Are external calls mocked?
- Coverage appears to meet 80%+ threshold?

#### E. Code Quality
- Naming clarity (functions, variables, classes)
- Duplication (same logic appears 2+ times)
- Deep nesting (>4 levels)
- Commented-out code left in
</workflow>

<decision_logic>
- **No PR number/URL provided** → Ask for it
- **`gh` not authenticated** → Show `gh auth login` instructions
- **PR has >50 changed files** → Focus on `src/`, `app/`, core logic; skip lock/generated files
- **Security issue found (CRITICAL)** → Flag at top of report before anything else
- **No tests changed but logic changed** → Flag: "No tests added/modified for changed logic"
- **Only docs changed** → Skip security/logic; focus on clarity and accuracy
</decision_logic>

<output_format>
```markdown
## PR Review: <title> (#<number>)

**Branch**: `<head>` → `<base>`
**Changes**: +<additions> / -<deletions> across <N> files

---

### CRITICAL Issues
(Security or correctness blockers — must fix before merge)

- `path/to/file:42` — **Issue**. Remediation.

---

### Warnings
(Should fix — code quality, missing tests, non-critical bugs)

- `path/to/file:17` — **Issue**. Remediation.

---

### Suggestions
(Nice to have — style, naming, minor improvements)

- `path/to/file:88` — Suggestion.

---

### Looks Good
- Items that passed review

---

### Summary
| Dimension | Status |
|-----------|--------|
| Correctness | PASS / WARN / FAIL |
| Security | PASS / WARN / FAIL |
| Best Practices | PASS / WARN / FAIL |
| Test Coverage | PASS / WARN / FAIL |
| Code Quality | PASS / WARN / FAIL |

**Verdict**: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
```
</output_format>

<success_criteria>
- [ ] All 5 dimensions analyzed for every changed file
- [ ] CRITICAL issues flagged at top with file:line and remediation
- [ ] Verdict clearly stated
- [ ] No false positives on generated/lock files
- [ ] Project-specific lens applied (see below)
</success_criteria>

<self_review_first>
Before presenting any non-trivial change as "complete", run the project-specific lens below on your own diff. Apply review-grade cleanups during the initial implementation, not after. Common easy wins:

- Two near-identical helpers in two siblings? Extract to the base on the first pass, not the third.
- Repeating a string literal as both a Kafka topic and a test selector? Module-level constant on the first pass.
- Reusable test factory in two test files? `make_*` fixture in conftest, not a private `_make_*` per file.
- Comment carrying a ticket prefix (`PBAT-NNNNN: …`)? Strip the prefix on the first pass; ticket history belongs in PR/git, not in code.
- Trailing newlines on every file you touch — fix while you're there.

**Verify reviewer suggestions at the cited lines, don't reason from memory.** Before agreeing OR disagreeing with any reviewer suggestion (Baz, Copilot, human), open the file at the cited lines and read the actual code. For dependency / cross-repo claims, also `grep -rEn '...' ~/PycharmProjects/` neighboring repos — the bot's named file may not be the only relevant one. "Probably looks like X" reasoning produces both false confirmations (apply a fix that wasn't needed) and false denials (dismiss a real bug because the imagined code looked fine).

**Reproduce CI checks locally on CI's runtime version before declaring ready.** Read `.github/workflows/*.yml` for the runtime version (`python-version: 3.11`, etc.) and the install footprint (`requirements.txt`? `tests/requirements.txt`? extras?). Match all of it locally — don't trust the IDE's long-lived venv. Run every CI step (lint + tests + build), not just the one wired in the IDE. **When CI is delegated to a reusable workflow you don't own** (`uses: <org>/<repo>/.github/workflows/X.yml@<ref>`), the upstream's hard-coded paths/filenames are part of the contract — read the upstream once before renaming or splitting any file it consumes. A locally sensible rename of `tests/requirements.txt` or `pytest.ini` will fail CI in a way that looks unrelated to the rename. The "CI tells me what flake8 could've told me 30s earlier" loop is avoidable.

The "I'll let pr-review catch it" loop is avoidable churn.

**Tech-lead self-review checklist** — run this against your own diff BEFORE declaring code done. If you skip it, the reviewer (human or bot) does it for you AND you eat reviewer churn.

1. **Dead code.** Anything declared but never imported / called? Delete it.
2. **Module size + responsibility.** Any file > 200 lines doing more than one thing? Split it.
3. **Magic numbers + duplication.** Same constant in 2+ places → hoist to shared config. Same logic in 2 functions → extract.
4. **Reflection.** See `~/.claude/rules/base-conventions/RULE.md` §"Code Clarity" (the `getattr`/`hasattr` bullet) — no `getattr`/`hasattr`/`setattr` on types you wrote.
5. **Complexity.** Any nested loop scaling with input that a dict makes O(1)? Any list-of-strings scan that should be a set? Never accept O(n²) silently.
6. **Try/except.** Catching `Exception:` or bare `except:` → narrow it. Swallowing without logging → don't.
7. **Comments.** Restates the code? Delete. Explains WHY a non-obvious choice? Keep.
8. **Tests.** Every public function covered? Edge cases? Empty inputs? Boundary conditions?
9. **Types.** Public function signatures fully typed? Optional return type pinned? Conversely — type aliases earn their weight only when they make a recurring shape readable. A one-use `TypeAlias` over a nested `Callable[..., Callable[..., Awaitable[Any]]]` is harder to parse than the inline annotation it replaces; collapse it to the simpler form (`Optional[Callable]`) unless the precise generic fixes a real ambiguity or reduces duplication.
10. **Reuse.** Is there an existing helper that does this? Check the project, the framework, the stdlib BEFORE writing a new one.
11. **Project-specific lens pass.** Apply the `<project_specific_lens>` block below to your own diff.
12. **Senior-reviewer mental check.** If you imagine a senior reviewer reading this, what's the first thing they'd flag? Fix it now.
13. **Grep sibling call sites of the primitive you just fixed.** When the fix is a pattern (replacing `scalar_one_or_none()` with `.first()`, removing a swallowed `except:`, adding a `customer_id` filter, swapping `.isdigit()` for `.isdecimal()`), the file usually has 2-3 mirror copies of the same broken code. Run `grep -n <primitive> <file>` (or `rg <primitive> app/<module>/`) before declaring done — the same primitive misused once is almost always misused 2-3 times. A pattern fix that ships with only one site updated leaks the regression to the next reviewer pass; calling sites of a bug class are siblings, not strangers.
14. **Paired-method symmetry.** If the class exposes paired/parallel methods (`publish` + `publish_batch`, `get` + `list`, `sync` + `async`), check that retries, logging, auth, and metrics apply to BOTH or NEITHER. Asymmetric cross-cutting concerns leak through the un-wrapped path in production — fix the symmetry before declaring done.
</self_review_first>

<duplication_classification>
When a finding suggests extracting a shared helper, classify it BEFORE applying:

- **Real duplication** — same args, same data flow, same constants → extract to base/shared module.
- **Shape-similarity** — different mappers / topics / source-data types that just *look* alike → leave it; report "shape-similar only, not extracting" with the divergence list.

Don't auto-apply extract findings without that classification. A 2-call-site abstraction over genuinely different signatures is thin and awkward; revisit when a third lands.
</duplication_classification>

<project_specific_lens>

The 5 generic dimensions above catch language-level issues. The following lens — distilled from recurring review feedback in SensiAI codebases — catches architectural and project-conventions issues that the generic pass misses. Apply BOTH layers; treat each principle below as a first-class review dimension.

### A. Layer separation is non-negotiable
api → logic/handler → mapper → db. Each layer has a single responsibility:
- **API**: response shaping, raise HTTP errors, no DB awareness, no business logic. ("api level should not be aware to db level")
- **Logic / handler**: business rules, orchestration. Logic for domain X lives in `logic/X.py` — don't reach across domains directly; call the other domain's logic. ("use agencies logic — domain separation!!!!!!")
- **Mappers**: only map between objects. No logger, no DB calls, no logic. ("in mapper we only map between class — keep the file clear and clean, no logic in it.")
- **DB / repo**: only DB access. No API/schema awareness. One repo per table; cross-table logic doesn't belong in repos. ("move the whole creation of db object to the mapper — here should accept db object and not dict.")
Flag any layer leak — including: API calling DB directly, logic calling DB without going through repo, mapper containing logic, repo accepting/returning api schema objects.

### B. Tests use real objects; mock only external resources
See the canonical rule in `~/.claude/skills/testing/SKILL.md` `<pytest_principles>` "Real objects for domain types". Project quote: "use only real object and not MagicMock — in all tests" / "Always use real objects, mock only external resources (db, clients etc)". Flag `MagicMock(id=..., ams_id=...)` style mocks for domain types as CHANGES_REQUESTED.

Other testing rules:
- Logic changed → tests must be added/updated. No tests = CHANGES_REQUESTED.
- For migrations: don't only test the post-migration shape — test the migration path itself ("exist row in db without status/status None and see that it being update to value 1").
- Integration tests under `local_stack/` do NOT use `pytest.ini` (that's unit-test only). Don't conflate the two.
- For enum / lookup tables: cache 1h–1d TTL when reading.
- Use existing `add_*` / `assert_and_commit_data` helpers in `local_stack/conftest.py`; don't reinvent.
- Test names must match the behavior they assert.

### C. Reuse Sensi internal packages before writing new code
Before approving any new HTTP client, secrets handler, SQS publisher, postgres session, redis client, or AMS-API caller — grep for the equivalent Sensi package and demand its use:
- `sensi-cloud` → secrets manager, SQS (use the singleton pattern)
- `sensi-postgres` → DB sessions (multi-client via `client_name="X"`; envvars are auto-resolved by config)
- `sensi-ams-api-client` → all AMS API calls (don't write raw `requests.get(...)` to AMS endpoints)
- `sensi-logger` → structured logging with `logger.contextualize(...)` for request scope
- `sensi-redis` → async redis
- `sensi-ams-db-python` → customers DB ORM (`sensi_ams_db_orm.models.*`)
Re-implementing what these provide is a CHANGES_REQUESTED. ("highly recommend to use sensi-ams-api-client pkg to avoid issues" / "please use sensi-cloud pkg" / "use singleton as other claude components")

### D. Migrations must be safe for existing rows
- New NOT NULL column → must have a `DEFAULT` or an explicit backfill. Otherwise existing rows break and rollback breaks dependent services.
- Don't wrap migrations in `BEGIN`/`COMMIT` — `run_db.sh` wraps each migration in its own transaction.
- Don't use a sequence for a predefined / lookup table.
- Most enum / lookup tables include a `description` column for consistency.
- Renaming a column → keep the old column AND add the new one with a backfill ALTER, don't just delete the old name.
- Tests must exercise the migration path: existing-row scenario, default-value-set-by-migration scenario, AND the new-write scenario.
- For composite-PK / shape changes in `models.py`: ORM regenerated and committed (both `models.py` and `prisma/schema.prisma`).

### E. Env vars + config go through pydantic Settings
- Never `os.environ.get(...)` scattered through code. All env vars in `app/core/config.py` (or `app/util/settings.py`) as a pydantic `Settings` class — UPPER_SNAKE_CASE.
- New env var → must be added to helm values for every env (dev / usdev / staging / prod). Mirror naming from sister services (e.g., `*_RR_DB_*` for read-replica clients, mirroring ams-api-service).
- Secrets in helm → 1Password operator references (`op://<env>-platform/<service>/<key>`), never plaintext.
- Username, phone_number, SENTRY_DSN — these are NOT secrets; flag if the PR treats them as such.
- For tests / debug knobs, env-var-with-default is fine ("for tests and if you like to change it in the future why not?").

### F. Integration tests are real infrastructure
- `local_stack/` runs against actual containers (postgres, redis, localstack, customers_postgres). Wire the customers DB through `ams-db-schema` package + a separate seed SQL.
- Service in compose names matter — test code references the compose service hostname.
- `--exit-code-from <test>` is mandatory on the CI `docker compose up` so failures propagate.
- Each new table touched by the change should have a row inserted (or covered by `assert_and_commit_data`); `test_run_db_script` style tests need every table populated.
- **CI-coverage gate: a `--ignore=tests/test_*.py` line in the service Dockerfile means CI doesn't run those tests.** If you add an ignore (because the test imports a module not in the service image), you MUST add a compensating GHA step in the same PR that installs the right deps and runs the ignored tests. "Test exists but CI doesn't run it" ≡ "test doesn't exist." Cross-check: is the new workflow a required check on the PR?

### G. Delete dead code aggressively
- Commented-out code in a fresh repo is clutter from day 1.
- `try/except` wrapping code already wrapped at api/middleware level → redundant, remove.
- Wrappers around generic exceptions that just log and re-raise — remove or make specific.
- "if not used, delete" — applies to `Region`, `ReferredBy`, `Administrator`, model fields, helper functions, params, imports.
- Don't wrap mappers with `try/except` ("map should never fail — therefore no need try/catch").
- A function with the comment `# TODO` to delete IS the signal to delete.

### H. Naming reflects context, not noise
- Repo lives in customers context → don't prefix functions with `customer_` redundantly. ("if the repository is customers_device so all funcs in it should not be with 'customer' name in them")
- `shift` ≠ `visit`; visit can exist without shift. Don't conflate.
- `schedule` ≠ `clock` — schedule data and time-tracking data are different concepts.
- When you only return an id, name the field `*_id` (e.g., `category_id`, not `category`).
- ORM/known-type property → call it directly. See `~/.claude/rules/base-conventions/RULE.md` §"Code Clarity" for the canonical no-reflection rule.
- Field names in pydantic should reflect the real value semantics; if the column is `bo_id` but the value is a customer id, use a pydantic alias and name the field `customer_id`.

### I. Pydantic and validation
- Validate at API boundary (request body / query / headers) — not redundantly in logic + db.
- Don't add defaults if the user must pass the value. ("dont use default for this value, make sure to use only what the user pass")
- Use pydantic correctly → many helper / parser functions disappear ("if you use pydantic correctly you don't need this func at all").
- Use `Field(...)` patterns for constraints (min_length, ge, etc.) — don't validate in code.
- For new v2 APIs at SensiAI: mandatory headers (X-Context-Id, x-user-id, x-client-name) + mandatory `customer_id` query param. Missing/invalid → 422.

### J. DB query and repository discipline
- Use the read replica for getters (mirror the `*_RR_DB_*` env-var convention).
- Always filter by `customer_id` and `status=1` (soft-delete guard) when querying customer-scoped tables — these are pure filters, not optional params.
- Don't filter on the DB what the client can filter at runtime; don't add joins that aren't needed.
- One repo per table. Cross-table logic lives in logic/handler, not in a repo.
- Use `execute_list_query` / shared helpers; don't reinvent them.
- Update without re-querying when possible (`UPDATE ... WHERE id = ?`); don't fetch + update unless you need the row.
- For upserts, rely on unique indexes — don't query first then insert/update.
- Logging the compiled SQL at DEBUG (with literal binds) is the project pattern; flag if a new repo lacks it.

### K. Dependencies
- New requirement pinned to a placeholder (`0.0.0`, branch ref, `+pbat.NNNNN`) → mandatory reminder comment: "update to real version after dep PR merges to master".
- Pin versions for libraries that frequently break (sensi-* packages, kafka). `pytz` is fine unpinned.
- `uv.lock` / `yarn.lock` — yes, commit them. But check: was a lock file committed by accident in a place that shouldn't have one?

### L. Refactor and abstractions
- Don't extract a helper for 2 call sites with subtly different logic — comment why and skip.
- A shared abstraction at 2 callers is thin and awkward; "revisit when a third lands."
- **No speculative code.** Don't add branches, helpers, Settings fields, or storage envelopes for callers that don't exist. Examples: an `isinstance(result, Response)` check when no handler returns Response; a Settings field that's never read (only projected back to env via setdefault); base64-wrapping JSON bytes "in case we need non-JSON later". Each speculative branch costs latency on every request and is dead code until a real caller appears. Revisit when one does.
- **No speculative recommendations.** A "could it be X?" is a question; a recommendation requires evidence. Before recommending a change to "improve" something measurable (hit-rate, latency, cost, error rate), either (a) pull the data and prove the upside, or (b) ask one clarifying question to bound the hypothesis. Speculation framed as a finding is a credibility hit — and the "fix" often does nothing or introduces risk (e.g., dropping a cache-key field whose variance is zero ships a cross-tenant leak for zero gain). When a hypothesis depends on a fact about the system ("the bearer is per-caller"), verify it from code/config — don't pattern-match from generic experience.
- Splitting a long function into clearly-named helpers (`handle_unknown_emails`, `send_slack_replay_for_invalid_agency_status`) is encouraged for readability.
- Generic `try/except` blocks that wrap a long function should usually be split — error handling per case is more specific.
- Circular imports → pass the resolved object as a param instead of importing the resolver inside the client.
- `getattr` / `isinstance` on known ORM properties is a code smell; remove and call the property directly.
- "Move to const / env var" — magic numbers, sentinels, allowed-host lists, max-size — extract.

### M. Clients and scrapers
- HTTP clients: validate URL scheme (`https`) and hostname allow-list at the boundary.
- Async vs sync: blocking `requests.get` inside an async function → `asyncio.to_thread(...)`.
- Use the project's `GRAPHQL` internal object for known constants — don't hard-code values that scraping resolves.
- Token refresh: refresh on use (when the API returns a "refresh required" error), not on a timer.
- Don't keep both `requests` and `httpx.AsyncClient` for the same flow — pick one.

### N. Dockerfile / docker-compose / helm
- Use the Sensi ECR mirror for base images (`443793523615.dkr.ecr.eu-west-1.amazonaws.com/...`).
- Service names in compose must match what the tests / helm probes expect (`<service>-service`, not `web`).
- `--abort-on-container-exit --exit-code-from <test>` is mandatory in CI.
- helm `containerPort` must match the Dockerfile `EXPOSE` and the uvicorn `--port`.
- 1Password operator inject for db/api credentials — not plaintext, not in repo.
- Comment out → delete; don't ship "comment all file" placeholders.

### O. PR hygiene
- README / `CLAUDE.md` / `docs/` updated when behavior changed.
- Doc updated when API behavior changed.
- Commit doesn't accidentally include `.env`, model files, lock files that shouldn't exist.
- ORM regenerated and BOTH `models.py` + `prisma/schema.prisma` committed when schema changed.
- Don't ship "comment all file" placeholders or `# TODO` files.
- "Not related to this PR" changes — flag as a separate-PR concern.

### P. Code / style discipline (cross-cutting)
- **Cleanup belongs in `finally`** — closing connections, releasing locks, removing temp files, pushing metrics that must fire even on error. "Move to finally" / "do it in finally" recurs.
- **Static-method scrutiny** — `@staticmethod` is suspect when the method clearly belongs to instance state; flag "Why is it static? you don't use them as static methods" cases.
- **Healthcheck must not run a heavy query** — `/health` returning a probe every 30s should NOT do real DB work. Either return 200 (alive) or do `SELECT 1` only. A real query per probe is a CHANGES_REQUESTED.
- **Webhook response conventions** — third-party webhooks (Twilio, etc.) often expect empty body / specific Content-Type. FastAPI's default `return None → null + application/json` breaks them. When reviewing a new webhook, check the third-party's expected response shape.
- **Probe null/empty paths through** — when a model field can be `None`, ask "what does the code do when it is None? when empty? when whitespace?". Don't accept a single guard at one layer if the field flows through several.
- **File I/O hygiene** — `open(...)` always with `encoding="utf-8"`. `open` without `close` (or without `with`) is a leak.
- **Logging hygiene** — `print` → `logging`. `logging.exception("…")` (not `logging.error`) when inside `except` so the traceback is captured. Don't catch + silently ignore.
- **Catch specific exceptions** — generic `except Exception` (or bare `except:`) is "too broad" and gets flagged. Catch the actual error class and let unknown ones propagate.
- **Comprehensions over manual loops** — when building a list/dict from another iterable, comprehensions are preferred over `for` + `.append()`. For dataframes, `nunique()`, `set_index()`, `to_csv(index=False)` are project idioms.
- **CLI flag conventions** — flags use dashes (`--continuous-label`), accessed in code with underscores (`args.continuous_label`). For tri-state options use `choices=[...]`, not three booleans. Boolean flags are bare `--flag`, not `--flag true`.
- **Type hint conventions** — `Optional[X]` not `Union[X, None]`. Be consistent: all `Path` or all `str` for path-typed args, not mixed. `Literal["a", "b"]` for mode strings. Don't `cast` when you can simply annotate the return.
- **Don't pin defaults that the caller must always pass** — "no default" recurs; defaults silently mask missing-arg bugs.
- **Linters must pass** — `black`, `isort`, `flake8` (and `pylint` where the project uses it). An `isort` miss on imports is a small but consistent flag.
- **Avoid changing param order on a stable interface** — additive params at the end with a default; reordering breaks every caller.
- **`is True` / `is False` / `is None`** — explicit comparisons for `None`; for booleans only when the value can also be a non-bool truthy/falsy and the distinction matters.
- **Prefer correct collection type over deferred dedup** — when a field semantically holds a unique-and-ordered collection, declare it that way (`set[T]` for unique-unordered; insertion-ordered `dict[T, None]` or accumulate-via-`if x not in lst` for unique-ordered). Don't carry a `list[T]` and clean up with `sorted(set(field))` at the end — end-of-function cleanup hides the invariant and makes "is this dedup'd at this point?" un-greppable. Reserve `sorted(set(x))` only for boundaries where you can't change the type (external API responses).

</project_specific_lens>
