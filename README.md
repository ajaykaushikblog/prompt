# BrowsePrompt — updated application

An existing React application upgraded with a **Next.js production frontend**, an integrated Express API, PostgreSQL persistence, image uploads, model moderation, account workflows, a content-management workspace, and reproducible localhost deployment. Vite is retained for the Figma Make preview and optional frontend editing.

**This is not completion of every feature in the master specification.** See “Limitations” below and `IMPLEMENTATION_REPORT.md`. The complete localhost workflow serves frontend and API together on **http://localhost:3000**. The Figma preview can connect to the development-only API on port 3001; that preview data is separate from your Mac’s PostgreSQL database.

## October 2026 design and workflow update

This full source archive preserves React/Vite, the shared Next.js frontend, Express/PostgreSQL APIs, Docker/Caddy files and existing operational scripts. Nothing was deployed or changed in AWS, Namecheap, DNS or a production database. See `MODIFICATION_REPORT.md` and `TEST_REPORT.md` for this update's changes and actual verification; `IMPLEMENTATION_REPORT.md` records historical work, not this run's test results.

- Editorial warm-neutral design with locally served Inter 4.1 (SIL Open Font License), system fallbacks and `font-display: swap`, shared by Vite and Next.js. Prompt details now align the media and metadata sidebar in the same desktop row; at 1000px and below the order is media, metadata/actions, then prompt content.
- Admin → Navigation now has independent Desktop, Mobile and Footer editors with grouping, ordering, visibility/audience controls, preview and per-location atomic saves. Existing `header`/`footer` JSON is still read for compatibility.
- Single prompts stay uncluttered. Up to ten phases can carry purpose, input/output types, earlier-phase dependency, independently selected model, optional author-provided settings, reference image, negative prompt and notes. Copy one phase or the ordered workflow; preview a submission before sending it for review.
- Database category discovery adds App and Music when no equivalent exists, and supports label, position, visibility and featured editing while preserving category IDs and prompt associations.
- Apply additive migrations `database/006_discovery_navigation.sql` and `database/007_independent_navigation_defaults.sql` through `scripts/migrate.mjs` when upgrading your own local installation. Migration 007 initializes only absent explicit desktop/footer locations from customized legacy menus, preserves existing labels/flags/order, adds only missing Home/About/Contact destinations and leaves explicit locations (including empty menus) untouched. Fresh seed provides all three explicit menus. The runner applies SQL files in order inside a tracked transaction. No phase migration is needed beyond existing `005`: richer phase objects remain in its JSONB column. Back up first; do not manually reset data.
- New API: owner-only `POST /api/admin/navigation/:location` with `{ "items": [...] }`, where location is `desktop_primary`, `mobile_navigation` or `footer_navigation`. Existing settings endpoint remains compatible. `GET /api/prompts?workflow=true` lists real published multi-phase records; `phase_count` does not expose locked bodies.
- No new environment variables, external generation service or fabricated model specifications. Image/video size, duration and FPS values are optional author instructions, not provider support guarantees. Native video/audio file uploads and automated generation remain unavailable.

Public entry points: `/`, `/prompts?q=...&category=...&model=...`, `/prompts/:id`, `/categories/:id`, `/models`, `/guides`, `/resources`, `/about`, `/contact`, `/privacy`, `/terms`, `/cookies`, `/sign-in`, `/sign-up`, `/submit-prompt`, `/dashboard`, and `/admin` (role protected). Local full application: http://localhost:3000; health: http://localhost:3000/api/health. No public deployment URL was created.

Recommended next steps: run the unchanged local Docker workflow below; review policy text and image licenses; configure email only if real delivery is needed; curate actual workflows and featured prompts; maintain model capabilities from official provider documentation before publishing support claims.

## Earlier preserved improvements

- Create your own account at `/sign-up`; no administrator is required for ordinary registration.
- White-and-cream styling with self-hosted BrowsePrompt Inter, system sans-serif fallbacks and high-contrast dark-mode text.
- Light/dark switch available on desktop and mobile, with your preference saved.
- Submit a single copy-and-paste prompt or add up to ten ordered phases, such as “Create image” then “Animate image.” Each phase has a title, prompt text, and its own copy button. Leave Full prompt blank for a phase-only submission.
- Administrators can edit, reorder, and remove phases during review. Protected phases follow the same server-side access rules as protected prompt text.
- Visitor-facing service errors are concise; terminal setup instructions are no longer displayed on public content pages.
- Docker startup explains how to start Docker Desktop if its engine is unavailable.

