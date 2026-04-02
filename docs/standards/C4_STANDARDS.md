# Visual Documentation Standards (C4 Model)

We use the C4 Model to maintain a consistent visual language across all architecture diagrams.

> **Why C4?** Because a shared vocabulary eliminates the ambiguity of bespoke diagram styles. Every engineer reads the same diagram the same way.

---

## Diagram Levels

| Level | Name | Shows | When Required |
|-------|------|-------|---------------|
| **L1** | System Context | How the system interacts with users and external dependencies | Always |
| **L2** | Containers | High-level breakdown into Web Apps, APIs, Databases, and Messaging Buses | Always |
| **L3** | Components | Internal structural breakdown for highly complex containers | When a container exceeds 5+ internal modules, or when onboarding feedback indicates L2 is insufficient |

---

## Tooling & Location

* **Source:** Structurizr DSL or Mermaid.js — stored in `docs/architecture/`.
* **Rendered output:** `docs/diagrams/` — generated automatically by the CI/CD pipeline. **Do not edit manually.**
* **Why code?** Diagrams that live in code get reviewed, versioned, and updated. Diagrams that live in Confluence get forgotten.

---

## Authoring Rules

* All diagrams must use the standard C4 element types: Person, Software System, Container, Component.
* Relationships must include a label describing intent (e.g., "reads from", "publishes events to").
* External systems are always shown at L1. Do not duplicate them at L2 unless the container interaction detail is required.
* Diagrams are committed in the same PR as the code or ADR that motivated the change.

---

## Review Cadence

> **Quarterly Review:** The C4 model is reviewed against the running system every quarter. Stale or inaccurate diagrams are flagged as tech debt and tracked in the backlog.

The review is owned by the lead engineer for each service. Findings are filed as backlog items, not blocking issues — unless the diagram actively contradicts production behaviour.
