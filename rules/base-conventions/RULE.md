---
name: base-conventions
description: Universal coding standards (naming, function design, error handling, comments, file organization) that apply regardless of language or framework.
---

# Base Coding Conventions

## Clarity
- Names reflect purpose: `getUserByEmail()` not `getUser()`; no abbreviations (`userId` not `uid`).
- Functions do ONE thing; if describing it needs "and", split. Over ~30 lines → look to split.
- Early returns over nested conditionals. No magic numbers — name them (`MAX_RETRIES = 3`).
- Pass the domain entity, not its exploded fields, when args always travel together.
- Reuse a value already on the object; don't recompute a second copy of the same truth.

## Don't reach for reflection when you know the type
You wrote the signature — access `obj.attribute` / `obj["key"]` directly. `hasattr`/`getattr`/`dict.get(k, default)` are for genuinely dynamic dispatch (plugin loaders, ORM column iteration) or third-party objects you don't control — not for tracking your own dataclass fields. For per-subclass config, declare a class attribute (`TENANT_SCOPED: bool = False`) subclasses override, not a runtime `hasattr` probe.

## Imports & files
- All imports at module top — never inside a function body (an in-function import hides a circular-dependency smell; fix the cycle by injecting the dependency). Only exception: an optional/heavy dep behind a feature flag, with a one-line why.
- Layout follows the project's existing convention — strict-layered (`api → logic → repositories → models`) or feature-folders. Match what's there; don't impose the other. One primary export per file.

## Error handling
- Validate at system boundaries (user input, external APIs, file reads) — not everywhere.
- Fail fast with specific messages: `"user_id must be positive, got -1"` not `"invalid input"`.
- Never swallow errors (`except: pass`). Prefer typed exceptions over generic `Error(...)`.

## Config & comments
- Config from env vars (never hardcode URLs/timeouts/limits); module-level `UPPER_SNAKE_CASE` constants.
- Comments explain WHY, not WHAT — default is NO comment. Add one line only when a naive reader would ask "why this weird construction?" and the answer is a past bug or subtle invariant. Trim existing comment blocks when editing; don't extend them.

## Tooling discipline (this harness)
- Edit tracked files ONLY via Read → Edit/Write. Never `python -c` / `sed -i` / `awk -i inplace` / heredoc redirection — they bypass the diff preview and protect-files hooks and mangle multiline content.
- zsh doesn't word-split unquoted expansions: iterate with an array (`for f in "${FILES[@]}"`), never `for f in $FILES`.
- Write to the project's linter on the first pass — check line length / alignment / import rules in its config before writing style-sensitive code; don't ship pretty-but-failing code.
- Verify assumptions against the real code/config before asserting a fact; say what you verified.