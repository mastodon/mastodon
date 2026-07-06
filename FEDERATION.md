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
- [FEP-044f: Consent-respecting quote posts](https://codeberg.org/fediverse/fep/src/branch/main/fep/044f/fep-044f.md)
- [FEP-3b86: Activity Intents](https://codeberg.org/fediverse/fep/src/branch/main/fep/3b86/fep-3b86.md): offer handlers for `Object` and `Create` (with support for the `content` parameter only), has support for the `Follow`, `Announce`, `Like` and `Object` intents
- [FEP-521a: Representing actor's public keys](https://codeberg.org/fediverse/fep/src/branch/main/fep/521a/fep-521a.md): starting with Mastodon 4.7, we support RSA and Ed25519 keys exposed through FEP-521a, but we do not expose our keys this way
- [FEP-8b32: Object Integrity Proofs](https://codeberg.org/fediverse/fep/src/branch/main/fep/8b32/fep-8b32.md): starting with Mastodon 4.7, we support top-level Object Integrity Proofs using the `eddsa-jcs-2022` cryptosuite, but we do not emit any Object Integrity Proof

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

Before Mastodon v4.5.0, Mastodon only supported HTTP Signatures such as defined in the [draft-cavage-http-signatures-12](https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures) specification draft.

Starting with Mastodon v4.5.0, Mastodon supports requests signed using HTTP Message Signatures (RFC9421) with the [`rsa-v1_5-sha256` algorithm](https://datatracker.ietf.org/doc/html/rfc9421#name-rsassa-pkcs1-v1_5-using-sha) in addition to the old `draft-cavage-http-signatures-12` draft. Mastodon v4.7 also supports verifying signatures using the [`ed25519` algorithm](https://datatracker.ietf.org/doc/html/rfc9421#name-eddsa-using-curve-edwards25).

| Mastodon version        | Support for `draft-cavage-http-signatures-12` | Support for RFC 9421                    |
| ----------------------- | --------------------------------------------- | --------------------------------------- |
| v4.4.0 (EOL 2026-12-17) | `rsa-sha256` inbound and outbound             | No                                      |
| v4.5.0                  | `rsa-sha256` inbound and outbound             | `rsa-v1_5-sha256` inbound               |
| v4.6.0                  | `rsa-sha256` inbound and outbound             | `rsa-v1_5-sha256` inbound               |
| v4.7.0 (unreleased)     | `rsa-sha256` inbound and outbound             | `rsa-v1_5-sha256` and `ed25519` inbound |

- [HTTP Signatures information and examples](https://docs.joinmastodon.org/spec/security/#http)
- [HTTP Message Signatures information and examples](https://docs.joinmastodon.org/spec/security/#http-message-signatures)

### Optional extensions

- [Linked-Data Signatures](https://docs.joinmastodon.org/spec/security/#ld)
- [Bearcaps](https://docs.joinmastodon.org/spec/bearcaps/)

#### Embedded signatures

Mastodon supports embedded signatures through either [Linked-Data Signatures](https://docs.joinmastodon.org/spec/security/#ld) or [Object Integrity Proofs](https://docs.joinmastodon.org/spec/security/#fep-8b32).

| Mastodon version        | Support for Linked Data Signatures      | Support FEP-8b32: Object Integrity Proofs |
| ----------------------- | --------------------------------------- | ----------------------------------------- |
| v4.4.0 (EOL 2026-12-17) | `RsaSignature2017` inbound and outbound | No                                        |
| v4.5.0                  | `RsaSignature2017` inbound and outbound | No                                        |
| v4.6.0                  | `RsaSignature2017` inbound and outbound | No                                        |
| v4.7.0 (unreleased)     | `RsaSignature2017` inbound and outbound | top-level `eddsa-jcs-2022` inbound        |

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
| Media and avatar/header descriptions (`name`/`summary`)       | 10000      | Description will be truncated      |
| Collection name (`FeaturedCollection` `name`)                 | 256        | Name will be truncated             |
| Collection description (`FeaturedCollection` `summary`)       | 2048       | Description will be truncated      |
