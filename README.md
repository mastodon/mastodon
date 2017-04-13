Mastodon
========

[![Build Status](http://img.shields.io/travis/tootsuite/mastodon.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/tootsuite/mastodon.svg)][code_climate]

[travis]: https://travis-ci.org/tootsuite/mastodon
[code_climate]: https://codeclimate.com/github/tootsuite/mastodon

Mastodon is a free, open-source social network server. A decentralized solution to commercial platforms, it avoids the risks of a single company monopolizing your communication. Anyone can run Mastodon and participate in the social network seamlessly.

An alternative implementation of the GNU social project. Based on [ActivityStreams](https://en.wikipedia.org/wiki/Activity_Streams_(format)), [Webfinger](https://en.wikipedia.org/wiki/WebFinger), [PubsubHubbub](https://en.wikipedia.org/wiki/PubSubHubbub) and [Salmon](https://en.wikipedia.org/wiki/Salmon_(protocol)).

Click on the screenshot to watch a demo of the UI:

[![Screenshot](http://puu.sh/vMcvm/290f459dd4.jpg)][youtube_demo]

[youtube_demo]: https://www.youtube.com/watch?v=YO1jQ8_rAMU

The project focus is a clean REST API and a good user interface. Ruby on Rails is used for the back-end, while React.js and Redux are used for the dynamic front-end. A static front-end for public resources (profiles and statuses) is also provided.

If you would like, you can [support the development of this project on Patreon][patreon]. Alternatively, you can donate to this BTC address: `17j2g7vpgHhLuXhN4bueZFCvdxxieyRVWd`

[patreon]: https://www.patreon.com/user?u=619786

## Resources

- [List of Mastodon instances](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/List-of-Mastodon-instances.md)
- [Use this tool to find Twitter friends on Mastodon](https://mastodon-bridge.herokuapp.com)
- [API overview](https://github.com/tootsuite/documentation/blob/master/Using-the-API/API.md)
- [Frequently Asked Questions](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md)
- [List of apps](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md)

## Features

- **Fully interoperable with GNU social and any OStatus platform**
  Whatever implements Atom feeds, ActivityStreams, Salmon, PubSubHubbub and Webfinger is part of the network
- **Real-time timeline updates**
  See the updates of people you're following appear in real-time in the UI via WebSockets
- **Federated thread resolving**
  If someone you follow replies to a user unknown to the server, the server fetches the full thread so you can view it without leaving the UI
- **Media attachments like images and WebM**
  Upload and view images and WebM videos attached to the updates
- **OAuth2 and a straightforward REST API**
  Mastodon acts as an OAuth2 provider so 3rd party apps can use the API, which is RESTful and simple
- **Background processing for long-running tasks**
  Mastodon tries to be as fast and responsive as possible, so all long-running tasks that can be delegated to background processing, are
- **Deployable via Docker**
  You don't need to mess with dependencies and configuration if you want to try Mastodon, if you have Docker and Docker Compose the deployment is extremely easy
  
## Development

Please follow the [development guide](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Development-guide.md) from the documentation repository.

## Deployment

There are guides in the documentation repository for [deploying on various platforms](https://github.com/tootsuite/documentation#running-mastodon).

## Development _and_ Deployment with Nanobox

Nanobox lets you develop apps in an environment identical to (or at least nearly so) the environment it will deploy to. It supports deploying to [multiple cloud providers](https://github.com/nanobox-io/nanobox-provider-integrations), so you have lots of choices about where your instance will run.

### Development

You will need [Nanobox](https://nanobox.io/) installed, along with Docker if you're on Linux (Windows and macOS can use Docker Native, but the bundled VirtualBox is more performant while the Docker team works out some filesystem speed issues). The process is simple - clone the repo, set a few variables with `nanobox evar add local <VARIABLE>=<value>` (see below on which ones need to be set), and run `nanobox run` to get to a console. It will take some time to build your local dev environment, but once it's done, simply set up the DB using `bundle exec rake db:setup` as normal, and you're off.

### Deployment

To deploy, you'll need to create an application in [your Nanobox dashboard](https://dashboard.nanobox.io/apps) (which requires a [Nanobox.io](https://dashboard.nanobox.io/users/register) account), clone the repo (if you haven't already set up the local development environment), set the new app as your deploy target with `nanobox remote add <app-name>`, set up the variables below using either `nanobox evar add <VARIABLE>=<value>` or the app's dashboard, and then run `nanobox deploy`.

### Environment Variables

Mastodon will not run under Nanobox without first setting a handful of required variables:

- `RAILS_ENV` - set this to `production`, unless you're in development (this value is treated as `development` if it isn't set)
- `PAPERCLIP_SECRET` - set to a random string of characters; you can use `nanobox run bundle exec rake secret` to generate one
- `SECRET_KEY_BASE` - set to a random string of characters; you can use `nanobox run bundle exec rake secret` to generate one
- `OTP_SECRET` - set to a random string of characters; you can use `nanobox run bundle exec rake secret` to generate one

You can also set some optional values, which should override the defaults in `.env.nanobox`:

- `LOCAL_DOMAIN` - set to whatever domain you want to use as your instance name; defaults to `<app-name>.nanoapp.io`, which is provided by Nanobox for use as a CNAME target
- `SINGLE_USER_MODE` - set this to `true` if you want to run a single-user instance; default is unset

And really any other setting you'd normally put into `.env.production`, such as:

- `SMTP_SERVER` - your SMTP server's address; default is blank
- `SMTP_PORT` - your SMTP server's port number; defaults to 587, which is almost always correct
- `SMTP_LOGIN` - your SMTP username; default is blank
- `SMTP_PASSWORD` - your SMTP password; default is blank
- `SMTP_FROM_ADDRESS` - this instance's emails will come from this address; defaults to `notifications@<LOCAL_DOMAIN>`
- etc...

## Contributing

You can open issues for bugs you've found or features you think are missing. You can also submit pull requests to this repository. [Here are the guidelines for code contributions](CONTRIBUTING.md)

**IRC channel**: #mastodon on irc.freenode.net

## Extra credits

- The [Emoji One](https://github.com/Ranks/emojione) pack has been used for the emojis
- The error page image courtesy of [Dopatwo](https://www.youtube.com/user/dopatwo)

![Mastodon error image](https://mastodon.social/oops.png)
