# The Highlander Community App

<p align="center">
  <img alt="The Highlander logo" src="./app/javascript/images/logo-symbol-wordmark.svg?raw=true" width="360" />
</p>

The Highlander is a local community app built on Mastodon. It keeps Mastodon's
open-source server foundation, moderation tools, media handling, OAuth2, and
REST/Streaming APIs, while adapting the product for an unfederated local news
and community-reading experience.

This repository contains the Highlander Mastodon fork used by
[thehighlander.app](https://thehighlander.app).

## What Highlander changes

- **All-reader home feed**: public posts are delivered to active readers instead
  of relying only on the follow graph.
- **Unfederated app model**: Highlander does not use Mastodon federation or
  ActivityPub-facing network behavior.
- **Installable PWA**: Highlander can be installed from the browser for a
  native-like mobile experience without an app store.
- **Content categories**: accounts can be assigned categories, and category
  badges appear in status and admin views.
- **Reader category filters**: readers can turn optional categories on or off in
  their home feed.
- **Category notifications**: readers can opt into push notifications for
  selected categories.
- **Highlander roles**: the fork adds a `Poster` role to the starter roles and category-management
  permissions for admins.
- **Highlander onboarding and branding**: welcome flows, email copy, themes, and
  public-facing text are customized for The Highlander.

For implementation details and maintainer notes, read
[Highlander features](docs/HIGHLANDER_FEATURES.md).

## Documentation

- [Highlander features](docs/HIGHLANDER_FEATURES.md): Highlander-specific product
  behavior, API endpoints, roles, feed changes, and focused specs.
- [Development setup](docs/DEVELOPMENT.md): local development environment
  setup.
- [Operations notes](docs/OPERATIONS.md): Highlander-specific production
  recovery notes, including Elestio 502 recovery.
- [Contributing](CONTRIBUTING.md): upstream contribution guidance that still
  applies to most code-level changes.
- [Security policy](SECURITY.md): reporting security issues.

For upstream Mastodon administration and deployment concepts, refer to the
[Mastodon documentation](https://docs.joinmastodon.org). Some branding and
product behavior in this repository intentionally differs from upstream.

## Tech stack

- [Ruby on Rails](https://github.com/rails/rails) powers the web app, REST API,
  admin UI, and background jobs.
- [PostgreSQL](https://www.postgresql.org/) is the primary database.
- [Redis](https://redis.io/) and [Sidekiq](https://sidekiq.org/) handle caching,
  feeds, and job processing.
- [Node.js](https://nodejs.org/) powers the streaming API.
- [React](https://react.dev/) and [Redux](https://redux.js.org/) power the
  interactive frontend.

## Requirements

- **Ruby** 3.3+
- **PostgreSQL** 14+
- **Redis** 7.0+
- **Node.js** 22+
- **FFmpeg** 5.1+

## Development

Set up a local development environment with [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).
PWA testing needs a production-mode local run behind HTTPS; see
[Testing the PWA](docs/DEVELOPMENT.md#testing-the-pwa).

Common commands:

```shell
bin/setup
bin/dev
bin/rspec
yarn test
```

After setup, the local app is available at `http://localhost:3000`. The default
development admin account is `admin@mastodon.local` or `admin@localhost`,
depending on setup, with password `mastodonadmin`.

## Upstream base

The Highlander is based on Mastodon, a free, open-source social network server
licensed under AGPLv3. Mastodon provides much of the core server, moderation,
API, and frontend infrastructure, but Highlander is operated as an unfederated
application.

Useful upstream links:

- [Mastodon project](https://github.com/mastodon/mastodon)
- [Mastodon documentation](https://docs.joinmastodon.org)

## License

Copyright (c) 2016-2025 Eugen Rochko (+ [`mastodon authors`](AUTHORS.md))

Licensed under GNU Affero General Public License as stated in the [LICENSE](LICENSE):

```text
Copyright (c) 2016-2025 Eugen Rochko & other Mastodon contributors

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License along
with this program. If not, see https://www.gnu.org/licenses/
```
