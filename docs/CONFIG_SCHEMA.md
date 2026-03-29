# Configuration schema

Mastodon ships a machine-readable JSON Schema (draft 2020-12)
that describes every environment variable the application reads.

## Generating the schema

With a working Ruby environment and all gems installed, run:

```shell
bundle exec rails mastodon:config:schema > mastodon-config.schema.json
```

## Schema structure

The top-level object is a JSON Schema `object` whose `properties` are the
environment-variable names.  Each property carries:

| Field | Purpose |
|-------|---------|
| `type` | Semantic type (`string`, `integer`, `boolean`, or `number`). |
| `description` | Human-readable explanation of the variable, including its effect and any caveats. |
| `default` | The value Mastodon uses when the variable is absent. Omitted when there is no meaningful default. |
| `enum` | Allowed values for constrained strings. |
| `minimum` / `maximum` | Numeric bounds. |
| `format` | JSON Schema semantic format hint (e.g. `uri`, `email`). |
| `examples` | Representative values shown in UIs and documentation. |
| `x-group` | *(Extension)* Logical grouping name — used by UIs to cluster related settings. |
| `x-secret` | *(Extension)* `true` when the value is a cryptographic secret that should never be displayed or logged. |
| `x-restart-required` | *(Extension)* `false` when a change can take effect without restarting Mastodon processes (rare). Absent on most properties, meaning a restart is always required. |

### Groups

| Group | Variables covered |
|-------|------------------|
| `federation` | Domain name, federation mode, single-user mode |
| `database` | PostgreSQL primary and read-replica connections |
| `redis` | Main, Sidekiq, and cache Redis connections including Sentinel |
| `email` | SMTP and bulk-mail SMTP settings |
| `storage` | S3, OpenStack Swift, Azure Blob Storage, local filesystem |
| `search` | Elasticsearch / OpenSearch |
| `authentication` | LDAP, PAM, OIDC, SAML, CAS, SSO behaviour |
| `web-server` | Puma, Sidekiq, proxy, and CDN settings |
| `secrets` | Cryptographic keys and tokens |
| `features` | Behavioural feature flags |
| `retention` | IP, session, and user-activity retention periods |
| `translation` | DeepL and LibreTranslate integration |
| `captcha` | hCaptcha |
| `cache-buster` | CDN cache purge integration |
| `observability` | Prometheus exporter and OpenTelemetry |
| `media` | ffmpeg paths and S3 batch-delete tuning |

## Adding new variables

Property metadata lives in
[`lib/mastodon/configuration/annotations.yml`](../lib/mastodon/configuration/annotations.yml).
Add a new top-level key for the variable name with at minimum `type`, `group`,
and `description`:

```yaml
MY_NEW_VAR:
  type: string          # string / integer / boolean / number
  group: features
  description: What this variable does.
  default: some-value   # omit if there is no meaningful default
  enum: [a, b, c]       # omit if values are unconstrained
  secret: true          # set when the value must not be logged or displayed
```

The `EnvScanner` will catch any variable that appears in the source but is
absent from `annotations.yml` (see [Lint check](#lint-check) below).

Run `bundle exec rails mastodon:config:schema > mastodon-config.schema.json`
after editing and commit the updated JSON file.

## Lint check

`bundle exec rails mastodon:config:lint` statically scans the source tree for
literal `ENV.fetch` / `ENV[]` accesses and reports any variable that is absent
from `annotations.yml` and not in the explicit exclusion list
(`EnvScanner::EXCLUDED_VARS`).  CI runs this check automatically on every PR
that touches `config/`, `lib/mastodon/`, or the schema files.

If you add a new env var without updating `annotations.yml`, CI will fail and
tell you exactly which file uses the undocumented variable.

Variables that are intentionally undocumented (deprecated aliases, Rails
internals, CI/dev-only vars) belong in `EnvScanner::EXCLUDED_VARS` rather than
in `annotations.yml`.

Regenerate `mastodon-config.schema.json` whenever you upgrade Mastodon to pick
up newly added variables.
