# Changelog

All notable changes to this project will be documented in this file.

## [4.5.9] - 2026-04-15

### Security

- Insufficient verification of email addresses ([GHSA-5r37-qpwq-2jhh](https://github.com/mastodon/mastodon/security/advisories/GHSA-5r37-qpwq-2jhh))
- Updated dependencies

### Added

- Add trademark warning to `mastodon:setup` task (#38548 by @ClearlyClaire)

### Fixed

- Fix definition for `quote` in JSON-LD context (#38686 by @ClearlyClaire)
- Fix being unable to disable sound for quote update notification (#38537 by @ClearlyClaire)
- Fix being able to quote someone you blocked (#38608 by @ClearlyClaire)

## [4.5.8] - 2026-03-24

### Security

- Fix insufficient checks on quote authorizations ([GHSA-q4g8-82c5-9h33](https://github.com/mastodon/mastodon/security/advisories/GHSA-q4g8-82c5-9h33))
- Fix open redirect in legacy path handler ([GHSA-xqw8-4j56-5hj6](https://github.com/mastodon/mastodon/security/advisories/GHSA-xqw8-4j56-5hj6))
- Updated dependencies

### Added

- Add for searching already-known private GtS posts (#38057 by @ClearlyClaire)

### Changed

- Change media description length limit for remote media attachments from 1500 to 10000 characters (#37921 by @ClearlyClaire)
- Change HTTP signatures to skip the `Accept` header (#38132 by @ClearlyClaire)
- Change numeric AP endpoints to redirect to short account URLs when HTML is requested (#38056 by @ClearlyClaire)

### Fixed

- Fix some model definitions in `tootctl maintenance fix-duplicates` (#38214 by @ClearlyClaire)
- Fix overly strict checks for current username on account migration page (#38183 by @mjankowski)
- Fix OpenStack Swift Keystone token rate limiting (#38145 by @hugogameiro)
- Fix poll expiration notification being re-triggered on implicit updates (#38078 by @ClearlyClaire)
- Fix incorrect translation string in webauthn mailers (#38062 by @mjankowski)
- Fix “Unblock” and “Unmute” actions being disabled when blocked (#38075 by @ClearlyClaire)
- Fix username availability check being wrongly applied on race conditions (#37975 by @ClearlyClaire)
- Fix hover card unintentionally being shown in some cases (#38039 and #38112 by @diondiondion)
- Fix existing posts not being removed from lists when a list member is unfollowed (#38048 by @ClearlyClaire)

## [4.5.7] - 2026-02-24

### Security

- Reject unconfirmed FASPs (#37926 by @oneiros, [GHSA-qgmm-vr4c-ggjg](https://github.com/mastodon/mastodon/security/advisories/GHSA-qgmm-vr4c-ggjg))
- Re-use custom socket class for FASP requests (#37925 by @oneiros, [GHSA-46w6-g98f-wxqm](https://github.com/mastodon/mastodon/security/advisories/GHSA-46w6-g98f-wxqm))

### Added

- Add `--suspended-only` option to `tootctl emoji purge` (#37828 and #37861 by @ClearlyClaire and @mjankowski)

### Fixed

- Fix emoji data not being properly cached (#37858 by @ChaosExAnima)
- Fix delete & redraft of pending posts (#37839 by @ClearlyClaire)
- Fix processing separate key documents without the ActivityStreams context (#37826 by @ClearlyClaire)
- Fix custom emojis not being purged on domain suspension (#37808 by @ClearlyClaire)
- Fix users without special permissions being able to stream disabled timelines (#37791 by @ClearlyClaire)
- Fix processing of object updates with duplicate hashtags (#37756 by @ClearlyClaire)

## [4.5.6] - 2026-02-03

### Security

- Fix ActivityPub collection caching logic for pinned posts and featured tags not checking blocked accounts ([GHSA-ccpr-m53r-mfwr](https://github.com/mastodon/mastodon/security/advisories/GHSA-ccpr-m53r-mfwr))

### Changed

- Shorten caching of quote posts pending approval (#37570 and #37592 by @ClearlyClaire)

### Fixed

- Fix relationship cache not being cleared when handling account migrations (#37664 by @ClearlyClaire)
- Fix quote cancel button not appearing after edit then delete-and-redraft (#37066 by @PGrayCS)
- Fix followers with profile subscription (bell icon) being notified of post edits (#37646 by @ClearlyClaire)
- Fix error when encountering invalid tag in updated object (#37635 by @ClearlyClaire)
- Fix cross-server conversation tracking (#37559 by @ClearlyClaire)
- Fix recycled connections not being immediately closed (#37335 and #37674 by @ClearlyClaire and @shleeable)

## [4.5.5] - 2026-01-20

### Security

- Fix missing limits on various federated properties [GHSA-gg8q-rcg7-p79g](https://github.com/mastodon/mastodon/security/advisories/GHSA-gg8q-rcg7-p79g)
- Fix remote user suspension bypass [GHSA-5h2f-wg8j-xqwp](https://github.com/mastodon/mastodon/security/advisories/GHSA-5h2f-wg8j-xqwp)
- Fix missing length limits on some user-provided fields [GHSA-6x3w-9g92-gvf3](https://github.com/mastodon/mastodon/security/advisories/GHSA-6x3w-9g92-gvf3)
- Fix missing access check for push notification settings update [GHSA-f3q8-7vw3-69v4](https://github.com/mastodon/mastodon/security/advisories/GHSA-f3q8-7vw3-69v4)

### Changed

- Skip tombstone creation on deleting from 404 (#37533 by @ClearlyClaire)

### Fixed

- Fix potential duplicate handling of quote accept/reject/delete (#37537 by @ClearlyClaire)
- Fix `FeedManager#filter_from_home` error when handling a reblog of a deleted status (#37486 by @ClearlyClaire)
- Fix needlessly complicated SQL query in status batch removal (#37469 by @ClearlyClaire)
- Fix `quote_approval_policy` being reset to user defaults when omitted in status update (#37436 and #37474 by @mjankowski and @shleeable)
- Fix `Vary` parsing in cache control enforcement (#37426 by @MegaManSec)
- Fix missing URI scheme test in `QuoteRequest` handling (#37425 by @MegaManSec)
- Fix thread-unsafe ActivityPub activity dispatch (#37423 by @MegaManSec)
- Fix URI generation for reblogs by accounts with numerical ActivityPub identifiers (#37415 by @oneiros)
- Fix SignatureParser accepting duplicate parameters in HTTP Signature header (#37375 by @shleeable)
- Fix emoji with variant selector not being rendered properly (#37320 by @ChaosExAnima)
- Fix mobile admin sidebar displaying under batch table toolbar (#37307 by @diondiondion)

## [4.5.4] - 2026-01-07

### Security

- Fix SSRF protection bypass ([GHSA](https://github.com/mastodon/mastodon/security/advisories/GHSA-xfrj-c749-jxxq))
- Fix missing ownership check in severed relationships controller ([GHSA](https://github.com/mastodon/mastodon/security/advisories/GHSA-ww85-x9cp-5v24))

### Changed

- Change HTTP Signature verification status from 401 to 503 on temporary failure to get remote actor (#37221 by @ClearlyClaire)

### Fixed

- Fix custom emojis not being rendered in profile fields (#37365 by @ClearlyClaire)
- Fix serialization of context pages (#37376 by @ClearlyClaire)
- Fix quotes with CWs but no text not having fallback link (#37361 by @ClearlyClaire)
- Fix outdated link target for “locked” warning (#37366 by @ClearlyClaire)
- Fix local custom emojis sometimes being rendered in remote posts (#37284 by @ChaosExAnima)
- Fix some assets not being loaded from configured CDN (#37310 by @ChaosExAnima)
- Fix notifications page error in Tor browser (#37285 by @diondiondion)
- Fix custom emojis not being displayed in CWs and fav/boost notifications (#37272 and #37306 by @ChaosExAnima and @ClearlyClaire)
- Fix default `Admin` role not including `view_feeds` permission (#37301 by @ClearlyClaire)
- Fix hashtag autocomplete replacing suggestion's first characters with input (#37281 by @ClearlyClaire)
- Fix mentions of domain-blocked users being processed (#37257 by @ClearlyClaire)

## [4.5.3] - 2025-12-08

### Security

- Fix inconsistent error handling leaking information on existence of private posts ([GHSA-gwhw-gcjx-72v8](https://github.com/mastodon/mastodon/security/advisories/GHSA-gwhw-gcjx-72v8))

### Fixed

- Fix “Delete and Redraft” on a non-quote being treated as a quote post in some cases (#37140 by @ClearlyClaire)
- Fix YouTube embeds by sending referer (#37126 by @ChaosExAnima)
- Fix streamed quoted polls not being hydrated correctly (#37118 by @ClearlyClaire)
- Fix creation of duplicate conversations (#37108 by @oneiros)
- Fix extraneous `noreferrer` in external links (#37107 by @ChaosExAnima)
- Fix edge case error handling in some database migrations (#37079 by @ClearlyClaire)
- Fix error handling when re-fetching already-known statuses (#37077 by @ClearlyClaire)
- Fix post navigation in single-column mode when Advanced UI is enabled (#37044 by @diondiondion)
- Fix `tootctl status remove` removing quoted posts and remote quotes of local posts (#37009 by @ClearlyClaire)
- Fix known expensive S3 batch delete operation failing because of short timeouts (#37004 by @ClearlyClaire)
- Fix compose autosuggest always lowercasing input token (#36995 by @ClearlyClaire)

## [4.5.2] - 2025-11-20

### Changed

- Change private quote education modal to not show up on self-quotes (#36926 by @ClearlyClaire)

### Fixed

- Fix missing fallback link in CW-only quote posts (#36963 by @ClearlyClaire)
- Fix statuses without text being hidden while loading (#36962 by @ClearlyClaire)
- Fix `g` + `h` keyboard shortcut not working when a post is focused (#36935 by @diondiondion)
- Fix quoting overwriting current content warning (#36934 by @ClearlyClaire)
- Fix scroll-to-status in threaded view being unreliable (#36927 by @ClearlyClaire)
- Fix path resolution for emoji worker (#36897 by @ChaosExAnima)
- Fix `tootctl upgrade storage-schema` failing with `ArgumentError` (#36914 by @shugo)
- Fix cross-origin handling of CSS modules (#36890 by @ClearlyClaire)
- Fix error with remote tags including percent signs (#36886 and #36925 by @ChaosExAnima and @ClearlyClaire)
- Fix bogus quote approval policy not always being replaced correctly (#36885 by @ClearlyClaire)
- Fix hashtag completion not being inserted correctly (#36884 by @ClearlyClaire)
- Fix Cmd/Ctrl + Enter in the composer triggering confirmation dialog action (#36870 by @diondiondion)

## [4.5.1] - 2025-11-13

### Fixed

- Fix Cmd/Ctrl + Enter not submitting Alt text modal on some browsers (#36866 by @diondiondion)
- Fix posts coming from public/hashtag streaming being marked as unquotable (#36860 and #36869 by @ClearlyClaire)
- Fix old previously-undiscovered posts being treated as new when receiving an `Update` (#36848 by @ClearlyClaire)
- Fix blank screen in browsers that don't support `Intl.DisplayNames` (#36847 by @diondiondion)
- Fix filters not being applied to quotes in detailed view (#36843 by @ClearlyClaire)
- Fix scroll shift caused by fetch-all-replies alerts (#36807 by @diondiondion)
- Fix dropdown menu not focusing first item when opened via keyboard (#36804 by @diondiondion)
- Fix assets build issue on arch64 (#36781 by @ClearlyClaire)
- Fix `/api/v1/statuses/:id/context` sometimes returing `Mastodon-Async-Refresh` without `result_count` (#36779 by @ClearlyClaire)
- Fix prepared quote not being discarded with contents when replying (#36778 by @ClearlyClaire)

## [4.5.0] - 2025-11-06

### Added

- **Add support for allowing and authoring quotes** (#35355, #35578, #35614, #35618, #35624, #35626, #35652, #35629, #35665, #35653, #35670, #35677, #35690, #35697, #35689, #35699, #35700, #35701, #35709, #35714, #35713, #35715, #35725, #35749, #35769, #35780, #35762, #35804, #35808, #35805, #35819, #35824, #35828, #35822, #35835, #35865, #35860, #35832, #35891, #35894, #35895, #35820, #35917, #35924, #35925, #35914, #35930, #35941, #35939, #35948, #35955, #35967, #35990, #35991, #35975, #35971, #36002, #35986, #36031, #36034, #36038, #36054, #36052, #36055, #36065, #36068, #36083, #36087, #36080, #36091, #36090, #36118, #36119, #36128, #36094, #36129, #36138, #36132, #36151, #36158, #36171, #36194, #36220, #36169, #36130, #36249, #36153, #36299, #36291, #36301, #36315, #36317, #36364, #36383, #36381, #36459, #36464, #36461, #36516, #36528, #36549, #36550, #36559, #36693, #36704, #36690, #36689, #36696, #36721, #36695 and #36736 by @ChaosExAnima, @ClearlyClaire, @Lycolia, @diondiondion, and @tribela)\
  This includes a revamp of the composer interface.\
  See https://blog.joinmastodon.org/2025/09/introducing-quote-posts/ for a user-centric overview of the feature, and https://docs.joinmastodon.org/client/quotes/ for API documentation.
- **Add support for fetching and refreshing replies to the web UI** (#35210, #35496, #35575, #35500, #35577, #35602, #35603, #35654, #36141, #36237, #36172, #36256, #36271, #36334, #36382, #36239, #36484, #36481, #36583, #36627 and #36547 by @ClearlyClaire, @diondiondion, @Gargron and @renchap)
- **Add ability to block words in usernames** (#35407, #35655, and #35806 by @ClearlyClaire and @Gargron)
- Add ability to individually disable local or remote feeds for visitors or logged-in users `disabled` value to server setting for live and topic feeds, as well as user permission to bypass that (#36338, #36467, #36497, #36563, #36577, #36585, #36607 and #36703 by @ClearlyClaire)\
  This splits the `timeline_preview` setting into four more granular settings controlling live feeds and topic (hashtag, trending link) feeds.\
  The setting for local topic feeds has 2 values: `public` and `authenticated`. Every other setting has 3 values: `public`, `authenticated`, `disabled`.\
  When `disabled`, users with the “View live and topic feeds” will still be able to view them.
- Add support for displaying of quote posts in Moderator UI (#35964 by @ThisIsMissEm)
- Add support for displaying link previews for Admin UI (#35958 by @ThisIsMissEm)
- Add a new server setting to choose the server landing page (#36588 and #36602 by @ClearlyClaire and @renchap)
- Add support for `Update` activities on converted object types (#36322 by @ClearlyClaire)
- Add support for dynamic viewport height (#36272 by @e1berd)
- Add support for numeric-based URIs for new local accounts (#32724, #36304, #36316, and #36365 by @ClearlyClaire)
- Add default visualizer for audio upload without poster (#36734 by @ChaosExAnima)
- Add Traditional Mongolian to posting languages (#36196 by @shimon1024)
- Add example post with manual quote approval policy to `dev:populate_sample_data` (#36099 by @ClearlyClaire)
- Add server-side support for handling posts with a quote policy allowing followers to quote (#36093 and #36127 by @ClearlyClaire)
- Add schema.org markup to SEO-enabled posts (#36075 by @Gargron)
- Add migration to fill unset default quote policy based on default post privacy (#36041 by @ClearlyClaire)
- Add “Posting defaults” setting page, moving existing settings from “Other” (#35896, #36033, #35966, #35969, and #36084 by @ClearlyClaire and @diondiondion)
- Added emoji from Twemoji v16 (#36501 and #36530 by @ChaosExAnima)
- Add feature to select custom emoji rendering (#35229, #35282, #35253, #35424, #35473, #35483, #35505, #35568, #35605, #35659, #35664, #35739, #35985, #36051, #36071, #36137, #36165, #36248, #36262, #36275, #36293, #36341, #36342, #36366, #36377, #36378, #36385, #36393, #36397, #36403, #36413, #36410, #36454, #36402, #36503, #36502, #36532, #36603, #36409, #36638 and #36750 by @ChaosExAnima, @ClearlyClaire and @braddunbar)\
  This also completely reworks the processing and rendering of emojis and server-rendered HTML in statuses and other places.
- Add support for exposing conversation context for new public conversations according to FEP-7888 (#35959 and #36064 by @ClearlyClaire and @jesseplusplus)
- Add digest re-check before removing followers in synchronization mechanism (#34273 by @ClearlyClaire)
- Add support for displaying Valkey version on admin dashboard (#35785 by @ykzts)
- Add delivery failure tracking and handling to FASP jobs (#35625, #35628, and #35723 by @oneiros)
- Add example of quote post with a preview card to development sample data (#35616 by @ClearlyClaire)
- Add second set of blocked text that applies to accounts regardless of account age for spam-blocking (#35563 by @ClearlyClaire)

### Changed

- Change confirmation dialogs for follow button actions “unfollow”, “unblock”, and “withdraw request” (#36289 by @diondiondion)
- Change “Follow” button labels (#36264 by @diondiondion)
- Change appearance settings to introduce new Advanced settings section (#36496 and #36506 by @diondiondion)
- Change display of blocked and muted quoted users (#36619 by @ClearlyClaire)\
  This adds `blocked_account`, `blocked_domain` and `muted_account` values to the `state` attribute of `Quote` and `ShallowQuote` REST API entities.
- Change submitting an empty post to show an error rather than failing silently (#36650 by @diondiondion)
- Change "Privacy and reach" settings from "Public profile" to their own top-level category (#27294 by @ChaelCodes)
- Change number of times quote verification is retried to better deal with temporary failures (#36698 by @ClearlyClaire)
- Change display of content warnings in Admin UI (#35935 by @ThisIsMissEm)
- Change styling of column banners (#36531 by @ClearlyClaire)
- Change recommended Node version to 24 (LTS) (#36539 by @renchap)
- Change min. characters required for logged-out account search from 5 to 3 (#36487 by @Gargron)
- Change browser target to Vite legacy plugin defaults (#36611 by @larouxn)
- Change index on `follows` table to improve performance of some queries (#36374 by @ClearlyClaire)
- Change links to accounts in settings and moderation views to link to local view unless account is suspended (#36340 by @diondiondion)
- Change redirection for denied registration from web app to sign-in page with error message (#36384 by @ClearlyClaire)
- Change support for RFC9421 HTTP signatures to be enabled unconditionally (#36610 by @oneiros)
- Change wording and design of interaction dialog to simplify it (#36124 by @diondiondion)
- Change dropdown menus to allow disabled items to be focused (#36078 by @diondiondion)
- Change modal background colours in light mode (#36069 by @diondiondion)
- Change “Posting defaults” settings page to enforce `nobody` quote policy for `private` default visibility (#36040 by @ClearlyClaire)
- Change description of “Quiet public” (#36032 by @ClearlyClaire)
- Change “Boost with original visibility” to “Share again with your followers” (#36035 by @ClearlyClaire)
- Change handling of push subscriptions to automatically delete invalid ones on delivery (#35987 by @ThisIsMissEm)
- Change design of quote posts in web UI (#35584 and #35834 by @Gargron)
- Change auditable accounts to be sorted by username in admin action logs interface (#35272 by @breadtk)
- Change order of translation restoration and service credit on post card (#33619 by @colindean)
- Change position of ‘add more’ to be inside table toolbar on reports (#35963 by @ThisIsMissEm)
- Change docker-compose.yml sidekiq health check to work for both 4.4 and 4.5 (#36498 by @ClearlyClaire)

### Fixed

- Fix relationship not being fetched to evaluate whether to show a quote post (#36517 by @ClearlyClaire)
- Fix rendering of poll options in status history modal (#35633 by @ThisIsMissEm)
- Fix “mute” button being displayed to unauthenticated visitors in hashtag dropdown (#36353 by @mkljczk)
- Fix initially selected language in Rules panel, hide selector when no alternative translations exist (#36672 by @diondiondion)
- Fix URL comparison for mentions in case of empty path (#36613 and #36626 by @ClearlyClaire)
- Fix hashtags not being picked up when full-width hash sign is used (#36103 and #36625 by @ClearlyClaire and @Gargron)
- Fix layout of severed relationships when purged events are listed (#36593 by @mejofi)
- Fix Skeleton placeholders being animated when setting to reduce animations is enabled (#36716 by @ClearlyClaire)
- Fix vacuum tasks being interrupted by a single batch failure (#36606 by @Gargron)
- Fix handling of unreachable network error for search services (#36587 by @mjankowski)
- Fix bookmarks export when a bookmarked status is soft-deleted (#36576 by @ClearlyClaire)
- Fix text overflow alignment for long author names in News (#36562 by @diondiondion)
- Fix discovery preamble missing word in admin settings (#36560 by @belatedly)
- Fix overflow handling of `.more-from-author` (#36310 by @edent)
- Fix unfortunate action button wrapping in admin area (#36247 by @diondiondion)
- Fix translate button width in Safari (#36164 and #36216 by @diondiondion)
- Fix login page linking to other pages within OAuth authorization flow (#36115 by @Gargron)
- Fix stale search results being displayed in Web UI while new query is in progress (#36053 by @ChaosExAnima)
- Fix YouTube iframe not being able to start at a defined time (#26584 by @BrunoViveiros)
- Fix banned text being able to be circumvented via unicode (#35978 by @Gargron)
- Fix batch table toolbar displaying under status media (#35962 by @ThisIsMissEm)
- Fix incorrect RSS feed MIME type in gzip_types directive (#35562 by @iioflow)
- Fix 404 error after deleting status from detail view (#35800) (#35881 by @crafkaz)
- Fix feeds keyboard navigation issues (#35853, #35864, and #36267 by @braddunbar and @diondiondion)
- Fix layout shift caused by “Who to follow” widget (#35861 by @diondiondion)
- Fix Vagrantfile (#35765 by @ClearlyClaire)
- Fix reply indicator displaying wrong avatar in rare cases (#35756 by @ClearlyClaire)
- Fix `Chewy::UndefinedUpdateStrategy` in `dev:populate_sample_data` task when Elasticsearch is enabled (#35615 by @ClearlyClaire)
- Fix unnecessary account note addition for already-muted moved-to users (#35566 by @mjankowski)
- Fix seeded admin user creation failing on specific configurations (#35565 by @oneiros)
- Fix media modal images in Web UI having redundant `title` attribute (#35468 by @mayank99)
- Fix inconsistent default privacy post setting when unset in settings (#35422 by @oneiros)
- Fix glitchy status keyboard navigation (#35455 and #35504 by @diondiondion)
- Fix post being submitted when pressing “Enter” in the CW field (#35445 by @diondiondion)

### Removed

- Remove support for PostgreSQL 13 (#36540 by @renchap)

## [4.4.8] - 2025-10-21

### Security

- Fix quote control bypass ([GHSA-8h43-rcqj-wpc6](https://github.com/mastodon/mastodon/security/advisories/GHSA-8h43-rcqj-wpc6))

## [4.4.7] - 2025-10-15

### Fixed

- Fix forwarder being called with `nil` status when quote post is soft-deleted (#36463 by @ClearlyClaire)
- Fix moderation warning e-mails that include posts (#36462 by @ClearlyClaire)
- Fix allow_referrer_origin typo (#36460 by @ShadowJonathan)

## [4.4.6] - 2025-10-13

### Security

- Update dependencies `rack` and `uri`
- Fix streaming server connection not being closed on user suspension (by @ThisIsMissEm, [GHSA-r2fh-jr9c-9pxh](https://github.com/mastodon/mastodon/security/advisories/GHSA-r2fh-jr9c-9pxh))
- Fix password change through admin CLI not invalidating existing sessions and access tokens (by @ThisIsMissEm, [GHSA-f3q3-rmf7-9655](https://github.com/mastodon/mastodon/security/advisories/GHSA-f3q3-rmf7-9655))
- Fix streaming server allowing access to public timelines even without the `read` or `read:statuses` OAuth scopes (by @ThisIsMissEm, [GHSA-7gwh-mw97-qjgp](https://github.com/mastodon/mastodon/security/advisories/GHSA-7gwh-mw97-qjgp))

### Added

- Add support for processing quotes of deleted posts signaled through a `Tombstone` (#36381 by @ClearlyClaire)

### Fixed

- Fix quote post state sometimes not being updated through streaming server (#36408 by @ClearlyClaire)
- Fix inconsistent “pending tags” count on admin dashboard (#36404 by @mjankowski)
- Fix JSON payload being potentially mutated when processing interaction policies (#36392 by @ClearlyClaire)
- Fix quotes not being displayed in email notifications (#36379 by @diondiondion)
- Fix redirect to external object when URL is missing or malformed (#36347 by @ClearlyClaire)
- Fix quotes not being displayed in the featured carousel (#36335 by @diondiondion)

## [4.4.5] - 2025-09-23

### Security

- Update dependencies

### Added

- Add support for `has:quote` in search (#36217 by @ClearlyClaire)

### Changed

- Change quoted posts from silenced accounts to use a click-through rather than being hidden (#36166 and #36167 by @ClearlyClaire)

### Fixed

- Fix processing of out-of-order `Update` as implicit updates (#36190 by @ClearlyClaire)
- Fix getting `Create` and `Update` out of order (#36176 by @ClearlyClaire)
- Fix quotes with Content Warnings but no text being shown without Content Warnings (#36150 by @ClearlyClaire)

## [4.4.4] - 2025-09-16

### Security

- Update dependencies

### Fixed

- Fix missing memoization in `Web::PushNotificationWorker` (#36085 by @ClearlyClaire)
- Fix unresponsive areas around GIFV modals in some cases (#36059 by @ClearlyClaire)
- Fix missing `beforeUnload` confirmation when a poll is being authored (#36030 by @ClearlyClaire)
- Fix processing of remote edited statuses with new media and no text (#35970 by @unfokus)
- Fix polls not being displayed in moderation interface (#35644 and #35933 by @ThisIsMissEm)
- Fix WebUI handling of deleted quoted posts (#35909 and #35918 by @ClearlyClaire and @diondiondion)
- Fix “Edit” and “Delete & Redraft” on a poll not inserting empty option (#35892 by @ClearlyClaire)
- Fix loading of some compatibility CSS on some configurations (#35876 by @shleeable)
- Fix HttpLog not being enabled with `RAILS_LOG_LEVEL=debug` (#35833 by @mjankowski)
- Fix self-destruct scheduler behavior on some Redis setups (#35823 by @ClearlyClaire)
- Fix `tootctl admin create` not bypassing reserved username checks (#35779 by @ClearlyClaire)
- Fix interaction policy changes in implicit updates not being saved (#35751 by @ClearlyClaire)
- Fix quote revocation not being streamed (#35710 by @ClearlyClaire)
- Fix export of large user archives by enabling Zip64 (#35850 by @ClearlyClaire)

### Changed

- Change labels for quote policy settings (#35893 by @ClearlyClaire)
- Change standalone “Share” page to redirect to web interface after posting (#35763 by @ChaosExAnima)

## [4.4.3] - 2025-08-05

### Security

- Update dependencies
- Fix incorrect rate-limit handling [GHSA-84ch-6436-c7mg](https://github.com/mastodon/mastodon/security/advisories/GHSA-84ch-6436-c7mg)

### Fixed

- Fix race condition caused by ActiveRecord query cache in `Create` critical path (#35662 by @ClearlyClaire)
- Fix race condition caused by quote post processing (#35657 by @ClearlyClaire)
- Fix WebUI crashing for accounts with `null` URL (#35651 by @ClearlyClaire)
- Fix friends-of-friends recommendations suggesting already-requested accounts (#35604 by @ClearlyClaire)
- Fix synchronous recursive fetching of deeply-nested quoted posts (#35600 by @ClearlyClaire)
- Fix “Expand this post” link including user `@undefined` (#35478 by @ClearlyClaire)

### Changed

- Change `StatusReachFinder` to consider quotes as well as reblogs (#35601 by @ClearlyClaire)
- Add restrictions on which quote posts can trend (#35507 by @ClearlyClaire)
- Change quote verification to not bypass authorization flow for mentions (#35528 by @ClearlyClaire)

## [4.4.2] - 2025-07-23

### Security

- Update dependencies

### Fixed

- Fix menu not clickable in Firefox (#35390 and #35414 by @diondiondion)
- Add `lang` attribute to current composer language in alt text modal (#35412 by @diondiondion)
- Fix quote posts styling on notifications page (#35411 by @diondiondion)
- Improve a11y of custom select menus in notifications settings (#35403 by @diondiondion)
- Fix selected item in poll select menus is unreadable in Firefox (#35402 by @diondiondion)
- Update age limit wording (#35387 by @diondiondion)
- Fix support for quote verification in implicit status updates (#35384 by @ClearlyClaire)
- Improve `Dropdown` component accessibility (#35373 by @diondiondion)
- Fix processing some incoming quotes failing because of missing JSON-LD context (#35354 and #35380 by @ClearlyClaire)
- Make bio hashtags open the local page instead of the remote instance (#35349 by @ChaosExAnima)
- Fix styling of external log-in button (#35320 by @ClearlyClaire)

## [4.4.1] - 2025-07-09

### Fixed

- Fix nearly every sub-directory being crawled as part of Vite build (#35323 by @ClearlyClaire)
- Fix assets not building when Redis is unavailable (#35321 by @oneiros)
- Fix replying from media modal or pop-in-player tagging user `@undefined` (#35317 by @ClearlyClaire)
- Fix support for special characters in various environment variables (#35314 by @mjankowski and @ClearlyClaire)
- Fix some database migrations failing for indexes manually removed by admins (#35309 by @mjankowski)

## [4.4.0] - 2025-07-08

### Added

- **Add “Followers you know” widget to user profiles and hover cards** (#34652, #34678, #34681, #34697, #34699, #34769, #34774 and #34914 by @diondiondion)
- **Add featured tab to profiles on web UI and rework pinned posts** (#34405, #34483, #34491, #34754, #34855, #34858, #34868, #34869, #34927, #34995, #35056 and #34931 by @ChaosExAnima, @ClearlyClaire, @Gargron, and @diondiondion)
- Add endorsed accounts to featured tab in web UI (#34421 and #34568 by @Gargron)\
  This also includes the following new REST API endpoints:
  - `GET /api/v1/accounts/:id/endorsements`: https://docs.joinmastodon.org/methods/accounts/#endorsements
  - `POST /api/v1/accounts/:id/endorse`: https://docs.joinmastodon.org/methods/accounts/#endorse
  - `POST /api/v1/accounts/:id/unendorse`: https://docs.joinmastodon.org/methods/accounts/#unendorse
- Add ability to add and remove hashtags from featured tags in web UI (#34489, #34887, and #34490 by @ClearlyClaire and @Gargron)\
  This is achieved through the new REST API endpoints:
  - `POST /api/v1/tags/:id/feature`: https://docs.joinmastodon.org/methods/tags/#feature
  - `POST /api/v1/tags/:id/unfeature`: https://docs.joinmastodon.org/methods/tags/#unfeature
- Add reminder when about to post without alt text in web UI (#33760 and #33784 by @Gargron)
- Add a warning in Web UI when composing a post when the selected and detected language are different (#33042, #33683, #33700, #33724, #33770, and #34193 by @ClearlyClaire and @Gargron)
- Add support for verifying and displaying remote quote posts (#34370, #34481, #34510, #34551, #34480, #34479, #34553, #34584, #34623, #34738, #34766, #34770, #34772, #34773, #34786, #34790, #34864, #34957, #34961, #35016, #35022, #35036, #34946, #34945 and #34958 by @ClearlyClaire and @diondiondion)\
  Support for verifying remote quotes according to [FEP-044f](https://codeberg.org/fediverse/fep/src/branch/main/fep/044f/fep-044f.md) and displaying them in the Web UI has been implemented.\
  Quoting other people is not implemented yet, and it is currently not possible to mark your own posts as allowing quotes. However, a new “Who can quote” setting has been added to the “Posting defaults” section of the user settings. This setting allows you to set a default that will be used for new posts made on Mastodon 4.5 and newer, when quote posts will be fully implemented.\
  In the REST API, quote posts are represented by a new `quote` attribute on `Status` and `StatusEdit` entities: https://docs.joinmastodon.org/entities/StatusEdit/#quote https://docs.joinmastodon.org/entities/Status/#quote
- Add ability to reorder and translate server rules (#34637, #34737, #34494, #34756, #34820, #34997, #35170, #35174 and #35174 by @ChaosExAnima and @ClearlyClaire)\
  Rules are now shown in the user’s language, if a translation has been set.\
  In the REST API, `Rule` entities now have a new `translations` attribute: https://docs.joinmastodon.org/entities/Rule/#translations
- Add emoji from Twemoji 15.1.0, including in the emoji picker/completion (#33395, #34321, #34620, and #34677 by @ChaosExAnima, @ClearlyClaire, @TheEssem, and @eramdam)
- Add option to remove account from followers in web UI (#34488 by @Gargron)
- Add relationship tags to profiles and hover cards in web UI (#34467 and #34792 by @Gargron and @diondiondion)
- Add ability to open posts in a new tab by middle-clicking in web UI (#32988, #33106, #33419, and #34700 by @ClearlyClaire, @Gargron, and @tribela)
- Add new filter action to blur media (#34256 by @ClearlyClaire)\
  In the REST API, this adds a new possible value of `blur` to the `filter_action` attribute: https://docs.joinmastodon.org/entities/Filter/#filter_action
- Add dropdown menu to hashtag links in web UI (#34393 by @Gargron)
- **Add server setting to allow referrer** (#33214, #33239, #33903, and #34731 by @ChaosExAnima, @ClearlyClaire, @Gargron, and @renchap)\
  In order to protect the privacy of users of small or thematic servers, Mastodon previously avoided transmitting referrer information when clicking outside links, which unfortunately made Mastodon completely invisible to other websites, even though the privacy implications on large generic servers are very limited.\
  Server administrators can now chose to opt in to transmit referrer information when following an external link. Only the domain name is transmitted, not the referrer path.
- Add double tap to zoom and swipe to dismiss to media modal in web UI (#34210 by @Gargron)
- Add link from Web UI for Hashtags to the Moderation UI (#31448 by @ThisIsMissEm)
- **Add terms of service** (#33055, #33233, #33230, #33703, #33699, #33994, #33993, #34105, #34122, #34200, #34527, #35053, #35115, #35126, #35127 and #35233 by @ClearlyClaire, @Gargron, @mjankowski, and @oneiros)\
  Server administrators can now fill in Terms of Service and notify their users of upcoming changes.
- Add optional bulk mailer settings (#35191 and #35203 by @oneiros)\
  This adds the optional environment variables `BULK_SMTP_PORT`, `BULK_SMTP_SERVER`, `BULK_SMTP_LOGIN` and so on analogous to `SMTP_PORT`, `SMTP_SERVER`, `SMTP_LOGIN` and related SMTP configuration environment variables.\
  When `BULK_SMTP_SERVER` is set, this group of variables is used instead of the regular ones for sending announcement notification emails and Terms of Service notification emails.
- **Add age verification on sign-up** (#34150, #34663, and #34636 by @ClearlyClaire and @Gargron)\
  Server administrators now have a setting to set a minimum age requirement for creating a new server, asking users for their date of birth. The date of birth is checked against the minimum age requirement server-side but not stored.\
  The following REST API changes have been made to accommodate this:
  - `registrations.min_age` has been added to the `Instance` entity: https://docs.joinmastodon.org/entities/Instance/#registrations-min_age
  - the `date_of_birth` parameter has been added to the account creation API: https://docs.joinmastodon.org/methods/accounts/#create
- Add ability to dismiss alt text badge by tapping it in web UI (#33737 by @Gargron)
- Add loading indicator to timeline gap indicators in web UI (#33762 by @Gargron)
- Add interaction modal when trying to interact with a poll while logged out (#32609 by @ThisIsMissEm)
- **Add experimental FASP support** (#34031, #34415, #34765, #34965, #34964, #34033, #35218, #35262 and #35263 by @oneiros)\
  This is a first step towards supporting “Fediverse Auxiliary Service Providers” (https://github.com/mastodon/fediverse_auxiliary_service_provider_specifications). This is mostly interesting to developers who would like to implement their own FASP, but also includes the capability to share data with a discovery provider (see https://www.fediscovery.org).
- Add ability for admins to send announcements to all users via email (#33928 and #34411 by @ClearlyClaire)\
  This is meant for critical announcements only, as this will potentially send a lot of emails and cannot be opted out of by users.
- Add Server Moderation Notes (#31529 by @ThisIsMissEm)
- Add loading spinner to “Post” button when sending a post (#35153 by @diondiondion)
- Add option to use system scrollbar styling (#32117 by @vmstan)
- Add hover cards to follow suggestions (#33749 by @ClearlyClaire)
- Add `t` hotkey for post translations (#33441 by @ClearlyClaire)
- Add timestamp to all announcements in Web UI (#18329 by @ClearlyClaire)
- Add dropdown menu with quick actions to lists of accounts in web UI (#34391, #34709, and #34767 by @Gargron, @diondiondion, and @mkljczk)
- Add support for displaying “year in review” notification in web UI (#32710, #32765, #32709, #32807, #32914, #33148, and #33882 by @Gargron and @mjankowski)\
  Note that the notification is currently not generated automatically, and at the moment requires a manual undocumented administrator action.
- Add experimental support for receiving HTTP Message Signatures (RFC9421) (#34814, #35033, #35109 and #35278 by @oneiros)\
  For now, this needs to be explicitly enabled through the `http_message_signatures` feature flag (`EXPERIMENTAL_FEATURES=http_message_signatures`). This currently only covers verifying such signatures (inbound HTTP requests), not issuing them (outbound HTTP requests).
- Add experimental Async Refreshes API (#34918 by @oneiros)
- Add experimental server-side feature to fetch remote replies (#32615, #34147, #34149, #34151, #34615, #34682, and #34702 by @ClearlyClaire and @sneakers-the-rat)\
  This experimental feature causes the server to recursively fetch replies in background tasks whenever a user opens a remote post. This happens asynchronously and the client is currently not notified of the existence of new replies, which will thus only be displayed the next time this post’s context gets requested.\
  This feature needs to be explicitly enabled server-side by setting `FETCH_REPLIES_ENABLED` environment variable to `true`.
- Add simple feature flag system through the `EXPERIMENTAL_FEATURES` environment variable (#34038 and #34124 by @oneiros)\
  This allows enabling comma-separated feature flags for experimental features.\
  The current supported feature flags are `inbound_quotes`, `fasp` and `http_message_signatures`.
- Add `dev:populate_sample_data` rake task to populate test data (#34676, #34733, #34771, #34787, and #34791 by @ClearlyClaire and @diondiondion)
- Add support for displaying fallback representation when receiving MathML (#27107 by @4e554c4c)
- Add warning for Elasticsearch index analyzers mismatch (#34515 and #34567 by @ClearlyClaire and @Gargron)
- Add `-only-mapping` option to `tootctl search deploy` (#34466 and #34566 by @Gargron)
- Add server-side support for grouping account sign-up notifications (#34298 by @ClearlyClaire)
- Add `registrations.reason_required` attribute to `/api/v2/instance` response (#34280 by @ClearlyClaire)\
  This is documented at https://docs.joinmastodon.org/entities/Instance/#registrations-reason_required
- Add `EXTRA_MEDIA_HOSTS` environment variable to add extra hosts to Content-Security-Policy (#34184 by @shleeable)
- Add `Deprecation` headers on deprecated API endpoints (#34262 and #34397 by @ClearlyClaire)\
  This is documented at https://docs.joinmastodon.org/api/guidelines/#deprecations
- Add `about`, `privacy_policy` and `terms_of_service` URLs to `/api/v2/instance` (#33849 by @ClearlyClaire)
- Add API to delete media attachments that are not in use (#33991 and #34035 by @ClearlyClaire and @ThisIsMissEm)\
  `DELETE /api/v1/media/:id`: https://docs.joinmastodon.org/methods/media/#delete
- Add optional `delete_media` parameter to `DELETE /api/v1/statuses/:id` (#33988 by @ClearlyClaire)\
  This is documented at https://docs.joinmastodon.org/methods/statuses/#delete
- Add `og:locale` to expose status language in OpenGraph previews (#34012 by @ThisIsMissEm)
- Add `-skip-filled-timeline` option to `tootctl feed build` to skip half-filled feeds (#33844 by @ClearlyClaire)
- Add support for changing the base Docker registry with the `BASE_REGISTRY` `ARG` (#33712 by @wolfspyre)
- Add an optional metric exporter (#33734, #33840, #34172, #34192, #34223, and #35005 by @oneiros and @renchap)\
  Optionally enable the `prometheus_exporter` ruby gem (see https://github.com/discourse/prometheus_exporter) to collect and expose metrics. See the documentation for all the details: https://docs.joinmastodon.org/admin/config/#prometheus
- Add `attribution_domains` attribute to `PATCH /api/v1/accounts/update_credentials` (#32730 by @c960657)\
  This is documented at https://docs.joinmastodon.org/methods/accounts/#update_credentials
- Add support for standard WebPush in addition to previous draft (#33572, #33528, and #33587 by @ClearlyClaire and @p1gp1g)
- Add support for Active Record query log tags (#33342 by @renchap)
- Add OTel trace & span IDs to logs (#33339 and #33362 by @renchap)
- Add missing `on_delete: :cascade` foreign keys option to various database columns (#33175 by @mjankowski)
- Add explicit migration breakpoints (#33089 by @ClearlyClaire)
- Add rel alternate rss/json links to pages for tags (#33179 by @mjankowski)
- Add media attachment description limit to instance API response (#33153 by @mjankowski)\
  This adds the `configuration.media_attachments.description_limit` attribute to the `Instance` entity, documented at https://docs.joinmastodon.org/entities/Instance/#description_limit
- Add `maxlength` to registration reason input (#33162 by @mjankowski)
- Add `REPLICA_PREPARED_STATEMENTS` and `REPLICA_DB_TASKS` environment variables (#32908 by @shleeable)\
  See documentation at https://docs.joinmastodon.org/admin/scaling/#read-replicas
- Add a range of reserved usernames to reduce potential misuse by malicious actors (#32828 by @jmking-iftas)
- Add operations on relays to the admin audit log (#32819 by @ThisIsMissEm)
- Add userinfo OAuth endpoint (#32548 by @ThisIsMissEm)
- Add the standard VCS attributes to OpenTelemetry spans (#32904 by @renchap)
- Add endpoint to remove web push subscription (#32626 by @oneiros)\
  Mastodon now sets a new `Unsubscribe-URL` request header when performing WebPush requests. This URL can be used by the WebPush server to disable the WebPush subscription on Mastodon’s side in case of unfixable errors.
- Add missing content warning text to RSS feeds (#32406 by @mjankowski)
- Add Swiss German to languages dropdown (#29281 by @FlohEinstein)

### Changed

- Change design of navigation panel in Web UI, change layout on narrow screens (#34910, #34987, #35017, #34986, #35029, #35065, #35067, #35072, #35074, #35075, #35101, #35173, #35183, #35193 and #35225 by @ClearlyClaire, @Gargron, and @diondiondion)
- Change design of lists in web UI (#32881, #33054, and #33036 by @Gargron)
- Change design of edit media modal in web UI (#33516, #33702, #33725, #33725, #33771, and #34345 by @Gargron)
- Change design of audio player in web UI (#34520, #34740, #34865, #34929, #34933, and #35034 by @ClearlyClaire, @Gargron, and @diondiondion)
- Change design of interaction modal in web UI (#33278 by @Gargron)
- Change list timelines to reflect added and removed users retroactively (#32930 by @Gargron)
- Change account search to be more forgiving of spaces (#34455 by @Gargron)
- Change unfollow button label from “Mutual” to “Unfollow” in web UI (#34392 by @Gargron)
- Change “Specific people” to “Private mention” in menu in web UI (#33963 by @Gargron)
- Change "Explore" to "Trending" and remove explanation banners (#34985 by @Gargron)
- Change media attachments of moderated posts to not be accessible (#34872 by @Gargron)
  Moderators will still be able to access them while they are kept, but they won't be accessible to the public in the meantime.
- Change language names in compose box language picker to be localized (#33402 by @c960657)
- Change onboarding flow in web UI (#32998, #33119, #33471 and #34962 by @ClearlyClaire and @Gargron)
- Change Advanced Web UI to use the new main menu instead of the “Getting started” column (#35117 by @diondiondion)
- Change emoji categories in admin interface to be ordered by name (#33630 by @ShadowJonathan)
- Change design of rich text elements in web UI (#32633 by @Gargron)
- Change wording of “single choice” to “pick one” in poll authoring form (#32397 by @ThisIsMissEm)
- Change returned favorite and boost counts to use those provided by the remote server, if available (#32620, #34594, #34618, and #34619 by @ClearlyClaire and @sneakers-the-rat)
- Change label of favourite notifications on private mentions (#31659 by @ClearlyClaire)
- Change wording of "discard draft?" confirmation dialogs (#35192 by @diondiondion)
- Change `libvips` to be enabled by default in place of ImageMagick (#34741 and #34753 by @ClearlyClaire and @diondiondion)
- Change avatar and header size limits from 2MB to 8MB when using libvips (#33002 by @Gargron)
- Change search to use query params in web UI (#32949 and #33670 by @ClearlyClaire and @Gargron)
- Change build system from Webpack to Vite (#34454, #34450, #34758, #34768, #34813, #34808, #34837, #34732, #35007, #35035 and #35177 by @ChaosExAnima, @ClearlyClaire, @mjankowski, and @renchap)
- Change account creation API to forbid creation from user tokens (#34828 by @ThisIsMissEm)
- Change `/api/v2/instance` to be enabled without authentication when limited federation mode is enabled (#34576 by @ClearlyClaire)
- Change `DEFAULT_LOCALE` to not override unauthenticated users’ browser language (#34535 by @ClearlyClaire)\
  If you want to preserve the old behavior, you can add `FORCE_DEFAULT_LOCALE=true`.
- Change size of profile picture on profile page from 90px to 92px (#34807 by @larouxn)
- Change passthrough video processing to emit `moov` atom at start of video (#34726 by @ClearlyClaire)
- Change kerning to be disabled for Japanese text to preserve monospaced alignment for readability (#34448 by @nagutabby)
- Change error handling of various endpoints to return 422 instead of 500 on invalid parameters (#29308, #34434, and #34452 by @danielmbrasil and @mjankowski)
- Change Web UI to use `<time>` tags for various timestamps (#34131 by @scarf005)
- Change devcontainer to be accessible from local network (#34269 by @ChaosExAnima)
- Change video transcoding code to skip re-encoding yuvj420p videos (#34098 by @rinsuki)
- Change web client settings to be saved earlier and more often (#34074 by @ClearlyClaire)
- Change test coverage report generation to be disabled by default, with opt-in through the `COVERAGE` environment variable (#33824 by @mjankowski)
- Change devcontainer to store bootsnap cache outside of bind mounts (#33677 by @c960657)
- Change error handling in the `mastodon:setup` rake task to summarize encountered errors at the end (#33603 by @mjankowski)
- Change tooltip of some moderation interface timestamps to include time in addition to date (#33191 by @ThisIsMissEm)
- Change organization and wording of `README.md`, `CONTRIBUTING.md` and `DEVELOPMENT.md` (#32143, #33328, #33517, #33637, #33728, #34675, and #34761 by @Lamparter, @andypiper, @diondiondion, @larouxn, @mikkelricky, and @mjankowski)
- Change custom CSS to be cached for longer and invalidated based on its contents (#33207 and #33583 by @mjankowski and @tribela)
- Change `tootctl maintenance fix-duplicates` to disable database statement timeouts (#33484 by @mjankowski)
- Change some icons in settings sidebar to avoid “double icon” near each other (#33449 by @mjankowski)
- Change animation on feed generation screen in web UI (#33311 by @Gargron)
- Change OTel instrumentation to not start traces with Redis spans (#33090 by @robbkidd)
- Change new post delivery to skip suspended followers (#27509 and #33030 by @ClearlyClaire and @oneiros)
- Change URL truncation to account for ellipses (#33229 by @FND)
- Change ability to navigate of unconfirmed users (#33209 by @Gargron)
- Change hashtag trends to be stored in the database instead of redis (#32837, #33189, and #34016 by @Gargron and @onekopaka)
- Change “social web” to “fediverse” in a few banners in web UI (#33101 by @Gargron)
- Change server rules to be collapsible (#33039 by @Gargron)
- Change design of modal loading and error screens in web UI (#33092 by @Gargron)
- Change error messages to be more accurate when failing to add an account to a list (#33082 by @Gargron)
- Change timezone picker in the default settings to show the default timezone (#31803 by @c960657)
- Change `tootctl accounts modify --disable-2fa` to remove webauthn credentials (#29883 by @mszpro)
- Change preview card processing to be more liberal in what it accepts (#31357 by @c960657)
- Change scheduled statuses to be discarded if the author’s account is frozen (#30729 by @PauloVilarinho)
- Change display of statuses in admin panel (#30813 by @ThisIsMissEm)
- Change parsing of `ALLOWED_PRIVATE_ADDRESSES` to happen at startup (#32850 by @ClearlyClaire)
- Change WebPush delivery to skip notifications older than 2 days old (#32842 by @ThisIsMissEm)
- Change PWA manifest to prefer official mobile apps (#27254 by @jake-anto)

### Removed

- **Remove support for Redis namespaces** (#34664 and #34665 by @ClearlyClaire)\
  See https://github.com/mastodon/redis_namespace_migration
- Remove support for imports started on pre-4.2.0 Mastodon versions (#34371 by @mjankowski)
- Remove support for PostgreSQL 12 and earlier (#34744 by @ClearlyClaire)
- Remove support for Node.JS < 20 (#34390 by @renchap)
- Remove support for Redis < 6.2 (#30413 by @ClearlyClaire)
- Remove support for Ruby 3.1 (#32363 by @mjankowski)
- Remove support for OAuth Password Grant Type (#30960 by @ThisIsMissEm)\
  https://docs.joinmastodon.org/spec/oauth/#token
- Remove `OTP_SECRET` environment variable and legacy OTP code (#34743, #34757, #34748, and #34810 by @ClearlyClaire and @mjankowski)\
  This breaks zero-downtime migrations from versions earlier than 4.3.0.
- Remove broken support for HTTP Basic Authentication (#34501 by @ThisIsMissEm)
- Remove system tooltip for alt text in web UI (#33736 by @Gargron)
- Remove `thing_type` and `thing_id` columns from settings table (#31971 and #33196 by @ClearlyClaire and @mjankowski)
- Remove redundant temporary index creation in `tootctl status remove` (#33023 by @ClearlyClaire)
- Remove duplicate indexes from database (#32454 by @mjankowski)
- Remove redundant title attribute in column links (#32258 by @c960657)

### Fixed

- Fix remote suspension of a user causing local instance to remove remote follows (#27588 by @ShadowJonathan)
- Fix blocked accounts not being automatically removed from trending statuses (#34891 by @ClearlyClaire)
- Fix nested buttons in search popout in web UI (#34871 by @Gargron)
- Fix not being able to scroll dropdown on touch devices in web UI (#34873 by @Gargron)
- Fix inconsistent filtering of silenced accounts for other silenced accounts (#34863 by @ClearlyClaire)
- Fix update checker listing updates older or equal to current running version (#33906 by @ClearlyClaire)
- Fix clicking a status multiple times causing duplicate entries in browser history (#35118 by @ClearlyClaire)
- Fix “Alt text” button submitting form in moderation interface (#35147 by @ClearlyClaire)
- Fix Firefox sometimes not updating spellcheck language in textarea (#35148 by @ClearlyClaire)
- Fix `NoMethodError` in edge case of emoji cache handling (#34749 by @dariusk)
- Fix handling of inlined `featured` collections in ActivityPub actor objects (#34789 and #34811 by @ClearlyClaire)
- Fix long link names in admin sidebar being truncated (#34727 by @diondiondion)
- Fix admin dashboard crash on specific Elasticsearch connection errors (#34683 by @ClearlyClaire)
- Fix OIDC account creation failing for long display names (#34639 by @defnull)
- Fix use of the deprecated `/api/v1/instance` endpoint in the moderation interface (#34613 by @renchap)
- Fix inaccessible “Clear search” button (#35152 and #35281 by @diondiondion)
- Fix search operators sometimes getting lost (#35190 by @ClearlyClaire)
- Fix directory scroll position reset (#34560 by @przucidlo)
- Fix needlessly complex SVG paths for oEmbed and logo (#34538 by @edent)
- Fix avatar sizing with long account name in some UI elements (#34514 by @gomasy)
- Fix empty menu section in status dropdown (#34431 by @ClearlyClaire)
- Fix the delete suggestion button not working (#34396 and #34398 by @ClearlyClaire and @renchap)
- Fix popover/dialog backgrounds not being blurred on older Webkit browsers (#35220 by @diondiondion)
- Fix radio buttons not always being correctly centered (#34389 by @ChaosExAnima)
- Fix visual glitches with adding post filters (#34387 by @ChaosExAnima)
- Fix bugs with upload progress (#34325 by @ChaosExAnima)
- Fix being unable to hide controls in full screen video in web UI (#34308 by @Gargron)
- Fix extra space under left-indented vertical videos (#34313 by @ClearlyClaire)
- Fix glitchy iOS media attachment drag interactions (#35057 by @diondiondion)
- Fix zoomed images being blurry in Safari (#35052 by @diondiondion)
- Fix redundant focus stop within status component in Web UI and make focus style more noticeable (#35037, #35051, #35096, #35150 and #35251 by @diondiondion)
- Fix digits in media player time readout not having a consistent width (#35038 by @diondiondion)
- Fix wrong text color for “Open in advanced web interface” banner in high-contrast theme (#35032 by @diondiondion)
- Fix hover card for limited accounts not hiding information as expected (#35024 by @diondiondion)
- Fix some animations not respecting the reduced animation preferences (#35018 by @ChaosExAnima)
- Fix direction of media gallery arrows in RTL locales (#35014 by @diondiondion)
- Fix cramped layout of follower recommendations on small viewports (#34967 and #35023 by @diondiondion)
- Fix two composers being shown at the same time in some cases (#35006 by @ChaosExAnima)
- Fix handling of remote attachments with multiple media types (#34996 by @ClearlyClaire)
- Fix broken colors in some themed SVGs in web UI (#34988 by @Gargron)
- Fix wrong dimensions on blurhash previews of news articles in web UI (#34990 by @Gargron)
- Fix wrong styles on action bar in media modal in web UI (#34989 by @Gargron)
- Fix search column input not updating on param change (#34951 by @PGrayCS)
- Fix account note textarea being interactable before the relationship gets fetched (#34932 by @ClearlyClaire)
- Fix SASS deprecation notices (#34278 by @ChaosExAnima)
- Fix display of failed-to-load image attachments in web UI (#34217 by @Gargron)
- Fix duplicate REST API requests on submitting account personal note with ctrl+enter (#34213 by @ClearlyClaire)
- Fix unnecessary rerenders in composer dropdown menu (#34133 by @ClearlyClaire)
- Fix behavior of database schema loading with `SKIP_POST_DEPLOYMENT_MIGRATIONS` (#34089 by @ClearlyClaire)
- Fix infinite scroll not working on profile media tab in web UI (#33860 and #34171 by @ClearlyClaire and @Gargron)
- Fix minor inefficiencies in domain suspension code (#33897 by @larouxn)
- Fix potential inefficiency in media privacy system check (#33858 by @ClearlyClaire)
- Fix public timeline inefficiency by adding the `language` column to the public timelines index (#33779 by @ClearlyClaire)
- Fix re-encoding of high-framerate VFR videos with FFmpeg 6+ (#33634 by @ClearlyClaire)
- Fix error when processing invalid `Announce` activity with missing object (#33570 by @ShadowJonathan)
- Fix color contrast in report modal (#33468 by @ClearlyClaire)
- Fix error 500 when passing an invalid `lang` parameter (#33467 by @ClearlyClaire)
- Fix `/share` not using server-set characters limit (#33459 by @kescherCode)
- Fix audio player modal having white-on-white buttons in light theme (#33444 by @ClearlyClaire)
- Fix favorite & bookmark text toggle in timeline, status and image view (#27209 by @gunchleoc)
- Fix Web UI erroneously stopping to offer expanding search results after second page (#33428 by @ClearlyClaire)
- Fix missing value limits for `UserRole` position (#33172 and #33349 by @mjankowski)
- Fix clicking on a profile mention while logged out potentially leading to incorrect account (#33324 by @ClearlyClaire)
- Fix missing `NOT NULL` constraints on various database columns (#33244, #33284, #33308, #33330, #33374, and #34498 by @ClearlyClaire and @mjankowski)
- Fix long account username overflowing on profiles (#33286 by @mjankowski)
- Fix Vagrant failure to sync dangling symlinks (#28101 by @filippog)
- Fix Chromium showing scrollbar on embedded posts (#33237 by @ClearlyClaire)
- Fix missing top border on Admin Hashtags UI (#31443 by @ThisIsMissEm)
- Fix design of search bar on explore screen in light theme in web UI (#33224 by @Gargron)
- Fix various visual sign-up flow issues (#33206 by @Gargron)
- Fix support of bidi text in account profiles (#33088 by @mokazemi)
- Fix wording of the error returned when scheduling a status too soon (#33156 by @mjankowski)
- Fix `inbox_url` presence on Relay not being validated (#32364 by @mjankowski)
- Fix ability to include multiple copies of `embed.js` (#33107 by @YKWeyer)
- Fix `rel="me"` check being case-sensitive (#32238 by @c960657)
- Fix wrong video dimensions for some rotated videos (#33008 and #33261 by @Gargron and @tribela)
- Fix error when viewing statuses to deleted replies in moderation view (#32986 by @ClearlyClaire)
- Fix missing autofocus on boost modal (#32953 by @tribela)
- Fix logic in “last used at per application” OAuth token list (#32912 by @mjankowski)
- Fix admin dashboard linking to pages the user does not have permission to see (#32843 by @ThisIsMissEm)
- Fix backspace navigation hotkey going back two pages instead of one on some browsers (#32826 by @c960657)
- Fix typo in translation string (#32821 by @ThisIsMissEm)
- Fix list of follow requests not having a back button (#32797 by @ClearlyClaire)
- Fix out-of-view post contents being inconsistent with in-view post contents (#32778, #32887, and #32895 by @ClearlyClaire)
- Fix `httplog` gem being used in production (#32776 and #32796 by @ClearlyClaire and @oneiros)
- Fix use of deprecated `execCommand` for copying text by using the `clipboard` API (#32598 by @renchap)
- Fix some translation strings not being properly pluralized (#27094 by @gunchleoc)

## [4.3.8] - 2025-05-06

### Security

- Update dependencies
- Check scheme on account, profile, and media URLs ([GHSA-x2rc-v5wx-g3m5](https://github.com/mastodon/mastodon/security/advisories/GHSA-x2rc-v5wx-g3m5))

### Added

- Add warning for REDIS_NAMESPACE deprecation at startup (#34581 by @ClearlyClaire)
- Add built-in context for interaction policies (#34574 by @ClearlyClaire)

### Changed

- Change activity distribution error handling to skip retrying for deleted accounts (#33617 by @ClearlyClaire)

### Removed

- Remove double-query for signed query strings (#34610 by @ClearlyClaire)

### Fixed

- Fix incorrect redirect in response to unauthenticated API requests in limited federation mode (#34549 by @ClearlyClaire)
- Fix sign-up e-mail confirmation page reloading on error or redirect (#34548 by @ClearlyClaire)

## [4.3.7] - 2025-04-02

### Added

- Add delay to profile updates to debounce them (#34137 by @ClearlyClaire)
- Add support for paginating partial collections in `SynchronizeFollowersService` (#34272 and #34277 by @ClearlyClaire)

### Changed

- Change account suspensions to be federated to recently-followed accounts as well (#34294 by @ClearlyClaire)
- Change `AccountReachFinder` to consider statuses based on suspension date (#32805 and #34291 by @ClearlyClaire and @mjankowski)
- Change user archive signed URL TTL from 10 seconds to 1 hour (#34254 by @ClearlyClaire)

### Fixed

- Fix static version of animated PNG emojis not being properly extracted (#34337 by @ClearlyClaire)
- Fix filters not applying in detailed view, favourites and bookmarks (#34259 and #34260 by @ClearlyClaire)
- Fix handling of malformed/unusual HTML (#34201 by @ClearlyClaire)
- Fix `CacheBuster` being queued for missing media attachments (#34253 by @ClearlyClaire)
- Fix incorrect URL being used when cache busting (#34189 by @ClearlyClaire)
- Fix streaming server refusing unix socket path in `DATABASE_URL` (#34091 by @ClearlyClaire)
- Fix “x” hotkey not working on boosted filtered posts (#33758 by @ClearlyClaire)

## [4.3.6] - 2025-03-13

### Security

- Update dependency `omniauth-saml`
- Update dependency `rack`

### Fixed

- Fix Stoplight errors when using `REDIS_NAMESPACE` (#34126 by @ClearlyClaire)

## [4.3.5] - 2025-03-10

### Changed

- Change hashtag suggestion to prefer personal history capitalization (#34070 by @ClearlyClaire)

### Fixed

- Fix processing errors for some HEIF images from iOS 18 (#34086 by @renchap)
- Fix streaming server not filtering unknown-language posts from public timelines (#33774 by @ClearlyClaire)
- Fix preview cards under Content Warnings not being shown in detailed statuses (#34068 by @ClearlyClaire)
- Fix username and display name being hidden on narrow screens in moderation interface (#33064 by @ClearlyClaire)

## [4.3.4] - 2025-02-27

### Security

- Update dependencies
- Change HTML sanitization to remove unusable and unused `embed` tag (#34021 by @ClearlyClaire, [GHSA-mq2m-hr29-8gqf](https://github.com/mastodon/mastodon/security/advisories/GHSA-mq2m-hr29-8gqf))
- Fix rate-limit on sign-up email verification ([GHSA-v39f-c9jj-8w7h](https://github.com/mastodon/mastodon/security/advisories/GHSA-v39f-c9jj-8w7h))
- Fix improper disclosure of domain blocks to unverified users ([GHSA-94h4-fj37-c825](https://github.com/mastodon/mastodon/security/advisories/GHSA-94h4-fj37-c825))

### Changed

- Change preview cards to be shown when Content Warnings are expanded (#33827 by @ClearlyClaire)
- Change warnings against changing encryption secrets to be even more noticeable (#33631 by @ClearlyClaire)
- Change `mastodon:setup` to prevent overwriting already-configured servers (#33603, #33616, and #33684 by @ClearlyClaire and @mjankowski)
- Change notifications from moderators to not be filtered (#32974 and #33654 by @ClearlyClaire and @mjankowski)

### Fixed

- Fix `GET /api/v2/notifications/:id` and `POST /api/v2/notifications/:id/dismiss` for ungrouped notifications (#33990 by @ClearlyClaire)
- Fix issue with some versions of libvips on some systems (#33853 by @kleisauke)
- Fix handling of duplicate mentions in incoming status `Update` (#33911 by @ClearlyClaire)
- Fix inefficiencies in timeline generation (#33839 and #33842 by @ClearlyClaire)
- Fix emoji rewrite adding unnecessary curft to the DOM for most emoji (#33818 by @ClearlyClaire)
- Fix `tootctl feeds build` not building list timelines (#33783 by @ClearlyClaire)
- Fix flaky test in `/api/v2/notifications` tests (#33773 by @ClearlyClaire)
- Fix incorrect signature after HTTP redirect (#33757 and #33769 by @ClearlyClaire)
- Fix polls not being validated on edition (#33755 by @ClearlyClaire)
- Fix media preview height in compose form when 3 or more images are attached (#33571 by @ClearlyClaire)
- Fix preview card sizing in “Author attribution” in profile settings (#33482 by @ClearlyClaire)
- Fix processing of incoming notifications for unfilterable types (#33429 by @ClearlyClaire)
- Fix featured tags for remote accounts not being kept up to date (#33372, #33406, and #33425 by @ClearlyClaire and @mjankowski)
- Fix notification polling showing a loading bar in web UI (#32960 by @Gargron)
- Fix accounts table long display name (#29316 by @WebCoder49)
- Fix exclusive lists interfering with notifications (#28162 by @ShadowJonathan)

## [4.3.3] - 2025-01-16

### Security

- Fix insufficient validation of account URIs ([GHSA-5wxh-3p65-r4g6](https://github.com/mastodon/mastodon/security/advisories/GHSA-5wxh-3p65-r4g6))
- Update dependencies

### Fixed

- Fix `libyaml` missing from `Dockerfile` build stage (#33591 by @vmstan)
- Fix incorrect notification settings migration for non-followers (#33348 by @ClearlyClaire)
- Fix down clause for notification policy v2 migrations (#33340 by @jesseplusplus)
- Fix error decrementing status count when `FeaturedTags#last_status_at` is `nil` (#33320 by @ClearlyClaire)
- Fix last paginated notification group only including data on a single notification (#33271 by @ClearlyClaire)
- Fix processing of mentions for post edits with an existing corresponding silent mention (#33227 by @ClearlyClaire)
- Fix deletion of unconfirmed users with Webauthn set (#33186 by @ClearlyClaire)
- Fix empty authors preview card serialization (#33151, #33466 by @mjankowski and @ClearlyClaire)

## [4.3.2] - 2024-12-03

### Added

- Add `tootctl feeds vacuum` (#33065 by @ClearlyClaire)
- Add error message when user tries to follow their own account (#31910 by @lenikadali)
- Add client_secret_expires_at to OAuth Applications (#30317 by @ThisIsMissEm)

### Changed

- Change design of Content Warnings and filters (#32543 by @ClearlyClaire)

### Fixed

- Fix processing incoming post edits with mentions to unresolvable accounts (#33129 by @ClearlyClaire)
- Fix error when including multiple instances of `embed.js` (#33107 by @YKWeyer)
- Fix inactive users' timelines being backfilled on follow and unsuspend (#33094 by @ClearlyClaire)
- Fix direct inbox delivery pushing posts into inactive followers' timelines (#33067 by @ClearlyClaire)
- Fix `TagFollow` records not being correctly handled in account operations (#33063 by @ClearlyClaire)
- Fix pushing hashtag-followed posts to feeds of inactive users (#33018 by @Gargron)
- Fix duplicate notifications in notification groups when using slow mode (#33014 by @ClearlyClaire)
- Fix posts made in the future being allowed to trend (#32996 by @ClearlyClaire)
- Fix uploading higher-than-wide GIF profile picture with libvips enabled (#32911 by @ClearlyClaire)
- Fix domain attribution field having autocorrect and autocapitalize enabled (#32903 by @ClearlyClaire)
- Fix titles being escaped twice (#32889 by @ClearlyClaire)
- Fix list creation limit check (#32869 by @ClearlyClaire)
- Fix error in `tootctl email_domain_blocks` when supplying `--with-dns-records` (#32863 by @mjankowski)
- Fix `min_id` and `max_id` causing error in search API (#32857 by @Gargron)
- Fix inefficiencies when processing removal of posts that use featured tags (#32787 by @ClearlyClaire)
- Fix alt-text pop-in not using the translated description (#32766 by @ClearlyClaire)
- Fix preview cards with long titles erroneously causing layout changes (#32678 by @ClearlyClaire)
- Fix embed modal layout on mobile (#32641 by @DismalShadowX)
- Fix and improve batch attachment deletion handling when using OpenStack Swift (#32637 by @hugogameiro)
- Fix blocks not being applied on link timeline (#32625 by @tribela)
- Fix follow counters being incorrectly changed (#32622 by @oneiros)
- Fix 'unknown' media attachment type rendering (#32613 and #32713 by @ThisIsMissEm and @renatolond)
- Fix tl language native name (#32606 by @seav)

### Security

- Update dependencies

## [4.3.1] - 2024-10-21

### Added

- Add more explicit explanations about author attribution and `fediverse:creator` (#32383 by @ClearlyClaire)
- Add ability to group follow notifications in WebUI, can be disabled in the column settings (#32520 by @renchap)
- Add back a 6 hours mute duration option (#32522 by @renchap)
- Add note about not changing ActiveRecord encryption secrets once they are set (#32413, #32476, #32512, and #32537 by @ClearlyClaire and @mjankowski)

### Changed

- Change translation feature to translate to selected regional variant (e.g. pt-BR) if available (#32428 by @c960657)

### Removed

- Remove ability to get embed code for remote posts (#32578 by @ClearlyClaire)\
  Getting the embed code is only reliable for local posts.\
  It never worked for non-Mastodon servers, and stopped working correctly with the changes made in 4.3.0.\
  We have therefore decided to remove the menu entry while we investigate solutions.

### Fixed

- Fix follow recommendation moderation page default language when using regional variant (#32580 by @ClearlyClaire)
- Fix column-settings spacing in local timeline in advanced view (#32567 by @lindwurm)
- Fix broken i18n in text welcome mailer tags area (#32571 by @mjankowski)
- Fix missing or incorrect cache-control headers for Streaming server (#32551 by @ThisIsMissEm)
- Fix only the first paragraph being displayed in some notifications (#32348 by @ClearlyClaire)
- Fix reblog icons on account media view (#32506 by @tribela)
- Fix Content-Security-Policy not allowing OpenStack SWIFT object storage URI (#32439 by @kenkiku1021)
- Fix back arrow pointing to the incorrect direction in RTL languages (#32485 by @renchap)
- Fix streaming server using `REDIS_USERNAME` instead of `REDIS_USER` (#32493 by @ThisIsMissEm)
- Fix follow recommendation carrousel scrolling on RTL layouts (#32462 and #32505 by @ClearlyClaire)
- Fix follow recommendation suppressions not applying immediately (#32392 by @ClearlyClaire)
- Fix language of push notifications (#32415 by @ClearlyClaire)
- Fix mute duration not being shown in list of muted accounts in web UI (#32388 by @ClearlyClaire)
- Fix “Mark every notification as read” not updating the read marker if scrolled down (#32385 by @ClearlyClaire)
- Fix “Mention” appearing for otherwise filtered posts (#32356 by @ClearlyClaire)
- Fix notification requests from suspended accounts still being listed (#32354 by @ClearlyClaire)
- Fix list edition modal styling (#32358 and #32367 by @ClearlyClaire and @vmstan)
- Fix 4 columns barely not fitting on 1920px screen (#32361 by @ClearlyClaire)
- Fix icon alignment in applications list (#32293 by @mjankowski)

## [4.3.0] - 2024-10-08

The following changelog entries focus on changes visible to users, administrators, client developers or federated software developers, but there has also been a lot of code modernization, refactoring, and tooling work, in particular by @mjankowski.

### Security

- **Add confirmation interstitial instead of silently redirecting logged-out visitors to remote resources** (#27792, #28902, and #30651 by @ClearlyClaire and @Gargron)\
  This fixes a longstanding open redirect in Mastodon, at the cost of added friction when local links to remote resources are shared.
- Fix ReDoS vulnerability on some Ruby versions ([GHSA-jpxp-r43f-rhvx](https://github.com/mastodon/mastodon/security/advisories/GHSA-jpxp-r43f-rhvx))
- Change `form-action` Content-Security-Policy directive to be more restrictive (#26897 and #32241 by @ClearlyClaire)
- Update dependencies

### Added

- **Add server-side notification grouping** (#29889, #30576, #30685, #30688, #30707, #30776, #30779, #30781, #30440, #31062, #31098, #31076, #31111, #31123, #31223, #31214, #31224, #31299, #31325, #31347, #31304, #31326, #31384, #31403, #31433, #31509, #31486, #31513, #31592, #31594, #31638, #31746, #31652, #31709, #31725, #31745, #31613, #31657, #31840, #31610, #31929, #32089, #32085, #32243, #32179 and #32254 by @ClearlyClaire, @Gargron, @mgmn, and @renchap)\
  Group notifications of the same type for the same target, so that your notifications no longer get cluttered by boost and favorite notifications as soon as a couple of your posts get traction.\
  This is done server-side so that clients can efficiently get relevant groups without having to go through numerous pages of individual notifications.\
  As part of this, the visual design of the entire notifications feature has been revamped.\
  This feature is intended to eventually replace the existing notifications column, but for this first beta, users will have to enable it in the “Experimental features” section of the notifications column settings.\
  The API is not final yet, but it consists of:
  - a new `group_key` attribute to `Notification` entities
  - `GET /api/v2/notifications`: https://docs.joinmastodon.org/methods/grouped_notifications/#get-grouped
  - `GET /api/v2/notifications/:group_key`: https://docs.joinmastodon.org/methods/grouped_notifications/#get-notification-group
  - `GET /api/v2/notifications/:group_key/accounts`: https://docs.joinmastodon.org/methods/grouped_notifications/#get-group-accounts
  - `POST /api/v2/notifications/:group_key/dismiss`: https://docs.joinmastodon.org/methods/grouped_notifications/#dismiss-group
  - `GET /api/v2/notifications/:unread_count`: https://docs.joinmastodon.org/methods/grouped_notifications/#unread-group-count
- **Add notification policies, filtered notifications and notification requests** (#29366, #29529, #29433, #29565, #29567, #29572, #29575, #29588, #29646, #29652, #29658, #29666, #29693, #29699, #29737, #29706, #29570, #29752, #29810, #29826, #30114, #30251, #30559, #29868, #31008, #31011, #30996, #31149, #31220, #31222, #31225, #31242, #31262, #31250, #31273, #31310, #31316, #31322, #31329, #31324, #31331, #31343, #31342, #31309, #31358, #31378, #31406, #31256, #31456, #31419, #31457, #31508, #31540, #31541, #31723, #32062 and #32281 by @ClearlyClaire, @Gargron, @TheEssem, @mgmn, @oneiros, and @renchap)\
  The old “Block notifications from non-followers”, “Block notifications from people you don't follow” and “Block direct messages from people you don't follow” notification settings have been replaced by a new set of settings found directly in the notification column.\
  You can now separately filter or drop notifications from people you don't follow, people who don't follow you, accounts created within the past 30 days, as well as unsolicited private mentions, and accounts limited by the moderation.\
  Instead of being outright dropped, notifications that you chose to filter are put in a separate “Filtered notifications” box that you can review separately without it clogging your main notifications.\
  This adds the following REST API endpoints:
  - `GET /api/v2/notifications/policy`: https://docs.joinmastodon.org/methods/notifications/#get-policy
  - `PATCH /api/v2/notifications/policy`: https://docs.joinmastodon.org/methods/notifications/#update-the-filtering-policy-for-notifications
  - `GET /api/v1/notifications/requests`: https://docs.joinmastodon.org/methods/notifications/#get-requests
  - `GET /api/v1/notifications/requests/:id`: https://docs.joinmastodon.org/methods/notifications/#get-one-request
  - `POST /api/v1/notifications/requests/:id/accept`: https://docs.joinmastodon.org/methods/notifications/#accept-request
  - `POST /api/v1/notifications/requests/:id/dismiss`: https://docs.joinmastodon.org/methods/notifications/#dismiss-request
  - `POST /api/v1/notifications/requests/accept`: https://docs.joinmastodon.org/methods/notifications/#accept-multiple-requests
  - `POST /api/v1/notifications/requests/dismiss`: https://docs.joinmastodon.org/methods/notifications/#dismiss-multiple-requests
  - `GET /api/v1/notifications/requests/merged`: https://docs.joinmastodon.org/methods/notifications/#requests-merged

  In addition, accepting one or more notification requests generates a new streaming event:
  - `notifications_merged`: an event of this type indicates accepted notification requests have finished merging, and the notifications list should be refreshed

- **Add notifications of severed relationships** (#27511, #29665, #29668, #29670, #29700, #29714, #29712, and #29731 by @ClearlyClaire and @Gargron)\
  Notify local users when they lose relationships as a result of a local moderator blocking a remote account or server, allowing the affected user to retrieve the list of broken relationships.\
  Note that this does not notify remote users.\
  This adds the `severed_relationships` notification type to the REST API and streaming, with a new [`event` attribute](https://docs.joinmastodon.org/entities/Notification/#relationship_severance_event).
- **Add hover cards in web UI** (#30754, #30864, #30850, #30879, #30928, #30949, #30948, #30931, and #31300 by @ClearlyClaire, @Gargron, and @renchap)\
  Hovering over an avatar or username will now display a hover card with the first two lines of the user's description and their first two profile fields.\
  This can be disabled in the “Animations and accessibility” section of the preferences.
- **Add "system" theme setting (light/dark theme depending on user system preference)** (#29748, #29553, #29795, #29918, #30839, and #30861 by @nshki, @ErikUden, @mjankowski, @renchap, and @vmstan)\
  Add a “system” theme that automatically switch between default dark and light themes depending on the user's system preferences.\
  Also changes the default server theme to this new “system” theme so that automatic theme selection happens even when logged out.
- **Add timeline of public posts about a trending link** (#30381 and #30840 by @Gargron)\
  You can now see public posts mentioning currently-trending articles from people who have opted into discovery features.\
  This adds a new REST API endpoint: https://docs.joinmastodon.org/methods/timelines/#link
- **Add author highlight for news articles whose authors are on the fediverse** (#30398, #30670, #30521, #30846, #31819, #31900 and #32188 by @Gargron, @mjankowski and @oneiros)\
  This adds a mechanism to [highlight the author of news articles](https://blog.joinmastodon.org/2024/07/highlighting-journalism-on-mastodon/) shared on Mastodon.\
  Articles hosted outside the fediverse can indicate a fediverse author with a meta tag:
  ```html
  <meta name="fediverse:creator" content="username@domain" />
  ```
  On the API side, this is represented by a new `authors` attribute to the `PreviewCard` entity: https://docs.joinmastodon.org/entities/PreviewCard/#authors \
  Users can allow arbitrary domains to use `fediverse:creator` to credit them by visiting `/settings/verification`.\
  This is federated as a new `attributionDomains` property in the `http://joinmastodon.org/ns` namespace, containing an array of domain names: https://docs.joinmastodon.org/spec/activitypub/#properties-used-1
- **Add in-app notifications for moderation actions and warnings** (#30065, #30082, and #30081 by @ClearlyClaire)\
  In addition to email notifications, also notify users of moderation actions or warnings against them directly within the app, so they are less likely to miss important communication from their moderators.\
  This adds the `moderation_warning` notification type to the REST API and streaming, with a new [`moderation_warning` attribute](https://docs.joinmastodon.org/entities/Notification/#moderation_warning).
- **Add domain information to profiles in web UI** (#29602 by @Gargron)\
  Clicking the domain of a user in their profile will now open a tooltip with a short explanation about servers and federation.
- **Add support for Redis sentinel** (#31694, #31623, #31744, #31767, and #31768 by @ThisIsMissEm and @oneiros)\
  See https://docs.joinmastodon.org/admin/scaling/#redis-sentinel
- **Add ability to reorder uploaded media before posting in web UI** (#28456 and #32093 by @Gargron)
- Add “A Mastodon update is available.” message on admin dashboard for non-bugfix updates (#32106 by @ClearlyClaire)
- Add ability to view alt text by clicking the ALT badge in web UI (#32058 by @Gargron)
- Add preview of followers removed in domain block modal in web UI (#32032 and #32105 by @ClearlyClaire and @Gargron)
- Add reblogs and favourites counts to statuses in ActivityPub (#32007 by @Gargron)
- Add moderation interface for searching hashtags (#30880 by @ThisIsMissEm)
- Add ability for admins to configure instance favicon and logo (#30040, #30208, #30259, #30375, #30734, #31016, and #30205 by @ClearlyClaire, @FawazFarid, @JasonPunyon, @mgmn, and @renchap)\
  This is also exposed through the REST API: https://docs.joinmastodon.org/entities/Instance/#icon
- Add `api_versions` to `/api/v2/instance` (#31354 by @ClearlyClaire)\
  Add API version number to make it easier for clients to detect compatible features going forward.\
  See API documentation at https://docs.joinmastodon.org/entities/Instance/#api-versions
- Add quick links to Administration and Moderation Reports from Web UI (#24838 by @ThisIsMissEm)
- Add link to `/admin/roles` in moderation interface when changing someone's role (#31791 by @ClearlyClaire)
- Add recent audit log entries in federation moderation interface (#27386 by @ThisIsMissEm)
- Add profile setup to onboarding in web UI (#27829, #27876, and #28453 by @Gargron)
- Add prominent share/copy button on profiles in web UI (#27865 and #27889 by @ClearlyClaire and @Gargron)
- Add optional hints for server rules (#29539 and #29758 by @ClearlyClaire and @Gargron)\
  Server rules can now be broken into a short rule name and a longer explanation of the rule.\
  This adds a new [`hint` attribute](https://docs.joinmastodon.org/entities/Rule/#hint) to `Rule` entities in the REST API.
- Add support for PKCE in OAuth flow (#31129 by @ThisIsMissEm)
- Add CDN cache busting on media deletion (#31353 and #31414 by @ClearlyClaire and @tribela)
- Add the OAuth application used in local reports (#30539 by @ThisIsMissEm)
- Add hint to user that other remote statuses may be missing (#26910, #31387, and #31516 by @Gargron, @audiodude, and @renchap)
- Add lang attribute on preview card title (#31303 by @c960657)
- Add check for `Content-Length` in `ResponseWithLimitAdapter` (#31285 by @c960657)
- Add `Accept-Language` header to fetch preview cards in the server's default language (#31232 by @c960657)
- Add support for PKCE Extension in OmniAuth OIDC through the `OIDC_USE_PKCE` environment variable (#31131 by @ThisIsMissEm)
- Add API endpoints for unread notifications count (#31191 by @ClearlyClaire)\
  This adds the following REST API endpoints:
  - `GET /api/v1/notifications/unread_count`: https://docs.joinmastodon.org/methods/notifications/#unread-count
- Add `/` keyboard shortcut to focus the search field (#29921 by @ClearlyClaire)
- Add button to view the Hashtag on the instance from Hashtags in Moderation UI (#31533 by @ThisIsMissEm)
- Add list of pending releases directly in mail notifications for version updates (#29436 and #30035 by @ClearlyClaire)
- Add “Appeals” link under “Moderation” navigation category in moderation interface (#31071 by @ThisIsMissEm)
- Add badge on account card in report moderation interface when account is already suspended (#29592 by @ClearlyClaire)
- Add admin comments directly to the `admin/instances` page (#29240 by @tribela)
- Add ability to require approval when users sign up using specific email domains (#28468, #28732, #28607, and #28608 by @ClearlyClaire)
- Add banner for forwarded reports made by remote users about remote content (#27549 by @ClearlyClaire)
- Add support HTML ruby tags in remote posts for east-asian languages (#30897 by @ThisIsMissEm)
- Add link to manage warning presets in admin navigation (#26199 by @vmstan)
- Add volume saving/reuse to video player (#27488 by @thehydrogen)
- Add Elasticsearch index size, ffmpeg and ImageMagick versions to the admin dashboard (#27301, #30710, #31130, and #30845 by @vmstan)
- Add `MASTODON_SIDEKIQ_READY_FILENAME` environment variable to use a file for Sidekiq to signal it is ready to process jobs (#30971 and #30988 by @renchap)\
  In the official Docker image, this is set to `sidekiq_process_has_started_and_will_begin_processing_jobs` so that Sidekiq will touch `tmp/sidekiq_process_has_started_and_will_begin_processing_jobs` to signal readiness.
- Add `S3_RETRY_LIMIT` environment variable to make S3 retries configurable (#23215 by @smiba)
- Add `S3_KEY_PREFIX` environment variable (#30181 by @S0yKaf)
- Add support for multiple `redirect_uris` when creating OAuth 2.0 Applications (#29192 by @ThisIsMissEm)
- Add Interlingue and Interlingua to interface languages (#28630 and #30828 by @Dhghomon and @renchap)
- Add Kashubian, Pennsylvania Dutch, Vai, Jawi Malay, Mohawk and Low German to posting languages (#26024, #26634, #27136, #29098, #27115, and #27434 by @EngineerDali, @HelgeKrueger, and @gunchleoc)
- Add option to use native Ruby driver for Redis through `REDIS_DRIVER=ruby` (#30717 by @vmstan)
- Add support for libvips in addition to ImageMagick (#30090, #30590, #30597, #30632, #30857, #30869, #30858 and #32104 by @ClearlyClaire, @Gargron, and @mjankowski)\
  Server admins can now use libvips as a faster and lighter alternative to ImageMagick for processing user-uploaded images.\
  This requires libvips 8.13 or newer, and needs to be enabled with `MASTODON_USE_LIBVIPS=true`.\
  This is enabled by default in the official Docker images, and is intended to completely replace ImageMagick in the future.
- Add validations to `Web::PushSubscription` (#30540 and #30542 by @ThisIsMissEm)
- Add anchors to each authorized application in `/oauth/authorized_applications` (#31677 by @fowl2)
- Add active animation to header settings button (#30221, #30307, and #30388 by @daudix)
- Add OpenTelemetry instrumentation (#30130, #30322, #30353, #30350 and #31998 by @julianocosta89, @renchap, @robbkidd and @timetinytim)\
  See https://docs.joinmastodon.org/admin/config/#otel for documentation
- Add API to get multiple accounts and statuses (#27871 and #30465 by @ClearlyClaire)\
  This adds `GET /api/v1/accounts` and `GET /api/v1/statuses` to the REST API, see https://docs.joinmastodon.org/methods/accounts/#index and https://docs.joinmastodon.org/methods/statuses/#index
- Add support for CORS to `POST /oauth/revoke` (#31743 by @ClearlyClaire)
- Add redirection back to previous page after site upload deletion (#30141 by @FawazFarid)
- Add RFC8414 OAuth 2.0 server metadata (#29191 by @ThisIsMissEm)
- Add loading indicator and empty result message to advanced interface search (#30085 by @ClearlyClaire)
- Add `profile` OAuth 2.0 scope, allowing more limited access to user data (#29087 and #30357 by @ThisIsMissEm)
- Add the role ID to the badge component (#29707 by @renchap)
- Add diagnostic message for failure during CLI search deploy (#29462 by @mjankowski)
- Add pagination `Link` headers on API accounts/statuses when pinned true (#29442 by @mjankowski)
- Add support for specifying custom CA cert for Elasticsearch through `ES_CA_FILE` (#29122 and #29147 by @ClearlyClaire)
- Add groundwork for annual reports for accounts (#28693 by @Gargron)\
  This lays the groundwork for a “year-in-review”/“wrapped” style report for local users, but is currently not in use.
- Add notification email on invalid second authenticator (#28822 by @ClearlyClaire)
- Add date of account deletion in list of accounts in the admin interface (#25640 by @tribela)
- Add new emojis from `jdecked/twemoji` 15.0 (#28404 by @TheEssem)
- Add configurable error handling in attachment batch deletion (#28184 by @vmstan)\
  This makes the S3 batch size configurable through the `S3_BATCH_DELETE_LIMIT` environment variable (defaults to 1000), and adds some retry logic, configurable through the `S3_BATCH_DELETE_RETRY` environment variable (defaults to 3).
- Add VAPID public key to instance serializer (#28006 by @ThisIsMissEm)
- Add support for serving JRD `/.well-known/host-meta.json` in addition to XRD host-meta (#32206 by @c960657)
- Add `nodeName` and `nodeDescription` to nodeinfo `metadata` (#28079 by @6543)
- Add Thai diacritics and tone marks in `HASHTAG_INVALID_CHARS_RE` (#26576 by @ppnplus)
- Add variable delay before link verification of remote account links (#27774 by @ClearlyClaire)
- Add support for invite codes in the registration API (#27805 by @ClearlyClaire)
- Add HTML lang attribute to preview card descriptions (#27503 by @srapilly)
- Add display of relevant account warnings to report action logs (#27425 by @ClearlyClaire)
- Add validation of allowed schemes on preview card URLs (#27485 by @mjankowski)
- Add token introspection without read scope to `/api/v1/apps/verify_credentials` (#27142 by @ThisIsMissEm)
- Add support for cross-origin request to `/nodeinfo/2.0` (#27413 by @palant)
- Add variable delay before link verification of remote account links (#27351 by @ClearlyClaire)
- Add PWA shortcut to `/explore` page (#27235 by @jake-anto)

### Changed

- **Change icons throughout the web interface** (#27385, #27539, #27555, #27579, #27700, #27817, #28519, #28709, #28064, #28775, #28780, #27924, #29294, #29395, #29537, #29569, #29610, #29612, #29649, #29844, #27780, #30974, #30963, #30962, #30961, #31362, #31363, #31359, #31371, #31360, #31512, #31511, #31525, #32153, and #32201 by @ClearlyClaire, @Gargron, @arbolitoloco1, @mjankowski, @nclm, @renchap, @ronilaukkarinen, and @zunda)\
  This changes all the interface icons from FontAwesome to Material Symbols for a more modern look, consistent with the official Mastodon Android app.\
  In addition, better care is given to pixel alignment, and icon variants are used to better highlight active/inactive state.
- **Change design of compose form in web UI** (#28119, #29059, #29248, #29372, #29384, #29417, #29456, #29406, #29651, #29659, #31889 and #32033 by @ClearlyClaire, @Gargron, @eai04191, @hinaloe, and @ronilaukkarinen)\
  The compose form has been completely redesigned for a more modern and consistent look, as well as spelling out the chosen privacy setting and language name at all times.\
  As part of this, the “Unlisted” privacy setting has been renamed to “Quiet public”.
- **Change design of modals in the web UI** (#29576, #29614, #29640, #29644, #30131, #30884, #31399, #31555, #31752, #31801, #31883, #31844, #31864, and #31943 by @ClearlyClaire, @Gargron, @tribela and @vmstan)\
  The mute, block, and domain block confirmation modals have been completely redesigned to be clearer and include more detailed information on the action to be performed.\
  They also have a more modern and consistent design, along with other confirmation modals in the application.
- **Change colors throughout the web UI** (#29522, #29584, #29653, #29779, #29803, #29809, #29808, #29828, #31034, #31168, #31266, #31348, #31349, #31361, #31510 and #32128 by @ClearlyClaire, @Gargron, @mjankowski, @renchap, and @vmstan)
- **Change onboarding prompt to follow suggestions carousel in web UI** (#28878, #29272, and #31912 by @Gargron)
- **Change email templates** (#28416, #28755, #28814, #29064, #28883, #29470, #29607, #29761, #29760, #29879, #32073 and #32132 by @c960657, @ClearlyClaire, @Gargron, @hteumeuleu, and @mjankowski)\
  All emails to end-users have been completely redesigned with a fresh new look, providing more information while making them easier to read and keeping maximum compatibility across mail clients.
- **Change follow recommendations algorithm** (#28314, #28433, #29017, #29108, #29306, #29550, #29619, and #31474 by @ClearlyClaire, @Gargron, @kernal053, @mjankowski, and @wheatear-dev)\
  This replaces the “past interactions” recommendation algorithm with a “friends of friends” algorithm that suggests accounts followed by people you follow, and a “similar profiles” algorithm that suggests accounts with a profile similar to your most recent follows.\
  In addition, the implementation has been significantly reworked, and all follow recommendations are now dismissable.\
  This change deprecates the `source` attribute in `Suggestion` entities in the REST API, and replaces it with the new [`sources` attribute](https://docs.joinmastodon.org/entities/Suggestion/#sources).
- Change account search algorithm (#30803 by @Gargron)
- **Change streaming server to use its own dependencies and its own docker image** (#24702, #27967, #26850, #28112, #28115, #28137, #28138, #28497, #28548, #30795, #31612, and #31615 by @TheEssem, @ThisIsMissEm, @jippi, @renchap, @timetinytim, and @vmstan)\
  In order to reduce the amount of runtime dependencies, the streaming server has been moved into a separate package and Docker image.\
  The `mastodon` image does not contain the streaming server anymore, as it has been moved to its own `mastodon-streaming` image.\
  Administrators may need to update their setup accordingly.
- Change how content warnings and filters are displayed in web UI (#31365, and #31761 by @Gargron)
- Change preview card processing to ignore `undefined` as canonical url (#31882 by @oneiros)
- Change embedded posts to use web UI (#31766, #32135 and #32271 by @Gargron)
- Change inner borders in media galleries in web UI (#31852 by @Gargron)
- Change design of media attachments and profile media tab in web UI (#31807, #32048, #31967, #32217, #32224 and #32257 by @ClearlyClaire and @Gargron)
- Change labels on thread indicators in web UI (#31806 by @Gargron)
- Change label of "Data export" menu item in settings interface (#32099 by @c960657)
- Change responsive break points on navigation panel in web UI (#32034 by @Gargron)
- Change cursor to `not-allowed` on disabled buttons (#32076 by @mjankowski)
- Change OAuth authorization prompt to not refer to apps as “third-party” (#32005 by @Gargron)
- Change Mastodon to issue correct HTTP signatures by default (#31994 by @ClearlyClaire)
- Change zoom icon in web UI (#29683 by @Gargron)
- Change directory page to use URL query strings for options (#31980, #31977 and #31984 by @ClearlyClaire and @renchap)
- Change report action buttons to be disabled when action has already been taken (#31773, #31822, and #31899 by @ClearlyClaire and @ThisIsMissEm)
- Change width of columns in advanced web UI (#31762 by @Gargron)
- Change design of unread conversations in web UI (#31763 by @Gargron)
- Change Web UI to allow viewing and severing relationships with suspended accounts (#27667 by @ClearlyClaire)\
  This also adds a `with_suspended` parameter to `GET /api/v1/accounts/relationships` in the REST API.
- Change preview card image size limit from 2MB to 8MB when using libvips (#31904 by @ClearlyClaire)
- Change avatars border radius (#31390 by @renchap)
- Change counters to be displayed on profile timelines in web UI (#30525 by @Gargron)
- Change disabled buttons color in light mode to make the difference more visible (#30998 by @renchap)
- Change design of people tab on explore in web UI (#30059 by @Gargron)
- Change sidebar text in web UI (#30696 by @Gargron)
- Change "Follow" to "Follow back" and "Mutual" when appropriate in web UI (#28452, #28465, and #31934 by @ClearlyClaire, @Gargron and @renchap)
- Change media to be hidden/blurred by default in report modal (#28522 by @ClearlyClaire)
- Change order of the "muting" and "blocking" list options in “Data Exports” (#26088 by @fixermark)
- Change admin and moderation notes character limit from 500 to 2000 characters (#30288 by @ThisIsMissEm)
- Change mute options to be in dropdown on muted users list in web UI (#30049 and #31315 by @ClearlyClaire and @Gargron)
- Change out-of-band hashtags design in web UI (#29732 by @Gargron)
- Change design of metadata underneath detailed posts in web UI (#29585, #29605, and #29648 by @ClearlyClaire and @Gargron)
- Change action button to be last on profiles in web UI (#29533 and #29923 by @ClearlyClaire and @Gargron)
- Change confirmation prompts in trending moderation interface to be more specific (#19626 by @tribela)
- Change “Trends” moderation menu to “Recommendations & Trends” and move follow recommendations there (#31292 by @ThisIsMissEm)
- Change irrelevant fields in account cleanup settings to be disabled unless automatic cleanup is enabled (#26562 by @c960657)
- Change dropdown menu icon to not be replaced by close icon when open in web UI (#29532 by @Gargron)
- Change back button to always appear in advanced web UI (#29551 and #29669 by @Gargron)
- Change border of active compose field search inputs (#29832 and #29839 by @vmstan)
- Change instances of Nokogiri HTML4 parsing to HTML5 (#31812, #31815, #31813, and #31814 by @flavorjones)
- Change link detection to allow `@` at the end of an URL (#31124 by @adamniedzielski)
- Change User-Agent to use Mastodon as the product, and http.rb as platform details (#31192 by @ClearlyClaire)
- Change layout and wording of the Content Retention server settings page (#27733 by @vmstan)
- Change unconfirmed users to be kept for one week instead of two days (#30285 by @renchap)
- Change maximum page size for Admin Domain Management APIs from 200 to 500 (#31253 by @ThisIsMissEm)
- Change database pool size to default to Sidekiq concurrency settings in Sidekiq processes (#26488 by @sinoru)
- Change alt text to empty string for avatars (#21875 by @jasminjohal)
- Change Docker images to use custom-built libvips and ffmpeg (#30571, #30569, and #31498 by @vmstan)
- Change external links in the admin audit log to plain text or local administration pages (#27139 and #27150 by @ClearlyClaire and @ThisIsMissEm)
- Change YJIT to be enabled when available (#30310 and #27283 by @ClearlyClaire and @mjankowski)\
  Enable Ruby's built-in just-in-time compiler. This improves performances substantially, at the cost of a slightly increased memory usage.
- Change `.env` file loading from deprecated `dotenv-rails` gem to `dotenv` gem (#29173 and #30121 by @mjankowski)\
  This should have no effect except in the unlikely case an environment variable included a newline.
- Change “Panjabi” language name to the more common spelling “Punjabi” (#27117 by @gunchleoc)
- Change encryption of OTP secrets to use ActiveRecord Encryption (#29831, #28325, #30151, #30202, #30340, and #30344 by @ClearlyClaire and @mjankowski)\
  This requires a manual step from administrators of existing servers. Indeed, they need to generate new secrets, which can be done using `bundle exec rails db:encryption:init`.\
  Furthermore, there is a risk that the introduced migration fails if the server was misconfigured in the past. If that happens, the migration error will include the relevant information.
- Change `/api/v1/announcements` to return regular `Status` entities (#26736 by @ClearlyClaire)
- Change imports to convert case-insensitive fields to lowercase (#29739 and #29740 by @ThisIsMissEm)
- Change stats in the admin interface to be inclusive of the full selected range, from beginning of day to end of day (#29416 and #29841 by @mjankowski)
- Change materialized views to be refreshed concurrently to avoid locks (#29015 by @Gargron)
- Change compose form to use server-provided post character and poll options limits (#28928 and #29490 by @ClearlyClaire and @renchap)
- Change streaming server logging from `npmlog` to `pino` and `pino-http` (#27828 by @ThisIsMissEm)\
  This changes the Mastodon streaming server log format, so this might be considered a breaking change if you were parsing the logs.
- Change media “ALT” label to use a specific CSS class (#28777 by @ClearlyClaire)
- Change streaming API host to not be overridden to localhost in development mode (#28557 by @ClearlyClaire)
- Change cookie rotator to use SHA1 digest for new cookies (#27392 by @ClearlyClaire)\
  Note that this requires that no pre-4.2.0 Mastodon web server is running when this code is deployed, as those would not understand the new cookies.\
  Therefore, zero-downtime updates are only supported if you're coming from 4.2.0 or newer. If you want to skip Mastodon 4.2, you will need to completely stop Mastodon services before updating.
- Change preview card deletes to be done using batch method (#28183 by @vmstan)
- Change `img-src` and `media-src` CSP directives to not include `https:` (#28025 and #28561 by @ClearlyClaire)
- Change self-destruct procedure (#26439, #29049, and #29420 by @ClearlyClaire and @zunda)\
  Instead of enqueuing deletion jobs immediately, `tootctl self-destruct` now outputs a value for the `SELF_DESTRUCT` environment variable, which puts a server in self-destruct mode, processing deletions in the background, while giving users access to their export archives.

### Removed

- Remove unused E2EE messaging code and related `crypto` OAuth scope (#31193, #31945, #31963, and #31964 by @ClearlyClaire and @mjankowski)
- Remove StatsD integration (replaced by OpenTelemetry) (#30240 by @mjankowski)
- Remove `CacheBuster` default options (#30718 by @mjankowski)
- Remove home marker updates from the Web UI (#22721 by @davbeck)\
  The web interface was unconditionally updating the home marker to the most recent received post, discarding any value set by other clients, thus making the feature unreliable.
- Remove support for Ruby 3.0 (reaching EOL) (#29702 by @mjankowski)
- Remove setting for unfollow confirmation modal (#29373 by @ClearlyClaire)\
  Instead, the unfollow confirmation modal will always be displayed.
- Remove support for Capistrano (#27295 and #30009 by @mjankowski and @renchap)

### Fixed

- **Fix link preview cards not always preserving the original URL from the status** (#27312 by @Gargron)
- Fix log out from user menu not working on Safari (#31402 by @renchap)
- Fix various issues when in link preview card generation (#28748, #30017, #30362, #30173, #30853, #30929, #30933, #30957, #30987, and #31144 by @adamniedzielski, @oneiros, @phocks, @timothyjrogers, and @tribela)
- Fix handling of missing links in Webfinger responses (#31030 by @adamniedzielski)
- Fix error when accepting an appeal for sensitive posts deleted in the meantime (#32037 by @ClearlyClaire)
- Fix error when encountering reblog of deleted post in feed rebuild (#32001 by @ClearlyClaire)
- Fix Safari browser glitch related to horizontal scrolling (#31960 by @Gargron)
- Fix unresolvable mentions sometimes preventing processing incoming posts (#29215 by @tribela and @ClearlyClaire)
- Fix too many requests caused by relationship look-ups in web UI (#32042 by @Gargron)
- Fix links for reblogs in moderation interface (#31979 by @ClearlyClaire)
- Fix the appearance of avatars when they do not load (#31966 and #32270 by @Gargron and @renchap)
- Fix spurious error notifications for aborted requests in web UI (#31952 by @c960657)
- Fix HTTP 500 error in `/api/v1/polls/:id/votes` when required `choices` parameter is missing (#25598 by @danielmbrasil)
- Fix security context sometimes not being added in LD-Signed activities (#31871 by @ClearlyClaire)
- Fix cross-origin loading of `inert.css` polyfill (#30687 by @louis77)
- Fix wrapping in dashboard quick access buttons (#32043 by @renchap)
- Fix recently used tags hint being displayed in profile edition page when there is none (#32120 by @mjankowski)
- Fix checkbox lists on narrow screens in the settings interface (#32112 by @mjankowski)
- Fix the position of status action buttons being affected by interaction counters (#32084 by @renchap)
- Fix the summary of converted ActivityPub object types to be treated as HTML (#28629 by @Menrath)
- Fix cutoff of instance name in sign-up form (#30598 by @oneiros)
- Fix invalid date searches returning 503 errors (#31526 by @notchairmk)
- Fix invalid `visibility` values in `POST /api/v1/statuses` returning 500 errors (#31571 by @c960657)
- Fix some components re-rendering spuriously in web UI (#31879 and #31881 by @ClearlyClaire and @Gargron)
- Fix sort order of moderation notes on Reports and Accounts (#31528 by @ThisIsMissEm)
- Fix email language when recipient has no selected locale (#31747 by @ClearlyClaire)
- Fix frequently-used languages not correctly updating in the web UI (#31386 by @c960657)
- Fix `POST /api/v1/statuses` silently ignoring invalid `media_ids` parameter (#31681 by @c960657)
- Fix handling of the `BIND` environment variable in the streaming server (#31624 by @ThisIsMissEm)
- Fix empty `aria-hidden` attribute value in logo resources area (#30570 by @mjankowski)
- Fix “Redirect URI” field not being marked as required in “New application” form (#30311 by @ThisIsMissEm)
- Fix right-to-left text in preview cards (#30930 by @ClearlyClaire)
- Fix rack attack `match_type` value typo in logging config (#30514 by @mjankowski)
- Fix various cases of duplicate, missing, or inconsistent borders or scrollbar styles (#31068, #31286, #31268, #31275, #31284, #31305, #31346, #31372, #31373, #31389, #31432, #31391, #31445, #32091, #32147 and #32137 by @ClearlyClaire, @mjankowski, @valtlai and @vmstan)
- Fix editing description of media uploads with custom thumbnails (#32221 by @ClearlyClaire)
- Fix race condition in `POST /api/v1/push/subscription` (#30166 by @ClearlyClaire)
- Fix post deletion not being delayed when those are part of an account warning (#30163 by @ClearlyClaire)
- Fix rendering error on `/start` when not logged in (#30023 by @timothyjrogers)
- Fix unneeded requests to blocked domains when receiving relayed signed activities from them (#31161 by @ClearlyClaire)
- Fix logo pushing header buttons out of view on certain conditions in mobile layout (#29787 by @ClearlyClaire)
- Fix notification-related records not being reattributed when merging accounts (#29694 by @ClearlyClaire)
- Fix results/query in `api/v1/featured_tags/suggestions` (#29597 by @mjankowski)
- Fix distracting and confusing always-showing scrollbar track in boost confirmation modal (#31524 by @ClearlyClaire)
- Fix being able to upload more than 4 media attachments in some cases (#29183 by @mashirozx)
- Fix preview card player getting embedded when clicking on the external link button (#29457 by @ClearlyClaire)
- Fix full date display not respecting the locale 12/24h format (#29448 by @renchap)
- Fix filters title and keywords overflow (#29396 by @GeopJr)
- Fix incorrect date format in “Follows and followers” (#29390 by @JasonPunyon)
- Fix navigation item active highlight for some paths (#32159 by @mjankowski)
- Fix “Edit media” modal sizing and layout when space-constrained (#27095 by @ronilaukkarinen)
- Fix modal container bounds (#29185 by @nico3333fr)
- Fix inefficient HTTP signature parsing using regexps and `StringScanner` (#29133 by @ClearlyClaire)
- Fix moderation report updates through `PUT /api/v1/admin/reports/:id` not being logged in the audit log (#29044, #30342, and #31033 by @mjankowski, @tribela, and @vmstan)
- Fix moderation interface allowing to select rule violation when there are no server rules (#31458 by @ThisIsMissEm)
- Fix redirection from paths with url-encoded `@` to their decoded form (#31184 by @timothyjrogers)
- Fix Trending Tags pending review having an unstable sort order (#31473 by @ThisIsMissEm)
- Fix the emoji dropdown button always opening the dropdown instead of behaving like a toggle (#29012 by @jh97uk)
- Fix processing of incoming posts with bearcaps (#26527 by @kmycode)
- Fix support for IPv6 redis connections in streaming (#31229 by @ThisIsMissEm)
- Fix search form re-rendering spuriously in web UI (#28876 by @Gargron)
- Fix `RedownloadMediaWorker` not being called on transient S3 failure (#28714 by @ClearlyClaire)
- Fix ISO code for Canadian French from incorrect `fr-QC` to `fr-CA` (#26015 by @gunchleoc)
- Fix `.opus` file uploads being misidentified by Paperclip (#28580 by @vmstan)
- Fix loading local accounts with extraneous domain part in WebUI (#28559 by @ClearlyClaire)
- Fix destructive actions in dropdowns not using error color in light theme (#28484 by @logicalmoody)
- Fix call to inefficient `delete_matched` cache method in domain blocks (#28374 by @ClearlyClaire)
- Fix status edits not always being streamed to mentioned users (#28324 by @ClearlyClaire)
- Fix onboarding step descriptions being truncated on narrow screens (#28021 by @ClearlyClaire)
- Fix duplicate IDs in relationships and familiar_followers APIs (#27982 by @KevinBongart)
- Fix modal content not being selectable (#27813 by @pajowu)
- Fix Web UI not displaying appropriate explanation when a user hides their follows/followers (#27791 by @ClearlyClaire)
- Fix format-dependent redirects being cached regardless of requested format (#27632 by @ClearlyClaire)
- Fix confusing screen when visiting a confirmation link for an already-confirmed email (#27368 by @ClearlyClaire)
- Fix explore page reloading when you navigate back to it in web UI (#27489 by @Gargron)
- Fix missing redirection from `/home` to `/deck/home` in the advanced interface (#27378 by @Signez)
- Fix empty environment variables not using default nil value (#27400 by @renchap)
- Fix language sorting in settings (#27158 by @gunchleoc)

_For previous changes, review the [stable-4.2 branch](https://github.com/mastodon/mastodon/blob/stable-4.2/CHANGELOG.md)_
