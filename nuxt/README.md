# Navree CRM on Nuxt

The Navree CRM front end on Nuxt 4: Vue 3, TypeScript (strict), Tailwind CSS 4, shadcn-vue (Reka UI), Pinia, TanStack Query for Vue, VeeValidate with zod, and pusher-js. It is the same CRM as `../web`, screen for screen, against the same API (`../api`).

The `@navree/nuxt` module is the backend-for-frontend. The browser calls only this app's own `/api/*` and `/broadcasting/auth`; Nitro keeps Navree's access token and rotating refresh token in httpOnly cookies and forwards each call with `Authorization: Bearer`. The browser never sees a token. The app has no BFF code of its own: the module (with `@navree/bff` and `@navree/client`) serves the routes and the session gate, and carries sign-in, real time and abilities.

```
browser ── same-origin /api/*, /broadcasting/auth ──▶ Nitro, @navree/nuxt ── Bearer ──▶ Navree API (crm-api)
   └──────────── ws://127.0.0.1:8092/app/{key} (pusher-js) ───────────────────────────▶ Navree real time
```

## Run

```sh
pnpm install

# 1. The API: crm-api on http://127.0.0.1:8092, on its own SQLite file
#    target/builds/crm-nuxt/crm.db (seeded with crm-demo the first time).
pnpm api                # serve (seeds a new database first)
pnpm api:fresh          # migrate:fresh + db:seed crm-demo, then serve
node scripts/start-api.mjs --worker   # also run queue:work (deal notifications)

# 2. The app on http://localhost:3102 (another terminal)
pnpm dev
NUXT_PUBLIC_DEMO_ACCOUNTS=1 pnpm dev  # one-click demo accounts on the login page

# Or with no API at all: MSW serves the API in the browser with demo data.
pnpm dev:mock
```

Sign in as `rep1@navree.test`, `rep2@`, `manager@` or `admin@navree.test`; every account uses `password123`.

`scripts/start-api.mjs` runs the crm-api binary from `$CRM_API_BIN`, else `target/builds/crm-nuxt/crm-api` (`.exe` on Windows), else a copy of `target/builds/patterns/debug/crm-api`. Build one with `CARGO_TARGET_DIR=target/builds/crm-nuxt cargo build -p crm-api` and point `CRM_API_BIN` at it. It never touches the API's own database or `.env`.

## The deepmerge override

Nitro's bundler asks for the `deepmerge` package. `pnpm-workspace.yaml` points that name at `vendor/deepmerge`, a small copy of Navree's own implementation that keeps the `deepmerge` API and never copies a key that reaches a prototype. `tests/unit/deepmerge.test.ts` proves it.

## Scripts

| Script | What it does |
|---|---|
| `pnpm dev` / `pnpm dev:mock` | The development server on http://localhost:3102, against the API or the mock |
| `pnpm build` / `pnpm start` | The production build, and serving it |
| `pnpm typecheck` / `pnpm test` | Type check and unit tests |
| `pnpm e2e` | Browser journeys against a real API |
| `pnpm gen:api` | Regenerates the typed client from `openapi.json` with `navree openapi:client` |
