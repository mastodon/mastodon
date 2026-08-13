# Staging Environment — staging.thehighlander.app

Status: **live**, restored with real production data (backup
`mastodon-production-20260715T143531Z`). This file documents exactly what
was done, so it doubles as the reference for rebuilding or updating staging
later.

## Current state

- URL: <https://staging.thehighlander.app/>
- Fallback URL (always works, no custom domain needed):
  <https://staging-highlander-u54198.vm.elestio.app/>
- **Password-protected (HTTP Basic Auth):** username `appowner`, password
  `Simon@thehighlander`. Browser prompts once and remembers it for the
  session. `/health` is excluded so Elestio's own monitoring still works
  without credentials.
- Elestio service: `staging-highlander` (Netcup, Europe)
- SSH: `ssh root@staging-highlander-u54198.vm.elestio.app` (key-based; your
  laptop's `~/.ssh/id_ed25519` is registered on the service)
- App directory on the VM: `/opt/app`
- Real admin login (inside the app, separate from the Basic Auth above):
  `mykola.litynskyi@faceit.com.ua` (password in `admin-creds.txt` on your
  Mac, same as production/local)
- Restored: 303 accounts, 549 statuses, 1,109 media files — matches the local
  restore exactly.
- Visual identification: a thin orange/yellow diagonal-striped line at the
  very top of every page (`STAGING_BANNER=true`), plus `noindex` meta tag and
  `robots.txt` disallow-all so it won't get indexed or confused with
  production.

### ⚠️ One remaining manual step: attach the custom domain in Elestio

`staging.thehighlander.app` resolves and routes correctly (confirmed via
`curl -sk`), but the site currently serves Elestio's default `*.elestio.app`
wildcard certificate, not one issued for your actual domain — browsers will
show a certificate warning until this is done.

**Fix:** In the Elestio dashboard, open the `staging-highlander` service →
**Domains** tab → add `staging.thehighlander.app`. Elestio will verify DNS
(already correct — the CNAME was added) and auto-provision a real Let's
Encrypt certificate. No server-side changes needed once that's done.

## What was actually done (differs from the original plan in places)

The original plan assumed a generic "Docker Compose from Git" Elestio
service. What you actually created was Elestio's **"Mastodon" marketplace
one-click app**, which deploys vanilla `ghcr.io/mastodon/mastodon:latest`
plus OpenSearch and pgAdmin — not our fork — with edge routing
(`elestio.yml`) already wired to specific host ports. The steps below adapt
to that reality instead of the original generic plan.

1. **Found Elestio's existing edge routing.** `/opt/app/elestio.yml` showed
   `443 → 172.17.0.1:7834` (the main app) as an already-configured route,
   generated from the template's `docker-compose.yml` port bindings. Two
   other routes (`6443 → 8367` for pgAdmin, `5443 → 6835` for OpenSearch
   Dashboards) exist but are now unused since those services were removed.
   `elestio-nginx` and `elestio-postfix` are Elestio's own infrastructure
   containers (not part of our app) — left untouched.

2. **Tore down the placeholder stack** (empty, no real data):
   ```shell
   cd /opt/app && docker compose down -v
   ```

3. **Replaced the app directory** with our fork instead of the template,
   keeping the same path since Elestio's routing is tied to it:
   ```shell
   mv /opt/app /opt/app.elestio-template-backup
   git clone --branch staging https://github.com/The-Highlander-Newspaper-Limited/highlander-mastodon.git /opt/app
   ```

4. **Adapted our `docker-compose.yml` port bindings** to match Elestio's
   existing routing instead of the repo's defaults (`3000`/`4000`):
   ```shell
   sed -i "s/- '3000:3000'/- '172.17.0.1:7834:3000'/; s/- '4000:4000'/- '172.17.0.1:8834:4000'/" docker-compose.yml
   ```
   Note: port `8834` (streaming) is **not** exposed through Elestio's edge —
   only `443→7834` (the main app) is wired up currently. Live-updating
   timelines won't work on staging until a proper route for streaming is
   added (same deferred item as local dev's streaming subdomain). Everything
   else — loading, login, browsing restored data — is unaffected.

5. **Built the image and generated secrets:**
   ```shell
   cp .env.production.sample .env.production
   docker compose build web
   docker compose run --rm web bundle exec rails secret
   docker compose run --rm web bundle exec rails mastodon:webpush:generate_vapid_key
   ```

6. **Configured `.env.production`** — real domain, production's actual
   `DB_NAME`/`LIMITED_FEDERATION_MODE` (confirmed from the backup's secrets
   file, not guessed), fresh `SECRET_KEY_BASE`/VAPID keys, and — critically —
   **production's actual `ACTIVE_RECORD_ENCRYPTION_*` keys** (not fresh
   ones), since the restored database's encrypted columns need the same keys
   used when they were encrypted:
   ```shell
   LOCAL_DOMAIN=staging.thehighlander.app
   ALTERNATE_DOMAINS=staging-highlander-u54198.vm.elestio.app

   REDIS_HOST=redis
   REDIS_PORT=6379

   DB_HOST=db
   DB_USER=postgres
   DB_NAME=highlander_production
   DB_PASS=
   DB_PORT=5432

   ES_ENABLED=false
   S3_ENABLED=false

   LIMITED_FEDERATION_MODE=true

   STREAMING_API_BASE_URL=https://staging.thehighlander.app

   IP_RETENTION_PERIOD=31556952
   SESSION_RETENTION_PERIOD=31556952

   SECRET_KEY_BASE=82a12534fc1be80cbad6627ac94c25f9a288e18b3bf536ba6cf08aeaea32d207cceb2a5e644b93f0b0e2369340bbd2dd4b7b7e8054f3c440eeb10ee8b423640b

   ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=cMDGEJV3Mrn3g3XhFBvxOmIKm85XSR5v
   ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=Tv58TjAnW7A2iQbIksUL93BnGgeKNbzG
   ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=szXh6q5seUH6eEAOtrDYlaYyOkef1XE8

   VAPID_PRIVATE_KEY=wuiplIZnNGImcx2QjCzR2xIudD9n_85y3qS8CVvK_V4=
   VAPID_PUBLIC_KEY=BCEx26XOnXkB1wZEFL62A9vvW4MvlS9Yv9YnxDB6imUvI6-d-h1bo6Q80SW7LtaFE2mwpkwlgdFAgPi86qYxvpE=
   ```
   **`SMTP_*` deliberately left unset** — see Safety section below.

7. **Brought up the stack:**
   ```shell
   docker compose up -d db redis
   docker compose run --rm -e SAFETY_ASSURED=1 web bundle exec rails db:setup
   docker compose up --build -d
   ```

8. **Transferred and restored the backup** — same procedure as the local
   restore in `RUNBOOK.md`, run against `/opt/app` on the VM instead of the
   local repo:
   ```shell
   # from the Mac:
   scp "/Volumes/Ronak Data/projects/upwork/Simon/Backup/mastodon-production-20260715T143531Z-bulk.tar.gz" root@staging-highlander-u54198.vm.elestio.app:/root/

   # on the VM:
   mkdir -p /root/restore
   tar -xzf /root/mastodon-production-20260715T143531Z-bulk.tar.gz -C /root/restore
   docker compose stop web streaming sidekiq
   docker compose exec -T db psql -U postgres -f - < /root/restore/postgresql-globals.sql
   docker compose exec -T db psql -U postgres -c "DROP DATABASE IF EXISTS highlander_production;"
   docker compose exec -T db psql -U postgres -c "CREATE DATABASE highlander_production;"
   docker compose exec -T db pg_restore -U postgres -d highlander_production --no-owner --no-privileges < /root/restore/postgresql-highlander_production.dump
   mv public/system public/system.pre-restore-backup
   tar -xzf /root/restore/public-system.tar.gz -C .
   docker compose run --rm -e SAFETY_ASSURED=1 web bundle exec rails db:migrate
   docker compose up -d web streaming sidekiq
   ```

9. **Verified:** `200 OK` at both URLs, restored counts match the local
   restore (303 accounts, 549 statuses, 1,109 media files), and the real
   admin account (`mykola.litynskyi@faceit.com.ua`) is present in the
   restored DB.

10. **Added visual identification** — `app/views/layouts/application.html.haml`
    gets a `noindex` meta tag and a thin fixed-position striped banner line,
    both gated behind `STAGING_BANNER=true`. First attempt used an inline
    `style=""` attribute, which Mastodon's CSP silently blocks (inline style
    attributes aren't covered by the `'nonce-...'` source, only actual
    `<style>` tags are) — the div rendered with zero applied styling and was
    invisible. Fixed by moving the CSS into a `<style>` tag carrying
    `request.content_security_policy_nonce`, matching the pattern the layout
    already uses elsewhere (`#inert-style`). All banner/noindex/robots.txt
    changes live **only on the `staging` branch** — none of it was pushed to
    `highlander-main`/production.

