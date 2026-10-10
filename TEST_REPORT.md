# BrowsePrompt actual validation report

## Run context

2026-10-10, approximately 01:02–01:20 UTC, Linux sandbox, Node 22.23.2, pnpm 10.34.3, Python 3.13, approximately 1 GiB RAM. Input: `webapp_backup_i382gc8r.tar.gz`. Checks ran serially; databases were isolated PGlite fixtures. No deployment, production database, DNS, AWS, Namecheap, email provider or live-service credentials were accessed.

## Commands actually executed

Commands below ran from the BrowsePrompt source folder unless noted. Local `node_modules/.bin` executables use the project's locked dependencies, not globally substituted versions.

| Command / check | Result | Actual outcome |
|---|---|---|
| `npx --yes pnpm@10.34.3 install --frozen-lockfile --ignore-workspace` | PASS, exit 0 | 282 locked packages installed; lockfile unchanged. |
| `node_modules/.bin/tsc --noEmit` | PASS, exit 0 | Initial and final checks completed without diagnostics. |
| `NODE_OPTIONS=--max-old-space-size=512 node_modules/.bin/vite build` | PASS, exit 0 | Original Figma-aware config; 2179 modules, production assets built. |
| `NODE_OPTIONS=--max-old-space-size=512 node_modules/.bin/vite build --config vite.production.config.ts` | PASS, exit 0 | Standalone production config; 2179 modules, production assets built. This build was used by the Vite browser suite. |
| `NODE_OPTIONS=--max-old-space-size=512 NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 node_modules/.bin/next build next-app --webpack` | PASS, exit 0 | TypeScript, optimized compilation, static pages and build traces completed; public catch-all route server-rendered. |
| `NODE_OPTIONS=--max-old-space-size=384 node --test --test-concurrency=1 tests/*.test.mjs` | PASS, exit 0 | Final rerun: 50 tests passed, 0 failed, 0 skipped; approximately 18.2 seconds. |
| `node_modules/.bin/playwright install --with-deps chromium` | PASS, exit 0 | Linux prerequisites and Chromium/headless shell 156.0.8078.4 (Playwright revision 1248) downloaded. |
| `NODE_OPTIONS=--max-old-space-size=384 node tests/browser.mjs` | PASS, exit 0 after corrected test assertions | Final full Vite run completed all stages, with no uncaught browser JavaScript errors or failed local font/script/stylesheet requests in the monitored page. |
| `NODE_OPTIONS=--max-old-space-size=384 TEST_FRONTEND=next node tests/browser.mjs` | PASS, exit 0 | Full Next.js production-entry browser run completed, including server-generated public HTML, protected-body exclusion and HTTP 404. |
| `node --check` on every `server/*.mjs`, `scripts/*.mjs`, `tests/*.mjs` | PASS | 20 modules; final edited browser file checked again. |
| `bash -n` on every `scripts/*.sh` | PASS | 8 shell scripts. |
| Python `json.loads` on strict source JSON; TypeScript `parseConfigFileTextToJson` on JSONC configs | PASS | 5 strict JSON files and 3 comment-capable configuration files. |
| Python `compile` on `scripts/package.py` | PASS | Packaging syntax valid. |
| `git diff --check` in containing worktree | PASS, exit 0 | No whitespace errors; rerun before packaging. |
| Actual migrations 001–007 and repeated 007 in `tests/navigation-migration.test.mjs` | PASS | Fresh seed, customized legacy order/labels/rules, equivalent internal destinations, explicit/empty locations, absent legacy defaults, idempotency and preserved prompt/category records. |
| Actual API workflow tests | PASS | Atomic independent menu persistence, legacy merge compatibility, owner-only authorization and unsafe-link rejection, plus retained authentication/content workflows. |
| `tests/package.test.mjs` | PASS | Synthetic secret/private-state exclusions, both Vite configurations byte-preserved, CRC validation and hard failures when essential migration/navigation/font/report/test files are removed. |
| `python3 scripts/package.py` | PASS, exit 0 | Complete source archive; hard-required inventory, CRC, fresh extraction and full byte equality checked. 107 source files. |

## Browser coverage actually completed on both entry points

