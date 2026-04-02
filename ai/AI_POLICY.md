# AI-Assisted Development Policy

> *"AI is a power tool, not an autopilot. The engineer holds the steering wheel — and the liability."*

This document defines how AI tools are used, governed, and audited within our engineering practice.

---

## 1. Approved Usage Tiers

| Tier | Activity | AI Assistance | Human Oversight |
|------|----------|--------------|-----------------|
| **Green** | Boilerplate code, unit test generation, doc drafts, refactoring suggestions, commit messages, RFC/ADR drafting | Fully encouraged | Standard code review |
| **Amber** | Business logic, API implementations, data transformations, infrastructure-as-code | Allowed with scrutiny | Author must understand and explain every line in review |
| **Red** | Authentication/authorization, cryptography, input validation/sanitization, database migrations, secret handling | AI drafts must be flagged | Mandatory review by security-aware senior engineer |

---

## 2. Core Rules

### 2.1 The Author Rule
> AI-generated code has **one author: you**. If you can't explain it line-by-line in a code review, you don't ship it.

### 2.2 Prompt Hygiene
* **Never** paste proprietary source code, secrets, API keys, PII, or customer data into external AI services.
* Use only **enterprise-tier, approved AI tools** that provide data privacy guarantees (e.g., GitHub Copilot Business/Enterprise, Azure OpenAI with data boundaries).
* Prompts used for architectural decisions should be saved alongside the RFC/ADR for traceability.

### 2.3 Validation Requirements
* AI-generated code must pass the same CI pipeline as human-written code — no exceptions.
* AI-generated tests must be reviewed for **meaningful assertions**, not just coverage inflation.
* AI-suggested architectural patterns must be validated against the project's existing ADRs and constraints.

### 2.4 Disclosure
* Pull Requests where AI substantially generated the implementation should note this in the PR description (e.g., "Core logic co-authored with Copilot").
* This is not about blame — it's about calibrating review depth.

---

## 3. AI in the Architecture Workflow

| Phase | How AI Assists | Guardrails |
|-------|---------------|------------|
| **Discovery** | Generate alternative approaches, challenge assumptions, explore trade-offs | Human validates against business context |
| **RFC Drafting** | Structure proposals, identify missing sections, research alternatives | Human architect owns the reasoning and final content |
| **ADR Writing** | Draft consequences, identify risks, cross-reference existing ADRs | Human validates against lived experience and codebase reality |
| **Code Generation** | Scaffold implementations from approved contracts/schemas | Must pass architecture unit tests (e.g., NetArchTest, ArchUnit) |
| **Test Generation** | Generate unit/integration test scaffolds from specifications | Human reviews assertion quality — not just green builds |
| **Code Review** | AI-assisted review tools can flag issues | Never replaces human reviewer approval |

---

## 4. Prohibited Practices

- Using AI to bypass code review ("AI wrote it, so it's fine")
- Blindly accepting AI-generated dependency upgrades without changelog review
- Using AI to generate security-sensitive code without flagging it for senior review
- Feeding production logs, customer data, or incident details into non-approved AI tools
- Using AI-generated code you haven't tested locally

---

## 5. AI Tooling Standards for Repositories

Every project repository should include:

```
ai/                    # AI policies and prompt libraries (top-level — prompts are development tooling)
├── AI_POLICY.md
├── approved-tools.md  # List of approved AI tools and their scopes
└── prompts/           # Skill/instruction files for Copilot, Claude, and other approved tools
```

AI-related test utilities (e.g., AI-generated test fixtures, prompt-based test generators) live alongside regular tests:
```
tests/ai/             # AI-assisted test generation configs and validation
```

---

## 6. Review & Evolution

* This policy is reviewed **semi-annually** as AI capabilities evolve rapidly.
* New AI tools must be evaluated and approved before team-wide adoption — file an RFC.
* Incidents caused by AI-generated code trigger a **post-mortem** with specific focus on what the AI got wrong and what the review process missed.
