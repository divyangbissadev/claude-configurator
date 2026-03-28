---
paths:
  - "**/*.py"
  - "**/*.ts"
  - "**/*.js"
  - "**/*.java"
  - "**/*.go"
---

# Security Conventions

- Never hardcode credentials, tokens, API keys, or connection strings
- Never log sensitive data (PII, passwords, tokens, session IDs)
- Never use string interpolation in database queries — use parameterized queries
- Never trust user input — validate at system boundaries
- Never commit secrets — use .gitignore and pre-commit hooks
- Use environment variables or secret managers for all credentials
- Prefer allow-lists over deny-lists for input validation
