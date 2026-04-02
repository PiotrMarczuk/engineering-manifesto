# Engineering Manifesto & Architectural Process

This document defines the professional standards for system design and feature delivery within this project. We prioritize **clarity**, **traceability**, and **automation** to ensure our architecture remains a living asset, not a decaying artifact.

---

## 1. The Macro-Workflow: System Architecture
*Triggered by foundational changes, new technologies, or cross-cutting integrations.*

> **Why a formal macro-workflow?** Because ad-hoc architecture decisions accumulate into accidental complexity. A lightweight process forces us to think before we build.

### Phase A: Discovery (The Sandbox)
* **Tooling:** LucidChart (Freehand / Whiteboard).
* **Objective:** Rapidly validate ideas and "break" concepts before committing to code.
* **Principle:** These diagrams are ephemeral. We don't aim for beauty; we aim for logic and consensus.
* **Why?** The cheapest place to find a design flaw is on a whiteboard, not in a Pull Request.

### Phase B: Proposal (RFC - Request for Comments)
* **Location:** `docs/rfc/[YYYY-MM-DD]-proposal-title.md`
* **Process:** Use `make new-rfc title="your proposal"` to create a dated file from the template. Edit it, then open a Pull Request for team review.
* **Context:** Attach or link your "Discovery" sketches from LucidChart to provide visual context during the discussion.
* **Why?** Writing forces precision. If you can't explain the trade-offs in prose, you don't understand them yet.

