<overview>
Phase 3 patterns. Build the internal wiring diagram. Read only import/require/use statements — not function bodies.
</overview>

<module_dependency_map>
For each file in DOMAIN, API, and INFRA directories:
- Read only the top section (imports/requires/use declarations)
- Build: `ModuleA → imports → ModuleB`
- Stop reading at the first non-import line

Identify:
- **Hub modules**: imported by 5+ other modules — changes here have wide blast radius
- **Leaf modules**: import nothing internal — pure utilities, models
- **Cycles**: Module A imports B imports A — flag as coupling risk
- **God files**: imported everywhere AND containing business logic — flag for refactor
</module_dependency_map>

<external_service_wiring>
Search for outbound connections:

| Pattern | Service type |
|---------|-------------|
| `axios`, `fetch`, `http.NewRequest`, `requests.get`, `RestTemplate`, `HttpClient` | Outbound HTTP |
| DSN strings, connection pool setup | Database |
| `amqp://`, `redis://`, Kafka brokers, SQS/SNS clients, PubSub | Message brokers |
| S3 clients, GCS clients, Azure Blob | Object storage |
| SMTP setup, SendGrid/Mailgun/SES | Email |
| Stripe, Razorpay, Twilio, Slack, GitHub, etc. | External APIs |

For each: service name, protocol, what data flows to it, what comes back.
</external_service_wiring>

<event_message_system>
Skip this section if no event patterns detected.

Search for: `emit`, `publish`, `dispatch`, `broadcast`, `subscribe`, `listen`, `on(`, `consumer`, `producer`, `channel`, `queue`, `topic`, `exchange`

Build: `Event/Message Name → Who Produces → Who Consumes → What Triggers It`

Identify:
- Async boundaries (where execution crosses a queue or event bus)
- Ordering guarantees (none / at-least-once / exactly-once)
- What happens on consumer failure
</event_message_system>

<config_consumers>
Map: which module reads which config key.
Identify: what crashes or degrades if each key is absent.
</config_consumers>
