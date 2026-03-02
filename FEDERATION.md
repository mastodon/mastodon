# Federation

## Supported federation protocols and standards

- [ActivityPub](https://www.w3.org/TR/activitypub/) (Server-to-Server)
- [WebFinger](https://webfinger.net/)
- [Http Signatures](https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures)
- [NodeInfo](https://nodeinfo.diaspora.software/)

## Supported FEPs

- [FEP-67ff: FEDERATION.md](https://codeberg.org/fediverse/fep/src/branch/main/fep/67ff/fep-67ff.md)
- [FEP-f1d5: NodeInfo in Fediverse Software](https://codeberg.org/fediverse/fep/src/branch/main/fep/f1d5/fep-f1d5.md)
- [FEP-8fcf: Followers collection synchronization across servers](https://codeberg.org/fediverse/fep/src/branch/main/fep/8fcf/fep-8fcf.md)
- [FEP-5feb: Search indexing consent for actors](https://codeberg.org/fediverse/fep/src/branch/main/fep/5feb/fep-5feb.md)
- [FEP-044f: Consent-respecting quote posts](https://codeberg.org/fediverse/fep/src/branch/main/fep/044f/fep-044f.md): partial support for incoming quote-posts

## ActivityPub in Mastodon

Mastodon largely follows the ActivityPub server-to-server specification but it makes uses of some non-standard extensions, some of which are required for interacting with Mastodon at all.

- [Supported ActivityPub vocabulary](https://docs.joinmastodon.org/spec/activitypub/)

### Required extensions

#### WebFinger

In Mastodon, users are identified by a `username` and `domain` pair (e.g., `Gargron@mastodon.social`).
This is used both for discovery and for unambiguously mentioning users across the fediverse. Furthermore, this is part of Mastodon's database design from its very beginnings.

As a result, Mastodon requires that each ActivityPub actor uniquely maps back to an `acct:` URI that can be resolved via WebFinger.

- [WebFinger information and examples](https://docs.joinmastodon.org/spec/webfinger/)

#### HTTP Signatures

In order to authenticate activities, Mastodon relies on HTTP Signatures, signing every `POST` and `GET` request to other ActivityPub implementations on behalf of the user authoring an activity (for `POST` requests) or an actor representing the Mastodon server itself (for most `GET` requests).

Mastodon requires all `POST` requests to be signed, and MAY require `GET` requests to be signed, depending on the configuration of the Mastodon server.

- [HTTP Signatures information and examples](https://docs.joinmastodon.org/spec/security/#http)

### Optional extensions

- [Linked-Data Signatures](https://docs.joinmastodon.org/spec/security/#ld)
- [Bearcaps](https://docs.joinmastodon.org/spec/bearcaps/)

### Additional documentation

- [Mastodon documentation](https://docs.joinmastodon.org/)

## Size limits

Mastodon imposes a few hard limits on federated content.
These limits are intended to be very generous and way above what the Mastodon user experience is optimized for, so as to accommodate future changes and unusual or unforeseen usage patterns, while still providing some limits for performance reasons.
The following table summarizes those limits.

| Limited property                                              | Size limit | Consequence of exceeding the limit |
| ------------------------------------------------------------- | ---------- | ---------------------------------- |
| Serialized JSON-LD                                            | 1MB        | **Activity is rejected/dropped**   |
| Profile fields (actor `PropertyValue` attachments) name/value | 2047       | Field name/value is truncated      |
| Number of profile fields (actor `PropertyValue` attachments)  | 50         | Fields list is truncated           |
| Poll options (number of `anyOf`/`oneOf` in a `Question`)      | 500        | Items list is truncated            |
| Account username (actor `preferredUsername`) length           | 2048       | **Actor will be rejected**         |
| Account display name (actor `name`) length                    | 2048       | Display name will be truncated     |
| Account note (actor `summary`) length                         | 20kB       | Account note will be truncated     |
| Account `attributionDomains`                                  | 256        | List will be truncated             |
| Account aliases (actor `alsoKnownAs`)                         | 256        | List will be truncated             |
| Custom emoji shortcode (`Emoji` `name`)                       | 2048       | Emoji will be rejected             |
| Media and avatar/header descriptions (`name`/`summary`)       | 1500       | Description will be truncated      |