### Phase C: Decision (ADR - Architecture Decision Record)
* **Location:** `docs/adr/` — managed by **[adr-tools](https://github.com/npryce/adr-tools)** (`brew install adr-tools`)
* **Process:** Once an RFC is approved, distill the outcome into a formal ADR. Use `adr new "decision title"` to create a correctly numbered file from `docs/adr/template.md`.
* **Key commands:**
  ```bash
  adr new "adopt postgresql"       # creates next numbered ADR from template.md
  adr list                         # table of all ADRs with status
  adr link 5 "Supersedes" 2        # links ADRs to each other
  ```
* **Rule:** Any "Hard to Reverse" decision (e.g., Database choice, Event-driven vs. Request-Response) **must** have an ADR.
* **ADR Statuses:** `Proposed` → `Accepted` → `Deprecated` | `Superseded`. When superseding an ADR, update the original with a `Superseded by: ADR-XXXX` link — use `adr link` to do this automatically.
* **Why?** Future engineers will ask "why did we choose X?" — an ADR answers that question in 5 minutes instead of 5 meetings.

### Phase D: Formalization (Architecture-as-Code)
* **Location:** `docs/architecture/`
* **Tooling:** Structurizr DSL / Mermaid.js.
* **Process:** Update the **C4 Model** (Level 1: Context & Level 2: Containers).
* **Automation:** Our CI/CD pipeline automatically renders these models into visual assets located in `docs/diagrams/`.
* **Why?** Diagrams that live in code get reviewed, versioned, and updated. Diagrams that live in Confluence get forgotten.

---

## 2. The Micro-Workflow: Feature Delivery
*Triggered for every User Story or technical Task.*

> **Why a micro-workflow?** Because skipping design on "just a small feature" is how monoliths grow tumors.

### Complexity Classification

Not every change needs the full ceremony. Size the process to the risk:

| Tier | Criteria | Required Steps |
|------|----------|----------------|
| **Small** | < 2 days, single service, no API changes | Code Review only |
| **Medium** | 2–5 days, single service, API or schema changes | TDR + Code Review |
| **Large** | > 5 days, cross-service, or new external dependency | Full RFC + TDR + Code Review |

### Steps

1.  **Technical Design Review (TDR):**
    * A TDR is a lightweight design session where the developer outlines the approach *before* writing production code — typically a sequence diagram, data flow sketch, or written summary attached to the ticket.
    * For complex features, the developer creates a **Sequence Diagram** in LucidChart to map data flow across services.
    * This diagram is attached to the issue/ticket before coding starts.
2.  **Contract-First Development:**
    * API Definitions (OpenAPI/Swagger) or Event Schemas must be finalized and reviewed before implementation begins.
    * *Why?* Parallel workstreams unlock when the contract is stable; implementation details can change freely behind a stable interface.
3.  **The "Golden Path" Implementation:**
    * **TDD:** Write tests for core business logic first.
    * **Clean Code:** Adhere to SOLID principles and project-specific patterns (e.g., CQRS, Result Pattern).
    * **Architecture Unit Tests:** Use architecture unit testing (e.g., NetArchTest for .NET, ArchUnit for JVM) to automatically enforce that layers (e.g., Domain vs. Infrastructure) remain decoupled.
    * *Why?* Tests document intent. When they break, they tell you *what* you violated, not just *that* something failed.
4.  **Observability First:**
    * Monitoring is not an afterthought. Structured logs, distributed traces, and metrics must be implemented alongside the feature logic using your platform's observability stack.
    * *Why?* If you can't see it in production, it doesn't exist. Debugging without telemetry is archaeology.

---

## 3. Definition of Done (DoD)
*A task is not "Done" until this checklist is fully satisfied:*

> **Why a formal DoD?** Because "it works on my machine" is not a deliverable. The DoD is our shared contract for what "finished" means.

- [ ] **Code Quality:** Passed Peer Review; follows Clean Code and security best practices.
- [ ] **Testing:** Unit/Integration tests pass with sufficient coverage. Architectural constraints are verified.
- [ ] **Documentation Update:** If the feature modified the system structure, the **C4 Model** in `/docs/architecture/` is updated.
- [ ] **Decision Log:** If a significant technical trade-off was made, a new **ADR** has been recorded.
- [ ] **Observability:** Custom metrics, logs, and alerts for the new feature are configured and tested.
- [ ] **Security:** No high-risk vulnerabilities detected in SAST/dependency scans. Secrets are managed via approved vaults — never committed to source control.
- [ ] **Deployment:** The feature is deployable via the automated CI/CD pipeline without manual intervention.

---

## 4. Visual Documentation Standards (C4 Model)

We use the **C4 Model** (Context → Containers → Components) to maintain a consistent visual language across all architecture diagrams. Source models live in `docs/architecture/`; rendered assets are generated by CI/CD into `docs/diagrams/`.

* **L1 and L2** are always required. L3 is required when a container exceeds 5+ internal modules.
* The C4 model is reviewed against the running system **every quarter**. Stale diagrams are tracked as tech debt.

> 📖 Diagram levels, authoring rules, tooling, and review process: [C4_STANDARDS.md](./standards/C4_STANDARDS.md)

---

## 5. Security Standards

Security is a design constraint, not a checklist item. It shapes every phase — from threat modelling in Discovery to dependency scanning on every PR.

* Threat modelling is required for any new external surface, auth flow, or third-party integration.
* High-severity SAST/SCA findings **block merge**.
* Secrets are never committed to source control — not even temporarily.

> 📖 Threat modelling, dependency scanning, secret management, and least-privilege rules: [SECURITY.md](./standards/SECURITY.md)

---

## 6. Emergency / Hotfix Fast Track

When production is down, process serves the incident — not the other way around.

* **Trigger:** P1/P2 incidents requiring an immediate code change.
* **Allowed Bypass:** RFC, TDR, and full documentation steps may be deferred.
* **Mandatory:** Code Review remains required (minimum 1 reviewer, can be synchronous/live).
* **Payback Window:** A **retroactive ADR** must be filed within **48 hours** of the fix, documenting the root cause, the decision made under pressure, and any follow-up work needed.
* **Why?** Speed without a paper trail creates legacy. The retroactive ADR ensures we learn from every incident.

---

## 7. Branching & Release Strategy (GitFlow)

We use **GitFlow** — `main` (production) → `develop` (integration) → `feature/*` / `release/*` / `hotfix/*`. It provides a late-stage testing gate before production and supports parallel release lines for customers on different versions.

* **Versioning:** Semantic Versioning (`MAJOR.MINOR.PATCH`). Every merge to `main` is tagged. Tags are immutable.
* **Multiple versions:** Long-lived `support/vX.Y` branches for customers on older versions; back-ports limited to security and P1 fixes only.
* **Why?** Deploying untested code is not moving fast — it's moving recklessly.

> 📖 Full branch model, rules, workflow, and support branch policy: [BRANCHING.md](./standards/BRANCHING.md)

---

## 8. API Versioning Strategy

Our public API uses **header-based versioning** (`Accept: application/vnd.myapp.v2+json`). URLs identify resources — not versions.

* **Max 2 concurrent versions** in production. When `v3` ships, `v1` enters a 6-month sunset window.
* **Breaking change = new version.** Adding optional fields is not breaking. Removal, rename, or behavior change is.
* **Implementation:** Use framework-native API versioning middleware; one handler set per version — no `if (version == X)` branching.
* **Why?** Stable URLs + explicit content negotiation = consumers can ignore versions they don't use.

> 📖 Full mechanism, sunset headers, response format, and implementation guidelines: [API_VERSIONING.md](./standards/API_VERSIONING.md)

---

## 9. AI-Assisted Development

AI is a power tool, not an autopilot. The author is always a human — never the model.

* **The Author Rule:** If you can't explain AI-generated code line-by-line in review, you don't ship it.
* **Prompt Hygiene:** Never paste secrets, PII, or proprietary logic into non-approved AI tools. Use only enterprise-tier tools listed in [Approved Tools](../ai/approved-tools.md).

> 📖 Full tier system (Green / Amber / Red), disclosure rules, prohibited practices, and tooling standards: [AI_POLICY.md](../ai/AI_POLICY.md)

---

## 10. Roadmap: Planned Manifesto Expansions

This manifesto is a living document. The following layers are planned for adoption:

### Next

| Layer | Description | Trigger |
|-------|-------------|---------|
| **Data Architecture & Governance** | PII classification, GDPR/CCPA compliance rules, data ownership matrix, retention policies | Before first feature handling personal data |
| **Non-Functional Requirements (NFRs)** | Performance budgets (e.g., P95 latency < 200ms), availability SLAs (99.9%), throughput targets per service | Before first production load test |
| **Cross-Cutting Patterns** | Standardized approaches for auth, caching, retry/circuit-breaker, error handling conventions, correlation IDs | When second service is introduced |
| **Incident Post-Mortems** | Blameless post-mortem template, severity classification (P1-P4), root cause analysis process, follow-up tracking | After first P1 incident or proactively |

### When You Scale

| Layer | Description | Trigger |
|-------|-------------|---------|
| **Cost Governance** | Cloud budget ownership per team/service, cost anomaly alerts, right-sizing reviews, FinOps integration | Monthly cloud spend exceeds $10K or 3+ services in production |
| **Code Ownership (CODEOWNERS)** | GitHub/Azure DevOps CODEOWNERS file, service ownership matrix, on-call rotation mapping | Team exceeds 8 engineers or 4+ services |
| **Dependency Lifecycle** | Framework upgrade cadence (quarterly), EOL tracking, "no new code on deprecated libraries" rule, automated upgrade PRs | More than 20 external dependencies or first EOL event |
| **Platform Engineering** | Internal Developer Platform (IDP), golden path templates, self-service infrastructure, developer experience metrics | Team exceeds 15 engineers or 3+ squads |
| **Compliance & Audit Trail** | Change audit logs, approval workflows for regulated environments, SOC 2 evidence collection | First enterprise customer or regulatory requirement |

> Each layer follows the same adoption process: file an **RFC**, reach consensus, record the **ADR**, and add the section to this manifesto.

---

*"Architecture is the decisions that are hard to change later." — Make them visible, make them traceable, and make them count.*