- Widths **320, 360, 375, 390, 430, 768, 1024, 1440**: homepage, listing, single prompt, sign-in, sign-up and signed-out admin entry; typography and no horizontal document overflow.
- Signed-in admin Navigation editor at all eight widths: keyboard-focusable audience selector and no overflow. Every menu location exercised Guest, Signed-in user and Administrator previews; hidden/rule-restricted links excluded correctly. Preview generated no settings writes. Saved runtime desktop/drawer/footer links matched each audience, with safe external `_blank` / `noopener noreferrer` attributes.
- Independent location edits: hide/show, reorder, save, reload, render in intended desktop/mobile/footer location and restore fixture settings.
- Prompt detail: media/sidebar desktop top alignment, content underneath media, mobile media→metadata/actions→content ordering and no overlap/overflow.
- Two-phase image→video workflow at all eight widths: per-phase model, input/output, dependency, image dimensions/aspect ratio, video duration/FPS/resolution/aspect ratio, reference image actually loaded, purpose/requirements, notes and negative prompt. Per-phase, negative-prompt and copy-all output checked, including clipboard-denied recovery. These are synthetic author-provided test settings, not provider capability claims.
- Search/category filtering, related-card destination paths, upload/submission/model review/publication, rich content sanitization and new account registration retained.
- Real local Inter WOFF2 loading verified through browser FontFace status. Intentionally blocked font request in a separate context verified readable system fallback; intentional image error verified fallback UI. This intentional failure context is excluded from normal request-success assertions.
- Light/dark switching and preference persistence; drawer Escape, close-on-navigation and focus restoration. Desktop/mobile prompt screenshots inspected in this run and showed the intended warm-neutral editorial layout. Screenshots and temporary uploads are not packaged.

Representative CSS-token contrast checks also ran: light ink/background **13.80:1**, muted/surface **6.24:1**, accent text/background **5.70:1**; dark equivalents **15.44:1**, **9.64:1**, **11.85:1**. Focus-visible and reduced-motion declarations were inspected. These spot checks are **not** a full accessibility/contrast audit of every rendered component or every browser.

## Initial failures and corrections (not hidden)

1. First expanded Vite run failed a new case-sensitive phase-metadata assertion because CSS renders labels as “Width Px,” not “width px.” Assertion made case-insensitive; no product styling changed.
2. Next Vite attempt failed a newly added synthetic user fixture using nonexistent role `user`. Fixture corrected to existing database role `registered_user`; no schema/authorization changed.
3. Next attempt compared footer defaults before asynchronous settings hydration finished. Runtime assertion now waits for the saved fixture's specific link before comparing. Final full Vite and Next runs passed.
4. A naive strict JSON scan rejected existing comment-bearing `.figma/make/dev.json`. Validation was corrected to use the comment-capable TypeScript parser for JSONC; the source configuration was not altered.
5. Initial archive safety inspection rejected a symbolic link inside the uploaded `.git` hooks. Only the actual `webapp/browseprompt` application was restored, preserving the sandbox worktree rather than importing archive Git internals.

## Blocked / skipped and known limitations

- **BLOCKED:** Docker/Compose container execution and standalone PostgreSQL infrastructure checks. `command -v docker` found no executable. PGlite tests execute real SQL/API handlers but omit the unsupported pgcrypto extension declaration; they do not establish container/production PostgreSQL readiness. `scripts/migrate.mjs` was syntax-checked and its ordered discovery inspected; its live `pg` connection path was not executed without PostgreSQL.
- **SKIPPED by scope:** production services, DNS/TLS, external email, AWS/Namecheap and payment/provider integrations. No live service verification was requested or performed.
- No configured lint script; no indiscriminate formatter run. Safari/Firefox, formal WCAG audit, exhaustive provider/image availability and load/security testing remain unverified.
- Existing operational feature limitations remain in README. BrowsePrompt is a library, not an image/video generator; model outputs are not guaranteed.

## Final named deliverable verification

`BrowsePrompt_Full_Updated_Website.zip` is copied outside the source tree from the internally verified package. The release procedure additionally runs ZIP CRC checks, extracts the exact named artifact into a fresh temporary directory, asserts the hard-required source inventory, compares all extracted files with the final source, rejects forbidden state/secrets filenames and confirms current reports plus both Vite configurations. Reports are finalized before the final release copy; the exact release artifact is rechecked after that copy. A passing source/build test is not a deployment claim.
