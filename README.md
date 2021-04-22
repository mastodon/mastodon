# Hometown: a Mastodon fork

<img width="300" src="https://live.staticflickr.com/7005/26777339042_b32cef4e1f_b.jpg" alt="photo of a village of stone huts nestled in a lush green valley">

Photo by [Joana Mujollari](https://www.flickr.com/photos/141654969@N04/26777339042/), CC0 / Public Domain.

Mastodon is a **free, open-source social network server** based on ActivityPub. This is *not* the official version of Mastodon; this is a separate version (i.e. a fork) maintained by [Darius Kazemi](https://friend.camp/@darius). For more information on Mastodon, you can see the [official website](https://joinmastodon.org) and the [upstream repo](https://github.com/tootsuite/mastodon).

__Hometown__ is a light weight fork of Mastodon. This fork is based on the principle of: minimum code change for maximum user experience change. By our best understanding, our major changes are not wanted by the Mastodon project, hence maintaining this fork instead of trying to commit the changes to Mastodon.

Please [check out our wiki](https://github.com/hometown-fork/hometown/wiki) for a list of Hometown-exclusive features. Some but not all of these are covered in this document.

You can also find [a list of running Hometown instances](https://github.com/hometown-fork/hometown/wiki/Hometown-servers), don't hesitate to open an issue to add yours!

## Support this project

Please consider [supporting Hometown by pledging to my Patreon](https://www.patreon.com/tinysubversions), which supports all my open source projects including this one!

Of course this project couldn't exist without Mastodon so maybe [support the Mastodon project Patreon](https://www.patreon.com/mastodon) too.

## Migrating from Mastodon to Hometown

Please see [this article in the wiki](https://github.com/hometown-fork/hometown/wiki/Initial-migration) for directions on migration from Mastodon to Hometown.

## Local only posting

Mastodon right now is designed to get your messages out to the entire fediverse. This is great, but there is a huge need for more private communities. And in a federated network I think it makes the most sense for your home server to be that community (hence "Hometown").

**In the context of Hometown, local only posting is a per-post security option that lets you set whether that post can federate out to other servers or not.**

I've been running Friend Camp, a Mastodon fork with local only posting, for about a year. Being able to have conversations with people on your server that don't federate is a hugely liberating thing. It allows inside jokes to develop. It allows people the freedom to complain about things that they wouldn't necessarily feel comfortable leaving a trusted server (cops, employers, etc). It also lets us do things like have a server-wide movie night where we flood the local timeline with posts about the movie, and it doesn't pollute the rest of the Fediverse.

This feature is based on [the work of Renato Lond](https://github.com/tootsuite/mastodon/pull/8427), which is itself based on a feature in the [Mastodon Glitch Edition](https://glitch-soc.github.io/docs/) fork.

## Reading more content types

Mastodon is microblogging software, meant for Twitter-style shortform posting.

Hometown is microblogging for _writing_, but its goal is to accept many content types for _reading_. So while I don't plan to let Hometown users publish massive blog posts, I would like your Hometown instance to be your one-stop shop for viewing all sorts of things on the Fediverse.

For Hometown this means if you subscribe to a service that sends out `Article` objects over ActivityPub (such as a blog on [Write As](https://write.as)), then those full articles render in your home timeline, behind a cut for length. Also, Hometown will render a variety of rich text like _italic_ and **bold**.

Click on this GIF for a brief video demo:

<img src="http://tinysubversions.com/pics/hometown-article.gif" alt="Video demo of someone clicking 'read article' on an incoming article post, which then renders a full article.">

This is based on rich text work by [Thibaut Girka](https://sitedethib.com), and my own work on `Article` support.

### It's more than just reading more stuff

Reading more content types also helps make the fediverse better. ActivityPub supports all kinds of content, but most ActivityPub servers shoehorn all their content into `Note` because that's the type that Mastodon treats as first-class. This has important implications for the fediverse and also on your day to do user experience.

Take the "quote tweet" debate for example.

Twitter has a feature called "quote tweeting" that lets you embed what someone else tweets, with your own comment right next to it. It's really useful for provide commentary in context, like this, where I point people to a sale and they can read both my comment on the sale and the original tweet about the sale in one post:

<img width="600" src="http://tinysubversions.com/pics/quote-tweet.png" alt="An example of a quote tweet from Twitter.">

But it's also open to abuse with people quote-tweeting things they disagree with to encourage a pile-on from their followers. There's been a lot of debate among Mastodon users as to whether the good of this feature outweighs the bad. So far, Mastodon has avoided implementing quoting.

What does this have to do with content types? Well, if we support an `Article` content type and a `Note` content type, we can support quoting for an `Article` but not for a `Note`. In practice this means that you can quote blog posts and news articles, but you can't quote a quick personal microblog note.

> Hometown doesn't support quoting articles yet... but it will.

## Better list management

If Hometown is going to be a universal reader, you're going to need better control over organizing your feeds than mainline Mastodon provides.

I've introduced a new kind of [exclusive list](https://github.com/hometown-fork/hometown/wiki/Exclusive-lists). In vanilla Mastodon, if you add an account to your "friends I like" list, posts from people on that list appear on that list. But they also appear on your home timeline, and maybe you don't want that! You'd rather treat your "friends I like" list as your "real" home timeline, and then check your home timeline when you're bored. Check out [more details about exclusive lists on the wiki](https://github.com/hometown-fork/hometown/wiki/Exclusive-lists).

## Better accessibility defaults

Look, right now this pretty much just means that we underline hyperlinks by default. I'm of course open to implementing other obviously beneficial accessibilty defaults that Mastodon itself doesn't implement.

## Hometown is still 99.999% Mastodon

I don't intend to stray very far from mainline Mastodon with this fork. If you want something that provides a ton of new features and widgets and stuff, the [Mastodon Glitch Edition](https://glitch-soc.github.io/docs/) fork is a wondrous kitchen sink of major and minor tweaks.

Part of why I don't want to stray far from mainline Mastodon is that this project is going to be just me for the foreseeable future, and I'd like to keep it up to date with new Mastodon versions as easily as possible. The less code I change from Mastodon, the easier that is. Hence the principle of "minimum code change for maximum user experience change."

## Versioning

Hometown uses [semantic versioning](https://semver.org) and follows a versioning convention like `v1.0.0+2.9.3`. The 1.0.0 part is the actual Hometown version number, and then the 2.9.3 after the + sign is what's known in semantic versioning as "build metadata". It just means that a particular release is synchronized with Mastodon version 2.9.3, so for example an upgrade from `v1.0.0+2.9.2` to `v1.0.0+2.9.3` would upgrade _Mastodon_ but not provide any new Hometown features or fixes.

## Contributing to Hometown

Setting up your Hometown development environment is [exactly like setting up your Mastodon development environment](https://docs.joinmastodon.org/dev/overview/). Pull requests should be made to the `hometown-dev` branch, which is our default branch in Github.

## License

Copyright (C) 2016-2020 Eugen Rochko & other Mastodon contributors (see [AUTHORS.md](AUTHORS.md))

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
