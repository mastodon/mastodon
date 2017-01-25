Protocol extensions
===================

Some functionality in Mastodon required some additions to the protocols to enable seamless federation of those features:

1. ActivityStreams was lacking verbs for block/unblock. Mastodon creates Salmon slaps for block and unblock events, which are not part of a user's public feed, but are nevertheless delivered to the target user. The intent of these Salmon slaps is not to notify the target user, but to notify the target user's server, so that it can perform any number of UX-related tasks such as removing the target user as a follower of the blocker, and/or displaying a message to the target user such as "You can't follow this person because you've been blocked"

  The Salmon slaps have the exact same structure as standard follow/unfollow slaps, the verbs are namespaced:

  - `http://mastodon.social/schema/1.0/block`
  - `http://mastodon.social/schema/1.0/unblock`

2. Statuses can be marked as containing sensitive (or not safe for work) media. This is symbolized by a `<category term="nsfw" />` on the Atom entry

3. Statuses can have a content warning (used e.g. for warning about spoilers in the text). It is stored in the `warning` attribute on the `<content />` tag of the Atom entry

4. Statuses that are intended to be listed publicly on e.g. "whole known network" or "public" timelines contain a `<link rel="mentioned" href="http://activityschema.org/collection/public" ostatus:object-type="http://activitystrea.ms/schema/1.0/collection"/>`. Conversely, statuses which do not contain that, are intended to be low key, unlisted
