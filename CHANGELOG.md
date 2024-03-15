# Changelog

All notable changes to this project will be documented in this file.

## [4.2.7] - 2024-02-16

### Fixed

- Fix OmniAuth tests and edge cases in error handling ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29201), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/29207))
- Fix new installs by upgrading to the latest release of the `nsa` gem, instead of a no longer existing commit ([mjankowski](https://github.com/mastodon/mastodon/pull/29065))

### Security

- Fix insufficient checking of remote posts ([GHSA-jhrq-qvrm-qr36](https://github.com/mastodon/mastodon/security/advisories/GHSA-jhrq-qvrm-qr36))

## [4.2.6] - 2024-02-14

### Security

- Update the `sidekiq-unique-jobs` dependency (see [GHSA-cmh9-rx85-xj38](https://github.com/mhenrixon/sidekiq-unique-jobs/security/advisories/GHSA-cmh9-rx85-xj38))
  In addition, we have disabled the web interface for `sidekiq-unique-jobs` out of caution.
  If you need it, you can re-enable it by setting `ENABLE_SIDEKIQ_UNIQUE_JOBS_UI=true`.
  If you only need to clear all locks, you can now use `bundle exec rake sidekiq_unique_jobs:delete_all_locks`.
- Update the `nokogiri` dependency (see [GHSA-xc9x-jj77-9p9j](https://github.com/sparklemotion/nokogiri/security/advisories/GHSA-xc9x-jj77-9p9j))
- Disable administrative Doorkeeper routes ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/29187))
- Fix ongoing streaming sessions not being invalidated when applications get deleted in some cases ([GHSA-7w3c-p9j8-mq3x](https://github.com/mastodon/mastodon/security/advisories/GHSA-7w3c-p9j8-mq3x))
  In some rare cases, the streaming server was not notified of access tokens revocation on application deletion.
- Change external authentication behavior to never reattach a new identity to an existing user by default ([GHSA-vm39-j3vx-pch3](https://github.com/mastodon/mastodon/security/advisories/GHSA-vm39-j3vx-pch3))
  Up until now, Mastodon has allowed new identities from external authentication providers to attach to an existing local user based on their verified e-mail address.
  This allowed upgrading users from a database-stored password to an external authentication provider, or move from one authentication provider to another.
  However, this behavior may be unexpected, and means that when multiple authentication providers are configured, the overall security would be that of the least secure authentication provider.
  For these reasons, this behavior is now locked under the `ALLOW_UNSAFE_AUTH_PROVIDER_REATTACH` environment variable.
  In addition, regardless of this environment variable, Mastodon will refuse to attach two identities from the same authentication provider to the same account.

## [4.2.5] - 2024-02-01

### Security

- Fix insufficient origin validation (CVE-2024-23832, [GHSA-3fjr-858r-92rw](https://github.com/mastodon/mastodon/security/advisories/GHSA-3fjr-858r-92rw))

## [4.2.4] - 2024-01-24

### Fixed

- Fix error when processing remote files with unusually long names ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28823))
- Fix processing of compacted single-item JSON-LD collections ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28816))
- Retry 401 errors on replies fetching ([ShadowJonathan](https://github.com/mastodon/mastodon/pull/28788))
- Fix `RecordNotUnique` errors in LinkCrawlWorker ([tribela](https://github.com/mastodon/mastodon/pull/28748))
- Fix Mastodon not correctly processing HTTP Signatures with query strings ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28443), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/28476))
- Fix potential redirection loop of streaming endpoint ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28665))
- Fix streaming API redirection ignoring the port of `streaming_api_base_url` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28558))
- Fix error when processing link preview with an array as `inLanguage` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28252))
- Fix unsupported time zone or locale preventing sign-up ([Gargron](https://github.com/mastodon/mastodon/pull/28035))
- Fix "Hide these posts from home" list setting not refreshing when switching lists ([brianholley](https://github.com/mastodon/mastodon/pull/27763))
- Fix missing background behind dismissable banner in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/27479))
- Fix line wrapping of language selection button with long locale codes ([gunchleoc](https://github.com/mastodon/mastodon/pull/27100), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/27127))
- Fix `Undo Announce` activity not being sent to non-follower authors ([MitarashiDango](https://github.com/mastodon/mastodon/pull/18482))
- Fix N+1s because of association preloaders not actually getting called ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28339))
- Fix empty column explainer getting cropped under certain conditions ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28337))
- Fix `LinkCrawlWorker` error when encountering empty OEmbed response ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28268))
- Fix call to inefficient `delete_matched` cache method in domain blocks ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28367))

### Security

- Add rate-limit of TOTP authentication attempts at controller level ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28801))

## [4.2.3] - 2023-12-05

### Fixed

- Fix dependency on `json-canonicalization` version that has been made unavailable since last release

## [4.2.2] - 2023-12-04

### Changed

- Change dismissed banners to be stored server-side ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27055))
- Change GIF max matrix size error to explicitly mention GIF files ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27927))
- Change `Follow` activities delivery to bypass availability check ([ShadowJonathan](https://github.com/mastodon/mastodon/pull/27586))
- Change single-column navigation notice to be displayed outside of the logo container ([renchap](https://github.com/mastodon/mastodon/pull/27462), [renchap](https://github.com/mastodon/mastodon/pull/27476))
- Change Content-Security-Policy to be tighter on media paths ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26889))
- Change post language code to include country code when relevant ([gunchleoc](https://github.com/mastodon/mastodon/pull/27099), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/27207))

### Fixed

- Fix upper border radius of onboarding columns ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27890))
- Fix incoming status creation date not being restricted to standard ISO8601 ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27655), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/28081))
- Fix some posts from threads received out-of-order sometimes not being inserted into timelines ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27653))
- Fix posts from force-sensitized accounts being able to trend ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27620))
- Fix error when trying to delete already-deleted file with OpenStack Swift ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27569))
- Fix batch attachment deletion when using OpenStack Swift ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27554))
- Fix processing LDSigned activities from actors with unknown public keys ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27474))
- Fix error and incorrect URLs in `/api/v1/accounts/:id/featured_tags` for remote accounts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27459))
- Fix report processing notice not mentioning the report number when performing a custom action ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27442))
- Fix handling of `inLanguage` attribute in preview card processing ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27423))
- Fix own posts being removed from home timeline when unfollowing a used hashtag ([kmycode](https://github.com/mastodon/mastodon/pull/27391))
- Fix some link anchors being recognized as hashtags ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27271), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/27584))
- Fix format-dependent redirects being cached regardless of requested format ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27634))

## [4.2.1] - 2023-10-10

### Added

- Add redirection on `/deck` URLs for logged-out users ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27128))
- Add support for v4.2.0 migrations to `tootctl maintenance fix-duplicates` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27147))

### Changed

