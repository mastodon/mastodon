Mastodon CE
========

Mastodon CE is a fork of [Mastodon](https://github.com/tootsuite/mastodon) developed cooperatively by [bbnet](https://source.heropunch.io/bbnet/bbnet). The focus of this fork is on interoperability and community-responsive development.

## What's different?

- **Fully separated front-end and back-end.**
  Use the Mastodon CE front-end with any back-end. Use the Mastodon CE back-end with any front-end.
- **Plays nice with the rest of the fediverse.**
  Other instances don't need to conform to Mastodon CE. bbnet will fix bugs which cause problems for neighbors.
- **What the people want, not the media.**
  Mastodon CE will deliver long overdue features and fixes that communties have been craving. Our goal is not to fit in with silicon valley aesthetics and dazzle the media with appearances. Our goal is to create a functional useful piece of software that meets the needs of communities who use it.

## Resources

- [About bbnet](https://source.heropunch.io/bbnet/bbnet)
- [API overview](https://github.com/heropunch/mastodon-ce/wiki/API)
- [Frequently Asked Questions](https://github.com/heropunch/mastodon-ce/wiki/FAQ)
- [List of apps](https://github.com/heropunch/mastodon-ce/wiki/Apps)

## Features of Mastodon

- **Actually fully interoperable with GNU social and any OStatus platform**
  Whatever implements Atom feeds, ActivityStreams, Salmon, PubSubHubbub and Webfinger is part of the network
- **Real-time timeline updates**
  See the updates of people you're following appear in real-time in the UI via WebSockets
- **Federated thread resolving**
  If someone you follow replies to a user unknown to the server, the server fetches the full thread so you can view it without leaving the UI.
- **Media attachments like images and WebM**
  Upload and view images and WebM videos attached to the updates
- **OAuth2 and a straightforward REST API**
  Mastodon acts as an OAuth2 provider so 3rd party apps can use the API, which is RESTful and simple
- **Background processing for long-running tasks**
  Mastodon tries to be as fast and responsive as possible, so all long-running tasks that can be delegated to background processing, are
- **Deployable via Docker**
  You don't need to mess with dependencies and configuration if you want to try Mastodon, if you have Docker and Docker Compose the deployment is extremely easy

## Deployment

- `LOCAL_DOMAIN` should be the domain/hostname of your instance. This is **absolutely required** as it is used for generating unique IDs for everything federation-related
- `LOCAL_HTTPS` set it to `true` if HTTPS works on your website. This is used to generate canonical URLs, which is also important when generating and parsing federation-related IDs

Consult the example configuration file, `.env.production.sample` for the full list. Among other things you need to set details for the SMTP server you are going to use.

## Requirements

- Ruby
- Node.js
- PostgreSQL
- Redis
- Nginx

## Running with Docker and Docker-Compose

[![](https://images.microbadger.com/badges/version/gargron/mastodon.svg)](https://microbadger.com/images/gargron/mastodon "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/gargron/mastodon.svg)](https://microbadger.com/images/gargron/mastodon "Get your own image badge on microbadger.com")

The project now includes a `Dockerfile` and a `docker-compose.yml` file (which requires at least docker-compose version `1.10.0`).

Review the settings in `docker-compose.yml`. Note that it is not default to store the postgresql database and redis databases in a persistent storage location,
so you may need or want to adjust the settings there.

Then, you need to fill in the `.env.production` file:

    cp .env.production.sample .env.production
    nano .env.production

Do NOT change the `REDIS_*` or `DB_*` settings when running with the default docker configurations.

You will need to fill in, at least: `LOCAL_DOMAIN`, `LOCAL_HTTPS`, `PAPERCLIP_SECRET`, `SECRET_KEY_BASE`, `OTP_SECRET`, and the `SMTP_*` settings.  To generate the `PAPERCLIP_SECRET`, `SECRET_KEY_BASE`, and `OTP_SECRET`, you may use:

Before running the first time, you need to build the images:

    docker-compose build


    docker-compose run --rm web rake secret

Do this once for each of those keys, and copy the result into the `.env.production` file in the appropriate field.

Then you should run the `db:migrate` command to create the database, or migrate it from an older release:

    docker-compose run --rm web rails db:migrate

Then, you will also need to precompile the assets:

    docker-compose run --rm web rails assets:precompile

before you can launch the docker image with:

    docker-compose up

If you wish to run this as a daemon process instead of monitoring it on console, use instead:

    docker-compose up -d

Then you may login to your new Mastodon instance by browsing to http://localhost:3000/

Following that, make sure that you read the [production guide](https://github.com/heropunch/mastodon-ce/wiki/Production-guide). You are probably going to want to understand how
to configure Nginx to make your Mastodon instance available to the rest of the world.

The container has two volumes, for the assets and for user uploads, and optionally two more, for the postgresql and redis databases.

The default docker-compose.yml maps them to the repository's `public/assets` and `public/system` directories, you may wish to put them somewhere else. Likewise, the PostgreSQL and Redis images have data containers that you may wish to map somewhere where you know how to find them and back them up.

**Note**: The `--rm` option for docker-compose will remove the container that is created to run a one-off command after it completes. As data is stored in volumes it is not affected by that container clean-up.

### Tasks

- `rake mastodon:media:clear` removes uploads that have not been attached to any status after a while, you would want to run this from a periodic cronjob
- `rake mastodon:push:clear` unsubscribes from PuSH notifications for remote users that have no local followers. You may not want to actually do that, to keep a fuller footprint of the fediverse or in case your users will soon re-follow
- `rake mastodon:push:refresh` re-subscribes PuSH for expiring remote users, this should be run periodically from a cronjob and quite often as the expiration time depends on the particular hub of the remote user
- `rake mastodon:feeds:clear_all` removes all timelines, which forces them to be re-built on the fly next time a user tries to fetch their home/mentions timeline. Only for troubleshooting
- `rake mastodon:feeds:clear` removes timelines of users who haven't signed in lately, which allows to save RAM and improve message distribution. This is required to be run periodically so that when they login again the regeneration process will trigger

Running any of these tasks via docker-compose would look like this:

    docker-compose run --rm web rake mastodon:media:clear

### Updating

This approach makes updating to the latest version a real breeze.

1. `git pull` to download updates from the repository
2. `docker-compose build` to compile the Docker image out of the changed source files
3. (optional) `docker-compose run --rm web rails db:migrate` to perform database migrations. Does nothing if your database is up to date
4. (optional) `docker-compose run --rm web rails assets:precompile` to compile new JS and CSS assets
5. `docker-compose up -d` to re-create (restart) containers and pick up the changes

## Deployment without Docker

Docker is great for quickly trying out software, but it has its drawbacks too. If you prefer to run Mastodon without using Docker, refer to the [production guide](https://github.com/heropunch/mastodon-ce/wiki/Production-guide) for examples, configuration and instructions.

## Deployment on Scalingo

[![Deploy on Scalingo](https://cdn.scalingo.com/deploy/button.svg)](https://my.scalingo.com/deploy?source=https://github.com/heropunch/mastodon-ce#master)

[You can view a guide for deployment on Scalingo here.](https://github.com/heropunch/mastodon-ce/wiki/Scalingo-guide)

## Deployment on Heroku (experimental)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Mastodon can run on [Heroku](https://heroku.com), but it gets expensive and impractical due to how Heroku prices resource usage. [You can view a guide for deployment on Heroku here](https://github.com/heropunch/mastodon-ce/wiki/Heroku-guide), but you have been warned.

## Development with Vagrant

A quick way to get a development environment up and running is with Vagrant. You will need recent versions of [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed.

[You can find the guide for setting up a Vagrant development environment here.](https://github.com/heropunch/mastodon-ce/wiki/Vagrant-guide)

## Contributing

You can open issues for bugs you've found or features you think are missing. You can also submit pull requests to this repository. [Here are the guidelines for code contributions](CONTRIBUTING.md)

**IRC channel**: #mastodon on irc.freenode.net

## Extra credits

- The [Emoji One](https://github.com/Ranks/emojione) pack has been used for the emojis
- The error page image courtesy of [Dopatwo](https://www.youtube.com/user/dopatwo)

![Mastodon error image](https://mastodon.social/oops.png)
