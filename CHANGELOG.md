Changelog
=========

All notable changes to this project will be documented in this file.

## [2.6.5] - 2018-12-01
### Changed

- Change lists to display replies to others on the list and list owner (#9324)

### Fixed

- Fix failures caused by commonly-used JSON-LD contexts being unavailable (#9412)

## [2.6.4] - 2018-11-30
### Fixed

- Fix yarn dependencies not installing due to yanked event-stream package (#9401)

## [2.6.3] - 2018-11-30
### Added

- Add hyphen to characters allowed in remote usernames (#9345)

### Changed

- Change server user count to exclude suspended accounts (#9380)

### Fixed

- Fix ffmpeg processing sometimes stalling due to overfilled stdout buffer (#9368)
- Fix missing DNS records raising the wrong kind of exception (#9379)
- Fix already queued deliveries still trying to reach inboxes marked as unavailable (#9358)

### Security

- Fix TLS handshake timeout not being enforced (#9381)

## [2.6.2] - 2018-11-23
### Added

- Add Page to whitelisted ActivityPub types (#9188)
- Add 20px to column width in web UI (#9227)
- Add amount of freed disk space in `tootctl media remove` (#9229, #9239, #9288)
- Add "Show thread" link to self-replies (#9228)

### Changed

- Change order of Atom and RSS links so Atom is first (#9302)
- Change Nginx configuration for Nanobox apps (#9310)
- Change the follow action to appear instant in web UI (#9220)
- Change how the ActiveRecord connection is instantiated in on_worker_boot (#9238)
- Change `tootctl accounts cull` to always touch accounts so they can be skipped (#9293)
- Change mime type comparison to ignore JSON-LD profile (#9179)

### Fixed

- Fix web UI crash when conversation has no last status (#9207)
- Fix follow limit validator reporting lower number past threshold (#9230)
- Fix form validation flash message color and input borders (#9235)
- Fix invalid twitter:player cards being displayed (#9254)
- Fix emoji update date being processed incorrectly (#9255)
- Fix playing embed resetting if status is reloaded in web UI (#9270, #9275)
- Fix web UI crash when favouriting a deleted status (#9272)
- Fix intermediary arrays being created for hash maps (#9291)
- Fix filter ID not being a string in REST API (#9303)

### Security

- Fix multiple remote account deletions being able to deadlock the database (#9292)
- Fix HTTP connection timeout of 10s not being enforced (#9329)

## [2.6.1] - 2018-10-30
### Fixed

- Fix resolving resources by URL not working due to a regression in #9132 (#9171)
- Fix reducer error in web UI when a conversation has no last status (#9173)

## [2.6.0] - 2018-10-30
### Added

- Add link ownership verification (#8703)
- Add conversations API (#8832)
- Add limit for the number of people that can be followed from one account (#8807)
- Add admin setting to customize mascot (#8766)
- Add support for more granular ActivityPub audiences from other software, i.e. circles (#8950, #9093, #9150)
- Add option to block all reports from a domain (#8830)
- Add user preference to always expand toots marked with content warnings (#8762)
- Add user preference to always hide all media (#8569)
- Add `force_login` param to OAuth authorize page (#8655)
- Add `tootctl accounts backup` (#8642, #8811)
- Add `tootctl accounts create` (#8642, #8811)
- Add `tootctl accounts cull` (#8642, #8811)
- Add `tootctl accounts delete` (#8642, #8811)
- Add `tootctl accounts modify` (#8642, #8811)
- Add `tootctl accounts refresh` (#8642, #8811)
- Add `tootctl feeds build` (#8642, #8811)
- Add `tootctl feeds clear` (#8642, #8811)
- Add `tootctl settings registrations open` (#8642, #8811)
- Add `tootctl settings registrations close` (#8642, #8811)
- Add `min_id` param to REST API to support backwards pagination (#8736)
- Add a confirmation dialog when hitting reply and the compose box isn't empty (#8893)
- Add PostgreSQL disk space growth tracking in PGHero (#8906)
- Add button for disabling local account to report quick actions bar (#9024)
- Add Czech language (#8594)
- Add `same-site` (`lax`) attribute to cookies (#8626)
- Add support for styled scrollbars in Firefox Nightly (#8653)
- Add highlight to the active tab in web UI profiles (#8673)
- Add auto-focus for comment textarea in report modal (#8689)
- Add auto-focus for emoji picker's search field (#8688)
- Add nginx and systemd templates to `dist/` directory (#8770)
- Add support for `/.well-known/change-password` (#8828)
- Add option to override FFMPEG binary path (#8855)
- Add `dns-prefetch` tag when using different host for assets or uploads (#8942)
- Add `description` meta tag (#8941)
- Add `Content-Security-Policy` header (#8957)
- Add cache for the instance info API (#8765)
- Add suggested follows to search screen in mobile layout (#9010)
- Add CORS header to `/.well-known/*` routes (#9083)
- Add `card` attribute to statuses returned from REST API (#9120)
- Add in-stream link preview (#9120)
- Add support for ActivityPub `Page` objects (#9121)

### Changed

- Change forms design (#8703)
- Change reports overview to group by target account (#8674)
- Change web UI to show "read more" link on overly long in-stream statuses (#8205)
- Change design of direct messages column (#8832, #9022)
- Change home timelines to exclude DMs (#8940)
- Change list timelines to exclude all replies (#8683)
- Change admin accounts UI default sort to most recent (#8813)
- Change documentation URL in the UI (#8898)
- Change style of success and failure messages (#8973)
- Change DM filtering to always allow DMs from staff (#8993)
- Change recommended Ruby version to 2.5.3 (#9003)
- Change docker-compose default to persist volumes in current directory (#9055)
- Change character counters on edit profile page to input length limit (#9100)
- Change notification filtering to always let through messages from staff (#9152)
- Change "hide boosts from user" function also hiding notifications about boosts (#9147)
- Change CSS `detailed-status__wrapper` class actually wrap the detailed status (#8547)

### Deprecated

- `GET /api/v1/timelines/direct` → `GET /api/v1/conversations` (#8832)
- `POST /api/v1/notifications/dismiss` → `POST /api/v1/notifications/:id/dismiss` (#8905)
- `GET /api/v1/statuses/:id/card` → `card` attributed included in status (#9120)

### Removed

- Remove "on this device" label in column push settings (#8704)
- Remove rake tasks in favour of tootctl commands (#8675)

### Fixed

- Fix remote statuses using instance's default locale if no language given (#8861)
- Fix streaming API not exiting when port or socket is unavailable (#9023)
- Fix network calls being performed in database transaction in ActivityPub handler (#8951)
- Fix dropdown arrow position (#8637)
- Fix first element of dropdowns being focused even if not using keyboard (#8679)
- Fix tootctl requiring `bundle exec` invocation (#8619)
- Fix public pages not using animation preference for avatars (#8614)
- Fix OEmbed/OpenGraph cards not understanding relative URLs (#8669)
- Fix some dark emojis not having a white outline (#8597)
- Fix media description not being displayed in various media modals (#8678)
- Fix generated URLs of desktop notifications missing base URL (#8758)
- Fix RTL styles (#8764, #8767, #8823, #8897, #9005, #9007, #9018, #9021, #9145, #9146)
- Fix crash in streaming API when tag param missing (#8955)
- Fix hotkeys not working when no element is focused (#8998)
- Fix some hotkeys not working on detailed status view (#9006)
- Fix og:url on status pages (#9047)
- Fix upload option buttons only being visible on hover (#9074)
- Fix tootctl not returning exit code 1 on wrong arguments (#9094)
- Fix preview cards for appearing for profiles mentioned in toot (#6934, #9158)
- Fix local accounts sometimes being duplicated as faux-remote (#9109)
- Fix emoji search when the shortcode has multiple separators (#9124)
- Fix dropdowns sometimes being partially obscured by other elements (#9126)
- Fix cache not updating when reply/boost/favourite counters or media sensitivity update (#9119)
- Fix empty display name precedence over username in web UI (#9163)
- Fix td instead of th in sessions table header (#9162)
- Fix handling of content types with profile (#9132)

## [2.5.2] - 2018-10-12
### Security

- Fix XSS vulnerability (#8959)

## [2.5.1] - 2018-10-07
### Fixed

- Fix database migrations for PostgreSQL below 9.5 (#8903)
- Fix class autoloading issue in ActivityPub Create handler (#8820)
- Fix cache statistics not being sent via statsd when statsd enabled (#8831)
- Bump puma from 3.11.4 to 3.12.0 (#8883)

### Security

- Fix some local images not having their EXIF metadata stripped on upload (#8714)
- Fix being able to enable a disabled relay via ActivityPub Accept handler (#8864)
- Bump nokogiri from 1.8.4 to 1.8.5 (#8881)
- Fix being able to report statuses not belonging to the reported account (#8916)
