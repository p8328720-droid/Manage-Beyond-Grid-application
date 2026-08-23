GitHub Actions: storing and using Supabase keys

1) Add secrets to your repository
- Go to your GitHub repo → Settings → Secrets and variables → Actions → New repository secret.
- Add the following secrets:
  - `SUPABASE_URL` (e.g. https://jebiwzrskyxnrxicuse.supabase.co)
  - `SUPABASE_ANON_KEY` (public anon key) — used in client builds
  - `SUPABASE_SERVICE_ROLE_KEY` (service_role key) — MUST be kept secret and only used server-side (Actions, server functions)

2) Example workflow
- See `.github/workflows/supabase_admin_tasks.yml` for an example that:
  - Calls Supabase Admin API using `SERVICE_ROLE_KEY` to create users
  - Demonstrates how to pass `SUPABASE_ANON_KEY` into a build step via `--dart-define`

3) Best practices
- Never expose `SERVICE_ROLE_KEY` in client-side code or logs.
- Use `workflow_dispatch` or protected branches for admin workflows.
- Rotate keys via Supabase Dashboard if exposed and update GitHub secrets.
