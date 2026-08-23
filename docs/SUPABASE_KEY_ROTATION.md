Supabase Key Rotation Instructions

Purpose
- Remove sensitive keys from the repository and rotate keys in Supabase if they were committed.

When to rotate
- If `SUPABASE_ANON_KEY` or `SERVICE_ROLE_KEY` were ever committed to version control or shared publicly.

Steps to rotate keys (Supabase Dashboard)
1. Sign in to https://app.supabase.com and open your project.
2. Go to "Settings" → "API".
3. Under "Project API keys":
   - `anon` / `public` key: you may rotate if you suspect exposure. Note: rotating anon key will require updating client apps.
   - `service_role` key: rotate immediately if exposed. This key grants full DB access and must remain secret.
4. Click the rotate/regenerate button next to the key you want to rotate. Copy the new value.

Update your code and environments
- Local development:
  - Edit your local `.env` file and replace `SUPABASE_ANON_KEY` with the new anon key.
  - Do NOT commit `.env`.
- CI / Hosting:
  - In your CI/CD provider (GitHub Actions, GitLab CI, Vercel, etc.) update the secret entries:
    - `SUPABASE_ANON_KEY` (if used)
    - `SUPABASE_SERVICE_ROLE_KEY` (server-only; do NOT expose to client builds)
- Server-side apps / functions:
  - Update environment variables and restart the service.

Invalidate existing sessions (optional)
- If you rotated the `service_role` key due to a breach, consider invalidating existing JWTs by:
  - Going to Supabase → Authentication → Settings → JWT Expiry and setting a short expiry temporarily.
  - Forcing sign-out for all users is not directly available; you can revoke refresh tokens per-user via Admin API.

Checklist after rotation
- [ ] `.env` removed from repository and added to `.gitignore`.
- [ ] CI secrets updated with new keys.
- [ ] Mobile/web apps updated and redeployed if necessary.
- [ ] Confirm login flows work (email/password and OAuth).

If you want, I can:
- Provide a GitHub Actions snippet showing how to store and use the `SUPABASE_ANON_KEY` and `SERVICE_ROLE_KEY` securely.
- Generate curl commands to use the new `service_role` key for admin tasks (creating users) — keep the key secret.
