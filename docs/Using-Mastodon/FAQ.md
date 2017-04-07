Frequently Asked Questions
==========================

#### What is a Mastodon?

A prehistoric animal, predecessor of the mammoth.

#### Why the name Mastodon?

There's a progressive metal band with the same name that I'm a fan of that brought the animal to my attention. I thought it's a pretty cool name/animal.

#### How exactly is it decentralized?

There are different ways in which something can be decentralized; in this case, Mastodon is the "federated" kind. Think e-mail, not BitTorrent. There are different servers (instances), users have an account on one of them, but can interact and follow each other regardless of where their account is.

#### Technically, how does the federation work?

We are using the OStatus suite of protocols:

1. Webfinger for user-on-domain lookup
2. Atom feeds with ActivityStreams, Portable Contacts, Threads extensions for the actual content
3. PubSubHubbub for subscribing to Atom feeds
4. Salmon for delivering certain items from the Atom feeds to interested parties such as the mentioned user, author of the status being replied to, person being followed, etc

#### What is mastodon.social?

The "flagship" instance of Mastodon, aka the server I run myself with the latest code. It's not supposed to be the only instance in the end.

#### What else is part of the federated network?

Let's call it the "fediverse". It has existed for a longer while, populated by GNU social servers, Friendica, Hubzilla, Diaspora etc. Not every one of those servers is fully compatible with every other. Mastodon strives to be fully standards-compliant and compatibility with GNU social is higher in priority than the others.

#### I tried logging into a GNU social client app with Mastodon and it didn't work, why?

While Mastodon is compatible with GNU social in terms of server to server communication, the client to server API (aka how you access Mastodon) is different. Therefore, client apps that were made for specifically GNU social will not work with Mastodon. The reason for this is half technical, half ideological.

Because Mastodon has been created from a blank slate, it is much simpler to have the API mirror internal structures as closely as possible, rather than build an emulation layer. Secondly, the GNU social client API is actually a half-way implementation of the legacy Twitter API - that's the reason why it works with some older Twitter client apps. However, many of those apps are not maintained anymore, the GNU social API does not actually keep up with the real Twitter API and never fully implemented all its features; at the same time, the Twitter API was never meant for a federated service and so obscures some of the functionality.


#### How is Mastodon funded?

Development of Mastodon and hosting of mastodon.social is funded through my [Patreon (also BTC/PayPal donations)](https://www.patreon.com/user?u=619786). Beyond that, I am not interested in VC funding, monetizing, advertising, or anything of that sort. I could offer setup/maintenance services on demand.

The software is free and open source and communities should host their own servers if they can, that way the costs are more or less distributed. Obviously it'd be hard for me to pay the bills if literally everyone decided to use the mastodon.social instance only.