Figma Make starts the development-only API and Vite together through its supervised development runner. It uses local PGlite storage under `/tmp` and is not a production database or the recommended Mac deployment. The portable ZIP’s Vite config proxies to the full application on port 3000 instead.

## Quick start on macOS — full application

1. Install **Docker Desktop for Mac**, open it, and wait for Docker to be running.
2. Extract the ZIP, then open Terminal in the extracted folder:

```bash
cd "/path/to/extracted/BrowsePrompt"
bash scripts/local-start.sh
bash scripts/local-admin.sh
```

`local-start.sh` generates unique local database and setup secrets in `.env.local`, builds the image, starts PostgreSQL, applies tracked migrations, seeds original demonstration content, and starts the application. It does not reset an existing database or replace existing secrets.

`local-admin.sh` asks you for your administrator email and a unique password of at least 16 characters. **There are no default login credentials.** This script actually inserts the administrator into your local database. The password is stored only as a bcrypt hash, not written into documentation or `.env.local`.

To generate credentials automatically instead of choosing them, run `bash scripts/local-admin.sh --generate`. It creates `admin@browseprompt.local` with a unique random password and prints the credentials only after successful database creation. Save the password privately; it is not stored in project files. This local email is not a deliverable inbox, so email workflows require an actual address/provider or the development mailbox. Both modes refuse to replace an existing administrator.

Open:

- Website: **http://localhost:3000**
- Sign in: **http://localhost:3000/sign-in**
- Admin: **http://localhost:3000/admin**
- Health: **http://localhost:3000/api/health**

Sign in with the email and password you chose. The old frontend-only login problem is resolved by serving `/api` and the built website from the same application.

### Stop, restart, logs, and data

```bash
bash scripts/local-stop.sh
# Restart existing containers:
docker compose --env-file .env.local -f docker-compose.local.yml up -d --wait
# Logs:
docker compose --env-file .env.local -f docker-compose.local.yml logs --tail=100 web
docker compose --env-file .env.local -f docker-compose.local.yml ps
```

Database and upload storage persist in Docker named volumes. Never use `down -v` unless you intentionally want to destroy local data. PostgreSQL is not exposed on any host port. The website is bound only to `127.0.0.1:3000`.

To apply updates, back up first and rerun `bash scripts/local-start.sh`. Seed inserts use conflict protection and do not overwrite user-managed content.

### Troubleshooting

- **Port 3000 in use:** `lsof -i :3000`; stop the other application before starting BrowsePrompt.
- **Docker unavailable:** open Docker Desktop, then verify `docker info`.
- **Image-pull rate limit:** retry after the provider limit clears or sign in to Docker Hub. This is not a database-password problem.
- **No database connection in the UI:** ensure you opened port **3000**, not a frontend-only Vite preview. Check `/api/health` and web/db logs.
- **Database password changed after initialization:** the existing PostgreSQL volume retains its original password. Restore the old environment value or deliberately rotate it using PostgreSQL administration; do not delete the volume to fix this.
- **Administrator already exists:** bootstrap intentionally refuses to create another owner. Sign in or use password reset.
- **Local email:** no paid provider is needed. Sign in as owner, open Admin → Development email, and use the queued verification/reset link. This mailbox is disabled in production. Never share reset links.

## Optional frontend editing on the Mac

The supported toolchain is **Node 22** and **pnpm 10.34.3**. Docker startup does not require Node installed on your Mac.

```bash
npx --yes pnpm@10.34.3 install --frozen-lockfile
npx --yes pnpm@10.34.3 exec vite --config vite.production.config.ts
```

`BrowsePrompt_Full_Updated_Website.zip` preserves both configurations: the original Figma-aware `vite.config.ts` (port 8443, API proxy to 3001) and `vite.production.config.ts` for standalone local editing (port 5173, API proxy to 3000). The command above explicitly selects the standalone configuration. Run the full Docker workflow first if you want Vite editing with functional accounts. Vite then uses **http://localhost:5173**. `scripts/package.py` now preserves both configurations byte-for-byte; it no longer substitutes the standalone configuration over the original.

The project pins pnpm 10.34.3. pnpm 12 can enforce a newer minimum-release-age policy and reject recently published locked packages. Prefer the pinned version, or wait for the release-age cutoff; do not silently disable a security policy.

Inside Figma Make the supervised frontend server is already running; do not start another one.

