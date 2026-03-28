# CLAUDE.md — Rust API Service

## Project

REST API with Axum, SQLx, and PostgreSQL.

- **Repo**: GitHub — `myorg/rust-api`
- **Stack**: Rust 1.77, Axum, SQLx, PostgreSQL, Tokio
- **Team**: Infrastructure

## Commands

```bash
cargo build           # Build
cargo test            # Run all tests
cargo clippy          # Lint
cargo fmt --check     # Format check
sqlx migrate run      # Run migrations
cargo run             # Start server (port 3000)
```

## Verification

- After ANY code change: run `cargo test`
- Before committing: run `cargo clippy && cargo test`
- Commit format: `feat|fix|chore: <summary>`

## Critical Anti-Patterns

- **No `unwrap()` in production code** — use `?` operator or explicit error handling
- **No `clone()` without justification** — prefer borrowing
- **No `unsafe` without a safety comment** — document the invariant
- **No `String` where `&str` suffices** — minimize allocations
- **No `Box<dyn Error>`** — use `thiserror` for library, `anyhow` for app
- **No blocking in async context** — use `tokio::task::spawn_blocking`

## Architecture

```
src/
├── main.rs             # Entrypoint, router setup
├── config.rs           # Configuration (env vars)
├── error.rs            # Error types (thiserror)
├── db/                 # Database layer
│   ├── mod.rs          # Pool setup
│   └── models/         # SQLx query models
├── handlers/           # Axum request handlers (thin)
├── services/           # Business logic
├── middleware/         # Auth, logging, CORS
└── tests/              # Integration tests
migrations/             # SQLx migrations
```
