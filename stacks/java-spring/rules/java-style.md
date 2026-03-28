---
paths:
  - src/**/*.java
---

# Java & Spring Boot Conventions

- Java 17+ with modern features (records, sealed classes, pattern matching)
- Constructor injection with `final` fields — no field injection
- `@ConfigurationProperties` for typed config — no scattered `@Value`
- Controllers: thin, delegate to services, return ResponseEntity
- Services: business logic, transactional boundaries
- Repositories: Spring Data JPA interfaces
- DTOs: Java records for request/response objects