- Change some worker lock TTLs to be shorter-lived ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27246))
- Change user archive export allowed period from 7 days to 6 days ([suddjian](https://github.com/mastodon/mastodon/pull/27200))

### Fixed

- Fix duplicate reports being sent when reporting some remote posts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27355))
- Fix clicking on already-opened thread post scrolling to the top of the thread ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27331), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/27338), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/27350))
- Fix some remote posts getting truncated ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27307))
- Fix some cases of infinite scroll code trying to fetch inaccessible posts in a loop ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27286))
- Fix `Vary` headers not being set on some redirects ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27272))
- Fix mentions being matched in some URL query strings ([mjankowski](https://github.com/mastodon/mastodon/pull/25656))
- Fix unexpected linebreak in version string in the Web UI ([vmstan](https://github.com/mastodon/mastodon/pull/26986))
- Fix double scroll bars in some columns in advanced interface ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27187))
- Fix boosts of local users being filtered in account timelines ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27204))
- Fix multiple instances of the trend refresh scheduler sometimes running at once ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27253))
- Fix importer returning negative row estimates ([jgillich](https://github.com/mastodon/mastodon/pull/27258))
- Fix incorrectly keeping outdated update notices absent from the API endpoint ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27021))
- Fix import progress not updating on certain failures ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27247))
- Fix websocket connections being incorrectly decremented twice on errors ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/27238))
- Fix explore prompt appearing because of posts being received out of order ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27211))
- Fix explore prompt sometimes showing up when the home TL is loading ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27062))
- Fix link handling of mentions in user profiles when logged out ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27185))
- Fix filtering audit log for entries about disabling 2FA ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27186))
- Fix notification toasts not respecting reduce-motion ([c960657](https://github.com/mastodon/mastodon/pull/27178))
- Fix retention dashboard not displaying correct month ([vmstan](https://github.com/mastodon/mastodon/pull/27180))
- Fix tIME chunk not being properly removed from PNG uploads ([TheEssem](https://github.com/mastodon/mastodon/pull/27111))
- Fix division by zero in video in bitrate computation code ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27129))
- Fix inefficient queries in “Follows and followers” as well as several admin pages ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27116), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/27306))
- Fix ActiveRecord using two connection pools when no replica is defined ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27061))
- Fix the search documentation URL in system checks ([renchap](https://github.com/mastodon/mastodon/pull/27036))

## [4.2.0] - 2023-09-21

The following changelog entries focus on changes visible to users, administrators, client developers or federated software developers, but there has also been a lot of code modernization, refactoring, and tooling work, in particular by [@danielmbrasil](https://github.com/danielmbrasil), [@mjankowski](https://github.com/mjankowski), [@nschonni](https://github.com/nschonni), [@renchap](https://github.com/renchap), and [@takayamaki](https://github.com/takayamaki).

### Added

- **Add full-text search of opted-in public posts and rework search operators** ([Gargron](https://github.com/mastodon/mastodon/pull/26485), [jsgoldstein](https://github.com/mastodon/mastodon/pull/26344), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26657), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26650), [jsgoldstein](https://github.com/mastodon/mastodon/pull/26659), [Gargron](https://github.com/mastodon/mastodon/pull/26660), [Gargron](https://github.com/mastodon/mastodon/pull/26663), [Gargron](https://github.com/mastodon/mastodon/pull/26688), [Gargron](https://github.com/mastodon/mastodon/pull/26689), [Gargron](https://github.com/mastodon/mastodon/pull/26686), [Gargron](https://github.com/mastodon/mastodon/pull/26687), [Gargron](https://github.com/mastodon/mastodon/pull/26692), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26697), [Gargron](https://github.com/mastodon/mastodon/pull/26699), [Gargron](https://github.com/mastodon/mastodon/pull/26701), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26710), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26739), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26754), [Gargron](https://github.com/mastodon/mastodon/pull/26662), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26755), [Gargron](https://github.com/mastodon/mastodon/pull/26781), [Gargron](https://github.com/mastodon/mastodon/pull/26782), [Gargron](https://github.com/mastodon/mastodon/pull/26760), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26756), [Gargron](https://github.com/mastodon/mastodon/pull/26784), [Gargron](https://github.com/mastodon/mastodon/pull/26807), [Gargron](https://github.com/mastodon/mastodon/pull/26835), [Gargron](https://github.com/mastodon/mastodon/pull/26847), [Gargron](https://github.com/mastodon/mastodon/pull/26834), [arbolitoloco1](https://github.com/mastodon/mastodon/pull/26893), [tribela](https://github.com/mastodon/mastodon/pull/26896), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26927), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26959), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/27014))
  This introduces a new `public_statuses` Elasticsearch index for public posts by users who have opted in to their posts being searchable (`toot#indexable` flag).
  This also revisits the other indexes to provide more useful indexing, and adds new search operators such as `from:me`, `before:2022-11-01`, `after:2022-11-01`, `during:2022-11-01`, `language:fr`, `has:poll`, or `in:library` (for searching only in posts you have written or interacted with).
  Results are now ordered chronologically.
- **Add admin notifications for new Mastodon versions** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26582))
  This is done by querying `https://api.joinmastodon.org/update-check` every 30 minutes in a background job.
  That URL can be changed using the `UPDATE_CHECK_URL` environment variable, and the feature outright disabled by setting that variable to an empty string (`UPDATE_CHECK_URL=`).
- **Add “Privacy and reach” tab in profile settings** ([Gargron](https://github.com/mastodon/mastodon/pull/26484), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26508))
  This reorganized scattered privacy and reach settings to a single place, as well as improve their wording.
- **Add display of out-of-band hashtags in the web interface** ([Gargron](https://github.com/mastodon/mastodon/pull/26492), [arbolitoloco1](https://github.com/mastodon/mastodon/pull/26497), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26506), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26525), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26606), [Gargron](https://github.com/mastodon/mastodon/pull/26666), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26960))
- **Add role badges to the web interface** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25649), [Gargron](https://github.com/mastodon/mastodon/pull/26281))
- **Add ability to pick domains to forward reports to using the `forward_to_domains` parameter in `POST /api/v1/reports`** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25866), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26636))
  The `forward_to_domains` REST API parameter is a list of strings. If it is empty or omitted, the previous behavior is maintained.
  The `forward` parameter still needs to be set for `forward_to_domains` to be taken into account.
  The forwarded-to domains can only include that of the original author and people being replied to.
- **Add forwarding of reported replies to servers being replied to** ([Gargron](https://github.com/mastodon/mastodon/pull/25341), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26189))
- Add `ONE_CLICK_SSO_LOGIN` environment variable to directly link to the Single-Sign On provider if there is only one sign up method available ([CSDUMMI](https://github.com/mastodon/mastodon/pull/26083), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26368), [CSDUMMI](https://github.com/mastodon/mastodon/pull/26857), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26901))
- **Add webhook templating** ([Gargron](https://github.com/mastodon/mastodon/pull/23289))
- **Add webhooks for local `status.created`, `status.updated`, `account.updated` and `report.updated`** ([VyrCossont](https://github.com/mastodon/mastodon/pull/24133), [VyrCossont](https://github.com/mastodon/mastodon/pull/24243), [VyrCossont](https://github.com/mastodon/mastodon/pull/24211))
- **Add exclusive lists** ([dariusk, necropolina](https://github.com/mastodon/mastodon/pull/22048), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25324))
- **Add a confirmation screen when suspending a domain** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25144), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25603))
- **Add support for importing lists** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25203), [mgmn](https://github.com/mastodon/mastodon/pull/26120), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26372))
- **Add optional hCaptcha support** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25019), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25057), [Gargron](https://github.com/mastodon/mastodon/pull/25395), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26388))
- **Add lines to threads in web UI** ([Gargron](https://github.com/mastodon/mastodon/pull/24549), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24677), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24696), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24711), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24714), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24713), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24715), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24800), [teeerevor](https://github.com/mastodon/mastodon/pull/25706), [renchap](https://github.com/mastodon/mastodon/pull/25807))
- **Add new onboarding flow to web UI** ([Gargron](https://github.com/mastodon/mastodon/pull/24619), [Gargron](https://github.com/mastodon/mastodon/pull/24646), [Gargron](https://github.com/mastodon/mastodon/pull/24705), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24872), [ThisIsMissEm](https://github.com/mastodon/mastodon/pull/24883), [Gargron](https://github.com/mastodon/mastodon/pull/24954), [stevenjlm](https://github.com/mastodon/mastodon/pull/24959), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25010), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25275), [Gargron](https://github.com/mastodon/mastodon/pull/25559), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25561))
- **Add auto-refresh of accounts we get new messages/edits of** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26510))
- **Add Elasticsearch cluster health check and indexes mismatch check to dashboard** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26448), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26605), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26658))
- Add `hide_collections`, `discoverable` and `indexable` attributes to credentials API ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26998))
- Add `S3_ENABLE_CHECKSUM_MODE` environment variable to enable checksum verification on compatible S3-providers ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26435))
- Add admin API for managing tags ([rrgeorge](https://github.com/mastodon/mastodon/pull/26872))
- Add a link to hashtag timelines from the Trending hashtags moderation interface ([gunchleoc](https://github.com/mastodon/mastodon/pull/26724))
- Add timezone to datetimes in e-mails ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26822))
- Add `authorized_fetch` server setting in addition to env var ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25798), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26958))
- Add avatar image to webfinger responses ([tvler](https://github.com/mastodon/mastodon/pull/26558))
- Add debug logging on signature verification failure ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26637), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26812))
- Add explicit error messages when DeepL quota is exceeded ([lutoma](https://github.com/mastodon/mastodon/pull/26704))
- Add Elasticsearch/OpenSearch version to “Software” in admin dashboard ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26652))
- Add `data-nosnippet` attribute to remote posts and local posts with `noindex` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26648))
- Add support for federating `memorial` attribute ([rrgeorge](https://github.com/mastodon/mastodon/pull/26583))
- Add Cherokee and Kalmyk to languages dropdown ([gunchleoc](https://github.com/mastodon/mastodon/pull/26012), [gunchleoc](https://github.com/mastodon/mastodon/pull/26013))
- Add `DELETE /api/v1/profile/avatar` and `DELETE /api/v1/profile/header` to the REST API ([danielmbrasil](https://github.com/mastodon/mastodon/pull/25124), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26573))
- Add `ES_PRESET` option to customize numbers of shards and replicas ([Gargron](https://github.com/mastodon/mastodon/pull/26483), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26489))
  This can have a value of `single_node_cluster` (default), `small_cluster` (uses one replica) or `large_cluster` (uses one replica and a higher number of shards).
- Add `CACHE_BUSTER_HTTP_METHOD` environment variable ([renchap](https://github.com/mastodon/mastodon/pull/26528), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26542))
- Add support for `DB_PASS` when using `DATABASE_URL` ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/26295))
- Add `GET /api/v1/instance/languages` to REST API ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24443))
- Add primary key to `preview_cards_statuses` join table ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25243), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26384), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26447), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26737), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26979))
- Add client-side timeout on resend confirmation button ([Gargron](https://github.com/mastodon/mastodon/pull/26300))
- Add published date and author to news on the explore screen in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/26155))
- Add `lang` attribute to various UI components ([c960657](https://github.com/mastodon/mastodon/pull/23869), [c960657](https://github.com/mastodon/mastodon/pull/23891), [c960657](https://github.com/mastodon/mastodon/pull/26111), [c960657](https://github.com/mastodon/mastodon/pull/26149))
- Add stricter protocol fields validation for accounts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25937))
- Add support for Azure blob storage ([mistydemeo](https://github.com/mastodon/mastodon/pull/23607), [mistydemeo](https://github.com/mastodon/mastodon/pull/26080))
- Add toast with option to open post after publishing in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25564), [Signez](https://github.com/mastodon/mastodon/pull/25919), [Gargron](https://github.com/mastodon/mastodon/pull/26664))
- Add canonical link tags in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25715))
- Add button to see results for polls in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25726))
- Add at-symbol prepended to mention span title ([forsamori](https://github.com/mastodon/mastodon/pull/25684))
- Add users index on `unconfirmed_email` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25672), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25702))
- Add superapp index on `oauth_applications` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25670))
- Add index to backups on `user_id` column ([mjankowski](https://github.com/mastodon/mastodon/pull/25647))
- Add onboarding prompt when home feed too slow in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25267), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25556), [Gargron](https://github.com/mastodon/mastodon/pull/25579), [renchap](https://github.com/mastodon/mastodon/pull/25580), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25581), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25617), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25917), [Gargron](https://github.com/mastodon/mastodon/pull/26829), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26935))
- Add `POST /api/v1/conversations/:id/unread` API endpoint to mark a conversation as unread ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25509))
- Add `translate="no"` to outgoing mentions and links ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25524))
- Add unsubscribe link and headers to e-mails ([Gargron](https://github.com/mastodon/mastodon/pull/25378), [c960657](https://github.com/mastodon/mastodon/pull/26085))
- Add logging of websocket send errors ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/25280))
- Add time zone preference ([Gargron](https://github.com/mastodon/mastodon/pull/25342), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26025))
- Add `legal` as report category ([Gargron](https://github.com/mastodon/mastodon/pull/23941), [renchap](https://github.com/mastodon/mastodon/pull/25400), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26509))
- Add `data-nosnippet` so Google doesn't use trending posts in snippets for `/` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25279))
- Add card with who invited you to join when displaying rules on sign-up ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23475))
- Add missing primary keys to `accounts_tags` and `statuses_tags` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25210))
- Add support for custom sign-up URLs ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25014), [renchap](https://github.com/mastodon/mastodon/pull/25108), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25190), [mgmn](https://github.com/mastodon/mastodon/pull/25531))
  This is set using `SSO_ACCOUNT_SIGN_UP` and reflected in the REST API by adding `registrations.sign_up_url` to the `/api/v2/instance` endpoint.
- Add polling and automatic redirection to `/start` on email confirmation ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25013))
- Add ability to block sign-ups from IP using the CLI ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24870))
- Add ALT badges to media that has alternative text in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/24782), [c960657](https://github.com/mastodon/mastodon/pull/26166)
- Add ability to include accounts with pending follow requests in lists ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19727), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24810))
- Add trend management to admin API ([rrgeorge](https://github.com/mastodon/mastodon/pull/24257))
  - `POST /api/v1/admin/trends/statuses/:id/approve`
  - `POST /api/v1/admin/trends/statuses/:id/reject`
  - `POST /api/v1/admin/trends/links/:id/approve`
  - `POST /api/v1/admin/trends/links/:id/reject`
  - `POST /api/v1/admin/trends/tags/:id/approve`
  - `POST /api/v1/admin/trends/tags/:id/reject`
  - `GET /api/v1/admin/trends/links/publishers`
  - `POST /api/v1/admin/trends/links/publishers/:id/approve`
  - `POST /api/v1/admin/trends/links/publishers/:id/reject`
- Add user handle to notification mail recipient address ([HeitorMC](https://github.com/mastodon/mastodon/pull/24240))
- Add progress indicator to sign-up flow ([Gargron](https://github.com/mastodon/mastodon/pull/24545))
- Add client-side validation for taken username in sign-up form ([Gargron](https://github.com/mastodon/mastodon/pull/24546))
- Add `--approve` option to `tootctl accounts create` ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24533))
- Add “In Memoriam” banner back to profiles ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23591), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/23614))
  This adds the `memorial` attribute to the `Account` REST API entity.
- Add colour to follow button when hashtag is being followed ([c960657](https://github.com/mastodon/mastodon/pull/24361))
- Add further explanations to the profile link verification instructions ([drzax](https://github.com/mastodon/mastodon/pull/19723))
- Add a link to Identity provider's account settings from the account settings ([CSDUMMI](https://github.com/mastodon/mastodon/pull/24100), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24628))
- Add support for streaming server to connect to postgres with self-signed certs through the `sslmode` URL parameter ([ramuuns](https://github.com/mastodon/mastodon/pull/21431))
- Add support for specifying S3 storage classes through the `S3_STORAGE_CLASS` environment variable ([hyl](https://github.com/mastodon/mastodon/pull/22480))
- Add support for incoming rich text ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23913))
- Add support for Ruby 3.2 ([tenderlove](https://github.com/mastodon/mastodon/pull/22928), [casperisfine](https://github.com/mastodon/mastodon/pull/24142), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24202), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26934))
- Add API parameter to safeguard unexpected mentions in new posts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18350))

### Changed

- **Change hashtags to be displayed separately when they are the last line of a post** ([renchap](https://github.com/mastodon/mastodon/pull/26499), [renchap](https://github.com/mastodon/mastodon/pull/26614), [renchap](https://github.com/mastodon/mastodon/pull/26615))
- **Change reblogs to be excluded from "Posts and replies" tab in web UI** ([Gargron](https://github.com/mastodon/mastodon/pull/26302))
- **Change interaction modal in web interface** ([Gargron, ClearlyClaire](https://github.com/mastodon/mastodon/pull/26075), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26269), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26268), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26267), [mgmn](https://github.com/mastodon/mastodon/pull/26459), [tribela](https://github.com/mastodon/mastodon/pull/26461), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26593), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26795))
- **Change design of link previews in web UI** ([Gargron](https://github.com/mastodon/mastodon/pull/26136), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26151), [Gargron](https://github.com/mastodon/mastodon/pull/26153), [Gargron](https://github.com/mastodon/mastodon/pull/26250), [Gargron](https://github.com/mastodon/mastodon/pull/26287), [Gargron](https://github.com/mastodon/mastodon/pull/26286), [c960657](https://github.com/mastodon/mastodon/pull/26184))
- **Change "direct message" nomenclature to "private mention" in web UI** ([Gargron](https://github.com/mastodon/mastodon/pull/24248))
- **Change translation feature to cover Content Warnings, poll options and media descriptions** ([c960657](https://github.com/mastodon/mastodon/pull/24175), [S-H-GAMELINKS](https://github.com/mastodon/mastodon/pull/25251), [c960657](https://github.com/mastodon/mastodon/pull/26168), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26452))
- **Change account search to match by text when opted-in** ([jsgoldstein](https://github.com/mastodon/mastodon/pull/25599), [Gargron](https://github.com/mastodon/mastodon/pull/26378))
- **Change import feature to be clearer, less error-prone and more reliable** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21054), [mgmn](https://github.com/mastodon/mastodon/pull/24874))
- **Change local and federated timelines to be tabs of a single “Live feeds” column** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25641), [Gargron](https://github.com/mastodon/mastodon/pull/25683), [mgmn](https://github.com/mastodon/mastodon/pull/25694), [Plastikmensch](https://github.com/mastodon/mastodon/pull/26247), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26633))
- **Change user archive export to be faster and more reliable, and export `.zip` archives instead of `.tar.gz` ones** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23360), [TheEssem](https://github.com/mastodon/mastodon/pull/25034))
- **Change `mastodon-streaming` systemd unit files to be templated** ([e-nomem](https://github.com/mastodon/mastodon/pull/24751))
- **Change `statsd` integration to disable sidekiq metrics by default** ([mjankowski](https://github.com/mastodon/mastodon/pull/25265), [mjankowski](https://github.com/mastodon/mastodon/pull/25336), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26310))
  This deprecates `statsd` support and disables the sidekiq integration unless `STATSD_SIDEKIQ` is set to `true`.
  This is because the `nsa` gem is unmaintained, and its sidekiq integration is known to add very significant overhead.
  Later versions of Mastodon will have other ways to get the same metrics.
- **Change replica support to native Rails adapter** ([krainboltgreene](https://github.com/mastodon/mastodon/pull/25693), [Gargron](https://github.com/mastodon/mastodon/pull/25849), [Gargron](https://github.com/mastodon/mastodon/pull/25874), [Gargron](https://github.com/mastodon/mastodon/pull/25851), [Gargron](https://github.com/mastodon/mastodon/pull/25977), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26074), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26326), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26386), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26856))
  This is a breaking change, dropping `makara` support, and requiring you to update your database configuration if you are using replicas.
  To tell Mastodon to use a read replica, you can either set the `REPLICA_DB_NAME` environment variable (along with `REPLICA_DB_USER`, `REPLICA_DB_PASS`, `REPLICA_DB_HOST`, and `REPLICA_DB_PORT`, if they differ from the primary database), or the `REPLICA_DATABASE_URL` environment variable if your configuration is based on `DATABASE_URL`.
- Change DCT method used for JPEG encoding to float ([electroCutie](https://github.com/mastodon/mastodon/pull/26675))
- Change from `node-redis` to `ioredis` for streaming ([gmemstr](https://github.com/mastodon/mastodon/pull/26581))
- Change private statuses index to index without crutches ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26713))
- Change video compression parameters ([Gargron](https://github.com/mastodon/mastodon/pull/26631), [Gargron](https://github.com/mastodon/mastodon/pull/26745), [Gargron](https://github.com/mastodon/mastodon/pull/26766), [Gargron](https://github.com/mastodon/mastodon/pull/26970))
- Change admin e-mail notification settings to be their own settings group ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26596))
- Change opacity of the delete icon in the search field to be more visible ([AntoninDelFabbro](https://github.com/mastodon/mastodon/pull/26449))
- Change Account Search to prioritize username over display name ([jsgoldstein](https://github.com/mastodon/mastodon/pull/26623))
- Change follow recommendation materialized view to be faster in most cases ([renchap, ClearlyClaire](https://github.com/mastodon/mastodon/pull/26545))
- Change `robots.txt` to block GPTBot ([Foritus](https://github.com/mastodon/mastodon/pull/26396))
- Change header of hashtag timelines in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/26362), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26416))
- Change streaming `/metrics` to include additional metrics ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/26299), [ThisIsMissEm](https://github.com/mastodon/mastodon/pull/26945))
- Change indexing frequency from 5 minutes to 1 minute, add locks to schedulers ([Gargron](https://github.com/mastodon/mastodon/pull/26304))
- Change column link to add a better keyboard focus indicator ([teeerevor](https://github.com/mastodon/mastodon/pull/26278))
- Change poll form element colors to fit with the rest of the ui ([teeerevor](https://github.com/mastodon/mastodon/pull/26139), [teeerevor](https://github.com/mastodon/mastodon/pull/26162), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26164))
- Change 'favourite' to 'favorite' for American English ([marekr](https://github.com/mastodon/mastodon/pull/24667), [gunchleoc](https://github.com/mastodon/mastodon/pull/26009), [nabijaczleweli](https://github.com/mastodon/mastodon/pull/26109))
- Change ActivityStreams representation of suspended accounts to not use a blank `name` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25276))
- Change focus UI for keyboard only input ([teeerevor](https://github.com/mastodon/mastodon/pull/25935), [Gargron](https://github.com/mastodon/mastodon/pull/26125), [Gargron](https://github.com/mastodon/mastodon/pull/26767))
- Change thread view to scroll to the selected post rather than the post being replied to ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24685))
- Change links in multi-column mode so tabs are open in single-column mode ([Signez](https://github.com/mastodon/mastodon/pull/25893), [Signez](https://github.com/mastodon/mastodon/pull/26070), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25973), [Signez](https://github.com/mastodon/mastodon/pull/26019), [Signez](https://github.com/mastodon/mastodon/pull/26759))
- Change searching with `#` to include account index ([jsgoldstein](https://github.com/mastodon/mastodon/pull/25638))
- Change label and design of sensitive and unavailable media in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25712), [Gargron](https://github.com/mastodon/mastodon/pull/26135), [Gargron](https://github.com/mastodon/mastodon/pull/26330))
- Change button colors to increase hover/focus contrast and consistency ([teeerevor](https://github.com/mastodon/mastodon/pull/25677), [Gargron](https://github.com/mastodon/mastodon/pull/25679))
- Change dropdown icon above compose form from ellipsis to bars in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25661))
- Change header backgrounds to use fewer different colors in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25577))
- Change files to be deleted in batches instead of one-by-one ([Gargron](https://github.com/mastodon/mastodon/pull/23302), [S-H-GAMELINKS](https://github.com/mastodon/mastodon/pull/25586), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25587))
- Change emoji picker icon ([iparr](https://github.com/mastodon/mastodon/pull/25479))
- Change edit profile page ([Gargron](https://github.com/mastodon/mastodon/pull/25413), [c960657](https://github.com/mastodon/mastodon/pull/26538))
- Change "bot" label to "automated" ([Gargron](https://github.com/mastodon/mastodon/pull/25356))
- Change design of dropdowns in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25107))
- Change wording of “Content cache retention period” setting to highlight destructive implications ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23261))
- Change autolinking to allow carets in URL search params ([renchap](https://github.com/mastodon/mastodon/pull/25216))
- Change share action from being in action bar to being in dropdown in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25105))
- Change sessions to be ordered from most-recent to least-recently updated ([frankieroberto](https://github.com/mastodon/mastodon/pull/25005))
- Change vacuum scheduler to also delete expired tokens and unused application records ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24868), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24871))
- Change "Sign in" to "Login" ([Gargron](https://github.com/mastodon/mastodon/pull/24942))
- Change domain suspensions to also be checked before trying to fetch unknown remote resources ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24535))
- Change media components to use aspect-ratio rather than compute height themselves ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24686), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24943), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26801))
- Change logo version in header based on screen size in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/24707))
- Change label from "For you" to "People" on explore screen in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/24706))
- Change logged-out WebUI HTML pages to be cached for a few seconds ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24708))
- Change unauthenticated responses to be cached in REST API ([Gargron](https://github.com/mastodon/mastodon/pull/24348), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24662), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24665))
- Change HTTP caching logic ([Gargron](https://github.com/mastodon/mastodon/pull/24347), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24604))
- Change hashtags and mentions in bios to open in-app in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/24643))
- Change styling of the recommended accounts to allow bio to be more visible ([chike00](https://github.com/mastodon/mastodon/pull/24480))
- Change account search in moderation interface to allow searching by username including the leading `@` ([HeitorMC](https://github.com/mastodon/mastodon/pull/24242))
- Change all components to use the same error page in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/24512))
- Change search pop-out in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/24305))
- Change user settings to be stored in a more optimal way ([Gargron](https://github.com/mastodon/mastodon/pull/23630), [c960657](https://github.com/mastodon/mastodon/pull/24321), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24453), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24460), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24558), [Gargron](https://github.com/mastodon/mastodon/pull/24761), [Gargron](https://github.com/mastodon/mastodon/pull/24783), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25508), [jsgoldstein](https://github.com/mastodon/mastodon/pull/25340), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26884), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/27012))
- Change media upload limits and remove client-side resizing ([Gargron](https://github.com/mastodon/mastodon/pull/23726))
- Change design of account rows in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/24247), [Gargron](https://github.com/mastodon/mastodon/pull/24343), [Gargron](https://github.com/mastodon/mastodon/pull/24956), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25131))
- Change log-out to use Single Logout when using external log-in through OIDC ([CSDUMMI](https://github.com/mastodon/mastodon/pull/24020))
- Change sidekiq-bulk's batch size from 10,000 to 1,000 jobs in one Redis call ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24034))
- Change translation to only be offered for supported languages ([c960657](https://github.com/mastodon/mastodon/pull/23879), [c960657](https://github.com/mastodon/mastodon/pull/24037))
  This adds the `/api/v1/instance/translation_languages` REST API endpoint that returns an object with the supported translation language pairs in the form:
  ```json
  {
    "fr": ["en", "de"]
  }
  ```
  (where `fr` is a supported source language and `en` and `de` or supported output language when translating a `fr` string)
- Change compose form checkbox to native input with `appearance: none` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22949))
- Change posts' clickable area to be larger ([c960657](https://github.com/mastodon/mastodon/pull/23621))
- Change `followed_by` link to `location=all` if account is local on /admin/accounts/:id page ([tribela](https://github.com/mastodon/mastodon/pull/23467))

### Removed

- **Remove support for Node.js 14** ([renchap](https://github.com/mastodon/mastodon/pull/25198))
- **Remove support for Ruby 2.7** ([nschonni](https://github.com/mastodon/mastodon/pull/24237))
- **Remove clustering from streaming API** ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/24655))
- **Remove anonymous access to the streaming API** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23989))
- Remove obfuscation of reply count in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/26768))
- Remove `kmr` from language selection, as it was a duplicate for `ku` ([gunchleoc](https://github.com/mastodon/mastodon/pull/26014), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26787))
- Remove 16:9 cropping from web UI ([Gargron](https://github.com/mastodon/mastodon/pull/26132))
- Remove back button from bookmarks, favourites and lists screens in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/26126))
- Remove display name input from sign-up form ([Gargron](https://github.com/mastodon/mastodon/pull/24704))
- Remove `tai` locale ([c960657](https://github.com/mastodon/mastodon/pull/23880))
- Remove empty Kushubian (csb) local files ([nschonni](https://github.com/mastodon/mastodon/pull/24151))
- Remove `Permissions-Policy` header from all responses ([Gargron](https://github.com/mastodon/mastodon/pull/24124))

### Fixed

- **Fix filters not being applying in the explore page** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25887))
- **Fix being unable to load past a full page of filtered posts in Home timeline** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24930))
- **Fix log-in flow when involving both OAuth and external authentication** ([CSDUMMI](https://github.com/mastodon/mastodon/pull/24073))
- **Fix broken links in account gallery** ([c960657](https://github.com/mastodon/mastodon/pull/24218))
- **Fix migration handler not updating lists** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24808))
- Fix crash when viewing a moderation appeal and the moderator account has been deleted ([xrobau](https://github.com/mastodon/mastodon/pull/25900))
- Fix error in Web UI when server rules cannot be fetched ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26957))
- Fix paragraph margins resulting in irregular read-more cut-off in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/26828))
- Fix notification permissions being requested immediately after login ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26472))
- Fix performances of profile directory ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26840), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26842))
- Fix mute button and volume slider feeling disconnected in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/26827), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26860))
- Fix “Scoped order is ignored, it's forced to be batch order.” warnings ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26793))
- Fix blocked domain appearing in account feeds ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26823))
- Fix invalid `Content-Type` header for WebP images ([c960657](https://github.com/mastodon/mastodon/pull/26773))
- Fix minor inefficiencies in `tootctl search deploy` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26721))
- Fix filter form in profiles directory overflowing instead of wrapping ([arbolitoloco1](https://github.com/mastodon/mastodon/pull/26682))
- Fix sign up steps progress layout in right-to-left locales ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26728))
- Fix bug with “favorited by” and “reblogged by“ view on posts only showing up to 40 items ([timothyjrogers](https://github.com/mastodon/mastodon/pull/26577), [timothyjrogers](https://github.com/mastodon/mastodon/pull/26574))
- Fix bad search type heuristic ([Gargron](https://github.com/mastodon/mastodon/pull/26673))
- Fix not being able to negate prefix clauses in search ([Gargron](https://github.com/mastodon/mastodon/pull/26672))
- Fix timeout on invalid set of exclusionary parameters in `/api/v1/timelines/public` ([danielmbrasil](https://github.com/mastodon/mastodon/pull/26239))
- Fix adding column with default value taking longer on Postgres >= 11 ([Gargron](https://github.com/mastodon/mastodon/pull/26375))
- Fix light theme select option for hashtags ([teeerevor](https://github.com/mastodon/mastodon/pull/26311))
- Fix AVIF attachments ([c960657](https://github.com/mastodon/mastodon/pull/26264))
- Fix incorrect URL normalization when fetching remote resources ([c960657](https://github.com/mastodon/mastodon/pull/26219), [c960657](https://github.com/mastodon/mastodon/pull/26285))
- Fix being unable to filter posts for individual Chinese languages ([gunchleoc](https://github.com/mastodon/mastodon/pull/26066))
- Fix preview card sometimes linking to 4xx error pages ([c960657](https://github.com/mastodon/mastodon/pull/26200))
- Fix emoji picker button scrolling with textarea content in single-column view ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25304))
- Fix missing border on error screen in light theme in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/26152))
- Fix UI overlap with the loupe icon in the Explore Tab ([gol-cha](https://github.com/mastodon/mastodon/pull/26113))
- Fix unexpected redirection to `/explore` after sign-in ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26143))
- Fix `/api/v1/statuses/:id/unfavourite` and `/api/v1/statuses/:id/unreblog` returning non-updated counts ([c960657](https://github.com/mastodon/mastodon/pull/24365))
- Fix clicking the “Back” button sometimes leading out of Mastodon ([c960657](https://github.com/mastodon/mastodon/pull/23953), [CSFlorin](https://github.com/mastodon/mastodon/pull/24835), [S-H-GAMELINKS](https://github.com/mastodon/mastodon/pull/24867), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25281))
- Fix processing of `null` ActivityPub activities ([tribela](https://github.com/mastodon/mastodon/pull/26021))
- Fix hashtag posts not being removed from home feed on hashtag unfollow ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26028))
- Fix for "follows you" indicator in light web UI not readable ([vmstan](https://github.com/mastodon/mastodon/pull/25993))
- Fix incorrect line break between icon and number of reposts & favourites ([edent](https://github.com/mastodon/mastodon/pull/26004))
- Fix sounds not being loaded from assets host ([Signez](https://github.com/mastodon/mastodon/pull/25931))
- Fix buttons showing inconsistent styles ([teeerevor](https://github.com/mastodon/mastodon/pull/25903), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25965), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26341), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/26482))
- Fix trend calculation working on too many items at a time ([Gargron](https://github.com/mastodon/mastodon/pull/25835))
- Fix dropdowns being disabled for logged out users in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25714), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25964))
- Fix explore page being inaccessible when opted-out of trends in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25716))
- Fix re-activated accounts possibly getting deleted by `AccountDeletionWorker` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25711))
- Fix `/api/v2/search` not working with following query param ([danielmbrasil](https://github.com/mastodon/mastodon/pull/25681))
- Fix inefficient query when requesting a new confirmation email from a logged-in account ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25669))
- Fix unnecessary concurrent calls to `/api/*/instance` in web UI ([mgmn](https://github.com/mastodon/mastodon/pull/25663))
- Fix resolving local URL for remote content ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25637))
- Fix search not being easily findable on smaller screens in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25576), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25631))
- Fix j/k keyboard shortcuts on some status lists ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25554))
- Fix missing validation on `default_privacy` setting ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25513))
- Fix incorrect pagination headers in `/api/v2/admin/accounts` ([danielmbrasil](https://github.com/mastodon/mastodon/pull/25477))
- Fix non-interactive upload container being given a `button` role and tabIndex ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25462))
- Fix always redirecting to onboarding in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/25396))
- Fix inconsistent use of middle dot (·) instead of bullet (•) to separate items ([j-f1](https://github.com/mastodon/mastodon/pull/25248))
- Fix spacing of middle dots in the detailed status meta section ([j-f1](https://github.com/mastodon/mastodon/pull/25247))
- Fix prev/next buttons color in media viewer ([renchap](https://github.com/mastodon/mastodon/pull/25231))
- Fix email addresses not being properly updated in `tootctl maintenance fix-duplicates` ([mjankowski](https://github.com/mastodon/mastodon/pull/25118))
- Fix unicode surrogate pairs sometimes being broken in page title ([eai04191](https://github.com/mastodon/mastodon/pull/25148))
- Fix various inefficient queries against account domains ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25126))
- Fix video player offering to expand in a lightbox when it's in an `iframe` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25067))
- Fix post embed previews ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25071))
- Fix inadequate error handling in several API controllers when given invalid parameters ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24947), [danielmbrasil](https://github.com/mastodon/mastodon/pull/24958), [danielmbrasil](https://github.com/mastodon/mastodon/pull/25063), [danielmbrasil](https://github.com/mastodon/mastodon/pull/25072), [danielmbrasil](https://github.com/mastodon/mastodon/pull/25386), [danielmbrasil](https://github.com/mastodon/mastodon/pull/25595))
- Fix uncaught `ActiveRecord::StatementInvalid` in Mastodon::IpBlocksCLI ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24861))
- Fix various edge cases with local moves ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24812))
- Fix `tootctl accounts cull` crashing when encountering a domain resolving to a private address ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23378))
- Fix `tootctl accounts approve --number N` not aproving the N earliest registrations ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24605))
- Fix being unable to clear media description when editing posts ([c960657](https://github.com/mastodon/mastodon/pull/24720))
- Fix unavailable translations not falling back to English ([mgmn](https://github.com/mastodon/mastodon/pull/24727))
- Fix anonymous visitors getting a session cookie on first visit ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24584), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24650), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24664))
- Fix cutting off first letter of hashtag links sometimes in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/24623))
- Fix crash in `tootctl accounts create --reattach --force` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24557), [danielmbrasil](https://github.com/mastodon/mastodon/pull/24680))
- Fix characters being emojified even when using Variation Selector 15 (text) ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20949), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24615))
- Fix uncaught ActiveRecord::StatementInvalid exception in `Mastodon::AccountsCLI#approve` ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24590))
- Fix email confirmation skip option in `tootctl accounts modify USERNAME --email EMAIL --confirm` ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24578))
- Fix tooltip for dates without time ([c960657](https://github.com/mastodon/mastodon/pull/24244))
- Fix missing loading spinner and loading more on scroll in Private Mentions column ([c960657](https://github.com/mastodon/mastodon/pull/24446))
- Fix account header image missing from `/settings/profile` on narrow screens ([c960657](https://github.com/mastodon/mastodon/pull/24433))
- Fix height of announcements not being updated when using reduced animations ([c960657](https://github.com/mastodon/mastodon/pull/24354))
- Fix inconsistent radius in advanced interface drawer ([thislight](https://github.com/mastodon/mastodon/pull/24407))
- Fix loading more trending posts on scroll in the advanced interface ([OmmyZhang](https://github.com/mastodon/mastodon/pull/24314))
- Fix poll ending notification for edited polls ([c960657](https://github.com/mastodon/mastodon/pull/24311))
- Fix max width of media in `/about` and `/privacy-policy` ([mgmn](https://github.com/mastodon/mastodon/pull/24180))
- Fix streaming API not being usable without `DATABASE_URL` ([Gargron](https://github.com/mastodon/mastodon/pull/23960))
- Fix external authentication not running onboarding code for new users ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23458))

## [4.1.8] - 2023-09-19

### Fixed

- Fix post edits not being forwarded as expected ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26936))
- Fix moderator rights inconsistencies ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26729))
- Fix crash when encountering invalid URL ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26814))
- Fix cached posts including stale stats ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26409))
- Fix uploading of video files for which `ffprobe` reports `0/0` average framerate ([NicolaiSoeborg](https://github.com/mastodon/mastodon/pull/26500))
- Fix unexpected audio stream transcoding when uploaded video is eligible to passthrough ([yufushiro](https://github.com/mastodon/mastodon/pull/26608))

### Security

- Fix missing HTML sanitization in translation API (CVE-2023-42452, [GHSA-2693-xr3m-jhqr](https://github.com/mastodon/mastodon/security/advisories/GHSA-2693-xr3m-jhqr))
- Fix incorrect domain name normalization (CVE-2023-42451, [GHSA-v3xf-c9qf-j667](https://github.com/mastodon/mastodon/security/advisories/GHSA-v3xf-c9qf-j667))

## [4.1.7] - 2023-09-05

### Changed

- Change remote report processing to accept reports with long comments, but truncate them ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/25028))

### Fixed

- **Fix blocking subdomains of an already-blocked domain** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26392))
- Fix `/api/v1/timelines/tag/:hashtag` allowing for unauthenticated access when public preview is disabled ([danielmbrasil](https://github.com/mastodon/mastodon/pull/26237))
- Fix inefficiencies in `PlainTextFormatter` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26727))

## [4.1.6] - 2023-07-31

### Fixed

- Fix memory leak in streaming server ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/26228))
- Fix wrong filters sometimes applying in streaming ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26159), [ThisIsMissEm](https://github.com/mastodon/mastodon/pull/26213), [renchap](https://github.com/mastodon/mastodon/pull/26233))
- Fix incorrect connect timeout in outgoing requests ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26116))

## [4.1.5] - 2023-07-21

### Added

- Add check preventing Sidekiq workers from running with Makara configured ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25850))

### Changed

- Change request timeout handling to use a longer deadline ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26055))

### Fixed

- Fix moderation interface for remote instances with a .zip TLD ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25885))
- Fix remote accounts being possibly persisted to database with incomplete protocol values ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25886))
- Fix trending publishers table not rendering correctly on narrow screens ([vmstan](https://github.com/mastodon/mastodon/pull/25945))

### Security

- Fix CSP headers being unintentionally wide ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/26105))

## [4.1.4] - 2023-07-07

### Fixed

- Fix branding:generate_app_icons failing because of disallowed ICO coder ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25794))
- Fix crash in admin interface when viewing a remote user with verified links ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25796))
- Fix processing of media files with unusual names ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25788))

## [4.1.3] - 2023-07-06

### Added

- Add fallback redirection when getting a webfinger query `LOCAL_DOMAIN@LOCAL_DOMAIN` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23600))

### Changed

- Change OpenGraph-based embeds to allow fullscreen ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25058))
- Change AccessTokensVacuum to also delete expired tokens ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24868))
- Change profile updates to be sent to recently-mentioned servers ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24852))
- Change automatic post deletion thresholds and load detection ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24614))
- Change `/api/v1/statuses/:id/history` to always return at least one item ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25510))
- Change auto-linking to allow carets in URL query params ([renchap](https://github.com/mastodon/mastodon/pull/25216))

### Removed

- Remove invalid `X-Frame-Options: ALLOWALL` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25070))

### Fixed

- Fix wrong view being displayed when a webhook fails validation ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25464))
- Fix soft-deleted post cleanup scheduler overwhelming the streaming server ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/25519))
- Fix incorrect pagination headers in `/api/v2/admin/accounts` ([danielmbrasil](https://github.com/mastodon/mastodon/pull/25477))
- Fix multiple inefficiencies in automatic post cleanup worker ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24607), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24785), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24840))
- Fix performance of streaming by parsing message JSON once ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/25278), [ThisIsMissEm](https://github.com/mastodon/mastodon/pull/25361))
- Fix CSP headers when `S3_ALIAS_HOST` includes a path component ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25273))
- Fix `tootctl accounts approve --number N` not approving N earliest registrations ([danielmbrasil](https://github.com/mastodon/mastodon/pull/24605))
- Fix reports not being closed when performing batch suspensions ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24988))
- Fix being able to vote on your own polls ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25015))
- Fix race condition when reblogging a status ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25016))
- Fix “Authorized applications” inefficiently and incorrectly getting last use date ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25060))
- Fix “Authorized applications” crashing when listing apps with certain admin API scopes ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25713))
- Fix multiple N+1s in ConversationsController ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25134), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25399), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/25499))
- Fix user archive takeouts when using OpenStack Swift ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24431))
- Fix searching for remote content by URL not working under certain conditions ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25637))
- Fix inefficiencies in indexing content for search ([VyrCossont](https://github.com/mastodon/mastodon/pull/24285), [VyrCossont](https://github.com/mastodon/mastodon/pull/24342))

### Security

- Add finer permission requirements for managing webhooks ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25463))
- Update dependencies
- Add hardening headers for user-uploaded files ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/25756))
- Fix verified links possibly hiding important parts of the URL (CVE-2023-36462)
- Fix timeout handling of outbound HTTP requests (CVE-2023-36461)
- Fix arbitrary file creation through media processing (CVE-2023-36460)
- Fix possible XSS in preview cards (CVE-2023-36459)

