# Wedding Invitation App

This project is a mobile-first wedding invitation and information site built with SvelteKit, TypeScript, and Tailwind CSS.

## Tech stack

- SvelteKit
- TypeScript
- Tailwind CSS
- Supabase Postgres for RSVP and guest data
- Azure Static Web Apps for hosting
- Cloudinary or Azure Blob Storage for photo uploads

## Project structure

- `src/routes` — page routes and app entry points
- `src/app.css` — Tailwind and theme styling
- `supabase/schema.sql` — database schema for guests, RSVPs, comments, and events
- `.github/workflows/azure-deploy.yml` — Azure deployment pipeline
- `.env.example` — environment variables for local development

## Local setup

1. Install dependencies:
   ```bash
   npm install
   ```
2. Copy environment variables:
   ```bash
   cp .env.example .env
   ```
3. Start the development server:
   ```bash
   npm run dev -- --host
   ```
4. Open the local app in your browser at `http://localhost:5173`.

## Database setup

Create a Supabase project and run the SQL in `supabase/schema.sql` to initialize the following tables:

- `guests`
- `rsvps`
- `comments`
- `events`

## Azure deployment

1. Create a GitHub repository and push the project to `main`.
2. In Azure Portal, create a Static Web App with GitHub integration.
3. Add the following GitHub repository secrets:
   - `AZURE_STATIC_WEB_APP_API_TOKEN`
   - `PUBLIC_SUPABASE_URL`
   - `PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
4. Optional app settings can also be configured in the GitHub Actions environment variables.
5. The workflow at `.github/workflows/azure-deploy.yml` will deploy automatically on push to `main`.

## Git initialization

```bash
git init
git add .
git commit -m "Initial wedding invitation app"
git branch -M main
git remote add origin <your-github-url>
git push -u origin main
```

## Notes

This repository is intentionally set up as the base foundation for the later phases: responsive layout, event schedule, RSVP engine, guestbook, and personalization features.
