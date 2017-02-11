Protocol extensions
===================

Some functionality in Mastodon required some additions to the protocols to enable seamless federation of those features:

### Federation of blocks/unblocks

ActivityStreams was lacking verbs for block/unblock. Mastodon creates Salmon slaps for block and unblock events, which are not part of a user's public feed, but are nevertheless delivered to the target user. The intent of these Salmon slaps is not to notify the target user, but to notify the target user's server, so that it can perform any number of UX-related tasks such as removing the target user as a follower of the blocker, and/or displaying a message to the target user such as "You can't follow this person because you've been blocked"

The Salmon slaps have the exact same structure as standard follow/unfollow slaps, the verbs are namespaced:

- `http://mastodon.social/schema/1.0/block`
- `http://mastodon.social/schema/1.0/unblock`

### Federation of sensitive material

Statuses can be marked as containing sensitive (or not safe for work) media. This is symbolized by a `<category term="nsfw" />` on the Atom entry

### Federation of privacy features
#### Locked accounts and status privacy levels

Accounts and statuses have an access "scope":

Accounts can be "private" or "public". The former requires a follow request to be approved before a follow relationship can be established, the latter can be followed directly.

Statuses can be "private", "unlisted" or "public". Private must only be shown to the followers of the account or people mentioned in the status; public can be displayed publicly. Unlisted statuses may be displayed publicly but preferably outside of any spotlights e.g. "whole known network" or "public" timelines.

Namespace of the scope element is `http://mastodon.social/schema/1.0`. Example:

```xml
<entry>
  <!-- ... -->
  <author>
    <!-- ... -->
    <mastodon:scope>private</mastodon:scope>
  </author>
  <!-- ... -->
  <mastodon:scope>private</mastodon:scope>
</entry>
```

#### Follow requests

Mastodon uses the following Salmon slaps to signal a follow request, a follow request authorization and a follow request rejection:

- `http://activitystrea.ms/schema/1.0/request-friend`
- `http://activitystrea.ms/schema/1.0/authorize`
- `http://activitystrea.ms/schema/1.0/reject`

The activity object of the request-friend slap is the account in question. The activity object of the authorize and reject slaps is the original request-friend activity. Request-friend slap is sent to the locked account, when the end-user of that account decides, the authorize/reject decision slap is sent back to the requester.

#### PuSH amendment

Mastodon will only deliver PuSH payloads to callback URLs the domain of which matches at least one follower of the account in question. That means anonymous manual/subscriptions are not possible.

Private statuses do not appear on Atom feeds, but do get delivered in PuSH payloads to the domains of approved followers.
