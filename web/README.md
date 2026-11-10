# Navree CRM web

The Next.js 16 front end for the Navree CRM API (`../api`). It talks to the API's REST interface (the OpenAPI document is served at `/api/openapi.json`) and can also run on its own against an in-browser mock of it.

The backend-for-frontend, the abilities and the real-time channels come from the published `@navree/next` and `@navree/client` packages. This app keeps only what is specific to the CRM.

## Run

```sh
pnpm install

# With the mock API (no crm-api needed). Sign in as rep1@navree.test / password123
# (also rep2@, manager@, admin@navree.test). The login page has one-click demo accounts.
pnpm dev:mock

# Against the real API (default): crm-api on http://127.0.0.1:8080
pnpm dev
NAVREE_API_URL=http://127.0.0.1:9000 pnpm dev   # the API elsewhere
```

Start the API first with the commands in the repository's README.

## Scripts

| Script | What it does |
|---|---|
| `pnpm dev` / `pnpm dev:mock` | The development server on http://localhost:3000, against the API or the mock |
| `pnpm build` / `pnpm start` | The production build, and serving it |
| `pnpm typecheck` / `pnpm lint` / `pnpm test` | Type check, lint and unit tests |
| `pnpm e2e` | Browser journeys (`E2E_REAL_API=1` starts a real API from `../api`) |
| `pnpm gen:api` | Regenerates the typed client from `openapi.json` with `navree openapi:client` |

## How the browser reaches the API

The browser never talks to the API directly. The route handlers `src/app/api/[...path]/route.ts` and `src/app/broadcasting/auth/route.ts` are the backend-for-frontend (`@navree/next`, created in `src/lib/navree.ts`): they keep the tokens in httpOnly cookies and forward requests to `NAVREE_API_URL` with `Authorization: Bearer`.
