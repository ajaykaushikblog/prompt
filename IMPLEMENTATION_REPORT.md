# BrowsePrompt v3 continuation report — historical / superseded

This file preserves earlier implementation notes and earlier reported checks. **None of the PASS claims below describes the 2026-10-10 remaining-work run.** See `MODIFICATION_REPORT.md` and `TEST_REPORT.md` for this exact uploaded snapshot and its actual verification. Current typography is self-hosted Inter 4.1 (`BrowsePrompt Inter`), not Poppins, DM Sans or Manrope. References below to older fonts or remote Google Fonts are historical only; current CSS requests no remote font.

## Earlier fixes and historical reported results

Follow-up: AI Models loading was traced to the temporary preview API process exiting between sessions. The Figma development runner now starts API and Vite in one supervised lifecycle and terminates both together. Bootstrap verification passed after restarting the stale preview. Live browser checks loaded eight models and ChatGPT details, checked 390/1024/1440 widths, verified Poppins and white dark-mode headings, confirmed theme persistence, and loaded home/guides/resources without service errors. The Vite production build passed. Typography now uses Poppins rather than the earlier DM Sans/Manrope combination.

- Added visible account registration, retained authenticated sessions, and verified registration in both browser entry points.
- Added DM Sans/Manrope typography, white-and-cream surfaces, and a persistent dark/light switch visible at mobile widths.
- Removed the long preview disclaimer from prompt detail/library pages and replaced visitor-facing deployment instructions with concise service errors.
- Connected the Figma Vite configuration to a separate development API on port 3001 with persistent PGlite data under `/tmp`. It is not the Mac/production PostgreSQL database and needs its own running API process.
- Added migration `005_prompt_phases.sql`, validated ordered phases, submission/review editing, phase-only submissions, per-phase copying, and server-side protection of phase bodies.
- Improved Docker Desktop startup guidance without changing existing secrets or volumes.

Verification completed before packaging:

- `pnpm test`: **39 passed, 0 failed**.
- `pnpm build`: passed.
- `pnpm test:browser`: passed.
- `pnpm build:next`: passed, including TypeScript checking.
- `pnpm test:next`: passed.
- Browser suites checked 360, 390, 768, 1024 and 1440 pixel widths, registration, owner login, search/filter, image uploads, moderation, rich-content publication, two-phase copying, theme persistence, protected HTML and no browser JavaScript errors.
- Development API health, guides, resources, deals and models returned HTTP 200 with seeded content.
- Shell syntax and `git diff --check`: passed.

Initial responsive overflow, test-selector ambiguity and verification rate-limit exhaustion were corrected. Parallel verification processes were killed by resource limits; the final build/browser sequence passed when run serially. Docker container execution was not reverified here; a running Docker Desktop engine remains required on macOS. Remote image availability and Google Fonts depend on network access. Existing master-spec limitations below still apply.

## Architecture

The original interactive React interface and compatible Express API were preserved. Production now uses a built Next.js frontend in the same Node/Express process. Public prompts, model pages, content pages, authors and category listings have server-generated HTML and metadata, followed by the interactive interface. Vite remains the Figma preview/editing entry point.

PostgreSQL access uses parameterized `pg` queries and tracked SQL migrations, not Prisma. Docker serves one web process, PostgreSQL and Caddy. The separate localhost configuration exposes only loopback port 3000; PostgreSQL remains private.

## New capabilities

- Safe Markdown content studio: formatting toolbar, write/preview modes, headings, lists, quotes, code, tables, images, table of contents and allowlisted video links.
- Server-side Markdown sanitization and page-level SEO fields.
- Form-based branding, SEO and homepage controls; discovery section ordering/visibility, selected models, initial card count and CTA configuration.
- Database-backed homepage discovery sections for models, guides, resources and deals.
- Owner-controlled user roles and activation with session revocation, self-mutation protection and audit records.
- Bulk prompt lock/unlock, feature/unfeature, archive and publish; model approval remains mandatory before publication.
- Audited manual prompt membership grants with expiry; external action clicks are never treated as verified subscriptions.
- Private PDF/text product upload, separate persistent storage, authenticated delivery, expiring manual entitlements for priced products, and access denial after expiry. Manual grants do not assert payment.
- Descriptive slugs for new submissions while preserving old URLs.
- Docker context exclusions prevent secrets, uploaded files and source ZIPs from being baked into the image.

## Verification

The previous full run passed dependency installation, TypeScript, both Vite builds, Next.js production build, API/security tests and both browser entry points. Browser coverage includes five requested widths, server-rendered prompt content, locked HTML protection, HTTP 404, search/filtering, detail URL/refresh/copy, owner login, uploads, model review, publication and rich-editor preview/publication/safe rendering.

The current `TEST_REPORT.md` replaces these historical verification claims and records this run's ZIP validation. PGlite tests use the production API handlers and PostgreSQL schema, omitting the pgcrypto extension declaration. They are not proof of standalone container deployment. No lint script is configured.

## Remaining limitations

Native payment processing, signed payment webhooks, order/review management, OAuth, S3, analytics loaders, executable ad/AdSense scripts, nested mega-menu editing, full-page drag-and-drop layouts, arbitrary galleries, fine-grained custom permissions, automated deletion and email retry jobs remain incomplete. Administrative tables use bounded results and client-side searching, not complete server-side admin pagination. Some media and reporting operations remain read-only.

The rich editor is Markdown-based rather than WYSIWYG. Only PDF/text private product files are supported; uploads are not malware-scanned. Manually granted access is not purchase verification. Publisher verification through YouTube/Telegram/WhatsApp is not implemented.

External email delivery, Docker runtime, TLS and AWS deployment require target-environment verification. The platform must not be described as fully production-ready or complete against every master-specification item.

No real administrator credentials, private keys, production data or database dumps are included.
