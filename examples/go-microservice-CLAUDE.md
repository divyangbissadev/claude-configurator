# CLAUDE.md — Go Microservice

## Project

gRPC microservice for order processing with PostgreSQL and Redis.

- **Repo**: GitHub — `myorg/order-service`
- **Stack**: Go 1.22, gRPC, PostgreSQL, Redis, Docker
- **Team**: Platform Engineering

## Commands

```bash
make build            # Build binary
make test             # Run all tests
make test-integration # Integration tests (requires Docker)
make lint             # golangci-lint
make proto            # Regenerate protobuf stubs
make docker-up        # Start dependencies (Postgres, Redis)
make migrate          # Run database migrations
```

## Verification

- After ANY code change: run `make test`
- Before committing: run `make lint && make test`
- Commit format: `feat|fix|chore: <summary>`

## Critical Anti-Patterns

- **No `panic()` in library code** — return errors, let caller decide
- **No goroutine without context cancellation** — always pass `ctx`
- **No `init()` functions** — use explicit initialization for testability
- **No global mutable state** — pass dependencies explicitly
- **No ignoring errors** — `_ = someFunc()` is almost always wrong
- **No raw SQL without parameterization** — use `sqlx` named queries
- **No blocking in gRPC handlers** — use goroutines with context for long operations

## Architecture

```
cmd/server/             # Entrypoint
internal/
├── domain/             # Business logic (no external dependencies)
│   ├── order/          # Order aggregate
│   └── payment/        # Payment domain
├── infra/              # Infrastructure adapters
│   ├── postgres/       # Database repository implementations
│   ├── redis/          # Cache implementations
│   └── grpc/           # gRPC server and handlers
├── service/            # Application services (orchestrate domain + infra)
└── config/             # Configuration loading
proto/                  # Protobuf definitions
migrations/             # SQL migration files
```