## Content management

The owner workspace provides:

- Live database overview counts.
- Prompt review with image preview, editing, publishing, rejection, change requests, archiving, feature and lock controls.
- Proposed-model approval/rejection. Approved normalized duplicates resolve to the existing model.
- Model creation/editing/archiving and category creation/update.
- Markdown/plain-text guides, resources, deals and product landing pages; draft, published, scheduled and archived states.
- Content studio with formatting toolbar, preview, headings, lists, code, tables, quotes, images, automatic table-of-contents links, and allowlisted YouTube video links (`[Video: title](https://www.youtube.com/watch?v=VIDEO_ID)`).
- Image uploads with thumbnails stored in persistent storage.
- Subscriber viewing, CSV export and confirmed deletion.
- Image-banner advertising with enable/disable and consent-aware rendering.
- Form-based branding, SEO and homepage settings. Discovery sections can be reordered or hidden; published models can be featured; headline, CTA and initial card count are editable. Navigation uses a dedicated per-location visual editor; integration settings retain their JSON editor.
- Media records, owner-controlled user roles/activation, development mailbox, content reports and audit logs.
- Bulk prompt lock/unlock, feature/unfeature, archive and publish controls. Publication still requires model approval.
- Owner-granted prompt membership entitlements with a configurable expiry, audited independently of external subscription/payment claims.

Editor/moderator roles can access content actions. Owner-only settings, subscribers, mail, role changes and audit endpoints remain restricted. Owners cannot demote or deactivate themselves. Permission changes revoke the affected user's sessions.

## Prompt and account flows

- `/prompts` uses database search/filtering, 24-record pages, real model/category options, manual load-more, shareable query parameters, and database favorites.
- Cards open dedicated `/prompts/:id` pages that survive refresh.
- Listing APIs never send full prompt bodies. Locked bodies are checked against expiring server entitlements.
- Submission requires a signed-in user; images must belong to that user. New model names stay in a review queue. Publication is blocked until the proposed model is approved.
- `/dashboard` shows the user’s submission statuses and notes, profile editing, verification action, and account-deletion request.
- Verification and password-reset tokens are random, hashed in storage, expiring and single-use. Password resets invalidate existing sessions.
- Email locks require a verified signed-in email plus explicit marketing consent and grant 30-day access. External YouTube/WhatsApp/Telegram/custom clicks are never treated as verified membership.
- Newsletter consent persists. Welcome messages contain an expiring unsubscribe link.

## Images and uploads

JPEG, PNG and WebP images up to **5 MB** and **25 megapixels** are accepted. The server validates the filename extension/MIME allowlist, decodes image content, strips metadata by re-encoding, rotates/resizes to a maximum 1600-pixel dimension, and stores generated-name WebP files.

`UPLOAD_DIR` defaults to `uploads` outside Docker and `/app/uploads` in Docker. The Docker volume is writable by the non-root `node` user. Back up uploads along with the database; do not publish confidential files in this public image directory.

### Protected product files

Save a digital product, then reopen its editor as the site owner to upload a **PDF or text document up to 10 MB**. Product files use a separate `private_files` Docker volume, not public assets. PDF headers and text/binary boundaries are validated; uploads are not a substitute for malware scanning or rights review.

Free published files require sign-in. Priced files require an unexpired owner-granted entitlement; grant a registered account access in the product editor. Grants are audited and default to 30 days. This is **manual authorization, not payment verification**. External checkout is not automatically trusted. Native payment integration remains unimplemented.

`PRIVATE_DOWNLOAD_DIR` defaults to `private-files` outside Docker and `/app/private-files` in Docker. Back up this private volume separately and keep backups confidential. Old replacement files may remain in private storage; no automatic file-retention job is implemented.

## Environment

- `POSTGRES_PASSWORD`: unique Docker database password.
- `DATABASE_URL`: PostgreSQL connection string; Compose supplies the internal `db` hostname.
- `SITE_URL`: exact public origin, including scheme and port. Local Compose sets `http://localhost:3000`.
- `DOMAIN`: production DNS name for Caddy.
- `INITIAL_ADMIN_EMAIL`, `INITIAL_ADMIN_SETUP_SECRET`: explicit CLI bootstrap inputs.
- `ADMIN_PASSWORD`, `SETUP_SECRET`: supplied only to the bootstrap command, not committed or included in the ZIP.
- `NODE_ENV`: Next.js runs in production mode. `LOCAL_DEVELOPMENT=true` is an explicit localhost-only flag that allows HTTP cookies and the owner development mailbox; startup rejects this flag for a non-loopback site URL. Production defaults to Secure cookies.
- `USE_NEXT=true`: use the built Next.js frontend. Docker enables it; the Vite preview remains separate.
- `UPLOAD_DIR`: persistent image directory.
- `PRIVATE_DOWNLOAD_DIR`: private product-document directory.
- `EMAIL_PROVIDER_API_KEY`, `EMAIL_FROM_ADDRESS`: optional Resend transactional delivery. Without credentials, messages remain in the database development outbox.

