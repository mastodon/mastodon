Development guide
=================

**Don't use Docker to do development**. It's a quick way to get Mastodon running in production, it's **really really inconvenient for development**. Normally in Rails development environment you get hot reloading of backend code and on-the-fly compilation of assets like JS and CSS, but you lose those benefits by compiling a Docker image. If you want to contribute to Mastodon, it is worth it to simply set up a proper development environment.

In fact, all you need is described in the [production guide](Production-guide.md), **with the following exceptions**. You **don't** need:

- Nginx
- SystemD
- An `.env.production` file. If you need to set any environment variables, you can use an `.env` file
- To prefix any commands with `RAILS_ENV=production` since the default environment is "development" anyway
- Any cronjobs

The command to install project dependencies does not require any flags, i.e. simply

    bundle install

By default the development environment wants to connect to a `mastodon_development` database on localhost using your user/ident to login to Postgres (i.e. not a md5 password)

You can run Mastodon with:

    rails s

And open `http://localhost:3000` in your browser. Background jobs run inline (aka synchronously) in the development environment, so you don't need to run a Sidekiq process.

You can run tests with:

    rspec

You can check localization status with:

    i18n-tasks health

You can check code quality with:

    rubocop

## Development tips

You can use a localhost->world tunneling service like ngrok if you want to test federation, **however** that should not be your primary mode of operation. If you want to have a permanently federating server, set up a proper instance on a VPS with a domain name, and simply keep it up to date with your own fork of the project while doing development on localhost.

Ngrok and similar services give you a random domain on each start up. This is good enough to test how the code you're working on handles real-world situations. But as soon as your domain changes, for everybody else concerned you're a different instance than before.

Generally, federation bits are tricky to work on for exactly this reason - it's hard to test. And when you are testing with a disposable instance you are polluting the databases of the real servers you're testing against, usually not a big deal but can be annoying. The way I have handled this so far was thus: I have used ngrok for one session, and recorded the exchanges from its web interface to create fixtures and test suites. From then on I've been working with those rather than live servers.

I advise to study the existing code and the RFCs before trying to implement any federation-related changes. It's not *that* difficult, but I think "here be dragons" applies because it's easy to break.

If your development environment is running remotely (e.g. on a VPS or virtual machine), setting the `REMOTE_DEV` environment variable will swap your instance from using "letter opener" (which launches a local browser) to "letter opener web" (which collects emails and displays them at /letter_opener ).