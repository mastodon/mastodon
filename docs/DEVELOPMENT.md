# Development

## Overview

Before starting local development, read the [CONTRIBUTING] guide to understand
what changes are desirable and what general processes to use. You should also read the project's [AI Contribution Policy] to understand how we approach AI-assisted contributions.

## Environments

The following instructions will guide you through the process of setting up a local development instance of Mastodon on your computer.

There are instructions for these environments:

- [Vagrant](#vagrant)
- [macOS](#macos)
- [Linux](#linux)
- [Docker](#docker)
- [Dev Containers](#dev-containers)
- [GitHub Codespaces](#github-codespaces)

Once completed, continue with the [Next steps](#next-steps) section below.

### Vagrant

A **Vagrant** configuration is included for development purposes. To use it,
complete the following steps:

- Install Vagrant and Virtualbox
- Install the `vagrant-hostsupdater` plugin:
  `vagrant plugin install vagrant-hostsupdater`
- Run `vagrant up`
- Run `vagrant ssh -c "cd /vagrant && bin/dev"`
- Open `http://mastodon.local` in your browser

### macOS

To set up **macOS** for native development, complete the following steps:

- Install [Homebrew] and run:
  `brew install postgresql@14 redis libidn nvm vips`
  to install the required project dependencies
- Use a Ruby version manager to activate the ruby in `.ruby-version` and run
  `nvm use` to activate the node version from `.nvmrc`
- Start the database services by running `brew services start postgresql` and
  `brew services start redis`
- Run `RAILS_ENV=development bin/setup`, which will install the required ruby gems and node
  packages and prepare the database for local development

  (Note: If you are on Apple Silicon and get an error related to `libidn`, you should be able to fix this by running `gem install idn-ruby -- --with-idn-dir=$(brew --prefix libidn)`, then re-running the command above.)

- Finally, run the `bin/dev` script which will launch services via `overmind`
  (if installed) or `foreman`

### Linux

The Mastodon documentation has a [guide on installing Mastodon from source](https://docs.joinmastodon.org/dev/setup/#manual) on Linux.

### Docker

For production hosting and deployment with **Docker**, use the `Dockerfile` and
`docker-compose.yml` in the project root directory.

For local development, install and launch [Docker], and run:

```shell
docker compose -f .devcontainer/compose.yaml up -d
docker compose -f .devcontainer/compose.yaml exec app bin/setup
docker compose -f .devcontainer/compose.yaml exec app bin/dev
```

### Dev Containers

Within IDEs that support the [Development Containers] specification, start the
"Mastodon on local machine" container from the editor. The necessary `docker
compose` commands to build and setup the container should run automatically. For
**Visual Studio Code** this requires installing the [Dev Container extension].

### GitHub Codespaces

[GitHub Codespaces] provides a web-based version of VS Code and a cloud hosted
development environment configured with the software needed for this project.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)][codespace]

- Click the button to create a new codespace, and confirm the options
- Wait for the environment to build (takes a few minutes)
- When the editor is ready, run `bin/dev` in the terminal
- Wait for an _Open in Browser_ prompt. This will open Mastodon
- On the _Ports_ tab "stream" setting change _Port visibility_ → _Public_

## Next steps

- Once you have successfully set up a development environment, it will be available on http://localhost:3000
- Log in as the default admin user with the username `admin@mastodon.local` or `admin@localhost` (depending on your setup) and the password `mastodonadmin`.
- Check out the [Mastodon docs] for tips on working with emails in development (you'll need this when creating new user accounts) as well as a list of useful commands for testing and updating your dev instance.
- You can optionally populate your database with sample data by running `bin/rails dev:populate_sample_data`. This will create a `@showcase_account` account with various types of contents.

## Testing the PWA

For normal feature work, use `bin/dev`. For PWA install, service worker, and
push-notification testing, run the production Docker setup locally and open it
through an HTTPS URL. A local `http://localhost:3000` development server does
not exercise the same production assets and service worker path.

Use an HTTPS tunnel such as Cotunnel to expose local port `3000`. Start the
tunnel first and copy the generated HTTPS host name without the `https://`
prefix. For example, if the tunnel URL is
`https://highlander-dev.cotunnel.com`, use `highlander-dev.cotunnel.com` as
`LOCAL_DOMAIN` and `WEB_DOMAIN`.

Create or update `.env.production` for the local Docker run. Use the tunnel host
and the Docker service names from `docker-compose.yml`:

```shell
LOCAL_DOMAIN=highlander-dev.cotunnel.com
WEB_DOMAIN=highlander-dev.cotunnel.com

DB_HOST=db
DB_USER=postgres
DB_NAME=mastodon_production
DB_PASS=
DB_PORT=5432
REPLICA_DB_TASKS=false

REDIS_HOST=redis
REDIS_PORT=6379

ES_ENABLED=false
S3_ENABLED=false
```

Keep `.env.production` local-only and do not reuse real production secrets or a
real production database. The compose file stores local PostgreSQL, Redis, and
uploaded media data in gitignored directories under the repository.

If `.env.production` does not already have local secrets, generate them inside
the Docker image and paste the output into `.env.production`:

```shell
docker compose build web
docker compose run --rm web bundle exec rails secret
docker compose run --rm web bundle exec rails mastodon:webpush:generate_vapid_key
docker compose run --rm web bundle exec rails db:encryption:init
```

Initialize the local production-mode database:

```shell
docker compose up -d db redis
docker compose run --rm -e SAFETY_ASSURED=1 web bundle exec rails db:setup
```

Then start the same services used by the production-style compose setup:

```shell
docker compose up --build
```

Keep the HTTPS tunnel forwarding to `http://localhost:3000`, then open the
tunnel URL in the browser or on a mobile device. The tunnel hostname must match
`LOCAL_DOMAIN` and `WEB_DOMAIN`; if the tunnel URL changes, update
`.env.production`, restart Docker, and clear the browser's installed
PWA/service worker state before retesting install behavior.

The default tunnel-to-port-`3000` setup is enough for install and service worker
testing. If you need live timeline streaming too, expose the `streaming` service
on port `4000` through a separate HTTPS/WSS tunnel or a local reverse proxy that
routes `/api/v1/streaming` to the streaming container. When using a separate
streaming tunnel, set `STREAMING_API_BASE_URL` to that `wss://` URL in
`.env.production` and restart Docker.

When you change frontend code or production environment values that affect
compiled assets, rebuild the images with `docker compose up --build`.

[codespace]: https://codespaces.new/mastodon/mastodon?quickstart=1&devcontainer_path=.devcontainer%2Fcodespaces%2Fdevcontainer.json
[CONTRIBUTING]: ../CONTRIBUTING.md
[Dev Container extension]: https://containers.dev/supporting#dev-containers
[Development Containers]: https://containers.dev/supporting
[Docker]: https://docs.docker.com
[GitHub Codespaces]: https://docs.github.com/en/codespaces
[Homebrew]: https://brew.sh
[Mastodon docs]: https://docs.joinmastodon.org/dev/setup/#working-with-emails-in-development
[AI Contribution Policy]: https://github.com/mastodon/.github/blob/main/AI_POLICY.md
