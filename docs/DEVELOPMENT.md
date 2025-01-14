# Development

## Overview

Before starting local development, read the [CONTRIBUTING] guide to understand
what changes are desirable and what general processes to use.

## Environments

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
  `brew install postgresql@14 redis imagemagick libidn nvm`
  to install the required project dependencies
- Use a Ruby version manager to activate the ruby in `.ruby-version` and run
  `nvm use` to activate the node version from `.nvmrc`
- Run the `bin/setup` script, which will install the required ruby gems and node
  packages and prepare the database for local development
- Finally, run the `bin/dev` script which will launch services via `overmind`
  (if installed) or `foreman`

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

[codespace]: https://codespaces.new/mastodon/mastodon?quickstart=1&devcontainer_path=.devcontainer%2Fcodespaces%2Fdevcontainer.json
[CONTRIBUTING]: CONTRIBUTING.md
[Dev Container extension]: https://containers.dev/supporting#dev-containers
[Development Containers]: https://containers.dev/supporting
[Docker]: https://docs.docker.com
[GitHub Codespaces]: https://docs.github.com/en/codespaces
[Homebrew]: https://brew.sh