## [4.1.2] - 2023-04-04

### Fixed

- Fix crash in `tootctl` commands making use of parallelization when Elasticsearch is enabled ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24182), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/24377))
- Fix crash in `db:setup` when Elasticsearch is enabled ([rrgeorge](https://github.com/mastodon/mastodon/pull/24302))
- Fix user archive takeout when using OpenStack Swift or S3 providers with no ACL support ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24200))
- Fix invalid/expired invites being processed on sign-up ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24337))

### Security

- Update Ruby to 3.0.6 due to ReDoS vulnerabilities ([saizai](https://github.com/mastodon/mastodon/pull/24334))
- Fix unescaped user input in LDAP query ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24379))

## [4.1.1] - 2023-03-16

### Added

- Add redirection from paths with url-encoded `@` to their decoded form ([thijskh](https://github.com/mastodon/mastodon/pull/23593))
- Add `lang` attribute to native language names in language picker in Web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23749))
- Add headers to outgoing mails to avoid auto-replies ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23597))
- Add support for refreshing many accounts at once with `tootctl accounts refresh` ([9p4](https://github.com/mastodon/mastodon/pull/23304))
- Add confirmation modal when clicking to edit a post with a non-empty compose form ([PauloVilarinho](https://github.com/mastodon/mastodon/pull/23936))
- Add support for the HAproxy PROXY protocol through the `PROXY_PROTO_V1` environment variable ([CSDUMMI](https://github.com/mastodon/mastodon/pull/24064))
- Add `SENDFILE_HEADER` environment variable ([Gargron](https://github.com/mastodon/mastodon/pull/24123))
- Add cache headers to static files served through Rails ([Gargron](https://github.com/mastodon/mastodon/pull/24120))

### Changed

- Increase contrast of upload progress bar background ([toolmantim](https://github.com/mastodon/mastodon/pull/23836))
- Change post auto-deletion throttling constants to better scale with server size ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23320))
- Change order of bookmark and favourite sidebar entries in single-column UI for consistency ([TerryGarcia](https://github.com/mastodon/mastodon/pull/23701))
- Change `ActivityPub::DeliveryWorker` retries to be spread out more ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21956))

### Fixed

- Fix “Remove all followers from the selected domains” also removing follows and notifications ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23805))
- Fix streaming metrics format ([emilweth](https://github.com/mastodon/mastodon/pull/23519), [emilweth](https://github.com/mastodon/mastodon/pull/23520))
- Fix case-sensitive check for previously used hashtags in hashtag autocompletion ([deanveloper](https://github.com/mastodon/mastodon/pull/23526))
- Fix focus point of already-attached media not saving after edit ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23566))
- Fix sidebar behavior in settings/admin UI on mobile ([wxt2005](https://github.com/mastodon/mastodon/pull/23764))
- Fix inefficiency when searching accounts per username in admin interface ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23801))
- Fix duplicate “Publish” button on mobile ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23804))
- Fix server error when failing to follow back followers from `/relationships` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23787))
- Fix server error when attempting to display the edit history of a trendable post in the admin interface ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23574))
- Fix `tootctl accounts migrate` crashing because of a typo ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23567))
- Fix original account being unfollowed on migration before the follow request to the new account could be sent ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21957))
- Fix the “Back” button in column headers sometimes leaving Mastodon ([c960657](https://github.com/mastodon/mastodon/pull/23953))
- Fix pgBouncer resetting application name on every transaction ([Gargron](https://github.com/mastodon/mastodon/pull/23958))
- Fix unconfirmed accounts being counted as active users ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23803))
- Fix `/api/v1/streaming` sub-paths not being redirected ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23988))
- Fix drag'n'drop upload area text that spans multiple lines not being centered ([vintprox](https://github.com/mastodon/mastodon/pull/24029))
- Fix sidekiq jobs not triggering Elasticsearch index updates ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24046))
- Fix tags being unnecessarily stripped from plain-text short site description ([c960657](https://github.com/mastodon/mastodon/pull/23975))
- Fix HTML entities not being un-escaped in extracted plain-text from remote posts ([c960657](https://github.com/mastodon/mastodon/pull/24019))
- Fix dashboard crash on ElasticSearch server error ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23751))
- Fix incorrect post links in strikes when the account is remote ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23611))
- Fix misleading error code when receiving invalid WebAuthn credentials ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23568))
- Fix duplicate mails being sent when the SMTP server is too slow to close the connection ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23750))