Optional OAuth, S3, native payments, third-party verification and analytics loaders are not implemented, so unused secret variables are deliberately not included.

## Production deployment on AWS Lightsail

Use Ubuntu 24.04 LTS, preferably **2 vCPU, 4 GB RAM, 40 GB disk**. Builds may require additional RAM/swap. Install Docker Engine and Compose using Docker’s official Ubuntu instructions. Assign a static Lightsail IP; point your domain’s A record to it.

```bash
scp browseprompt-updated-complete.zip ubuntu@YOUR_HOST:~/
ssh ubuntu@YOUR_HOST
mkdir -p browseprompt && cd browseprompt
unzip ../browseprompt-updated-complete.zip
cp .env.example .env
chmod 600 .env
# Edit DOMAIN, SITE_URL, passwords and setup secret.
# Generate unique random secrets with: openssl rand -hex 32
sh scripts/deploy.sh
# In bash, enter your unique password and setup secret without echo:
read -rsp "Admin password: " ADMIN_PASSWORD; echo; export ADMIN_PASSWORD
read -rsp "Setup secret: " SETUP_SECRET; echo; export SETUP_SECRET
sh scripts/initial-admin-setup.sh
unset ADMIN_PASSWORD SETUP_SECRET
sh scripts/health-check.sh
```

Set `INITIAL_ADMIN_EMAIL` in `.env` before bootstrap. Remove the setup secret afterward. Configure transactional email before relying on production verification/password-reset delivery. Pending/failed messages remain in the outbox; automatic retry scheduling is not implemented.

Allow public **80/443**, and restrict SSH **22** to your own IP. Do not open PostgreSQL 5432. Caddy supplies automatic HTTPS when DNS is correct and ports are reachable.

```bash
docker compose logs --tail=100 web
docker compose logs --tail=100 caddy
docker compose restart web
docker compose ps
df -h
sh scripts/backup-db.sh
sh scripts/restore-db.sh backups/YOUR_BACKUP.dump
```

Local backup equivalent:

```bash
mkdir -p backups
umask 077
docker compose --env-file .env.local -f docker-compose.local.yml exec -T db \
  pg_dump -U browseprompt -d browseprompt -Fc > backups/local.dump
```

For production updates, back up database and uploads, retain the previous archive/image, and run `sh scripts/deploy.sh`. Roll back to the retained image/source. If a later migration is incompatible, restore its corresponding database backup while web is stopped. Never run `docker compose down -v` during routine maintenance.

Keep encrypted, restricted off-host backups and verify isolated restores. Upload backup: archive `/app/uploads` from the web container/volume to private backup storage. TLS failures: check DNS, static IP, firewall ports, other listeners on 80/443 and Caddy logs.

## Tests

```bash
npx --yes pnpm@10.34.3 install --frozen-lockfile --ignore-workspace
pnpm exec tsc --noEmit
pnpm build
pnpm exec vite build --config vite.production.config.ts
pnpm build:next
# Serial unit/integration execution for constrained environments:
NODE_OPTIONS=--max-old-space-size=384 pnpm exec node --test --test-concurrency=1 tests/*.test.mjs
pnpm exec playwright install --with-deps chromium
pnpm test:browser
pnpm test:next
```

Integration tests use PGlite, a PostgreSQL WASM engine, with the same schema and actual API handlers. The pgcrypto extension declaration is omitted in that isolated engine; built-in UUID generation is used. The memory engine is available only with `TEST_DATABASE=memory` and `API_NO_LISTEN=true`; normal startup uses PostgreSQL through `pg`. Browser tests run either the built Vite app or the real Next.js production entry point against the isolated backend, checking responsive overflow, server-rendered content, filters, prompt detail/refresh/copy, locks, owner login and publication. All test accounts are isolated fixtures, not usable development credentials.

