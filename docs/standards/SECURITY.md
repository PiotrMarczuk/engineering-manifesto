# Security Standards

Security is not a checklist item — it is a design constraint that shapes every phase of delivery.

> **Why shift left?** A security incident costs 100x more than a security review. Fixing vulnerabilities in production means you fixed them too late.

---

## Threat Modeling

* **When required:** Any new external-facing surface, new authentication/authorization flow, or new third-party integration.
* **Method:** STRIDE or a lightweight equivalent (e.g., a structured pre-coding conversation with the team documented in the RFC or TDR).
* **Output:** Identified threats and mitigations attached to the RFC or ticket before implementation begins.

---

## Dependency Scanning

* Automated SAST and SCA (Software Composition Analysis) scans run on every Pull Request.
* **High-severity findings block merge** — no exceptions without a documented risk acceptance sign-off from a senior engineer.
* Dependency upgrades triggered by security advisories are prioritised above feature work.

---

## Secret Management

* All secrets, keys, and connection strings are stored in an approved vault.
* Secrets **must never** be committed to source control — even temporarily, even in a private branch.
* `.env` files are excluded via `.gitignore`. Presence of a secret pattern in a PR triggers an automatic block and a mandatory rotation of the exposed credential.

---

## Least Privilege

* Service accounts and API keys are scoped to the minimum permissions required for their function.
* Permissions are reviewed when a service changes scope or is decommissioned.
* No shared credentials between services or environments.

---

## Security in the DoD

The Definition of Done (see [ARCH_PROCESS.md §3](../ARCH_PROCESS.md#3-definition-of-done-dod)) includes:
- No high-risk vulnerabilities in SAST/SCA scans.
- Secrets managed via approved vault — never in source control.

These are not optional. A feature that ships with a known high-severity vulnerability is not done.
