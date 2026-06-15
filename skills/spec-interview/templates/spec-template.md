# {{PROJECT_NAME}} Specification

> Generated via spec-interview on {{DATE}}
> Status: {{DRAFT | REVIEW | APPROVED}}

---

## 1. Overview

### 1.1 Problem Statement
{{What specific problem does this solve? Who experiences this pain?}}

### 1.2 Solution Summary
{{One paragraph describing the solution at a high level}}

### 1.3 Success Metrics
- Metric 1: {{description}} — Target: {{value}}
- Metric 2: {{description}} — Target: {{value}}

### 1.4 Non-Goals
{{What are we explicitly NOT doing?}}

---

## 2. Users & Use Cases

### 2.1 Target Users
| User Type | Description | Technical Level | Usage Frequency |
|-----------|-------------|-----------------|-----------------|
| {{Role}} | {{Who they are}} | {{Low/Medium/High}} | {{Daily/Weekly/Monthly}} |

### 2.2 Primary Use Cases
1. **{{Use Case Name}}**: {{Brief description of the user journey}}

### 2.3 User Journey
```
{{Entry Point}} → {{Step 1}} → {{Step 2}} → {{Decision Point}} → {{Outcome}}
```

---

## 3. Functional Requirements

### 3.1 Core Features (MVP)
| Feature | Description | Priority | Acceptance Criteria |
|---------|-------------|----------|---------------------|
| {{Name}} | {{What it does}} | P0 | {{How to verify it works}} |

### 3.2 Phase 2 Features
{{Features planned for subsequent release}}

---

## 4. Technical Architecture

### 4.1 System Overview
{{High-level architecture description}}

### 4.2 Data Model
{{Core entities and their relationships}}

### 4.3 API Design
| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| {{/path}} | {{GET/POST}} | {{What it does}} | {{Required/Public}} |

### 4.4 Technology Stack
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Frontend | {{tech}} | {{why}} |
| Backend | {{tech}} | {{why}} |
| Database | {{tech}} | {{why}} |

---

## 5. UI/UX Design

### 5.1 Key Screens/Views
1. **{{Screen Name}}**: {{Purpose and key elements}}

### 5.2 Error States
{{How errors are communicated to users}}

### 5.3 Accessibility Requirements
{{WCAG level, specific accommodations}}

---

## 6. Integration & Dependencies

### 6.1 External Systems
| System | Purpose | Protocol | Owner |
|--------|---------|----------|-------|
| {{Name}} | {{What we use it for}} | {{REST/GraphQL/etc}} | {{Team/Vendor}} |

### 6.2 Failure Handling
| Dependency | Failure Mode | Handling Strategy |
|------------|--------------|-------------------|
| {{System}} | {{How it fails}} | {{What we do}} |

---

## 7. Error Handling & Edge Cases

### 7.1 Error Taxonomy
| Error Type | User Message | Recovery |
|------------|--------------|----------|
| {{Category}} | {{What user sees}} | {{How to recover}} |

### 7.2 Edge Cases
| Scenario | Expected Behavior |
|----------|-------------------|
| {{What happens}} | {{How system responds}} |

---

## 8. Security & Privacy

### 8.1 Authentication
{{How users prove identity}}

### 8.2 Authorization
| Role | Create | Read | Update | Delete |
|------|--------|------|--------|--------|
| {{Role}} | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ |

### 8.3 Compliance Requirements
{{GDPR, SOC2, HIPAA, etc.}}

---

## 9. Performance & Reliability

### 9.1 Performance Targets
| Metric | Target | Measurement |
|--------|--------|-------------|
| Response time (p50) | {{ms}} | {{How measured}} |
| Response time (p99) | {{ms}} | {{How measured}} |

### 9.2 Availability Target
{{SLA: 99%, 99.9%, 99.99%}}

---

## 10. Operations

### 10.1 Deployment
{{How code gets to production}}

### 10.2 Monitoring & Alerting
| Metric | Threshold | Alert | Response |
|--------|-----------|-------|----------|
| {{What}} | {{Value}} | {{Who/How}} | {{Action}} |

### 10.3 Rollback Plan
{{How to undo a bad deploy}}

---

## 11. Testing Strategy

### 11.1 Test Levels
| Level | Scope | Tooling | Coverage Target |
|-------|-------|---------|-----------------|
| Unit | {{What}} | {{Tool}} | {{%}} |
| Integration | {{What}} | {{Tool}} | {{%}} |
| E2E | {{What}} | {{Tool}} | {{Scenarios}} |

### 11.2 Acceptance Criteria
{{Definition of "done" for the feature}}

---

## 12. Verification Environment

> Used by Ralph autonomous agent to generate accurate verification commands.

### 12.1 Dev Server
- **Start command:** {{npm run dev / python manage.py runserver / etc.}}
- **URL:** {{http://localhost:3000}}
- **Health endpoint:** {{/health or /api/health (if any)}}

### 12.2 Database
- **Type:** {{PostgreSQL / SQLite / MySQL / etc.}}
- **ORM/Migration tool:** {{Prisma / Alembic / Drizzle / Knex / etc.}}
- **Migration command:** {{npx prisma migrate deploy / alembic upgrade head / etc.}}

### 12.3 Test Runners
| Type | Tool | Command |
|------|------|---------|
| Unit tests | {{Jest / Pytest / etc.}} | {{npm test / pytest}} |
| E2E tests | {{Playwright / Cypress / etc.}} | {{npx playwright test}} |
| Typecheck | {{tsc / mypy / etc.}} | {{npx tsc --noEmit / mypy .}} |
| Lint | {{ESLint / Ruff / etc.}} | {{npm run lint / ruff check}} |

---

## 13. Implementation Plan

### 13.1 Phases
| Phase | Scope | Milestone |
|-------|-------|-----------|
| 1 | {{What's included}} | {{Deliverable}} |

### 13.2 Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {{What could go wrong}} | {{H/M/L}} | {{H/M/L}} | {{How to prevent/respond}} |

### 13.3 Open Questions
- [ ] {{Question}} — Owner: {{who will answer}}