In a containing pnpm workspace, use `pnpm install --frozen-lockfile --ignore-workspace` to install this project's own lockfile. Both browser scripts now check actual local font loading and font-failure fallback, initial desktop column alignment and mobile stacking, ordered phase dependencies/copy (including clipboard rejection), phase reordering/removal, independent menu hide/show/order/save/rendering, JavaScript errors and failed local font/script/style requests. They use ephemeral loopback servers and isolated PGlite data, never a live database. On memory-constrained Linux, run serially with `NODE_OPTIONS=--max-old-space-size=384` for browser tests and `512` for the Next build. Read `TEST_REPORT.md` for this run's actual outcomes and limitations.

There is no configured lint script. Formatting uses `pnpm format`; the current formatter has been observed to corrupt some compact inline TypeScript property separators, so rerun TypeScript after formatting and fix syntax before packaging.

## Complete source ZIP

Run from the project folder after updating reports:

```bash
python3 scripts/package.py
# Named delivery outside the source tree (the archive has project files at its root):
cp public/browseprompt-updated-complete.zip ../BrowsePrompt_Full_Updated_Website.zip
python3 -m zipfile -t ../BrowsePrompt_Full_Updated_Website.zip
```

The packager fails before writing a new ZIP if essential migrations, navigation code, fonts/licenses, scripts, tests or reports are absent/empty. It verifies CRC, extracts to a fresh temporary folder and compares every extracted source file byte-for-byte. Dependencies, real environment files, private keys, uploaded/private files, database backups, build outputs, caches and nested ZIPs are excluded; `.env.example` is included. Both Vite configurations, Next.js, Docker/Caddy, tests and migration history are preserved. See `TEST_REPORT.md` for the actual final named ZIP validation, including fresh extraction checks.

## Security and privacy

Passwords: bcrypt cost 12. Sessions: random 256-bit tokens, hashed in PostgreSQL, seven-day expiry, HttpOnly, SameSite Lax and production Secure cookies. Mutating requests with conflicting Origin are rejected. Inputs are validated; SQL parameters prevent injection. Content is rendered as plain text, not executable HTML. Admin roles come from the database, not browser input.

Consent records, unsubscribes, deletion requests and owner-only subscriber controls are implemented, but legal/retention compliance still requires owner review and operational procedures. Legal pages are starter templates, not legal advice. Do not launch as fully production-ready without completing missing requirements, auditing dependencies and testing your deployment.

## Limitations

- Next.js server-renders public listing/detail content and metadata, then loads the existing interactive React interface. Account/admin actions remain client-interactive with protected Express API handlers; this is a custom Next.js/Express monolith, not a rewrite of every endpoint into server actions.
- The discovery sections below the feed can be reordered. Arbitrary full-page layouts, unlimited-depth mega-menus, advanced prompt feature selection and image galleries remain incomplete. This update supports one grouping level in the independent navigation editors. The rich editor uses safe Markdown rather than a full WYSIWYG editor.
- Admin tables use bounded results and client-side searching, not full server-side admin pagination. Several modules remain read-only.
- No native checkout, signed payment webhooks, order/review administration or automatic external-action verification. Private document delivery and manual expiring entitlements are implemented, but are not proof of purchase.
- Image banners are implemented; AdSense/executable ad snippets and general custom scripts are not.
- No OAuth, S3, analytics loader, automatic email retry worker, fine-grained custom permission editor, social-profile editor or automated account deletion.
- The frontend-only Figma preview shows labeled samples; production API failures are not silently replaced with demo data.
- Docker image/Compose runtime, standalone PostgreSQL instance, SMTP/API delivery and AWS/TLS must be verified in the target environment. Tests on PGlite do not prove infrastructure deployment.

## Assets and dependency notices

Branding, sample prompt text and introductory guides are original demonstration content. Photography is illustrative Unsplash imagery, not model output; review https://unsplash.com/license. The architecture image is by Chris Reyem. Typography self-hosts the original Inter 4.1 variable WOFF2 from https://github.com/rsms/inter/tree/v4.1 in `public/fonts/InterVariable.woff2`; its full SIL Open Font License is in `public/fonts/OFL.txt`. The shared stylesheet loads it locally with swap and native system fallbacks; no remote font request is required. The mono token intentionally uses platform monospace fonts. Dependencies retain upstream licenses; inspect their package license files before redistribution. No fabricated ratings, testimonials, discounts, sales or engagement counts are displayed.
