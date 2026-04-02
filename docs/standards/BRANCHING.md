# Branching & Release Strategy (GitFlow)

We use **GitFlow** because our test suite is still maturing and we need to support multiple versions in production simultaneously. GitFlow provides the safety net of a `develop` integration branch where late-stage testing catches regressions before they reach `main`.

> **Why GitFlow?** Because deploying untested code to production is not "moving fast" — it's moving recklessly. GitFlow gives us a staging gate (`develop`) and the ability to maintain parallel release lines for customers on different versions.

---

## Branch Model

```
main ─────────────────────────────────────── (production, tagged releases only)
 │
 ├── hotfix/TICKET-999-critical-fix ──────── (branch from main, merge to main + develop)
 │
 └── develop ─────────────────────────────── (integration branch, CI runs here)
      │
      ├── feature/TICKET-123-add-payments ── (branch from develop, merge to develop)
      ├── feature/TICKET-456-update-schema
      │
      └── release/v1.2.0 ────────────────── (branch from develop, merge to main + develop)
```

## Branch Rules

| Branch | Purpose | Protected | Who Merges |
|--------|---------|-----------|------------|
| `main` | Production-ready, tagged releases only | Yes — no direct commits | Release Manager or CI after release branch approval |
| `develop` | Integration & late-stage testing | Yes — no direct commits | Any developer via approved PR |
| `feature/*` | New functionality | No | Author after code review (min 1 reviewer) |
| `release/*` | Release stabilization & QA | Yes | Release Manager after QA sign-off |
| `hotfix/*` | Emergency production fixes | No | Author after expedited review (see Emergency Fast Track) |

---

## Workflow

1. **Feature Development:** Branch from `develop` → `feature/TICKET-123-description`. Keep branches short-lived (target ≤ 5 days).
2. **Integration:** PR to `develop`. CI runs full test suite. Minimum 1 approval required.
3. **Release Preparation:** When `develop` is stable, branch to `release/vX.Y.Z`. Only bug fixes and version bumps go into this branch — no new features.
4. **Release:** Merge `release/vX.Y.Z` → `main`. Tag with semver (`v1.2.0`). Merge back to `develop` to capture any release fixes.
5. **Hotfix:** Branch from `main` → `hotfix/TICKET-999-description`. Merge to both `main` (tag) and `develop`.

---

## Versioning

* **Semantic Versioning (semver):** `MAJOR.MINOR.PATCH`
  - `MAJOR` — breaking API changes
  - `MINOR` — new features, backward-compatible
  - `PATCH` — bug fixes, no API changes
* Every merge to `main` is tagged. Tags are immutable.
* Release notes are auto-generated from PR titles and linked ADRs.

---

## Supporting Multiple Production Versions

* When customers run different versions, long-lived `support/vX.Y` branches are created from the relevant tag.
* Only **critical security fixes and P1 bug fixes** are back-ported to support branches.
* Support branches have a defined EOL — documented via ADR when the version ships.
