# Bersihinnih (BRH) — Hybrid Cleaning Service MVP

A static, responsive Indonesian-language MVP for shoe and helmet cleaning services.

## Included in the repository

- `index.html`: landing page, booking, tracking, and local demo admin.
- `brand.svg`, `favicon.svg`: BRH metallic-gold brand assets.
- `supabase/schema.sql`: initial PostgreSQL schema and row-level security starter policies.
- `vercel.json`: static-site configuration.

## Deploy to Vercel

1. Open https://vercel.com/new.
2. Import the GitHub repository `Philiphutahaean/bersihinnih`.
3. Choose the Vercel team/account that owns the deployment.
4. Framework preset: **Other**.
5. Root directory: repository root (`./`).
6. Build command: leave empty.
7. Output directory: leave empty.
8. Deploy.

The production branch is `main`. New commits to `main` deploy automatically after the Git integration is connected.

## Current MVP scope and limitations

The booking, tracking, and admin demonstration currently use browser `localStorage`. Data is local to one browser/device and is not shared with staff or customers. The file upload field only records the selected filename; it does not upload the photo. Payment is a preference only; no payment gateway is connected.

The admin demo is not authenticated and must not be used to store real customer data. Do not expose it as a production operations dashboard until authentication and server-side authorization are implemented.

## Backend setup (next production step)

1. Create a Supabase project.
2. Run `supabase/schema.sql` in the Supabase SQL editor.
3. Add a server-side API layer for booking creation, order tracking, price approval, and status changes.
4. Configure environment variables in Vercel (never commit secrets):
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY` (server-side only)
5. Add Supabase Auth roles for customer, staff, and admin before enabling the operations dashboard.
6. Add WhatsApp notifications and payment gateway only after the order workflow is tested.

## Important

This is a working front-end prototype, not yet a production-ready commerce/operations system. The SQL file is a secure starting point; the application still needs authenticated API routes and integration before real orders are accepted.
