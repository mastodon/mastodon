![Mastodon](https://i.imgur.com/NhZc40l.png)
========

[![GitHub release](https://img.shields.io/github/release/tootsuite/mastodon.svg)][releases]
[![Build Status](https://img.shields.io/circleci/project/github/tootsuite/mastodon.svg)][circleci]
[![Code Climate](https://img.shields.io/codeclimate/maintainability/tootsuite/mastodon.svg)][code_climate]
[![Translation status](https://weblate.joinmastodon.org/widgets/mastodon/-/svg-badge.svg)][weblate]
[![Docker Pulls](https://img.shields.io/docker/pulls/tootsuite/mastodon.svg)][docker]
[![Backers on Open Collective](https://opencollective.com/mastodon/backers/badge.svg)](#backers) 
[![Sponsors on Open Collective](https://opencollective.com/mastodon/sponsors/badge.svg)](#sponsors) 

[releases]: https://github.com/tootsuite/mastodon/releases
[circleci]: https://circleci.com/gh/tootsuite/mastodon
[code_climate]: https://codeclimate.com/github/tootsuite/mastodon
[weblate]: https://weblate.joinmastodon.org/engage/mastodon/
[docker]: https://hub.docker.com/r/tootsuite/mastodon/

Mastodon is a **free, open-source social network server** based on ActivityPub. Follow friends and discover new ones. Publish anything you want: links, pictures, text, video. All servers of Mastodon are interoperable as a federated network, i.e. users on one server can seamlessly communicate with users from another one. This includes non-Mastodon software that also implements ActivityPub!

Click below to **learn more** in a video:

[![Screenshot](https://blog.joinmastodon.org/2018/06/why-activitypub-is-the-future/ezgif-2-60f1b00403.gif)][youtube_demo]

[youtube_demo]: https://www.youtube.com/watch?v=IPSbNdBmWKE

## Navigation 

- [Project homepage 🐘](https://joinmastodon.org)
- [Support the development via Patreon][patreon]
- [View sponsors](https://joinmastodon.org/sponsors)
- [Blog](https://blog.joinmastodon.org)
- [Documentation](https://docs.joinmastodon.org)
- [Browse Mastodon servers](https://joinmastodon.org/#getting-started)
- [Browse Mastodon apps](https://joinmastodon.org/apps)

[patreon]: https://www.patreon.com/mastodon

## Features

<img src="https://docs.joinmastodon.org/elephant.svg" align="right" width="30%" />

**No vendor lock-in: Fully interoperable with any conforming platform**

It doesn't have to be Mastodon, whatever implements ActivityPub is part of the social network! [Learn more](https://blog.joinmastodon.org/2018/06/why-activitypub-is-the-future/)

**Real-time, chronological timeline updates**

See the updates of people you're following appear in real-time in the UI via WebSockets. There's a firehose view as well!

**Media attachments like images and short videos**

Upload and view images and WebM/MP4 videos attached to the updates. Videos with no audio track are treated like GIFs; normal videos are looped - like vines!

**Safety and moderation tools**

Private posts, locked accounts, phrase filtering, muting, blocking and all sorts of other features, along with a reporting and moderation system. [Learn more](https://blog.joinmastodon.org/2018/07/cage-the-mastodon/)

**OAuth2 and a straightforward REST API**

Mastodon acts as an OAuth2 provider so 3rd party apps can use the REST and Streaming APIs, resulting in a rich app ecosystem with a lot of choice!

## Deployment

**Tech stack:**

- **Ruby on Rails** powers the REST API and other web pages
- **React.js** and Redux are used for the dynamic parts of the interface
- **Node.js** powers the streaming API

**Requirements:**

- **PostgreSQL** 9.5+
- **Redis**
- **Ruby** 2.4+
- **Node.js** 8+

The repository includes deployment configurations for **Docker and docker-compose**, but also a few specific platforms like **Heroku**, **Scalingo**, and **Nanobox**. The [**stand-alone** installation guide](https://docs.joinmastodon.org/administration/installation/) is available in the documentation.

A **Vagrant** configuration is included for development purposes.

## Contributing

Mastodon is **free, open source software** licensed under **AGPLv3**.

You can open issues for bugs you've found or features you think are missing. You can also submit pull requests to this repository, or submit translations using Weblate. To get started, take a look at [CONTRIBUTING.md](CONTRIBUTING.md)

**IRC channel**: #mastodon on irc.freenode.net

## Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/tootsuite/mastodon/graphs/contributors"><img src="https://opencollective.com/mastodon/contributors.svg?width=890&button=false" /></a>


## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/mastodon#backer)]

<a href="https://opencollective.com/mastodon#backers" target="_blank"><img src="https://opencollective.com/mastodon/backers.svg?width=890"></a>


## Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/mastodon#sponsor)]

<a href="https://opencollective.com/mastodon/sponsor/0/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/1/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/2/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/3/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/4/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/5/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/6/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/7/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/8/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/mastodon/sponsor/9/website" target="_blank"><img src="https://opencollective.com/mastodon/sponsor/9/avatar.svg"></a>



## License

Copyright (C) 2016-2018 Eugen Rochko & other Mastodon contributors (see [AUTHORS.md](AUTHORS.md))

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
