# API Versioning Strategy

Our public API uses **header-based versioning (content negotiation)** to keep URLs clean while supporting multiple concurrent versions.

> **Why header-based?** Because URLs should identify resources, not implementation versions. Content negotiation keeps the URL space stable for consumers while giving us full control over version routing.

---

## Versioning Mechanism

```
GET /api/orders/12345
Accept: application/vnd.myapp.v2+json

→ Routes to v2 handler
```

| Header | Format | Example |
|--------|--------|---------|
| `Accept` (request) | `application/vnd.{app}.v{N}+json` | `application/vnd.myapp.v2+json` |
| `Content-Type` (response) | Same format echoed back | `application/vnd.myapp.v2+json` |

---

## Rules

1. **Default Version:** If no version header is provided, the API returns the **latest stable version** with a `Deprecation` warning header.
2. **Maximum 2 Concurrent Versions:** When `v3` ships, `v1` enters sunset. Only `v2` and `v3` are actively maintained.
3. **Breaking Change = New Version:** Adding optional fields is *not* a breaking change. Removing fields, renaming fields, changing types, or altering behavior *is*.
4. **Sunset Timeline:**
   - Deprecated version announcement → **minimum 6 months** before removal.
   - Sunset communicated via `Sunset` HTTP header (RFC 8594) and changelog.
   - Removal is documented with an ADR.
5. **Contract Location:** OpenAPI specs live in `docs/architecture/api/` and are versioned alongside code.

---

## Response Headers for Consumers

```http
HTTP/1.1 200 OK
Content-Type: application/vnd.myapp.v2+json
X-API-Version: 2
Sunset: Sat, 01 Oct 2027 00:00:00 GMT      ← only on deprecated versions
Deprecation: true                            ← only on deprecated versions
Link: <https://docs.myapp.com/migration/v2-to-v3>; rel="successor-version"
```

---

## Implementation Guidelines

* Use your framework's API versioning middleware to handle version routing via media type.
* Each version gets its own **handler/endpoint set**. No `if (version == 2)` branching inside shared handlers.
* Contract changes follow the **Contract-First** rule — OpenAPI spec is updated and reviewed before code changes.
* **Architecture Unit Tests** must verify that deprecated versions are not referenced by new code.
