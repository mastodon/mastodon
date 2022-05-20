**Mastodon fork for <https://littlefo.rest>**

[![Maintainability](https://api.codeclimate.com/v1/badges/1644d6adc0f9d1bbae6a/maintainability)](https://codeclimate.com/github/mashirozx/mastodon/maintainability)
[![DockerHub](https://img.shields.io/docker/pulls/mashirozx/mastodon.svg?logo=docker&color=2496ED)](https://hub.docker.com/r/mashirozx/mastodon)
[![Build Prod Image](https://github.com/mashirozx/mastodon/actions/workflows/docker-build-main.yml/badge.svg)](https://github.com/mashirozx/mastodon/actions/workflows/docker-build-main.yml)
[![Build Dev Image](https://github.com/mashirozx/mastodon/actions/workflows/docker-build-dev.yml/badge.svg)](https://github.com/mashirozx/mastodon/actions/workflows/docker-build-dev.yml)
[![Build Status](https://drone.2heng.xin/api/badges/mashirozx/mastodon/status.svg?ref=refs/heads/main)](https://drone.2heng.xin/mashirozx/mastodon)

[//]: # ([![DeepSource]&#40;https://deepsource.io/gh/mashirozx/mastodon.svg/?label=active+issues&#41;]&#40;https://deepsource.io/gh/mashirozx/mastodon/?ref=repository-badge&#41;)

[//]: # ([![CircleCI]&#40;https://circleci.com/gh/mashirozx/mastodon.svg?style=svg&#41;]&#40;https://circleci.com/gh/tootsuite/mastodon&#41;)

## Highlighted Features

- Custom toot max character size with environment variable (see `.env.production.sample`).
- Full Markdown support, demo [here](https://littlefo.rest/@mashiro/104670343090096501).
- Media Sudoku (media attachments upper limit increases to 9), demo [here](https://littlefo.rest/@mashiro/105426865955962437).
- Local-only toot support.
- Quotation support like twitter (QT but not RT).
- An easy-using translation button to translate toot in any language to your mother tongue with Google Translate (see specifications bellow).
- A bunch of awesome themes.
- Enhanced Elasticsearch experience with Chinese words segmentation support (see specifications bellow).
- Login with GitHub and GitLab OAuth 2, try it now [here](https://littlefo.rest)!

## Specifications

This is a rebase fork of `tootsuite/mastodon`, all local changes are rebased on the top. To pull the latest commits of this repo, use `git reset --hard origin/master` instead of `git pull`.

To enable the new custom features, please add the necessary configurations first according to the file end of `.env.production.sample`.

The translation backend is [here](https://github.com/mashirozx/google-translate-server) and the Docker image [here](https://hub.docker.com/r/mashirozx/google-translate-server), see `docker-compose.yml`.

**This project added the Chinese words segmentation support in Elasticsearch, please use this [Elasticsearch image](https://github.com/mashirozx/elasticsearch-cnplugin). Using the original version of Elasticsearch Engine may goes into error.**

## Finally

Thanks for the support of [JetBrains](https://jb.gg/OpenSourceSupport).

[<img width="100" src="https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.svg" alt="JetBrains Logo (Main) logo.">](https://jb.gg/OpenSourceSupport)

***
*Below is the original README*
***

![Mastodon](https://i.imgur.com/NhZc40l.png)
========

[![GitHub release](https://img.shields.io/github/release/mastodon/mastodon.svg)][releases]
[![Build Status](https://img.shields.io/circleci/project/github/mastodon/mastodon.svg)][circleci]
[![Code Climate](https://img.shields.io/codeclimate/maintainability/mastodon/mastodon.svg)][code_climate]
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/mastodon/localized.svg)][crowdin]
[![Docker Pulls](https://img.shields.io/docker/pulls/tootsuite/mastodon.svg)][docker]

[releases]: https://github.com/mastodon/mastodon/releases
[circleci]: https://circleci.com/gh/mastodon/mastodon
[code_climate]: https://codeclimate.com/github/mastodon/mastodon
[crowdin]: https://crowdin.com/project/mastodon
[docker]: https://hub.docker.com/r/tootsuite/mastodon/

Mastodon is a **free, open-source social network server** based on ActivityPub where users can follow friends and discover new ones. On Mastodon, users can publish anything they want: links, pictures, text, video. All Mastodon servers are interoperable as a federated network (users on one server can seamlessly communicate with users from another one, including non-Mastodon software that implements ActivityPub)!

Click below to **learn more** in a video:

[![Screenshot](https://blog.joinmastodon.org/2018/06/why-activitypub-is-the-future/ezgif-2-60f1b00403.gif)][youtube_demo]

[youtube_demo]: https://www.youtube.com/watch?v=IPSbNdBmWKE

## Navigation

- [Project homepage 🐘](https://joinmastodon.org)
- [Support the development via Patreon][patreon]
- [View sponsors](https://joinmastodon.org/sponsors)
- [Blog](https://blog.joinmastodon.org)
- [Documentation](https://docs.joinmastodon.org)
- [Browse Mastodon servers](https://joinmastodon.org/communities)
- [Browse Mastodon apps](https://joinmastodon.org/apps)

[patreon]: https://www.patreon.com/mastodon

## Features

<img src="https://docs.joinmastodon.org/elephant.svg" align="right" width="30%" />

### No vendor lock-in: Fully interoperable with any conforming platform

It doesn't have to be Mastodon; whatever implements ActivityPub is part of the social network! [Learn more](https://blog.joinmastodon.org/2018/06/why-activitypub-is-the-future/)

### Real-time, chronological timeline updates

Updates of people you're following appear in real-time in the UI via WebSockets. There's a firehose view as well!

### Media attachments like images and short videos

Upload and view images and WebM/MP4 videos attached to the updates. Videos with no audio track are treated like GIFs; normal videos loop continuously!

### Safety and moderation tools

Mastodon includes private posts, locked accounts, phrase filtering, muting, blocking and all sorts of other features, along with a reporting and moderation system. [Learn more](https://blog.joinmastodon.org/2018/07/cage-the-mastodon/)

### OAuth2 and a straightforward REST API

Mastodon acts as an OAuth2 provider, so 3rd party apps can use the REST and Streaming APIs. This results in a rich app ecosystem with a lot of choices!

## Deployment

### Tech stack:

- **Ruby on Rails** powers the REST API and other web pages
- **React.js** and Redux are used for the dynamic parts of the interface
- **Node.js** powers the streaming API

### Requirements:

- **PostgreSQL** 9.5+
- **Redis** 4+
- **Ruby** 2.5+
- **Node.js** 12+

The repository includes deployment configurations for **Docker and docker-compose** as well as specific platforms like **Heroku**, **Scalingo**, and **Nanobox**. The [**standalone** installation guide](https://docs.joinmastodon.org/admin/install/) is available in the documentation.

A **Vagrant** configuration is included for development purposes. To use it, complete following steps:

- Install Vagrant and Virtualbox
- Install the `vagrant-hostsupdater` plugin: `vagrant plugin install vagrant-hostsupdater`
- Run `vagrant up`
- Run `vagrant ssh -c "cd /vagrant && foreman start"`
- Open `http://mastodon.local` in your browser

## Contributing

Mastodon is **free, open-source software** licensed under **AGPLv3**.

You can open issues for bugs you've found or features you think are missing. You can also submit pull requests to this repository or submit translations using Crowdin. To get started, take a look at [CONTRIBUTING.md](CONTRIBUTING.md). If your contributions are accepted into Mastodon, you can request to be paid through [our OpenCollective](https://opencollective.com/mastodon).

**IRC channel**: #mastodon on irc.libera.chat

## License

Copyright (C) 2016-2022 Eugen Rochko & other Mastodon contributors (see [AUTHORS.md](AUTHORS.md))

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
