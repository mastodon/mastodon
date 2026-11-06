# Configuration schema

Mastodon ships a machine-readable JSON Schema (draft 2020-12)
that describes every environment variable the application reads.
`annotations.yml` is the canonical source; both the JSON schema and the
admin docs page are generated from it.

## Generating the schema

With a working Ruby environment and all gems installed, run:

```shell
bundle exec rails mastodon:config:schema > mastodon-config.schema.json
```

## Generating the admin docs page

The Hugo-flavored Markdown for `content/en/admin/config.md` in
`mastodon/documentation` is generated from the committed JSON schema:

```shell
bundle exec rails mastodon:config:docs > /path/to/documentation/content/en/admin/config.md
```

The task reads `mastodon-config.schema.json` in the project root by default.
Pass an explicit path as an argument if needed:

```shell
bundle exec rails 'mastodon:config:docs[/path/to/mastodon-config.schema.json]'
```

The generated Markdown should be committed in the documentation repository.
Regenerate it whenever `annotations.yml` changes and a new Mastodon release is
cut.

## Inter-repo workflow

`mastodon/mastodon` owns `annotations.yml` and `mastodon-config.schema.json`.
`mastodon/documentation` consumes the generated Markdown.  Two delivery options:

- **Manual**: a docs maintainer runs `mastodon:config:docs` against a tagged
  Mastodon release and commits the output.
- **Automated**: a docs-repo workflow checks out a Mastodon release, runs the
  task, and opens a PR.

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
| `x-status` | *(Extension)* `"deprecated"` or `"removed"`. Absent on active variables. |
| `x-version-history` | *(Extension)* Ordered list of `{version, change}` objects describing when the variable was added or changed. |
| `x-example-value` | *(Extension)* A single representative value rendered as `Example value: \`…\`` in docs. |
| `x-anchor` | *(Extension)* Explicit HTML anchor override; pass `""` to suppress the anchor entirely on a `removed` variable. |
| `x-hints` | *(Extension)* List of `{style, body}` Hugo hint shortcode blocks (`style` is `info`, `warning`, or `danger`). Emitted after the description. |
| `x-extra` | *(Extension)* Prose paragraph rendered after the hints and before the version-history block. |
| `x-trailing` | *(Extension)* Prose paragraph rendered after the example value (the very last body element). |
| `x-show-default` | *(Extension)* When `true`, emit a `**Default:** \`…\`` block in the rendered docs (most defaults are described inline in prose). |
| `x-suppress-removed-hint` | *(Extension)* When `true`, render a `removed` variable's description as plain prose instead of wrapping it in a danger hint. |

The schema also carries a top-level `x-docs-layout` object (not a per-property
field) that encodes the Hugo frontmatter and section tree used to generate the
admin docs page.  It is consumed by `mastodon:config:docs` and is not
meaningful to standard JSON Schema validators. `x-docs-layout.docs_only_variables`
holds annotation entries for variables that should appear in the rendered docs
but are not part of the live configuration surface (tombstones for removed
variables, Rails-internal vars upstream documents).

### Subsection fields

Subsections inside `docs.sections[*].subsections[*]` accept:

| Field | Purpose |
|-------|---------|
| `title`, `anchor` | Header label and explicit anchor ID. |
| `page_refs` | List of pages rendered as `{{< page-ref page="…" >}}` shortcodes (emitted first). |
| `pre_version_history` | Version-history block rendered before any prose (matches upstream's "Fetch All Replies" ordering). |
| `pre_hints` | Hint shortcodes rendered before the intro paragraph. |
| `intro` | Multi-paragraph Markdown intro. |
| `version_history` | Version-history block rendered after the intro. |
| `hints` | Hint shortcodes rendered after the intro and version history. |
| `variables` | Ordered list of variable names. |
| `subsections` | Nested sibling subsections (rendered at the same heading level — upstream uses a flat structure under SMTP). |

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
Add a new top-level key for the variable name.  Minimum required fields:

```yaml
MY_NEW_VAR:
  type: string          # string / integer / boolean / number
  group: features
  description: What this variable does.
  default: some-value   # omit if there is no meaningful default
  enum: [a, b, c]       # omit if values are unconstrained
  secret: true          # set when the value must not be logged or displayed
```

Optional docs-specific fields:

```yaml
MY_NEW_VAR:
  # ... required fields above ...
  description: |
    Long-form Markdown prose for the docs page.  Multi-paragraph, code blocks,
    and inline links are allowed.
  version_history:
    - version: 4.4.0
      change: Added.
  example_value: my-value          # rendered as `Example value: \`my-value\``
  status: active                   # active (default) | deprecated | removed
  anchor: my-anchor-override       # rare
  show_default: true               # emit a "**Default:** \`…\`" block
  hints:
    - style: warning               # info | warning | danger
      body: |
        Markdown body of the Hugo hint shortcode.
  extra: |
    Additional prose rendered after the hints (e.g. an inline "Defaults to false." note).
  trailing: |
    Additional prose rendered after the example value (e.g. supplementary links).
```

Also add the variable to the appropriate subsection in the `docs.sections`
tree at the bottom of `annotations.yml` so it appears in the generated docs
page.

The `EnvScanner` will catch any variable that appears in the source but is
absent from `annotations.yml` (see [Lint check](#lint-check) below).

Run `bundle exec rails mastodon:config:schema > mastodon-config.schema.json`
after editing and commit the updated JSON file.

### Tombstone variables

Variables that have been removed from the codebase should be kept in
`annotations.yml` with `status: removed` (and a `version_history` entry
recording when they were removed) so that the generated docs preserves
historical anchors and version-history blocks for users upgrading from old
installations.  They do not need to be moved to `EnvScanner::EXCLUDED_VARS`.

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
