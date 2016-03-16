Mastodon
========

Mastodon is a federated microblogging engine. An alternative implementation of the GNU Social project. Based on ActivityStreams, Webfinger, PubsubHubbub and Salmon.

**Current status of the project is early development. Documentation &co will be added later**

## Status

- GNU Social users can follow Mastodon users
- Mastodon users can follow GNU Social users
- Retweets, favourites, mentions, replies work in both directions
- Public pages for profiles and single statuses
- Sign up, login, forgotten passwords and changing password
- Mentions and URLs converted to links in statuses
- REST API, including home and mention timelines
- OAuth2 provider system for the API
- Upload header image for profile page
- Deleting statuses, deletion propagation

Missing:

- Media attachments (photos, videos)
- Streaming API
- Blocking users, blocking remote instances

## Configuration

- `LOCAL_DOMAIN` should be the domain/hostname of your instance. This is **absolutely required** as it is used for generating unique IDs for everything federation-related
- `LOCAL_HTTPS` set it to `true` if HTTPS works on your website. This is used to generate canonical URLs, which is also important when generating and parsing federation-related IDs
- `HUB_URL` should be the URL of the PubsubHubbub service that your instance is going to use. By default it is the open service of Superfeedr

Consult the example configuration file, `.env.production.sample` for the full list.

## Requirements

- PostgreSQL
- Redis

## Running with Docker and Docker-Compose

The project now includes a `Dockerfile` and a `docker-compose.yml`. You need to turn `.env.production.sample` into `.env.production` with all the variables set before you can:

    docker-compose build

And finally

    docker-compose up

As usual, the first thing you would need to do would be to run migrations:

    docker-compose run web rake db:migrate

And since the instance running in the container will be running in production mode, you need to pre-compile assets:

    docker-compose run web rake assets:precompile

The container has two volumes, for the assets and for user uploads. The default docker-compose.yml maps them to the repository's `public/assets` and `public/system` directories, you may wish to put them somewhere else. Likewise, the PostgreSQL and Redis images have data containers that you may wish to map somewhere where you know how to find them and back them up.
