# CLAUDE.md — SaaS Next.js App

## Project

Full-stack SaaS application with Next.js, Supabase, and Stripe.

- **Repo**: GitHub — `myorg/saas-app`
- **Stack**: TypeScript, Next.js 14, React 18, Supabase, Stripe
- **Team**: Product Engineering

## Commands

```bash
npm run dev           # Local development server (port 3000)
npm run build         # Production build
npm run test          # Jest unit tests + React Testing Library
npm run test:e2e      # Playwright E2E tests
npm run lint          # ESLint + Prettier check
npm run typecheck     # TypeScript strict mode
```

## Verification

- After ANY code change: run `npm run typecheck && npm run test`
- Before committing: run `npm run lint && npm run test`
- Commit format: `feat|fix|chore: <summary>`

## Critical Anti-Patterns

- **No `any` type** — use `unknown` and narrow, or define proper types
- **No `useEffect` for derived state** — compute during render or use `useMemo`
- **No direct Supabase calls in components** — use server actions or API routes
- **No Stripe secrets in client code** — server-side only via API routes
- **No `SELECT *`** — specify columns in Supabase queries
- **No unvalidated user input** — validate with Zod at API boundaries

## Architecture

```
app/                    # Next.js App Router
├── (auth)/             # Auth-gated routes
├── (marketing)/        # Public pages
├── api/                # API routes
│   ├── webhooks/       # Stripe webhooks
│   └── trpc/           # tRPC router
├── lib/
│   ├── supabase/       # Supabase client + server
│   ├── stripe/         # Stripe utilities
│   └── auth/           # Auth helpers
└── components/
    ├── ui/             # Design system (shadcn)
    └── features/       # Feature components
```
