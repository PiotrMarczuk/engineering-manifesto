# Engineering Manifesto

This repository serves as the **Single Source of Truth** for system architecture, technical decisions, and engineering standards. I follow an **Architecture-as-Code (AaC)** philosophy to ensure the documentation evolves at the same pace as the codebase.

---

## Repository Structure

```
/
├── docs/
│   ├── adr/                # Architecture Decision Records (Historical Log)
│   ├── rfc/                # Request for Comments (Proposals & Discussions)
│   ├── architecture/       # Source Models (Structurizr DSL / Mermaid)
│   ├── diagrams/           # Rendered Assets (CI/CD Output - Do not edit)
│   ├── standards/          # Detailed Engineering Standards
│   │   ├── BRANCHING.md        # GitFlow Branch Model & Release Strategy
│   │   └── API_VERSIONING.md   # API Versioning Strategy & Sunset Policy
│   └── ARCH_PROCESS.md     # Engineering Manifesto (Macro & Micro Workflows)
├── ai/                     # AI Policy, Approved Tools & Prompt Library
│   ├── AI_POLICY.md
│   ├── approved-tools.md
│   └── prompts/            # Skill/instruction files for Copilot & Claude
├── src/                    # Application Source Code
├── tests/                  # Test Suites (Unit, Integration, Architecture)
└── Makefile                # CLI Tooling (make new-rfc, make list-rfc, etc.)
```

---

## Our Engineering Workflow

We believe that clear communication precedes clean code. Every significant technical change follows this lifecycle:

1.  **Discovery:** Rapid prototyping and brainstorming in **LucidChart** (Sandbox phase).
2.  **Proposal:** Drafting an **RFC** in `/docs/rfc` followed by a Pull Request for peer review.
3.  **Decision:** Once consensus is reached, we formalize the outcome in a new **ADR** file in `/docs/adr`.
4.  **Blueprint:** The system model in `/docs/architecture` is updated. Our CI/CD pipeline automatically refreshes the visual assets.

> 📖 **Detailed workflow instructions, Code Review guidelines, and our full Manifesto can be found in: [Architecture Process](./docs/ARCH_PROCESS.md)**

---

## Definition of Done (DoD)

> 📖 The full Definition of Done checklist lives in [ARCH_PROCESS.md — Section 3](./docs/ARCH_PROCESS.md#3-definition-of-done-dod). That is the **single source of truth** — do not duplicate it here.

---

## Getting Started

1. **Onboarding:** Read the [ARCH_PROCESS.md](./docs/ARCH_PROCESS.md) to understand how we build systems.
2. **Context:** Browse the existing [ADRs](./docs/adr/) to understand the "Why" behind our current stack.
3. **Contribute:** Follow the RFC process for any major refactoring or new service introductions.

---
*“Architecture is the decisions that are hard to change later.” — Make them count.*