### Security

- Change user backups to use expiring URLs for download when possible ([Gargron](https://github.com/mastodon/mastodon/pull/24136))
- Add warning for object storage misconfiguration ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/24137))

## [4.1.0] - 2023-02-10

### Added

- **Add support for importing/exporting server-wide domain blocks** ([enbylenore](https://github.com/mastodon/mastodon/pull/20597), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/21471), [dariusk](https://github.com/mastodon/mastodon/pull/22803), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/21470))
- **Add listing of followed hashtags** ([connorshea](https://github.com/mastodon/mastodon/pull/21773))
- **Add support for editing media description and focus point of already-sent posts** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20878))
  - Previously, you could add and remove attachments, but not edit media description of already-attached media
  - REST API changes:
    - `PUT /api/v1/statuses/:id` now takes an extra `media_attributes[]` array parameter with the `id` of the updated media and their updated `description`, `focus`, and `thumbnail`
- **Add follow request banner on account header** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20785))
  - REST API changes:
    - `Relationship` entities have an extra `requested_by` boolean attribute representing whether the represented user has requested to follow you
- **Add confirmation screen when handling reports** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22375), [Gargron](https://github.com/mastodon/mastodon/pull/23156), [tribela](https://github.com/mastodon/mastodon/pull/23178))
- Add option to make the landing page be `/about` even when trends are enabled ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20808))
- Add `noindex` setting back to the admin interface ([prplecake](https://github.com/mastodon/mastodon/pull/22205))
- Add instance peers API endpoint toggle back to the admin interface ([dariusk](https://github.com/mastodon/mastodon/pull/22810))
- Add instance activity API endpoint toggle back to the admin interface ([dariusk](https://github.com/mastodon/mastodon/pull/22833))
- Add setting for status page URL ([Gargron](https://github.com/mastodon/mastodon/pull/23390), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/23499))
  - REST API changes:
    - Add `configuration.urls.status` attribute to the object returned by `GET /api/v2/instance`
- Add `account.approved` webhook ([Saiv46](https://github.com/mastodon/mastodon/pull/22938))
- Add 12 hours option to polls ([Pleclown](https://github.com/mastodon/mastodon/pull/21131))
- Add dropdown menu item to open admin interface for remote domains ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21895))
- Add `--remove-headers`, `--prune-profiles` and `--include-follows` flags to `tootctl media remove` ([evanphilip](https://github.com/mastodon/mastodon/pull/22149))
- Add `--email` and `--dry-run` options to `tootctl accounts delete` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22328))
- Add `tootctl accounts migrate` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22330))
- Add `tootctl accounts prune` ([tribela](https://github.com/mastodon/mastodon/pull/18397))
- Add `tootctl domains purge` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22063))
- Add `SIDEKIQ_CONCURRENCY` environment variable ([muffinista](https://github.com/mastodon/mastodon/pull/19589))
- Add `DB_POOL` environment variable support for streaming server ([Gargron](https://github.com/mastodon/mastodon/pull/23470))
- Add `MIN_THREADS` environment variable to set minimum Puma threads ([jimeh](https://github.com/mastodon/mastodon/pull/21048))
- Add explanation text to log-in page ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20946))
- Add user profile OpenGraph tag on post pages ([bramus](https://github.com/mastodon/mastodon/pull/21423))
- Add maskable icon support for Android ([workeffortwaste](https://github.com/mastodon/mastodon/pull/20904))
- Add Belarusian to supported languages ([Mixaill](https://github.com/mastodon/mastodon/pull/22022))
- Add Western Frisian to supported languages ([ykzts](https://github.com/mastodon/mastodon/pull/18602))
- Add Montenegrin to the language picker ([ayefries](https://github.com/mastodon/mastodon/pull/21013))
- Add Southern Sami and Lule Sami to the language picker ([Jullan-M](https://github.com/mastodon/mastodon/pull/21262))
- Add logging for Rails cache timeouts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21667))
- Add color highlight for active hashtag “follow” button ([MFTabriz](https://github.com/mastodon/mastodon/pull/21629))
- Add brotli compression to `assets:precompile` ([Izorkin](https://github.com/mastodon/mastodon/pull/19025))
- Add “disabled” account filter to the `/admin/accounts` UI ([tribela](https://github.com/mastodon/mastodon/pull/21282))
- Add transparency to modal background for accessibility ([edent](https://github.com/mastodon/mastodon/pull/18081))
- Add `lang` attribute to image description textarea and poll option field ([c960657](https://github.com/mastodon/mastodon/pull/23293))
- Add `spellcheck` attribute to Content Warning and poll option input fields ([c960657](https://github.com/mastodon/mastodon/pull/23395))
- Add `title` attribute to video elements in media attachments ([bramus](https://github.com/mastodon/mastodon/pull/21420))
- Add left and right margins to emojis ([dsblank](https://github.com/mastodon/mastodon/pull/20464))
- Add `roles` attribute to `Account` entities in REST API ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23255), [tribela](https://github.com/mastodon/mastodon/pull/23428))
- Add `reading:autoplay:gifs` to `/api/v1/preferences` ([j-f1](https://github.com/mastodon/mastodon/pull/22706))
- Add `hide_collections` parameter to `/api/v1/accounts/credentials` ([CarlSchwan](https://github.com/mastodon/mastodon/pull/22790))
- Add `policy` attribute to web push subscription objects in REST API at `/api/v1/push/subscriptions` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23210))
- Add metrics endpoint to streaming API ([Gargron](https://github.com/mastodon/mastodon/pull/23388), [Gargron](https://github.com/mastodon/mastodon/pull/23469))
- Add more specific error messages to HTTP signature verification ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21617))
- Add Storj DCS to cloud object storage options in the `mastodon:setup` rake task ([jtolio](https://github.com/mastodon/mastodon/pull/21929))
- Add checkmark symbol in the checkbox for sensitive media ([sidp](https://github.com/mastodon/mastodon/pull/22795))
- Add missing accessibility attributes to logout link in modals ([kytta](https://github.com/mastodon/mastodon/pull/22549))
- Add missing accessibility attributes to “Hide image” button in `MediaGallery` ([hs4man21](https://github.com/mastodon/mastodon/pull/22513))
- Add missing accessibility attributes to hide content warning field when disabled ([hs4man21](https://github.com/mastodon/mastodon/pull/22568))
- Add `aria-hidden` to footer circle dividers to improve accessibility ([hs4man21](https://github.com/mastodon/mastodon/pull/22576))
- Add `lang` attribute to compose form inputs ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23240))

### Changed

- **Ensure exact match is the first result in hashtag searches** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21315))
- Change account search to return followed accounts first ([dariusk](https://github.com/mastodon/mastodon/pull/22956))
- Change batch account suspension to create a strike ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20897))
- Change default reply language to match the default language when replying to a translated post ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22272))
- Change misleading wording about waitlists ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20850))
- Increase width of the unread notification border ([connorshea](https://github.com/mastodon/mastodon/pull/21692))
- Change new post notification button on profiles to make it more apparent when it is enabled ([tribela](https://github.com/mastodon/mastodon/pull/22541))
- Change trending tags admin interface to always show batch action controls ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23013))
- Change wording of some OAuth scope descriptions ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22491))
- Change wording of admin report handling actions ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18388))
- Change confirm prompts for relationships management ([tribela](https://github.com/mastodon/mastodon/pull/19411))
- Change language surrounding disability in prompts for media descriptions ([hs4man21](https://github.com/mastodon/mastodon/pull/20923))
- Change confusing wording in the sign in banner ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22490))
- Change `POST /settings/applications/:id` to regenerate token on scopes change ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23359))
- Change account moderation notes to make links clickable ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22553))
- Change link previews for statuses to never use avatar as fallback ([Gargron](https://github.com/mastodon/mastodon/pull/23376))
- Change email address input to be read-only for logged-in users when requesting a new confirmation e-mail ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23247))
- Change notifications per page from 15 to 40 in REST API ([Gargron](https://github.com/mastodon/mastodon/pull/23348))
- Change number of stored items in home feed from 400 to 800 ([Gargron](https://github.com/mastodon/mastodon/pull/23349))
- Change API rate limits from 300/5min per user to 1500/5min per user, 300/5min per app ([Gargron](https://github.com/mastodon/mastodon/pull/23347))
- Save avatar or header correctly even if the other one fails ([tribela](https://github.com/mastodon/mastodon/pull/18465))
- Change `referrer-policy` to `same-origin` application-wide ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23014), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/23037))
- Add 'private' to `Cache-Control`, match Rails expectations ([daxtens](https://github.com/mastodon/mastodon/pull/20608))
- Make the button that expands the compose form differentiable from the button that publishes a post ([Tak](https://github.com/mastodon/mastodon/pull/20864))
- Change automatic post deletion configuration to be accessible to moved users ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20774))
- Make tag following idempotent ([trwnh](https://github.com/mastodon/mastodon/pull/20860), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/21285))
- Use buildx functions for faster builds ([inductor](https://github.com/mastodon/mastodon/pull/20692))
- Split off Dockerfile components for faster builds ([moritzheiber](https://github.com/mastodon/mastodon/pull/20933), [ineffyble](https://github.com/mastodon/mastodon/pull/20948), [BtbN](https://github.com/mastodon/mastodon/pull/21028))
- Change last occurrence of “silence” to “limit” in UI text ([cincodenada](https://github.com/mastodon/mastodon/pull/20637))
- Change “hide toot” to “hide post” ([seanthegeek](https://github.com/mastodon/mastodon/pull/22385))
- Don't allow URLs that contain non-normalized paths to be verified ([dgl](https://github.com/mastodon/mastodon/pull/20999))
- Change the “Trending now” header to be a link to the Explore page ([connorshea](https://github.com/mastodon/mastodon/pull/21759))
- Change PostgreSQL connection timeout from 2 minutes to 15 seconds ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21790))
- Make handle more easily selectable on profile page ([cadars](https://github.com/mastodon/mastodon/pull/21479))
- Allow admins to refresh remotely-suspended accounts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22327))
- Change dropdown menu to contain “Copy link to post” even for non-public posts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21316))
- Allow adding relays in secure mode and limited federation mode ([ineffyble](https://github.com/mastodon/mastodon/pull/22324))
- Change timestamps to be displayed using the user's timezone throughout the moderation interface ([FrancisMurillo](https://github.com/mastodon/mastodon/pull/21878), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/22555))
- Change CSP directives on API to be tight and concise ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20960))
- Change web UI to not autofocus the compose form ([raboof](https://github.com/mastodon/mastodon/pull/16517), [Akkiesoft](https://github.com/mastodon/mastodon/pull/23094))
- Change idempotency key handling for posting when database access is slow ([lambda](https://github.com/mastodon/mastodon/pull/21840))
- Change remote media files to be downloaded outside of transactions ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21796))
- Improve contrast of charts in “poll has ended” notifications ([j-f1](https://github.com/mastodon/mastodon/pull/22575))
- Change OEmbed detection and validation to be somewhat more lenient ([ineffyble](https://github.com/mastodon/mastodon/pull/22533))
- Widen ElasticSearch version detection to not display a warning for OpenSearch ([VyrCossont](https://github.com/mastodon/mastodon/pull/22422), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/23064))
- Change link verification to allow pages larger than 1MB as long as the link is in the first 1MB ([untitaker](https://github.com/mastodon/mastodon/pull/22879))
- Update default Node.js version to Node.js 16 ([ineffyble](https://github.com/mastodon/mastodon/pull/22223), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/22342))

### Removed

- Officially remove support for Ruby 2.6 ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21477))
- Remove `object-fit` polyfill used for old versions of Microsoft Edge ([shuuji3](https://github.com/mastodon/mastodon/pull/22693))
- Remove `intersection-observer` polyfill for old Safari support ([shuuji3](https://github.com/mastodon/mastodon/pull/23284))
- Remove empty `title` tag from mailer layout ([nametoolong](https://github.com/mastodon/mastodon/pull/23078))
- Remove post count and last posts from ActivityPub representation of hashtag collections ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23460))

### Fixed

- **Fix changing domain block severity not undoing individual account effects** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22135))
- Fix suspension worker crashing on S3-compatible setups without ACL support ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22487))
- Fix possible race conditions when suspending/unsuspending accounts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22363))
- Fix being stuck in edit mode when deleting the edited posts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22126))
- Fix attached media uploads not being cleared when replying to a post ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23504))
- Fix filters not being applied to some notification types ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23211))
- Fix incorrect link in push notifications for some event types ([elizabeth-dev](https://github.com/mastodon/mastodon/pull/23286))
- Fix some performance issues with `/admin/instances` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21907))
- Fix some pre-4.0 admin audit logs ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22091))
- Fix moderation audit log items for warnings having incorrect links ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23242))
- Fix account activation being sometimes triggered before email confirmation ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23245))
- Fix missing OAuth scopes for admin APIs ([trwnh](https://github.com/mastodon/mastodon/pull/20918), [trwnh](https://github.com/mastodon/mastodon/pull/20979))
- Fix voter count not being cleared when a poll is reset ([afontenot](https://github.com/mastodon/mastodon/pull/21700))
- Fix attachments of edited posts not being fetched ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21565))
- Fix irreversible and whole_word parameters handling in `/api/v1/filters` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21988))
- Fix 500 error when marking posts as sensitive while some of them are deleted ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22134))
- Fix expanded posts not always being scrolled into view ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21797))
- Fix not being able to scroll the remote interaction modal on small screens ([xendke](https://github.com/mastodon/mastodon/pull/21763))
- Fix not being able to scroll in post history modal ([cadars](https://github.com/mastodon/mastodon/pull/23396))
- Fix audio player volume control on Safari ([minacle](https://github.com/mastodon/mastodon/pull/23187))
- Fix disappearing “Explore” tabs on Safari ([nyura](https://github.com/mastodon/mastodon/pull/20917), [ykzts](https://github.com/mastodon/mastodon/pull/20982))
- Fix wrong padding in RTL layout ([Gargron](https://github.com/mastodon/mastodon/pull/23157))
- Fix drag & drop upload area display in single-column mode ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23217))
- Fix being unable to get a single EmailDomainBlock from the admin API ([trwnh](https://github.com/mastodon/mastodon/pull/20846))
- Fix admin-set follow recommandations being case-sensitive ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23500))
- Fix unserialized `role` on account entities in admin API ([Gargron](https://github.com/mastodon/mastodon/pull/23290))
- Fix pagination of followed tags ([trwnh](https://github.com/mastodon/mastodon/pull/20861))
- Fix dropdown menu positions when scrolling ([sidp](https://github.com/mastodon/mastodon/pull/22916), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/23062))
- Fix email with empty domain name labels passing validation ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23246))
- Fix mysterious registration failure when “Require a reason to join” is set with open registrations ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22127))
- Fix attachment rendering of edited posts in OpenGraph ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22270))
- Fix invalid/empty RSS feed link on account pages ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20772))
- Fix error in `VerifyLinkService` when processing links with no href ([joshuap](https://github.com/mastodon/mastodon/pull/20741))
- Fix error in `VerifyLinkService` when processing links with invalid URLs ([untitaker](https://github.com/mastodon/mastodon/pull/23204))
- Fix media uploads with FFmpeg 5 ([dead10ck](https://github.com/mastodon/mastodon/pull/21191))
- Fix sensitive flag not being set when replying to a post with a content warning under certain conditions ([kedamaDQ](https://github.com/mastodon/mastodon/pull/21724))
- Fix misleading message briefly showing up when loading follow requests under some conditions ([c960657](https://github.com/mastodon/mastodon/pull/23386))
- Fix “Share @:user's profile” profile menu item not working ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21490))
- Fix crash and incorrect behavior in `tootctl domains crawl` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19004))
- Fix autoplay on iOS ([jamesadney](https://github.com/mastodon/mastodon/pull/21422))
- Fix user clean-up scheduler crash when an unconfirmed account has a moderation note ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23318))
- Fix spaces not being stripped in admin account search ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21324))
- Fix spaces not being stripped when adding relays ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22655))
- Fix infinite loading spinner instead of soft 404 for non-existing remote accounts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21303))
- Fix minor visual issue with the top border of verified account fields ([j-f1](https://github.com/mastodon/mastodon/pull/22006))
- Fix pending account approval and rejection not being recorded in the admin audit log ([FrancisMurillo](https://github.com/mastodon/mastodon/pull/22088))
- Fix “Sign up” button with closed registrations not opening modal on mobile ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22060))
- Fix UI header overflowing on mobile ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21783))
- Fix 500 error when trying to migrate to an invalid address ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21462))
- Fix crash when trying to fetch unobtainable avatar of user using external authentication ([lochiiconnectivity](https://github.com/mastodon/mastodon/pull/22462))
- Fix processing error on incoming malformed JSON-LD under some situations ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23416))
- Fix potential duplicate posts in Explore tab ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22121))
- Fix deprecation warning in `tootctl accounts rotate` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22120))
- Fix styling of featured tags in light theme ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23252))
- Fix missing style in warning and strike cards ([AtelierSnek](https://github.com/mastodon/mastodon/pull/22177), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/22302))
- Fix wasteful request to `/api/v1/custom_emojis` when not logged in ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22326))
- Fix replies sometimes being delivered to user-blocked domains ([tribela](https://github.com/mastodon/mastodon/pull/22117))
- Fix admin dashboard crash when using some ElasticSearch replacements ([cortices](https://github.com/mastodon/mastodon/pull/21006))
- Fix profile avatar being slightly offset into left border ([RiedleroD](https://github.com/mastodon/mastodon/pull/20994))
- Fix N+1 queries in `NotificationsController` ([nametoolong](https://github.com/mastodon/mastodon/pull/21202))
- Fix being unable to react to announcements with the keycap number sign emoji ([kescherCode](https://github.com/mastodon/mastodon/pull/22231))
- Fix height computation of post embeds ([hodgesmr](https://github.com/mastodon/mastodon/pull/22141))
- Fix accessibility issue of the search bar due to hidden placeholder ([alexstine](https://github.com/mastodon/mastodon/pull/21275))
- Fix layout change handler not being removed due to a typo ([nschonni](https://github.com/mastodon/mastodon/pull/21829))
- Fix typo in the default `S3_HOSTNAME` used in the `mastodon:setup` rake task ([danp](https://github.com/mastodon/mastodon/pull/19932))
- Fix the top action bar appearing in the multi-column layout ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20943))
- Fix inability to use local LibreTranslate without setting `ALLOWED_PRIVATE_ADDRESSES` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21926))
- Fix punycoded local domains not being prettified in initial state ([Tritlo](https://github.com/mastodon/mastodon/pull/21440))
- Fix CSP violation warning by removing inline CSS from SVG logo ([luxiaba](https://github.com/mastodon/mastodon/pull/20814))
- Fix margin for search field on medium window size ([minacle](https://github.com/mastodon/mastodon/pull/21606))
- Fix search popout scrolling with the page in single-column mode ([rgroothuijsen](https://github.com/mastodon/mastodon/pull/16463))
- Fix minor post cache hydration discrepancy ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19879))
- Fix `・` detection in hashtags ([parthoghosh24](https://github.com/mastodon/mastodon/pull/22888))
- Fix hashtag follows bypassing user blocks ([tribela](https://github.com/mastodon/mastodon/pull/22849))
- Fix moved accounts being incorrectly redirected to account settings when trying to view a remote profile ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22497))
- Fix site upload validations ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22479))
- Fix “Add new domain block” button using last submitted search value instead of the current one ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22485))
- Fix misleading hashtag warning when posting with “Followers only” or “Mentioned people only” visibility ([n0toose](https://github.com/mastodon/mastodon/pull/22827))
- Fix embedded posts with videos grabbing focus ([Akkiesoft](https://github.com/mastodon/mastodon/pull/22778))
- Fix `$` not being escaped in `.env.production` files generated by the `mastodon:setup` rake task ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/23012), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/23072))
- Fix sanitizer parsing link text as HTML when stripping unsupported links ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22558))
- Fix `scheduled_at` input not using `datetime-local` when editing announcements ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/21896))
- Fix REST API serializer for `Account` not including `moved` when the moved account has itself moved ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22483))
- Fix `/api/v1/admin/trends/tags` using wrong serializer ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18943))
- Fix situations in which instance actor can be set to a Mastodon-incompatible name ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22307))

### Security

- Add `form-action` CSP directive ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20781), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/20958), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/20962))
- Fix unbounded recursion in account discovery ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/22025))
- Revoke all authorized applications on password reset ([FrancisMurillo](https://github.com/mastodon/mastodon/pull/21325))
- Fix unbounded recursion in post discovery ([ClearlyClaire,nametoolong](https://github.com/mastodon/mastodon/pull/23506))

## [4.0.2] - 2022-11-15

### Fixed

- Fix wrong color on mentions hidden behind content warning in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/20724))
- Fix filters from other users being used in the streaming service ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20719))
- Fix `unsafe-eval` being used when `wasm-unsafe-eval` is enough in Content Security Policy ([Gargron](https://github.com/mastodon/mastodon/pull/20729), [prplecake](https://github.com/mastodon/mastodon/pull/20606))

## [4.0.1] - 2022-11-14

### Fixed

- Fix nodes order being sometimes mangled when rewriting emoji ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20677))

## [4.0.0] - 2022-11-14

Some of the features in this release have been funded through the [NGI0 Discovery](https://nlnet.nl/discovery) Fund, a fund established by [NLnet](https://nlnet.nl/) with financial support from the European Commission's [Next Generation Internet](https://ngi.eu/) programme, under the aegis of DG Communications Networks, Content and Technology under grant agreement No 825322.

### Added

- Add ability to filter followed accounts' posts by language ([Gargron](https://github.com/mastodon/mastodon/pull/19095), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19268))
- **Add ability to follow hashtags** ([Gargron](https://github.com/mastodon/mastodon/pull/18809), [Gargron](https://github.com/mastodon/mastodon/pull/18862), [Gargron](https://github.com/mastodon/mastodon/pull/19472), [noellabo](https://github.com/mastodon/mastodon/pull/18924))
- Add ability to filter individual posts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18945))
- **Add ability to translate posts** ([Gargron](https://github.com/mastodon/mastodon/pull/19218), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19433), [Gargron](https://github.com/mastodon/mastodon/pull/19453), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19434), [Gargron](https://github.com/mastodon/mastodon/pull/19388), [ykzts](https://github.com/mastodon/mastodon/pull/19244), [Gargron](https://github.com/mastodon/mastodon/pull/19245))
- Add featured tags to web UI ([noellabo](https://github.com/mastodon/mastodon/pull/19408), [noellabo](https://github.com/mastodon/mastodon/pull/19380), [noellabo](https://github.com/mastodon/mastodon/pull/19358), [noellabo](https://github.com/mastodon/mastodon/pull/19409), [Gargron](https://github.com/mastodon/mastodon/pull/19382), [ykzts](https://github.com/mastodon/mastodon/pull/19418), [noellabo](https://github.com/mastodon/mastodon/pull/19403), [noellabo](https://github.com/mastodon/mastodon/pull/19404), [Gargron](https://github.com/mastodon/mastodon/pull/19398), [Gargron](https://github.com/mastodon/mastodon/pull/19712), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/20018))
- **Add support for language preferences for trending statuses and links** ([Gargron](https://github.com/mastodon/mastodon/pull/18288), [Gargron](https://github.com/mastodon/mastodon/pull/19349), [ykzts](https://github.com/mastodon/mastodon/pull/19335))
  - Previously, you could only see trends in your current language
  - For less popular languages, that meant empty trends
  - Now, trends in your preferred languages' are shown on top, with others beneath
- Add server rules to sign-up flow ([Gargron](https://github.com/mastodon/mastodon/pull/19296))
- Add privacy icons to report modal in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19190))
- Add `noopener` to links to remote profiles in web UI ([shleeable](https://github.com/mastodon/mastodon/pull/19014))
- Add option to open original page in dropdowns of remote content in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/20299))
- Add warning for sensitive audio posts in web UI ([rgroothuijsen](https://github.com/mastodon/mastodon/pull/17885))
- Add language attribute to posts in web UI ([tribela](https://github.com/mastodon/mastodon/pull/18544))
- Add support for uploading WebP files ([Saiv46](https://github.com/mastodon/mastodon/pull/18506))
- Add support for uploading `audio/vnd.wave` files ([tribela](https://github.com/mastodon/mastodon/pull/18737))
- Add support for uploading AVIF files ([txt-file](https://github.com/mastodon/mastodon/pull/19647))
- Add support for uploading HEIC files ([Gargron](https://github.com/mastodon/mastodon/pull/19618))
- Add more debug information when processing remote accounts ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/15605), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19209))
- **Add retention policy for cached content and media** ([Gargron](https://github.com/mastodon/mastodon/pull/19232), [zunda](https://github.com/mastodon/mastodon/pull/19478), [Gargron](https://github.com/mastodon/mastodon/pull/19458), [Gargron](https://github.com/mastodon/mastodon/pull/19248))
  - Set for how long remote posts or media should be cached on your server
  - Hands-off alternative to `tootctl` commands
- **Add customizable user roles** ([Gargron](https://github.com/mastodon/mastodon/pull/18641), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18812), [Gargron](https://github.com/mastodon/mastodon/pull/19040), [tribela](https://github.com/mastodon/mastodon/pull/18825), [tribela](https://github.com/mastodon/mastodon/pull/18826), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18776), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18777), [unextro](https://github.com/mastodon/mastodon/pull/18786), [tribela](https://github.com/mastodon/mastodon/pull/18824), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19436))
  - Previously, there were 3 hard-coded roles, user, moderator, and admin
  - Create your own roles and decide which permissions they should have
- Add notifications for new reports ([Gargron](https://github.com/mastodon/mastodon/pull/18697), [Gargron](https://github.com/mastodon/mastodon/pull/19475))
- Add ability to select all accounts matching search for batch actions in admin UI ([Gargron](https://github.com/mastodon/mastodon/pull/19053), [Gargron](https://github.com/mastodon/mastodon/pull/19054))
- Add ability to view previous edits of a status in admin UI ([Gargron](https://github.com/mastodon/mastodon/pull/19462))
- Add ability to block sign-ups from IP ([Gargron](https://github.com/mastodon/mastodon/pull/19037))
- **Add webhooks to admin UI** ([Gargron](https://github.com/mastodon/mastodon/pull/18510))
- Add admin API for managing domain allows ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18668))
- Add admin API for managing domain blocks ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18247))
- Add admin API for managing e-mail domain blocks ([Gargron](https://github.com/mastodon/mastodon/pull/19066))
- Add admin API for managing canonical e-mail blocks ([Gargron](https://github.com/mastodon/mastodon/pull/19067))
- Add admin API for managing IP blocks ([Gargron](https://github.com/mastodon/mastodon/pull/19065), [trwnh](https://github.com/mastodon/mastodon/pull/20207))
- Add `sensitized` attribute to accounts in admin REST API ([trwnh](https://github.com/mastodon/mastodon/pull/20094))
- Add `services` and `metadata` to the NodeInfo endpoint ([MFTabriz](https://github.com/mastodon/mastodon/pull/18563))
- Add `--remove-role` option to `tootctl accounts modify` ([Gargron](https://github.com/mastodon/mastodon/pull/19477))
- Add `--days` option to `tootctl media refresh` ([tribela](https://github.com/mastodon/mastodon/pull/18425))
- Add `EMAIL_DOMAIN_LISTS_APPLY_AFTER_CONFIRMATION` environment variable ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18642))
- Add `IP_RETENTION_PERIOD` and `SESSION_RETENTION_PERIOD` environment variables ([kescherCode](https://github.com/mastodon/mastodon/pull/18757))
- Add `http_hidden_proxy` environment variable ([tribela](https://github.com/mastodon/mastodon/pull/18427))
- Add `ENABLE_STARTTLS` environment variable ([erbridge](https://github.com/mastodon/mastodon/pull/20321))
- Add caching for payload serialization during fan-out ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19637), [Gargron](https://github.com/mastodon/mastodon/pull/19642), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19746), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19747), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19963))
- Add assets from Twemoji 14.0 ([Gargron](https://github.com/mastodon/mastodon/pull/19733))
- Add reputation and followers score boost to SQL-only account search ([Gargron](https://github.com/mastodon/mastodon/pull/19251))
- Add Scots, Balaibalan, Láadan, Lingua Franca Nova, Lojban, Toki Pona to languages list ([VyrCossont](https://github.com/mastodon/mastodon/pull/20168))
- Set autocomplete hints for e-mail, password and OTP fields ([rcombs](https://github.com/mastodon/mastodon/pull/19833), [offbyone](https://github.com/mastodon/mastodon/pull/19946), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/20071))
- Add support for DigitalOcean Spaces in setup wizard ([v-aisac](https://github.com/mastodon/mastodon/pull/20573))

### Changed

- **Change brand color and logotypes** ([Gargron](https://github.com/mastodon/mastodon/pull/18592), [Gargron](https://github.com/mastodon/mastodon/pull/18639), [Gargron](https://github.com/mastodon/mastodon/pull/18691), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18634), [Gargron](https://github.com/mastodon/mastodon/pull/19254), [mayaeh](https://github.com/mastodon/mastodon/pull/18710))
- **Change post editing to be enabled in web UI** ([Gargron](https://github.com/mastodon/mastodon/pull/19103))
- **Change web UI to work for logged-out users** ([Gargron](https://github.com/mastodon/mastodon/pull/18961), [Gargron](https://github.com/mastodon/mastodon/pull/19250), [Gargron](https://github.com/mastodon/mastodon/pull/19294), [Gargron](https://github.com/mastodon/mastodon/pull/19306), [Gargron](https://github.com/mastodon/mastodon/pull/19315), [ykzts](https://github.com/mastodon/mastodon/pull/19322), [Gargron](https://github.com/mastodon/mastodon/pull/19412), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19437), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19415), [Gargron](https://github.com/mastodon/mastodon/pull/19348), [Gargron](https://github.com/mastodon/mastodon/pull/19295), [Gargron](https://github.com/mastodon/mastodon/pull/19422), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19414), [Gargron](https://github.com/mastodon/mastodon/pull/19319), [Gargron](https://github.com/mastodon/mastodon/pull/19345), [Gargron](https://github.com/mastodon/mastodon/pull/19310), [Gargron](https://github.com/mastodon/mastodon/pull/19301), [Gargron](https://github.com/mastodon/mastodon/pull/19423), [ykzts](https://github.com/mastodon/mastodon/pull/19471), [ykzts](https://github.com/mastodon/mastodon/pull/19333), [ykzts](https://github.com/mastodon/mastodon/pull/19337), [ykzts](https://github.com/mastodon/mastodon/pull/19272), [ykzts](https://github.com/mastodon/mastodon/pull/19468), [Gargron](https://github.com/mastodon/mastodon/pull/19466), [Gargron](https://github.com/mastodon/mastodon/pull/19457), [Gargron](https://github.com/mastodon/mastodon/pull/19426), [Gargron](https://github.com/mastodon/mastodon/pull/19427), [Gargron](https://github.com/mastodon/mastodon/pull/19421), [Gargron](https://github.com/mastodon/mastodon/pull/19417), [Gargron](https://github.com/mastodon/mastodon/pull/19413), [Gargron](https://github.com/mastodon/mastodon/pull/19397), [Gargron](https://github.com/mastodon/mastodon/pull/19387), [Gargron](https://github.com/mastodon/mastodon/pull/19396), [Gargron](https://github.com/mastodon/mastodon/pull/19385), [ykzts](https://github.com/mastodon/mastodon/pull/19334), [ykzts](https://github.com/mastodon/mastodon/pull/19329), [Gargron](https://github.com/mastodon/mastodon/pull/19324), [Gargron](https://github.com/mastodon/mastodon/pull/19318), [Gargron](https://github.com/mastodon/mastodon/pull/19316), [Gargron](https://github.com/mastodon/mastodon/pull/19263), [trwnh](https://github.com/mastodon/mastodon/pull/19305), [ykzts](https://github.com/mastodon/mastodon/pull/19273), [Gargron](https://github.com/mastodon/mastodon/pull/19801), [Gargron](https://github.com/mastodon/mastodon/pull/19790), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19773), [Gargron](https://github.com/mastodon/mastodon/pull/19798), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19724), [Gargron](https://github.com/mastodon/mastodon/pull/19709), [Gargron](https://github.com/mastodon/mastodon/pull/19514), [Gargron](https://github.com/mastodon/mastodon/pull/19562), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19981), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19978), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/20148), [Gargron](https://github.com/mastodon/mastodon/pull/20302), [cutls](https://github.com/mastodon/mastodon/pull/20400))
  - The web app can now be accessed without being logged in
  - No more `/web` prefix on web app paths
  - Profiles, posts, and other public pages now use the same interface for logged in and logged out users
  - The web app displays a server information banner
  - Pop-up windows for remote interaction have been replaced with a modal window
  - No need to type in your username for remote interaction, copy-paste-to-search method explained
  - Various hints throughout the app explain what the different timelines are
  - New about page design
  - New privacy policy page design shows when the policy was last updated
  - All sections of the web app now have appropriate window titles
  - The layout of the interface has been streamlined between different screen sizes
  - Posts now use more horizontal space
- Change label of publish button to be "Publish" again in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/18583))
- Change language to be carried over on reply in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18557))
- Change "Unfollow" to "Cancel follow request" when request still pending in web UI ([prplecake](https://github.com/mastodon/mastodon/pull/19363))
- **Change post filtering system** ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18058), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19050), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18894), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19051), [noellabo](https://github.com/mastodon/mastodon/pull/18923), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18956), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18744), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/19878), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/20567))
  - Filtered keywords and phrases can now be grouped into named categories
  - Filtered posts show which exact filter was hit
  - Individual posts can be added to a filter
  - You can peek inside filtered posts anyway
- Change path of privacy policy page from `/terms` to `/privacy-policy` ([Gargron](https://github.com/mastodon/mastodon/pull/19249))
- Change how hashtags are normalized ([Gargron](https://github.com/mastodon/mastodon/pull/18795), [Gargron](https://github.com/mastodon/mastodon/pull/18863), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18854))
- Change settings area to be separated into categories in admin UI ([Gargron](https://github.com/mastodon/mastodon/pull/19407), [Gargron](https://github.com/mastodon/mastodon/pull/19533))
- Change "No accounts selected" errors to use the appropriate noun in admin UI ([prplecake](https://github.com/mastodon/mastodon/pull/19356))
- Change e-mail domain blocks to match subdomains of blocked domains ([Gargron](https://github.com/mastodon/mastodon/pull/18979))
- Change custom emoji file size limit from 50 KB to 256 KB ([Gargron](https://github.com/mastodon/mastodon/pull/18788))
- Change "Allow trends without prior review" setting to also work for trending posts ([Gargron](https://github.com/mastodon/mastodon/pull/17977))
- Change admin announcements form to use single inputs for date and time in admin UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18321))
- Change search API to be accessible without being logged in ([Gargron](https://github.com/mastodon/mastodon/pull/18963), [Gargron](https://github.com/mastodon/mastodon/pull/19326))
- Change following and followers API to be accessible without being logged in ([Gargron](https://github.com/mastodon/mastodon/pull/18964))
- Change `AUTHORIZED_FETCH` to not block unauthenticated REST API access ([Gargron](https://github.com/mastodon/mastodon/pull/19803))
- Change Helm configuration ([deepy](https://github.com/mastodon/mastodon/pull/18997), [jgsmith](https://github.com/mastodon/mastodon/pull/18415), [deepy](https://github.com/mastodon/mastodon/pull/18941))
- Change mentions of blocked users to not be processed ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19725))
- Change max. thumbnail dimensions to 640x360px (360p) ([Gargron](https://github.com/mastodon/mastodon/pull/19619))
- Change post-processing to be deferred only for large media types ([Gargron](https://github.com/mastodon/mastodon/pull/19617))
- Change link verification to only work for https links without unicode ([Gargron](https://github.com/mastodon/mastodon/pull/20304), [Gargron](https://github.com/mastodon/mastodon/pull/20295))
- Change account deletion requests to spread out over time ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20222))
- Change larger reblogs/favourites numbers to be shortened in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/20303))
- Change incoming activity processing to happen in `ingress` queue ([Gargron](https://github.com/mastodon/mastodon/pull/20264))
- Change notifications to not link show preview cards in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20335))
- Change amount of replies returned for logged out users in REST API ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20355))
- Change in-app links to keep you in-app in web UI ([trwnh](https://github.com/mastodon/mastodon/pull/20540), [Gargron](https://github.com/mastodon/mastodon/pull/20628))
- Change table header to be sticky in admin UI ([sk22](https://github.com/mastodon/mastodon/pull/20442))

### Removed

- Remove setting that disables account deletes ([Gargron](https://github.com/mastodon/mastodon/pull/17683))
- Remove digest e-mails ([Gargron](https://github.com/mastodon/mastodon/pull/17985))
- Remove unnecessary sections from welcome e-mail ([Gargron](https://github.com/mastodon/mastodon/pull/19299))
- Remove item titles from RSS feeds ([Gargron](https://github.com/mastodon/mastodon/pull/18640))
- Remove volume number from hashtags in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/19253))
- Remove Nanobox configuration ([tonyjiang](https://github.com/mastodon/mastodon/pull/17881))

### Fixed

- Fix rules with same priority being sorted non-deterministically ([Gargron](https://github.com/mastodon/mastodon/pull/20623))
- Fix error when invalid domain name is submitted ([Gargron](https://github.com/mastodon/mastodon/pull/19474))
- Fix icons having an image role ([Gargron](https://github.com/mastodon/mastodon/pull/20600))
- Fix connections to IPv6-only servers ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20108))
- Fix unnecessary service worker registration and preloading when logged out in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20341))
- Fix unnecessary and slow regex construction ([raggi](https://github.com/mastodon/mastodon/pull/20215))
- Fix `mailers` queue not being used for mailers ([Gargron](https://github.com/mastodon/mastodon/pull/20274))
- Fix error in webfinger redirect handling ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20260))
- Fix report category not being set to `violation` if rule IDs are provided ([trwnh](https://github.com/mastodon/mastodon/pull/20137))
- Fix nodeinfo metadata attribute being an array instead of an object ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20114))
- Fix account endorsements not being idempotent ([trwnh](https://github.com/mastodon/mastodon/pull/20118))
- Fix status and rule IDs not being strings in admin reports REST API ([trwnh](https://github.com/mastodon/mastodon/pull/20122))
- Fix error on invalid `replies_policy` in REST API ([trwnh](https://github.com/mastodon/mastodon/pull/20126))
- Fix redrafting a currently-editing post not leaving edit mode in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20023))
- Fix performance by avoiding method cache busts ([raggi](https://github.com/mastodon/mastodon/pull/19957))
- Fix opening the language picker scrolling the single-column view to the top in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19983))
- Fix content warning button missing `aria-expanded` attribute in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19975))
- Fix redundant `aria-pressed` attributes in web UI ([Brawaru](https://github.com/mastodon/mastodon/pull/19912))
- Fix crash when external auth provider has no display name set ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19962))
- Fix followers count not being updated when migrating follows ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19998))
- Fix double button to clear emoji search input in web UI ([sunny](https://github.com/mastodon/mastodon/pull/19888))
- Fix missing null check on applications on strike disputes ([kescherCode](https://github.com/mastodon/mastodon/pull/19851))
- Fix featured tags not saving preferred casing ([Gargron](https://github.com/mastodon/mastodon/pull/19732))
- Fix language not being saved when editing status ([Gargron](https://github.com/mastodon/mastodon/pull/19543))
- Fix not being able to input featured tag with hash symbol ([Gargron](https://github.com/mastodon/mastodon/pull/19535))
- Fix user clean-up scheduler crash when an unconfirmed account has a moderation note ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19629))
- Fix being unable to withdraw follow request when confirmation modal is disabled in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19687))
- Fix inaccurate admin log entry for re-sending confirmation e-mails ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19674))
- Fix edits not being immediately reflected ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19673))
- Fix bookmark import stopping at the first failure ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19669))
- Fix account action type validation ([Gargron](https://github.com/mastodon/mastodon/pull/19476))
- Fix upload progress not communicating processing phase in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/19530))
- Fix wrong host being used for custom.css when asset host configured ([Gargron](https://github.com/mastodon/mastodon/pull/19521))
- Fix account migration form ever using outdated account data ([Gargron](https://github.com/mastodon/mastodon/pull/18429), [nightpool](https://github.com/mastodon/mastodon/pull/19883))
- Fix error when uploading malformed CSV import ([Gargron](https://github.com/mastodon/mastodon/pull/19509))
- Fix avatars not using image tags in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/19488))
- Fix handling of duplicate and out-of-order notifications in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19693))
- Fix reblogs being discarded after the reblogged status ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19731))
- Fix indexing scheduler trying to index when Elasticsearch is disabled ([Gargron](https://github.com/mastodon/mastodon/pull/19805))
- Fix n+1 queries when rendering initial state JSON ([Gargron](https://github.com/mastodon/mastodon/pull/19795))
- Fix n+1 query during status removal ([Gargron](https://github.com/mastodon/mastodon/pull/19753))
- Fix OCR not working due to Content Security Policy in web UI ([prplecake](https://github.com/mastodon/mastodon/pull/18817))
- Fix `nofollow` rel being removed in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/19455))
- Fix language dropdown causing zoom on mobile devices in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/19428))
- Fix button to dismiss suggestions not showing up in search results in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19325))
- Fix language dropdown sometimes not appearing in web UI ([Gargron](https://github.com/mastodon/mastodon/pull/19246))
- Fix quickly switching notification filters resulting in empty or incorrect list in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19052), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/18960))
- Fix media modal link button in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18877))
- Fix error upon successful account migration ([Gargron](https://github.com/mastodon/mastodon/pull/19386))
- Fix negatives values in search index causing queries to fail ([Gargron](https://github.com/mastodon/mastodon/pull/19464), [Gargron](https://github.com/mastodon/mastodon/pull/19481))
- Fix error when searching for invalid URL ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18580))
- Fix IP blocks not having a unique index ([Gargron](https://github.com/mastodon/mastodon/pull/19456))
- Fix remote account in contact account setting not being used ([Gargron](https://github.com/mastodon/mastodon/pull/19351))
- Fix swallowing mentions of unconfirmed/unapproved users ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19191))
- Fix incorrect and slow cache invalidation when blocking domain and removing media attachments ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19062))
- Fix HTTPs redirect behaviour when running as I2P service ([gi-yt](https://github.com/mastodon/mastodon/pull/18929))
- Fix deleted pinned posts potentially counting towards the pinned posts limit ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19005))
- Fix compatibility with OpenSSL 3.0 ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18449))
- Fix error when a remote report includes a private post the server has no access to ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18760))
- Fix suspicious sign-in mails never being sent ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18599))
- Fix fallback locale when somehow user's locale is an empty string ([tribela](https://github.com/mastodon/mastodon/pull/18543))
- Fix avatar/header not being deleted locally when deleted on remote account ([tribela](https://github.com/mastodon/mastodon/pull/18973))
- Fix missing `,` in Blurhash validation ([noellabo](https://github.com/mastodon/mastodon/pull/18660))
- Fix order by most recent not working for relationships page in admin UI ([tribela](https://github.com/mastodon/mastodon/pull/18996))
- Fix uncaught error when invalid date is supplied to API ([Gargron](https://github.com/mastodon/mastodon/pull/19480))
- Fix REST API sometimes returning HTML on error ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/19135))
- Fix ambiguous column names in `tootctl media refresh` ([tribela](https://github.com/mastodon/mastodon/pull/19206))
- Fix ambiguous column names in `tootctl search deploy` ([mashirozx](https://github.com/mastodon/mastodon/pull/18993))
- Fix `CDN_HOST` not being used in some asset URLs ([tribela](https://github.com/mastodon/mastodon/pull/18662))
- Fix `CAS_DISPLAY_NAME`, `SAML_DISPLAY_NAME` and `OIDC_DISPLAY_NAME` being ignored ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18568))
- Fix various typos in comments throughout the codebase ([luzpaz](https://github.com/mastodon/mastodon/pull/18604))
- Fix CSV import error when rows include unicode characters ([HamptonMakes](https://github.com/mastodon/mastodon/pull/20592))

### Security

- Fix being able to spoof link verification ([Gargron](https://github.com/mastodon/mastodon/pull/20217))
- Fix emoji substitution not applying only to text nodes in backend code ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20641))
- Fix emoji substitution not applying only to text nodes in web UI ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/20640))
- Fix rate limiting for paths with formats ([Gargron](https://github.com/mastodon/mastodon/pull/20675))
- Fix out-of-bound reads in blurhash transcoder ([delroth](https://github.com/mastodon/mastodon/pull/20388))

_For previous changes, review the [stable-3.5 branch](https://github.com/mastodon/mastodon/blob/stable-3.5/CHANGELOG.md)_
