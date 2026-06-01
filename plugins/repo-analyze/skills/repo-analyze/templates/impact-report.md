# Impact Report: [target]

**Direct callers:**     [modules that directly import or call this]
**Transitive impact:**  [modules that depend on direct callers]
**Routes affected:**    [any routes that invoke this]
**DB impact:**          [if a model: tables, migrations needed, related models]
**Event impact:**       [if an event producer/consumer: downstream consumers/upstream producers]
**Config impact:**      [if a config key: what stops working if it changes]
**Test coverage:**      [test files covering this target, if discoverable]

**Risk level: [LOW / MEDIUM / HIGH]**
**Reason:** [one sentence explaining the risk level]

---
Risk classification:
- LOW — leaf module, no dependents, no DB schema change, well-tested
- MEDIUM — 1–5 dependents, or DB migration needed, or partial test coverage
- HIGH — hub module (5+ dependents), breaking API change, no test coverage, or cross-service impact