11. **Added HTTP Basic Auth** — `config/initializers/staging_basic_auth.rb`
    (staging-only), a small Rack middleware gated behind
    `STAGING_BASIC_AUTH_USER`/`STAGING_BASIC_AUTH_PASSWORD`. Excludes
    `/health` specifically so Elestio's own monitoring isn't locked out.
    Credentials: username `appowner`, password `Simon@thehighlander`.

## Why staging cannot affect production

Staging's `db` container is a brand-new Postgres instance running only on
this VM, with its own disk. `DB_HOST=db` in `.env.production` resolves to
that local container by Docker network name — there is no network path from
staging to production's actual database (which isn't exposed to the
internet, runs on a different Elestio service on different hardware). The
restore was a one-way import of a static backup file, not a live connection.
Both databases happening to be named `highlander_production` is just a
naming convention from the backup's manifest, not a shared instance.

## Safety — this is real user data on a public URL

Same considerations as the local restore (see `RUNBOOK.md`), more so here
since this is internet-reachable:

- **`SMTP_*` is unset in `.env.production`.** The restored database has real
  users' real email addresses. Do not point this at a real mail relay —
  scheduled/background jobs could send real email to real people appearing
  to come from Highlander. If you need to test email delivery, point it at a
  sink (Mailtrap, Mailhog) first.
- **Fresh VAPID keys were generated for staging**, not production's. Restored
  users' push subscriptions were created against production's VAPID public
  key; sending from staging's different key pair makes the push service
  reject the send rather than actually notifying someone's device. Don't
  copy production's real VAPID keys in.
- Consider HTTP basic auth or an IP allowlist at the Elestio proxy level if
  you don't want this browsable by anyone who finds the URL while it holds
  real user data.
- `admin-creds.txt` and the backup's secrets archive are live production
  credentials — keep them where they already are, don't commit them.

## Useful commands

```shell
ssh root@staging-highlander-u54198.vm.elestio.app
cd /opt/app
docker compose ps
docker compose logs -f web streaming sidekiq
docker compose down            # stop everything (data persists in Docker volumes)
docker compose up -d           # bring it back up
```

## Open items

- Attach `staging.thehighlander.app` in Elestio's Domains tab (see above) —
  the only thing standing between this and a clean HTTPS experience.
- Streaming (`ws`) isn't routed through Elestio's edge yet — live timeline
  updates won't work until that's added (optional, deferred).
- `/opt/app.elestio-template-backup` on the VM still holds the original
  template's files if you ever want to reference them; safe to delete once
  you're confident staging is working as intended.
