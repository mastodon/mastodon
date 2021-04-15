Changelog
=========

All notable changes to this project will be documented in this file.

## Unreleased
### Added

- Add bookmarks ([ThibG](https://github.com/tootsuite/mastodon/pull/7107), [Gargron](https://github.com/tootsuite/mastodon/pull/12494), [Gomasy](https://github.com/tootsuite/mastodon/pull/12381))
- Add announcements ([Gargron](https://github.com/tootsuite/mastodon/pull/12662), [Gargron](https://github.com/tootsuite/mastodon/pull/12967), [Gargron](https://github.com/tootsuite/mastodon/pull/12970), [Gargron](https://github.com/tootsuite/mastodon/pull/12963), [Gargron](https://github.com/tootsuite/mastodon/pull/12950), [Gargron](https://github.com/tootsuite/mastodon/pull/12990), [Gargron](https://github.com/tootsuite/mastodon/pull/12949), [Gargron](https://github.com/tootsuite/mastodon/pull/12989), [Gargron](https://github.com/tootsuite/mastodon/pull/12964), [Gargron](https://github.com/tootsuite/mastodon/pull/12965), [ThibG](https://github.com/tootsuite/mastodon/pull/12958), [ThibG](https://github.com/tootsuite/mastodon/pull/12957), [Gargron](https://github.com/tootsuite/mastodon/pull/12955), [ThibG](https://github.com/tootsuite/mastodon/pull/12946), [ThibG](https://github.com/tootsuite/mastodon/pull/12954))
- Add number animations in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12948), [Gargron](https://github.com/tootsuite/mastodon/pull/12971))
- Add `kab`, `is`, `kn`, `mr`, `ur` to available locales ([Gargron](https://github.com/tootsuite/mastodon/pull/12882), [BoFFire](https://github.com/tootsuite/mastodon/pull/12962), [Gargron](https://github.com/tootsuite/mastodon/pull/12379))
- Add profile filter category ([ThibG](https://github.com/tootsuite/mastodon/pull/12918))
- Add ability to add oneself to lists ([ThibG](https://github.com/tootsuite/mastodon/pull/12271))
- Add hint how to contribute translations to preferences page ([Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12736))
- Add signatures to statuses in archive takeout ([noellabo](https://github.com/tootsuite/mastodon/pull/12649))
- Add support for `magnet:` and `xmpp` links ([ThibG](https://github.com/tootsuite/mastodon/pull/12905), [ThibG](https://github.com/tootsuite/mastodon/pull/12709))
- Add `follow_request` notification type ([ThibG](https://github.com/tootsuite/mastodon/pull/12198))
- Add ability to filter reports by account domain in admin UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12154))
- Add link to search for users connected from the same IP address to admin UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12157))
- Add link to reports targeting a specific domain in admin view ([ThibG](https://github.com/tootsuite/mastodon/pull/12513))
- Add support for EventSource streaming in web UI ([BenLubar](https://github.com/tootsuite/mastodon/pull/12887))
- Add hotkey for opening media attachments in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12498), [Kjwon15](https://github.com/tootsuite/mastodon/pull/12546))
- Add relationship-based options to status dropdowns in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12377), [ThibG](https://github.com/tootsuite/mastodon/pull/12535), [Gargron](https://github.com/tootsuite/mastodon/pull/12430))
- Add support for submitting media description with `ctrl`+`enter` in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12272))
- Add download button to audio and video players in web UI ([NimaBoscarino](https://github.com/tootsuite/mastodon/pull/12179))
- Add setting for whether to crop images in timelines in web UI ([duxovni](https://github.com/tootsuite/mastodon/pull/12126))
- Add support for `Event` activities ([tcitworld](https://github.com/tootsuite/mastodon/pull/12637))
- Add basic support for `Group` actors ([noellabo](https://github.com/tootsuite/mastodon/pull/12071))
- Add `S3_OVERRIDE_PATH_STYLE` environment variable ([Gargron](https://github.com/tootsuite/mastodon/pull/12594))
- Add `S3_OPEN_TIMEOUT` environment variable ([tateisu](https://github.com/tootsuite/mastodon/pull/12459))
- Add `LDAP_MAIL` environment variable ([madmath03](https://github.com/tootsuite/mastodon/pull/12053))
- Add `LDAP_UID_CONVERSION_ENABLED` environment variable ([madmath03](https://github.com/tootsuite/mastodon/pull/12461))
- Add `--remote-only` option to `tootctl emoji purge` ([ThibG](https://github.com/tootsuite/mastodon/pull/12810))
- Add `tootctl media remove-orphans` ([Gargron](https://github.com/tootsuite/mastodon/pull/12568), [Gargron](https://github.com/tootsuite/mastodon/pull/12571))
- Add `tootctl media lookup` command ([irlcatgirl](https://github.com/tootsuite/mastodon/pull/12283))
- Add cache for OEmbed endpoints to avoid extra HTTP requests ([Gargron](https://github.com/tootsuite/mastodon/pull/12403))
- Add support for KaiOS arrow navigation to public pages ([nolanlawson](https://github.com/tootsuite/mastodon/pull/12251))
- Add `discoverable` to accounts in REST API ([trwnh](https://github.com/tootsuite/mastodon/pull/12508))
- Add admin setting to disable default follows ([ArisuOngaku](https://github.com/tootsuite/mastodon/pull/12566))
- Add support for LDAP and PAM in the OAuth password grant strategy ([ntl-purism](https://github.com/tootsuite/mastodon/pull/12390))
- Allow support for `Accept`/`Reject` activities with a non-embedded object ([puckipedia](https://github.com/tootsuite/mastodon/pull/12199))

### Changed

- Change `last_status_at` to be a date, not datetime in REST API ([ThibG](https://github.com/tootsuite/mastodon/pull/12966))
- Change followers page to relationships page in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12927), [Gargron](https://github.com/tootsuite/mastodon/pull/12934))
- Change reported media attachments to always be hidden in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12879), [ThibG](https://github.com/tootsuite/mastodon/pull/12907))
- Change string from "Disable" to "Disable login" in admin UI ([nileshkumar](https://github.com/tootsuite/mastodon/pull/12201))
- Change report page structure in admin UI ([Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12615))
- Change swipe sensitivity to be lower on small screens in web UI ([umonaca](https://github.com/tootsuite/mastodon/pull/12168))
- Change audio/video playback to stop playback when out of view in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12486))
- Change media description label based on upload type in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12270))
- Change large numbers to render without decimal units in web UI ([noellabo](https://github.com/tootsuite/mastodon/pull/12706))
- Change "Add a choice" button to be disabled rather than hidden when poll limit reached in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12319), [hinaloe](https://github.com/tootsuite/mastodon/pull/12544))
- Change `tootctl statuses remove` to keep statuses favourited or bookmarked by local users ([ThibG](https://github.com/tootsuite/mastodon/pull/11267), [Gomasy](https://github.com/tootsuite/mastodon/pull/12818))
- Change domain block behavior to update user records (fast) before deleting data (slower) ([ThibG](https://github.com/tootsuite/mastodon/pull/12247))
- Change behaviour to strip audio metadata on uploads ([hugogameiro](https://github.com/tootsuite/mastodon/pull/12171))
- Change accepted length of remote media descriptions from 420 to 1,500 characters ([ThibG](https://github.com/tootsuite/mastodon/pull/12262))
- Change preferences pages structure ([Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12497), [mayaeh](https://github.com/tootsuite/mastodon/pull/12517), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12801), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12797), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12799), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12793))
- Change format of titles in RSS ([devkral](https://github.com/tootsuite/mastodon/pull/8596))
- Change favourite icon animation from spring-based motion to CSS animation in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12175))
- Change minimum required Node.js version to 10, and default to 12 ([Shleeble](https://github.com/tootsuite/mastodon/pull/12791), [mkody](https://github.com/tootsuite/mastodon/pull/12906), [Shleeble](https://github.com/tootsuite/mastodon/pull/12703))
- Change spam check to exempt server staff ([ThibG](https://github.com/tootsuite/mastodon/pull/12874))
- Change to fallback to to `Create` audience when `object` has no defined audience ([ThibG](https://github.com/tootsuite/mastodon/pull/12249))
- Change Twemoji library to 12.1.3 in web UI ([koyuawsmbrtn](https://github.com/tootsuite/mastodon/pull/12342))
- Change blocked users to be hidden from following/followers lists ([ThibG](https://github.com/tootsuite/mastodon/pull/12733))

### Removed

- Remove unused dependencies ([ykzts](https://github.com/tootsuite/mastodon/pull/12861), [mayaeh](https://github.com/tootsuite/mastodon/pull/12826), [ThibG](https://github.com/tootsuite/mastodon/pull/12822), [ykzts](https://github.com/tootsuite/mastodon/pull/12533))

### Fixed

- Fix some translatable strings being used wrongly ([Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12569), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12589), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12502), [mayaeh](https://github.com/tootsuite/mastodon/pull/12231))
- Fix headline of public timeline page when set to local-only ([ykzts](https://github.com/tootsuite/mastodon/pull/12224))
- Fix space between tabs not being spread evenly in web UI ([Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12944), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12961), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12446))
- Fix interactive delays in database migrations with no TTY ([Gargron](https://github.com/tootsuite/mastodon/pull/12969))
- Fix status overflowing in report dialog in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12959))
- Fix unlocalized dropdown button title in web UI ([Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/12947))
- Fix media attachments without file being uploadable ([Gargron](https://github.com/tootsuite/mastodon/pull/12562))
- Fix unfollow confirmations in profile directory in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12922))
- Fix duplicate `description` meta tag on accounts public pages ([ThibG](https://github.com/tootsuite/mastodon/pull/12923))
- Fix slow query of federated timeline ([notozeki](https://github.com/tootsuite/mastodon/pull/12886))
- Fix not all of account's active IPs showing up in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12909), [Gargron](https://github.com/tootsuite/mastodon/pull/12943))
- Fix search by IP not using alternative browser sessions in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12904))
- Fix “X new items” not showing up for slow mode on empty timelines in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12875))
- Fix OEmbed endpoint being inaccessible in secure mode ([Gargron](https://github.com/tootsuite/mastodon/pull/12864))
- Fix proofs API being inaccessible in secure mode ([Gargron](https://github.com/tootsuite/mastodon/pull/12495))
- Fix Ruby 2.7 incompatibilities ([ThibG](https://github.com/tootsuite/mastodon/pull/12831), [ThibG](https://github.com/tootsuite/mastodon/pull/12824), [Shleeble](https://github.com/tootsuite/mastodon/pull/12759), [zunda](https://github.com/tootsuite/mastodon/pull/12769))
- Fix invalid poll votes being accepted in REST API ([ThibG](https://github.com/tootsuite/mastodon/pull/12601))
- Fix old migrations failing because of strong migrations update ([ThibG](https://github.com/tootsuite/mastodon/pull/12787), [ThibG](https://github.com/tootsuite/mastodon/pull/12692))
- Fix reuse of detailed status components in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12792))
- Fix base64-encoded file uploads not being possible in REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/12748), [Gargron](https://github.com/tootsuite/mastodon/pull/12857))
- Fix resource_owner_from_credentials in Doorkeeper initializer ([Gargron](https://github.com/tootsuite/mastodon/pull/12743))
- Fix error due to missing authentication call in filters controller ([Gargron](https://github.com/tootsuite/mastodon/pull/12746))
- Fix uncaught unknown format error in host meta controller ([Gargron](https://github.com/tootsuite/mastodon/pull/12747))
- Fix URL search not returning private toots user has access to ([ThibG](https://github.com/tootsuite/mastodon/pull/12742), [ThibG](https://github.com/tootsuite/mastodon/pull/12336))
- Fix cache digesting log noise on status embeds ([Gargron](https://github.com/tootsuite/mastodon/pull/12750))
- Fix slowness due to layout thrashing when reloading a large set of statuses in web UI ([panarom](https://github.com/tootsuite/mastodon/pull/12661), [panarom](https://github.com/tootsuite/mastodon/pull/12744), [Gargron](https://github.com/tootsuite/mastodon/pull/12712))
- Fix error when fetching followers/following from REST API when user has network hidden ([Gargron](https://github.com/tootsuite/mastodon/pull/12716))
- Fix IDN mentions not being processed, IDN domains not being rendered ([Gargron](https://github.com/tootsuite/mastodon/pull/12715))
- Fix error when searching for empty phrase ([Gargron](https://github.com/tootsuite/mastodon/pull/12711))
- Fix backups stopping due to read timeouts ([chr-1x](https://github.com/tootsuite/mastodon/pull/12281))
- Fix batch actions on non-pending tags in admin UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12537))
- Fix sample `SAML_ACS_URL`, `SAML_ISSUER` ([orlea](https://github.com/tootsuite/mastodon/pull/12669))
- Fix manual scrolling issue on Firefox/Windows in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12648))
- Fix archive takeout failing if total dump size exceeds 2GB ([scd31](https://github.com/tootsuite/mastodon/pull/12602), [Gargron](https://github.com/tootsuite/mastodon/pull/12653))
- Fix custom emoji category creation silently erroring out on duplicate category ([ThibG](https://github.com/tootsuite/mastodon/pull/12647))
- Fix link crawler not specifying preferred content type ([ThibG](https://github.com/tootsuite/mastodon/pull/12646))
- Fix featured hashtag setting page erroring out instead of rejecting invalid tags ([ThibG](https://github.com/tootsuite/mastodon/pull/12436))
- Fix tooltip messages of single/multiple-choice polls switcher being reversed in web UI ([acid-chicken](https://github.com/tootsuite/mastodon/pull/12616))
- Fix typo in help text of `tootctl statuses remove` ([trwnh](https://github.com/tootsuite/mastodon/pull/12603))
- Fix generic HTTP 500 error on duplicate records ([Gargron](https://github.com/tootsuite/mastodon/pull/12563))
- Fix old migration failing with new status default scope ([ThibG](https://github.com/tootsuite/mastodon/pull/12493))
- Fix errors when using search API with no query ([Gargron](https://github.com/tootsuite/mastodon/pull/12541), [trwnh](https://github.com/tootsuite/mastodon/pull/12549))
- Fix poll options not being selectable via keyboard in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12538))
- Fix conversations not having an unread indicator in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12506))
- Fix lost focus when modals open/close in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12437))
- Fix pending upload count not being decremented on error in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12499))
- Fix empty poll options not being removed on remote poll update ([ThibG](https://github.com/tootsuite/mastodon/pull/12484))
- Fix OCR with delete & redraft in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12465))
- Fix blur behind closed registration message ([ThibG](https://github.com/tootsuite/mastodon/pull/12442))
- Fix OEmbed discovery not handling different URL variants in query ([Gargron](https://github.com/tootsuite/mastodon/pull/12439))
- Fix link crawler crashing on `<a>` tags without `href` ([ThibG](https://github.com/tootsuite/mastodon/pull/12159))
- Fix whitelisted subdomains being ignored in whitelist mode ([noiob](https://github.com/tootsuite/mastodon/pull/12435))
- Fix broken audit log in whitelist mode in admin UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12303))
- Fix unread indicator not honoring "Only media" option in local and federated timelines in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12330))
- Fix error when rebuilding home feeds ([dariusk](https://github.com/tootsuite/mastodon/pull/12324))
- Fix relationship caches being broken as result of a follow request ([ThibG](https://github.com/tootsuite/mastodon/pull/12299))
- Fix more items than the limit being uploadable in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12300))
- Fix various issues with account migration ([ThibG](https://github.com/tootsuite/mastodon/pull/12301))
- Fix filtered out items being counted as pending items in slow mode in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12266))
- Fix notification filters not applying to poll options ([ThibG](https://github.com/tootsuite/mastodon/pull/12269))
- Fix notification message for user's own poll saying it's a poll they voted on in web UI ([ykzts](https://github.com/tootsuite/mastodon/pull/12219))
- Fix polls with an expiration not showing up as expired in web UI ([noellabo](https://github.com/tootsuite/mastodon/pull/12222))
- Fix volume slider having an offset between cursor and slider in Chromium in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12158))
- Fix Vagrant image not accepting connections ([shrft](https://github.com/tootsuite/mastodon/pull/12180))
- Fix batch actions being hidden on small screens in admin UI ([ThibG](https://github.com/tootsuite/mastodon/pull/12183))
- Fix incoming federation not working in whitelist mode ([ThibG](https://github.com/tootsuite/mastodon/pull/12185))
- Fix error when passing empty `source` param to `PUT /api/v1/accounts/update_credentials` ([jglauche](https://github.com/tootsuite/mastodon/pull/12259))
- Fix HTTP-based streaming API being cacheable by proxies ([BenLubar](https://github.com/tootsuite/mastodon/pull/12945))
- Fix users being able to register while `tootctl self-destruct` is in progress ([Kjwon15](https://github.com/tootsuite/mastodon/pull/12877))
- Fix microformats detection in link crawler not ignoring `h-card` links ([nightpool](https://github.com/tootsuite/mastodon/pull/12189))
- Fix outline on full-screen video in web UI ([hinaloe](https://github.com/tootsuite/mastodon/pull/12176))
- Fix TLD domain blocks not being editable ([ThibG](https://github.com/tootsuite/mastodon/pull/12805))
- Fix Nanobox deploy hooks ([danhunsaker](https://github.com/tootsuite/mastodon/pull/12663))
- Fix needlessly complicated SQL query when performing account search amongst followings ([ThibG](https://github.com/tootsuite/mastodon/pull/12302))
- Fix favourites count not updating when unfavouriting in web UI ([NimaBoscarino](https://github.com/tootsuite/mastodon/pull/12140))
- Fix occasional crash on scroll in Chromium in web UI ([hinaloe](https://github.com/tootsuite/mastodon/pull/12274))
- Fix intersection observer not working in single-column mode web UI ([panarom](https://github.com/tootsuite/mastodon/pull/12735))
- Fix voting issue with remote polls that contain trailing spaces ([ThibG](https://github.com/tootsuite/mastodon/pull/12515))
- Fix dynamic elements not working in pgHero due to CSP rules ([ykzts](https://github.com/tootsuite/mastodon/pull/12489))
- Fix overly verbose backtraces when delivering ActivityPub payloads ([zunda](https://github.com/tootsuite/mastodon/pull/12798))

### Security

- Fix OEmbed leaking information about existence of non-public statuses ([Gargron](https://github.com/tootsuite/mastodon/pull/12930))
- Fix password change/reset not immediately invalidating other sessions ([Gargron](https://github.com/tootsuite/mastodon/pull/12928))
- Fix settings pages being cacheable by the browser ([Gargron](https://github.com/tootsuite/mastodon/pull/12714))

## [3.0.1] - 2019-10-10
### Added

- Add `tootctl media usage` command ([Gargron](https://github.com/tootsuite/mastodon/pull/12115))
- Add admin setting to auto-approve trending hashtags ([Gargron](https://github.com/tootsuite/mastodon/pull/12122), [Gargron](https://github.com/tootsuite/mastodon/pull/12130))

### Changed

- Change `tootctl media refresh` to skip already downloaded attachments ([Gargron](https://github.com/tootsuite/mastodon/pull/12118))

### Removed

- Remove auto-silence behaviour from spam check ([Gargron](https://github.com/tootsuite/mastodon/pull/12117))
- Remove HTML `lang` attribute from individual statuses in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12124))
- Remove fallback to long description on sidebar and meta description ([Gargron](https://github.com/tootsuite/mastodon/pull/12119))

### Fixed

- Fix preloaded JSON-LD context for identity not being used ([Gargron](https://github.com/tootsuite/mastodon/pull/12138))
- Fix media editing modal changing dimensions once the image loads ([Gargron](https://github.com/tootsuite/mastodon/pull/12131))
- Fix not showing whether a custom emoji has a local counterpart in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12135))
- Fix attachment not being re-downloaded even if file is not stored ([Gargron](https://github.com/tootsuite/mastodon/pull/12125))
- Fix old migration trying to use new column due to default status scope ([Gargron](https://github.com/tootsuite/mastodon/pull/12095))
- Fix column back button missing for not found accounts ([trwnh](https://github.com/tootsuite/mastodon/pull/12094))
- Fix issues with tootctl's parallelization and progress reporting ([Gargron](https://github.com/tootsuite/mastodon/pull/12093), [Gargron](https://github.com/tootsuite/mastodon/pull/12097))
- Fix existing user records with now-renamed `pt` locale ([Gargron](https://github.com/tootsuite/mastodon/pull/12092))
- Fix hashtag timeline REST API accepting too many hashtags ([Gargron](https://github.com/tootsuite/mastodon/pull/12091))
- Fix `GET /api/v1/instance` REST APIs being unavailable in secure mode ([Gargron](https://github.com/tootsuite/mastodon/pull/12089))
- Fix performance of home feed regeneration and merging ([Gargron](https://github.com/tootsuite/mastodon/pull/12084))
- Fix ffmpeg performance issues due to stdout buffer overflow ([hugogameiro](https://github.com/tootsuite/mastodon/pull/12088))
- Fix S3 adapter retrying failing uploads with exponential backoff ([Gargron](https://github.com/tootsuite/mastodon/pull/12085))
- Fix `tootctl accounts cull` advertising unused option flag ([Kjwon15](https://github.com/tootsuite/mastodon/pull/12074))

## [3.0.0] - 2019-10-03
### Added

- Add "not available" label to unloaded media attachments in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11715), [Gargron](https://github.com/tootsuite/mastodon/pull/11745))
- **Add profile directory to web UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/11688), [mayaeh](https://github.com/tootsuite/mastodon/pull/11872))
  - Add profile directory opt-in federation
  - Add profile directory REST API
- Add special alert for throttled requests in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11677))
- Add confirmation modal when logging out from the web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11671))
- **Add audio player in web UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/11644), [Gargron](https://github.com/tootsuite/mastodon/pull/11652), [Gargron](https://github.com/tootsuite/mastodon/pull/11654), [ThibG](https://github.com/tootsuite/mastodon/pull/11629), [Gargron](https://github.com/tootsuite/mastodon/pull/12056))
- **Add autosuggestions for hashtags in web UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/11422), [ThibG](https://github.com/tootsuite/mastodon/pull/11632), [Gargron](https://github.com/tootsuite/mastodon/pull/11764), [Gargron](https://github.com/tootsuite/mastodon/pull/11588), [Gargron](https://github.com/tootsuite/mastodon/pull/11442))
- **Add media editing modal with OCR tool in web UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/11563), [Gargron](https://github.com/tootsuite/mastodon/pull/11566), [ThibG](https://github.com/tootsuite/mastodon/pull/11575), [ThibG](https://github.com/tootsuite/mastodon/pull/11576), [Gargron](https://github.com/tootsuite/mastodon/pull/11577), [Gargron](https://github.com/tootsuite/mastodon/pull/11573), [Gargron](https://github.com/tootsuite/mastodon/pull/11571))
- Add indicator of unread notifications to window title when web UI is out of focus ([Gargron](https://github.com/tootsuite/mastodon/pull/11560), [Gargron](https://github.com/tootsuite/mastodon/pull/11572))
- Add indicator for which options you voted for in a poll in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11195))
- **Add search results pagination to web UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/11409), [ThibG](https://github.com/tootsuite/mastodon/pull/11447))
- **Add option to disable real-time updates in web UI ("slow mode")** ([Gargron](https://github.com/tootsuite/mastodon/pull/9984), [ykzts](https://github.com/tootsuite/mastodon/pull/11880), [ThibG](https://github.com/tootsuite/mastodon/pull/11883), [Gargron](https://github.com/tootsuite/mastodon/pull/11898), [ThibG](https://github.com/tootsuite/mastodon/pull/11859))
- Add option to disable blurhash previews in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11188))
- Add native smooth scrolling when supported in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11207))
- Add scrolling to the search bar on focus in web UI ([Kjwon15](https://github.com/tootsuite/mastodon/pull/12032))
- Add refresh button to list of rebloggers/favouriters in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12031))
- Add error description and button to copy stack trace to web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/12033))
- Add search and sort functions to hashtag admin UI ([mayaeh](https://github.com/tootsuite/mastodon/pull/11829), [Gargron](https://github.com/tootsuite/mastodon/pull/11897), [mayaeh](https://github.com/tootsuite/mastodon/pull/11875))
- Add setting for default search engine indexing in admin UI ([brortao](https://github.com/tootsuite/mastodon/pull/11804))
- Add account bio to account view in admin UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11473))
- **Add option to include reported statuses in warning e-mail from admin UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/11639), [Gargron](https://github.com/tootsuite/mastodon/pull/11812), [Gargron](https://github.com/tootsuite/mastodon/pull/11741), [Gargron](https://github.com/tootsuite/mastodon/pull/11698), [mayaeh](https://github.com/tootsuite/mastodon/pull/11765))
- Add number of pending accounts and pending hashtags to dashboard in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11514))
- **Add account migration UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/11846), [noellabo](https://github.com/tootsuite/mastodon/pull/11905), [noellabo](https://github.com/tootsuite/mastodon/pull/11907), [noellabo](https://github.com/tootsuite/mastodon/pull/11906), [noellabo](https://github.com/tootsuite/mastodon/pull/11902))
- **Add table of contents to about page** ([Gargron](https://github.com/tootsuite/mastodon/pull/11885), [ykzts](https://github.com/tootsuite/mastodon/pull/11941), [ykzts](https://github.com/tootsuite/mastodon/pull/11895), [Kjwon15](https://github.com/tootsuite/mastodon/pull/11916))
- **Add password challenge to 2FA settings, e-mail notifications** ([Gargron](https://github.com/tootsuite/mastodon/pull/11878))
- **Add optional public list of domain blocks with comments** ([ThibG](https://github.com/tootsuite/mastodon/pull/11298), [ThibG](https://github.com/tootsuite/mastodon/pull/11515), [Gargron](https://github.com/tootsuite/mastodon/pull/11908))
- Add an RSS feed for featured hashtags ([noellabo](https://github.com/tootsuite/mastodon/pull/10502))
- Add explanations to featured hashtags UI and profile ([Gargron](https://github.com/tootsuite/mastodon/pull/11586))
- **Add hashtag trends with admin and user settings** ([Gargron](https://github.com/tootsuite/mastodon/pull/11490), [Gargron](https://github.com/tootsuite/mastodon/pull/11502), [Gargron](https://github.com/tootsuite/mastodon/pull/11641), [Gargron](https://github.com/tootsuite/mastodon/pull/11594), [Gargron](https://github.com/tootsuite/mastodon/pull/11517), [mayaeh](https://github.com/tootsuite/mastodon/pull/11845), [Gargron](https://github.com/tootsuite/mastodon/pull/11774), [Gargron](https://github.com/tootsuite/mastodon/pull/11712), [Gargron](https://github.com/tootsuite/mastodon/pull/11791), [Gargron](https://github.com/tootsuite/mastodon/pull/11743), [Gargron](https://github.com/tootsuite/mastodon/pull/11740), [Gargron](https://github.com/tootsuite/mastodon/pull/11714), [ThibG](https://github.com/tootsuite/mastodon/pull/11631), [Sasha-Sorokin](https://github.com/tootsuite/mastodon/pull/11569), [Gargron](https://github.com/tootsuite/mastodon/pull/11524), [Gargron](https://github.com/tootsuite/mastodon/pull/11513))
  - Add hashtag usage breakdown to admin UI
  - Add batch actions for hashtags to admin UI
  - Add trends to web UI
  - Add trends to public pages
  - Add user preference to hide trends
  - Add admin setting to disable trends
- **Add categories for custom emojis** ([Gargron](https://github.com/tootsuite/mastodon/pull/11196), [Gargron](https://github.com/tootsuite/mastodon/pull/11793), [Gargron](https://github.com/tootsuite/mastodon/pull/11920), [highemerly](https://github.com/tootsuite/mastodon/pull/11876))
  - Add custom emoji categories to emoji picker in web UI
  - Add `category` to custom emojis in REST API
  - Add batch actions for custom emojis in admin UI
- Add max image dimensions to error message ([raboof](https://github.com/tootsuite/mastodon/pull/11552))
- Add aac, m4a, 3gp, amr, wma to allowed audio formats ([Gargron](https://github.com/tootsuite/mastodon/pull/11342), [umonaca](https://github.com/tootsuite/mastodon/pull/11687))
- **Add search syntax for operators and phrases** ([Gargron](https://github.com/tootsuite/mastodon/pull/11411))
- **Add REST API for managing featured hashtags** ([noellabo](https://github.com/tootsuite/mastodon/pull/11778))
- **Add REST API for managing timeline read markers** ([Gargron](https://github.com/tootsuite/mastodon/pull/11762))
- Add `exclude_unreviewed` param to `GET /api/v2/search` REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/11977))
- Add `reason` param to `POST /api/v1/accounts` REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/12064))
- **Add ActivityPub secure mode** ([Gargron](https://github.com/tootsuite/mastodon/pull/11269), [ThibG](https://github.com/tootsuite/mastodon/pull/11332), [ThibG](https://github.com/tootsuite/mastodon/pull/11295))
- Add HTTP signatures to all outgoing ActivityPub GET requests ([Gargron](https://github.com/tootsuite/mastodon/pull/11284), [ThibG](https://github.com/tootsuite/mastodon/pull/11300))
- Add support for ActivityPub Audio activities ([ThibG](https://github.com/tootsuite/mastodon/pull/11189))
- Add ActivityPub actor representing the entire server ([ThibG](https://github.com/tootsuite/mastodon/pull/11321), [rtucker](https://github.com/tootsuite/mastodon/pull/11400), [ThibG](https://github.com/tootsuite/mastodon/pull/11561), [Gargron](https://github.com/tootsuite/mastodon/pull/11798))
- **Add whitelist mode** ([Gargron](https://github.com/tootsuite/mastodon/pull/11291), [mayaeh](https://github.com/tootsuite/mastodon/pull/11634))
- Add config of multipart threshold for S3 ([ykzts](https://github.com/tootsuite/mastodon/pull/11924), [ykzts](https://github.com/tootsuite/mastodon/pull/11944))
- Add health check endpoint for web ([ykzts](https://github.com/tootsuite/mastodon/pull/11770), [ykzts](https://github.com/tootsuite/mastodon/pull/11947))
- Add HTTP signature keyId to request log ([Gargron](https://github.com/tootsuite/mastodon/pull/11591))
- Add `SMTP_REPLY_TO` environment variable ([hugogameiro](https://github.com/tootsuite/mastodon/pull/11718))
- Add `tootctl preview_cards remove` command ([mayaeh](https://github.com/tootsuite/mastodon/pull/11320))
- Add `tootctl media refresh` command ([Gargron](https://github.com/tootsuite/mastodon/pull/11775))
- Add `tootctl cache recount` command ([Gargron](https://github.com/tootsuite/mastodon/pull/11597))
- Add option to exclude suspended domains from `tootctl domains crawl` ([dariusk](https://github.com/tootsuite/mastodon/pull/11454))
- Add parallelization to `tootctl search deploy` ([noellabo](https://github.com/tootsuite/mastodon/pull/12051))
- Add soft delete for statuses for instant deletes through API ([Gargron](https://github.com/tootsuite/mastodon/pull/11623), [Gargron](https://github.com/tootsuite/mastodon/pull/11648))
- Add rails-level JSON caching ([Gargron](https://github.com/tootsuite/mastodon/pull/11333), [Gargron](https://github.com/tootsuite/mastodon/pull/11271))
- **Add request pool to improve delivery performance** ([Gargron](https://github.com/tootsuite/mastodon/pull/10353), [ykzts](https://github.com/tootsuite/mastodon/pull/11756))
- Add concurrent connection attempts to resolved IP addresses ([ThibG](https://github.com/tootsuite/mastodon/pull/11757))
- Add index for remember_token to improve login performance ([abcang](https://github.com/tootsuite/mastodon/pull/11881))
- **Add more accurate hashtag search** ([Gargron](https://github.com/tootsuite/mastodon/pull/11579), [Gargron](https://github.com/tootsuite/mastodon/pull/11427), [Gargron](https://github.com/tootsuite/mastodon/pull/11448))
- **Add more accurate account search** ([Gargron](https://github.com/tootsuite/mastodon/pull/11537), [Gargron](https://github.com/tootsuite/mastodon/pull/11580))
- **Add a spam check** ([Gargron](https://github.com/tootsuite/mastodon/pull/11217), [Gargron](https://github.com/tootsuite/mastodon/pull/11806), [ThibG](https://github.com/tootsuite/mastodon/pull/11296))
- Add new languages ([Gargron](https://github.com/tootsuite/mastodon/pull/12062))
  - Breton
  - Spanish (Argentina)
  - Estonian
  - Macedonian
  - New Norwegian
- Add NodeInfo endpoint ([Gargron](https://github.com/tootsuite/mastodon/pull/12002), [Gargron](https://github.com/tootsuite/mastodon/pull/12058))

### Changed

- **Change conversations UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/11896))
- Change dashboard to short number notation ([noellabo](https://github.com/tootsuite/mastodon/pull/11847), [noellabo](https://github.com/tootsuite/mastodon/pull/11911))
- Change REST API `GET /api/v1/timelines/public` to require authentication when public preview is off ([ThibG](https://github.com/tootsuite/mastodon/pull/11802))
- Change REST API `POST /api/v1/follow_requests/:id/(approve|reject)` to return relationship ([ThibG](https://github.com/tootsuite/mastodon/pull/11800))
- Change rate limit for media proxy ([ykzts](https://github.com/tootsuite/mastodon/pull/11814))
- Change unlisted custom emoji to not appear in autosuggestions ([Gargron](https://github.com/tootsuite/mastodon/pull/11818))
- Change max length of media descriptions from 420 to 1500 characters ([Gargron](https://github.com/tootsuite/mastodon/pull/11819), [ThibG](https://github.com/tootsuite/mastodon/pull/11836))
- **Change deletes to preserve soft-deleted statuses in unresolved reports** ([Gargron](https://github.com/tootsuite/mastodon/pull/11805))
- **Change tootctl to use inline parallelization instead of Sidekiq** ([Gargron](https://github.com/tootsuite/mastodon/pull/11776))
- **Change account deletion page to have better explanations** ([Gargron](https://github.com/tootsuite/mastodon/pull/11753), [Gargron](https://github.com/tootsuite/mastodon/pull/11763))
- Change hashtag component in web UI to show numbers for 2 last days ([Gargron](https://github.com/tootsuite/mastodon/pull/11742), [Gargron](https://github.com/tootsuite/mastodon/pull/11755), [Gargron](https://github.com/tootsuite/mastodon/pull/11754))
- Change OpenGraph description on sign-up page to reflect invite ([Gargron](https://github.com/tootsuite/mastodon/pull/11744))
- Change layout of public profile directory to be the same as in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11705))
- Change detailed status child ordering to sort self-replies on top ([ThibG](https://github.com/tootsuite/mastodon/pull/11686))
- Change window resize handler to switch to/from mobile layout as soon as needed ([ThibG](https://github.com/tootsuite/mastodon/pull/11656))
- Change icon button styles to make hover/focus states more obvious ([ThibG](https://github.com/tootsuite/mastodon/pull/11474))
- Change contrast of status links that are not mentions or hashtags ([ThibG](https://github.com/tootsuite/mastodon/pull/11406))
- **Change hashtags to preserve first-used casing** ([Gargron](https://github.com/tootsuite/mastodon/pull/11416), [Gargron](https://github.com/tootsuite/mastodon/pull/11508), [Gargron](https://github.com/tootsuite/mastodon/pull/11504), [Gargron](https://github.com/tootsuite/mastodon/pull/11507), [Gargron](https://github.com/tootsuite/mastodon/pull/11441))
- **Change unconfirmed user login behaviour** ([Gargron](https://github.com/tootsuite/mastodon/pull/11375), [ThibG](https://github.com/tootsuite/mastodon/pull/11394), [Gargron](https://github.com/tootsuite/mastodon/pull/11860))
- **Change single-column mode to scroll the whole page** ([Gargron](https://github.com/tootsuite/mastodon/pull/11359), [Gargron](https://github.com/tootsuite/mastodon/pull/11894), [Gargron](https://github.com/tootsuite/mastodon/pull/11891), [ThibG](https://github.com/tootsuite/mastodon/pull/11655), [Gargron](https://github.com/tootsuite/mastodon/pull/11463), [Gargron](https://github.com/tootsuite/mastodon/pull/11458), [ThibG](https://github.com/tootsuite/mastodon/pull/11395), [Gargron](https://github.com/tootsuite/mastodon/pull/11418))
- Change `tootctl accounts follow` to only work with local accounts ([angristan](https://github.com/tootsuite/mastodon/pull/11592))
- Change Dockerfile ([Shleeble](https://github.com/tootsuite/mastodon/pull/11710), [ykzts](https://github.com/tootsuite/mastodon/pull/11768), [Shleeble](https://github.com/tootsuite/mastodon/pull/11707))
- Change supported Node versions to include v12 ([abcang](https://github.com/tootsuite/mastodon/pull/11706))
- Change Portuguese language from `pt` to `pt-PT` ([Gargron](https://github.com/tootsuite/mastodon/pull/11820))
- Change domain block silence to always require approval on follow ([ThibG](https://github.com/tootsuite/mastodon/pull/11975))
- Change link preview fetcher to not perform a HEAD request first ([Gargron](https://github.com/tootsuite/mastodon/pull/12028))
- Change `tootctl domains purge` to accept multiple domains at once ([Gargron](https://github.com/tootsuite/mastodon/pull/12046))

### Removed

- **Remove OStatus support** ([Gargron](https://github.com/tootsuite/mastodon/pull/11205), [Gargron](https://github.com/tootsuite/mastodon/pull/11303), [Gargron](https://github.com/tootsuite/mastodon/pull/11460), [ThibG](https://github.com/tootsuite/mastodon/pull/11280), [ThibG](https://github.com/tootsuite/mastodon/pull/11278))
- Remove Atom feeds and old URLs in the form of `GET /:username/updates/:id` ([Gargron](https://github.com/tootsuite/mastodon/pull/11247))
- Remove WebP support ([angristan](https://github.com/tootsuite/mastodon/pull/11589))
- Remove deprecated config options from Heroku and Scalingo ([ykzts](https://github.com/tootsuite/mastodon/pull/11925))
- Remove deprecated REST API `GET /api/v1/search` API ([Gargron](https://github.com/tootsuite/mastodon/pull/11823))
- Remove deprecated REST API `GET /api/v1/statuses/:id/card` ([Gargron](https://github.com/tootsuite/mastodon/pull/11213))
- Remove deprecated REST API `POST /api/v1/notifications/dismiss?id=:id` ([Gargron](https://github.com/tootsuite/mastodon/pull/11214))
- Remove deprecated REST API `GET /api/v1/timelines/direct` ([Gargron](https://github.com/tootsuite/mastodon/pull/11212))

### Fixed

- Fix manifest warning ([ykzts](https://github.com/tootsuite/mastodon/pull/11767))
- Fix admin UI for custom emoji not respecting GIF autoplay preference ([ThibG](https://github.com/tootsuite/mastodon/pull/11801))
- Fix page body not being scrollable in admin/settings layout ([Gargron](https://github.com/tootsuite/mastodon/pull/11893))
- Fix placeholder colors for inputs not being explicitly defined ([Gargron](https://github.com/tootsuite/mastodon/pull/11890))
- Fix incorrect enclosure length in RSS ([tsia](https://github.com/tootsuite/mastodon/pull/11889))
- Fix TOTP codes not being filtered from logs during enabling/disabling ([Gargron](https://github.com/tootsuite/mastodon/pull/11877))
- Fix webfinger response not returning 410 when account is suspended ([Gargron](https://github.com/tootsuite/mastodon/pull/11869))
- Fix ActivityPub Move handler queuing jobs that will fail if account is suspended ([Gargron](https://github.com/tootsuite/mastodon/pull/11864))
- Fix SSO login not using existing account when e-mail is verified ([Gargron](https://github.com/tootsuite/mastodon/pull/11862))
- Fix web UI allowing uploads past status limit via drag & drop ([Gargron](https://github.com/tootsuite/mastodon/pull/11863))
- Fix expiring polls not being displayed as such in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11835))
- Fix 2FA challenge and password challenge for non-database users ([Gargron](https://github.com/tootsuite/mastodon/pull/11831), [Gargron](https://github.com/tootsuite/mastodon/pull/11943))
- Fix profile fields overflowing page width in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11828))
- Fix web push subscriptions being deleted on rate limit or timeout ([Gargron](https://github.com/tootsuite/mastodon/pull/11826))
- Fix display of long poll options in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11717), [ThibG](https://github.com/tootsuite/mastodon/pull/11833))
- Fix search API not resolving URL when `type` is given ([Gargron](https://github.com/tootsuite/mastodon/pull/11822))
- Fix hashtags being split by ZWNJ character ([Gargron](https://github.com/tootsuite/mastodon/pull/11821))
- Fix scroll position resetting when opening media modals in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11815))
- Fix duplicate HTML IDs on about page ([ThibG](https://github.com/tootsuite/mastodon/pull/11803))
- Fix admin UI showing superfluous reject media/reports on suspended domain blocks ([ThibG](https://github.com/tootsuite/mastodon/pull/11749))
- Fix ActivityPub context not being dynamically computed ([ThibG](https://github.com/tootsuite/mastodon/pull/11746))
- Fix Mastodon logo style on hover on public pages' footer ([ThibG](https://github.com/tootsuite/mastodon/pull/11735))
- Fix height of dashboard counters ([ThibG](https://github.com/tootsuite/mastodon/pull/11736))
- Fix custom emoji animation on hover in web UI directory bios ([ThibG](https://github.com/tootsuite/mastodon/pull/11716))
- Fix non-numbers being passed to Redis and causing an error ([Gargron](https://github.com/tootsuite/mastodon/pull/11697))
- Fix error in REST API for an account's statuses ([Gargron](https://github.com/tootsuite/mastodon/pull/11700))
- Fix uncaught error when resource param is missing in Webfinger request ([Gargron](https://github.com/tootsuite/mastodon/pull/11701))
- Fix uncaught domain normalization error in remote follow ([Gargron](https://github.com/tootsuite/mastodon/pull/11703))
- Fix uncaught 422 and 500 errors ([Gargron](https://github.com/tootsuite/mastodon/pull/11590), [Gargron](https://github.com/tootsuite/mastodon/pull/11811))
- Fix uncaught parameter missing exceptions and missing error templates ([Gargron](https://github.com/tootsuite/mastodon/pull/11702))
- Fix encoding error when checking e-mail MX records ([Gargron](https://github.com/tootsuite/mastodon/pull/11696))
- Fix items in StatusContent render list not all having a key ([ThibG](https://github.com/tootsuite/mastodon/pull/11645))
- Fix remote and staff-removed statuses leaving media behind for a day ([Gargron](https://github.com/tootsuite/mastodon/pull/11638))
- Fix CSP needlessly allowing blob URLs in script-src ([ThibG](https://github.com/tootsuite/mastodon/pull/11620))
- Fix ignoring whole status because of one invalid hashtag ([Gargron](https://github.com/tootsuite/mastodon/pull/11621))
- Fix hidden statuses losing focus ([ThibG](https://github.com/tootsuite/mastodon/pull/11208))
- Fix loading bar being obscured by other elements in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11598))
- Fix multiple issues with replies collection for pages further than self-replies ([ThibG](https://github.com/tootsuite/mastodon/pull/11582))
- Fix blurhash and autoplay not working on public pages ([Gargron](https://github.com/tootsuite/mastodon/pull/11585))
- Fix 422 being returned instead of 404 when POSTing to unmatched routes ([Gargron](https://github.com/tootsuite/mastodon/pull/11574), [Gargron](https://github.com/tootsuite/mastodon/pull/11704))
- Fix client-side resizing of image uploads ([ThibG](https://github.com/tootsuite/mastodon/pull/11570))
- Fix short number formatting for numbers above million in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11559))
- Fix ActivityPub and REST API queries setting cookies and preventing caching ([ThibG](https://github.com/tootsuite/mastodon/pull/11539), [ThibG](https://github.com/tootsuite/mastodon/pull/11557), [ThibG](https://github.com/tootsuite/mastodon/pull/11336), [ThibG](https://github.com/tootsuite/mastodon/pull/11331))
- Fix some emojis in profile metadata labels are not emojified. ([kedamaDQ](https://github.com/tootsuite/mastodon/pull/11534))
- Fix account search always returning exact match on paginated results ([Gargron](https://github.com/tootsuite/mastodon/pull/11525))
- Fix acct URIs with IDN domains not being resolved ([Gargron](https://github.com/tootsuite/mastodon/pull/11520))
- Fix admin dashboard missing latest features ([Gargron](https://github.com/tootsuite/mastodon/pull/11505))
- Fix jumping of toot date when clicking spoiler button ([ariasuni](https://github.com/tootsuite/mastodon/pull/11449))
- Fix boost to original audience not working on mobile in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11371))
- Fix handling of webfinger redirects in ResolveAccountService ([ThibG](https://github.com/tootsuite/mastodon/pull/11279))
- Fix URLs appearing twice in errors of ActivityPub::DeliveryWorker ([Gargron](https://github.com/tootsuite/mastodon/pull/11231))
- Fix support for HTTP proxies ([ThibG](https://github.com/tootsuite/mastodon/pull/11245))
- Fix HTTP requests to IPv6 hosts ([ThibG](https://github.com/tootsuite/mastodon/pull/11240))
- Fix error in ElasticSearch index import ([mayaeh](https://github.com/tootsuite/mastodon/pull/11192))
- Fix duplicate account error when seeding development database ([ysksn](https://github.com/tootsuite/mastodon/pull/11366))
- Fix performance of session clean-up scheduler ([abcang](https://github.com/tootsuite/mastodon/pull/11871))
- Fix older migrations not running ([zunda](https://github.com/tootsuite/mastodon/pull/11377))
- Fix URLs counting towards RTL detection ([ahangarha](https://github.com/tootsuite/mastodon/pull/11759))
- Fix unnecessary status re-rendering in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11211))
- Fix http_parser.rb gem not being compiled when no network available ([petabyteboy](https://github.com/tootsuite/mastodon/pull/11444))
- Fix muted text color not applying to all text ([trwnh](https://github.com/tootsuite/mastodon/pull/11996))
- Fix follower/following lists resetting on back-navigation in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11986))
- Fix n+1 query when approving multiple follow requests ([abcang](https://github.com/tootsuite/mastodon/pull/12004))
- Fix records not being indexed into ElasticSearch sometimes ([Gargron](https://github.com/tootsuite/mastodon/pull/12024))
- Fix needlessly indexing unsearchable statuses into ElasticSearch ([Gargron](https://github.com/tootsuite/mastodon/pull/12041))
- Fix new user bootstrapping crashing when to-be-followed accounts are invalid ([ThibG](https://github.com/tootsuite/mastodon/pull/12037))
- Fix featured hashtag URL being interpreted as media or replies tab ([Gargron](https://github.com/tootsuite/mastodon/pull/12048))
- Fix account counters being overwritten by parallel writes ([Gargron](https://github.com/tootsuite/mastodon/pull/12045))

### Security

- Fix performance of GIF re-encoding and always strip EXIF data from videos ([Gargron](https://github.com/tootsuite/mastodon/pull/12057))

## [2.9.3] - 2019-08-10
### Added

- Add GIF and WebP support for custom emojis ([Gargron](https://github.com/tootsuite/mastodon/pull/11519))
- Add logout link to dropdown menu in web UI ([koyuawsmbrtn](https://github.com/tootsuite/mastodon/pull/11353))
- Add indication that text search is unavailable in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11112), [ThibG](https://github.com/tootsuite/mastodon/pull/11202))
- Add `suffix` to `Mastodon::Version` to help forks ([clarfon](https://github.com/tootsuite/mastodon/pull/11407))
- Add on-hover animation to animated custom emoji in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11348), [ThibG](https://github.com/tootsuite/mastodon/pull/11404), [ThibG](https://github.com/tootsuite/mastodon/pull/11522))
- Add custom emoji support in profile metadata labels ([ThibG](https://github.com/tootsuite/mastodon/pull/11350))

### Changed

- Change default interface of web and streaming from 0.0.0.0 to 127.0.0.1 ([Gargron](https://github.com/tootsuite/mastodon/pull/11302), [zunda](https://github.com/tootsuite/mastodon/pull/11378), [Gargron](https://github.com/tootsuite/mastodon/pull/11351), [zunda](https://github.com/tootsuite/mastodon/pull/11326))
- Change the retry limit of web push notifications ([highemerly](https://github.com/tootsuite/mastodon/pull/11292))
- Change ActivityPub deliveries to not retry HTTP 501 errors ([Gargron](https://github.com/tootsuite/mastodon/pull/11233))
- Change language detection to include hashtags as words ([Gargron](https://github.com/tootsuite/mastodon/pull/11341))
- Change terms and privacy policy pages to always be accessible ([Gargron](https://github.com/tootsuite/mastodon/pull/11334))
- Change robots tag to include `noarchive` when user opts out of indexing ([Kjwon15](https://github.com/tootsuite/mastodon/pull/11421))

### Fixed

- Fix account domain block not clearing out notifications ([Gargron](https://github.com/tootsuite/mastodon/pull/11393))
- Fix incorrect locale sometimes being detected for browser ([Gargron](https://github.com/tootsuite/mastodon/pull/8657))
- Fix crash when saving invalid domain name ([Gargron](https://github.com/tootsuite/mastodon/pull/11528))
- Fix pinned statuses REST API returning pagination headers ([Gargron](https://github.com/tootsuite/mastodon/pull/11526))
- Fix "cancel follow request" button having unreadable text in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11521))
- Fix image uploads being blank when canvas read access is blocked ([ThibG](https://github.com/tootsuite/mastodon/pull/11499))
- Fix avatars not being animated on hover when not logged in ([ThibG](https://github.com/tootsuite/mastodon/pull/11349))
- Fix overzealous sanitization of HTML lists ([ThibG](https://github.com/tootsuite/mastodon/pull/11354))
- Fix block crashing when a follow request exists ([ThibG](https://github.com/tootsuite/mastodon/pull/11288))
- Fix backup service crashing when an attachment is missing ([ThibG](https://github.com/tootsuite/mastodon/pull/11241))
- Fix account moderation action always sending e-mail notification ([Gargron](https://github.com/tootsuite/mastodon/pull/11242))
- Fix swiping columns on mobile sometimes failing in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11200))
- Fix wrong actor URI being serialized into poll updates ([ThibG](https://github.com/tootsuite/mastodon/pull/11194))
- Fix statsd UDP sockets not being cleaned up in Sidekiq ([Gargron](https://github.com/tootsuite/mastodon/pull/11230))
- Fix expiration date of filters being set to "never" when editing them ([ThibG](https://github.com/tootsuite/mastodon/pull/11204))
- Fix support for MP4 files that are actually M4V files ([Gargron](https://github.com/tootsuite/mastodon/pull/11210))
- Fix `alerts` not being typecast correctly in push subscription in REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/11343))
- Fix some notices staying on unrelated pages ([ThibG](https://github.com/tootsuite/mastodon/pull/11364))
- Fix unboosting sometimes preventing a boost from reappearing on feed ([ThibG](https://github.com/tootsuite/mastodon/pull/11405), [Gargron](https://github.com/tootsuite/mastodon/pull/11450))
- Fix only one middle dot being recognized in hashtags ([Gargron](https://github.com/tootsuite/mastodon/pull/11345), [ThibG](https://github.com/tootsuite/mastodon/pull/11363))
- Fix unnecessary SQL query performed on unauthenticated requests ([Gargron](https://github.com/tootsuite/mastodon/pull/11179))
- Fix incorrect timestamp displayed on featured tags ([Kjwon15](https://github.com/tootsuite/mastodon/pull/11477))
- Fix privacy dropdown active state when dropdown is placed on top of it ([ThibG](https://github.com/tootsuite/mastodon/pull/11495))
- Fix filters not being applied to poll options ([ThibG](https://github.com/tootsuite/mastodon/pull/11174))
- Fix keyboard navigation on various dropdowns ([ThibG](https://github.com/tootsuite/mastodon/pull/11511), [ThibG](https://github.com/tootsuite/mastodon/pull/11492), [ThibG](https://github.com/tootsuite/mastodon/pull/11491))
- Fix keyboard navigation in modals ([ThibG](https://github.com/tootsuite/mastodon/pull/11493))
- Fix image conversation being non-deterministic due to timestamps ([Gargron](https://github.com/tootsuite/mastodon/pull/11408))
- Fix web UI performance ([ThibG](https://github.com/tootsuite/mastodon/pull/11211), [ThibG](https://github.com/tootsuite/mastodon/pull/11234))
- Fix scrolling to compose form when not necessary in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11246), [ThibG](https://github.com/tootsuite/mastodon/pull/11182))
- Fix save button being enabled when list title is empty in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11475))
- Fix poll expiration not being pre-filled on delete & redraft in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11203))
- Fix content warning sometimes being set when not requested in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11206))

### Security

- Fix invites not being disabled upon account suspension ([ThibG](https://github.com/tootsuite/mastodon/pull/11412))
- Fix blocked domains still being able to fill database with account records ([Gargron](https://github.com/tootsuite/mastodon/pull/11219))

## [2.9.2] - 2019-06-22
### Added

- Add `short_description` and `approval_required` to `GET /api/v1/instance` ([Gargron](https://github.com/tootsuite/mastodon/pull/11146))

### Changed

- Change camera icon to paperclip icon in upload form ([koyuawsmbrtn](https://github.com/tootsuite/mastodon/pull/11149))

### Fixed

- Fix audio-only OGG and WebM files not being processed as such ([Gargron](https://github.com/tootsuite/mastodon/pull/11151))
- Fix audio not being downloaded from remote servers ([Gargron](https://github.com/tootsuite/mastodon/pull/11145))

## [2.9.1] - 2019-06-22
### Added

- Add moderation API ([Gargron](https://github.com/tootsuite/mastodon/pull/9387))
- Add audio uploads ([Gargron](https://github.com/tootsuite/mastodon/pull/11123), [Gargron](https://github.com/tootsuite/mastodon/pull/11141))

### Changed

- Change domain blocks to automatically support subdomains ([Gargron](https://github.com/tootsuite/mastodon/pull/11138))
- Change Nanobox configuration to bring it up to date ([danhunsaker](https://github.com/tootsuite/mastodon/pull/11083))

### Removed

- Remove expensive counters from federation page in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11139))

### Fixed

- Fix converted media being saved with original extension and mime type ([Gargron](https://github.com/tootsuite/mastodon/pull/11130))
- Fix layout of identity proofs settings ([acid-chicken](https://github.com/tootsuite/mastodon/pull/11126))
- Fix active scope only returning suspended users ([ThibG](https://github.com/tootsuite/mastodon/pull/11111))
- Fix sanitizer making block level elements unreadable ([Gargron](https://github.com/tootsuite/mastodon/pull/10836))
- Fix label for site theme not being translated in admin UI ([palindromordnilap](https://github.com/tootsuite/mastodon/pull/11121))
- Fix statuses not being filtered irreversibly in web UI under some circumstances ([ThibG](https://github.com/tootsuite/mastodon/pull/11113))
- Fix scrolling behaviour in compose form ([ThibG](https://github.com/tootsuite/mastodon/pull/11093))

## [2.9.0] - 2019-06-13
### Added

- **Add single-column mode in web UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/10807), [Gargron](https://github.com/tootsuite/mastodon/pull/10848), [Gargron](https://github.com/tootsuite/mastodon/pull/11003), [Gargron](https://github.com/tootsuite/mastodon/pull/10961), [Hanage999](https://github.com/tootsuite/mastodon/pull/10915), [noellabo](https://github.com/tootsuite/mastodon/pull/10917), [abcang](https://github.com/tootsuite/mastodon/pull/10859), [Gargron](https://github.com/tootsuite/mastodon/pull/10820), [Gargron](https://github.com/tootsuite/mastodon/pull/10835), [Gargron](https://github.com/tootsuite/mastodon/pull/10809), [Gargron](https://github.com/tootsuite/mastodon/pull/10963), [noellabo](https://github.com/tootsuite/mastodon/pull/10883), [Hanage999](https://github.com/tootsuite/mastodon/pull/10839))
- Add waiting time to the list of pending accounts in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10985))
- Add a keyboard shortcut to hide/show media in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10647), [Gargron](https://github.com/tootsuite/mastodon/pull/10838), [ThibG](https://github.com/tootsuite/mastodon/pull/10872))
- Add `account_id` param to `GET /api/v1/notifications` ([pwoolcoc](https://github.com/tootsuite/mastodon/pull/10796))
- Add confirmation modal for unboosting toots in web UI ([aurelien-reeves](https://github.com/tootsuite/mastodon/pull/10287))
- Add emoji suggestions to content warning and poll option fields in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10555))
- Add `source` attribute to response of `DELETE /api/v1/statuses/:id` ([ThibG](https://github.com/tootsuite/mastodon/pull/10669))
- Add some caching for HTML versions of public status pages ([ThibG](https://github.com/tootsuite/mastodon/pull/10701))
- Add button to conveniently copy OAuth code ([ThibG](https://github.com/tootsuite/mastodon/pull/11065))

### Changed

- **Change default layout to single column in web UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/10847))
- **Change light theme** ([Gargron](https://github.com/tootsuite/mastodon/pull/10992), [Gargron](https://github.com/tootsuite/mastodon/pull/10996), [yuzulabo](https://github.com/tootsuite/mastodon/pull/10754), [Gargron](https://github.com/tootsuite/mastodon/pull/10845))
- **Change preferences page into appearance, notifications, and other** ([Gargron](https://github.com/tootsuite/mastodon/pull/10977), [Gargron](https://github.com/tootsuite/mastodon/pull/10988))
- Change priority of delete activity forwards for replies and reblogs ([Gargron](https://github.com/tootsuite/mastodon/pull/11002))
- Change Mastodon logo to use primary text color of the given theme ([Gargron](https://github.com/tootsuite/mastodon/pull/10994))
- Change reblogs counter to be updated when boosted privately ([Gargron](https://github.com/tootsuite/mastodon/pull/10964))
- Change bio limit from 160 to 500 characters ([trwnh](https://github.com/tootsuite/mastodon/pull/10790))
- Change API rate limiting to reduce allowed unauthenticated requests ([ThibG](https://github.com/tootsuite/mastodon/pull/10860), [hinaloe](https://github.com/tootsuite/mastodon/pull/10868), [mayaeh](https://github.com/tootsuite/mastodon/pull/10867))
- Change help text of `tootctl emoji import` command to specify a gzipped TAR archive is required ([dariusk](https://github.com/tootsuite/mastodon/pull/11000))
- Change web UI to hide poll options behind content warnings ([ThibG](https://github.com/tootsuite/mastodon/pull/10983))
- Change silencing to ensure local effects and remote effects are the same for silenced local users ([ThibG](https://github.com/tootsuite/mastodon/pull/10575))
- Change `tootctl domains purge` to remove custom emoji as well ([Kjwon15](https://github.com/tootsuite/mastodon/pull/10721))
- Change Docker image to keep `apt` working ([SuperSandro2000](https://github.com/tootsuite/mastodon/pull/10830))

### Removed

- Remove `dist-upgrade` from Docker image ([SuperSandro2000](https://github.com/tootsuite/mastodon/pull/10822))

### Fixed

- Fix RTL layout not being RTL within the columns area in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10990))
- Fix display of alternative text when a media attachment is not available in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10981))
- Fix not being able to directly switch between list timelines in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10973))
- Fix media sensitivity not being maintained in delete & redraft in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10980))
- Fix emoji picker being always displayed in web UI ([noellabo](https://github.com/tootsuite/mastodon/pull/10979), [yuzulabo](https://github.com/tootsuite/mastodon/pull/10801), [wcpaez](https://github.com/tootsuite/mastodon/pull/10978))
- Fix potential private status leak through caching ([ThibG](https://github.com/tootsuite/mastodon/pull/10969))
- Fix refreshing featured toots when the new collection is empty in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10971))
- Fix undoing domain block also undoing individual moderation on users from before the domain block ([ThibG](https://github.com/tootsuite/mastodon/pull/10660))
- Fix time not being local in the audit log ([yuzulabo](https://github.com/tootsuite/mastodon/pull/10751))
- Fix statuses removed by moderation re-appearing on subsequent fetches ([Kjwon15](https://github.com/tootsuite/mastodon/pull/10732))
- Fix misattribution of inlined announces if `attributedTo` isn't present in ActivityPub ([ThibG](https://github.com/tootsuite/mastodon/pull/10967))
- Fix `GET /api/v1/polls/:id` not requiring authentication for non-public polls ([Gargron](https://github.com/tootsuite/mastodon/pull/10960))
- Fix handling of blank poll options in ActivityPub ([ThibG](https://github.com/tootsuite/mastodon/pull/10946))
- Fix avatar preview aspect ratio on edit profile page ([Kjwon15](https://github.com/tootsuite/mastodon/pull/10931))
- Fix web push notifications not being sent for polls ([ThibG](https://github.com/tootsuite/mastodon/pull/10864))
- Fix cut off letters in last paragraph of statuses in web UI ([ariasuni](https://github.com/tootsuite/mastodon/pull/10821))
- Fix list not being automatically unpinned when it returns 404 in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11045))
- Fix login sometimes redirecting to paths that are not pages ([Gargron](https://github.com/tootsuite/mastodon/pull/11019))

## [2.8.4] - 2019-05-24
### Fixed

- Fix delivery not retrying on some inbox errors that should be retriable ([ThibG](https://github.com/tootsuite/mastodon/pull/10812))
- Fix unnecessary 5 minute cooldowns on signature verifications in some cases ([ThibG](https://github.com/tootsuite/mastodon/pull/10813))
- Fix possible race condition when processing statuses ([ThibG](https://github.com/tootsuite/mastodon/pull/10815))

### Security

- Require specific OAuth scopes for specific endpoints of the streaming API, instead of merely requiring a token for all endpoints, and allow using WebSockets protocol negotiation to specify the access token instead of using a query string ([ThibG](https://github.com/tootsuite/mastodon/pull/10818))

## [2.8.3] - 2019-05-19
### Added

- Add `og:image:alt` OpenGraph tag ([BenLubar](https://github.com/tootsuite/mastodon/pull/10779))
- Add clickable area below avatar in statuses in web UI ([Dar13](https://github.com/tootsuite/mastodon/pull/10766))
- Add crossed-out eye icon on account gallery in web UI ([Kjwon15](https://github.com/tootsuite/mastodon/pull/10715))
- Add media description tooltip to thumbnails in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10713))

### Changed

- Change "mark as sensitive" button into a checkbox for clarity ([ThibG](https://github.com/tootsuite/mastodon/pull/10748))

### Fixed

- Fix bug allowing users to publicly boost their private statuses ([ThibG](https://github.com/tootsuite/mastodon/pull/10775), [ThibG](https://github.com/tootsuite/mastodon/pull/10783))
- Fix performance in formatter by a little ([ThibG](https://github.com/tootsuite/mastodon/pull/10765))
- Fix some colors in the light theme ([yuzulabo](https://github.com/tootsuite/mastodon/pull/10754))
- Fix some colors of the high contrast theme ([yuzulabo](https://github.com/tootsuite/mastodon/pull/10711))
- Fix ambivalent active state of poll refresh button in web UI ([MaciekBaron](https://github.com/tootsuite/mastodon/pull/10720))
- Fix duplicate posting being possible from web UI ([hinaloe](https://github.com/tootsuite/mastodon/pull/10785))
- Fix "invited by" not showing up in admin UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10791))

## [2.8.2] - 2019-05-05
### Added

- Add `SOURCE_TAG` environment variable ([ushitora-anqou](https://github.com/tootsuite/mastodon/pull/10698))

### Fixed

- Fix cropped hero image on frontpage ([BaptisteGelez](https://github.com/tootsuite/mastodon/pull/10702))
- Fix blurhash gem not compiling on some operating systems ([Gargron](https://github.com/tootsuite/mastodon/pull/10700))
- Fix unexpected CSS animations in some browsers ([ThibG](https://github.com/tootsuite/mastodon/pull/10699))
- Fix closing video modal scrolling timelines to top ([ThibG](https://github.com/tootsuite/mastodon/pull/10695))

## [2.8.1] - 2019-05-04
### Added

- Add link to existing domain block when trying to block an already-blocked domain ([ThibG](https://github.com/tootsuite/mastodon/pull/10663))
- Add button to view context to media modal when opened from account gallery in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10676))
- Add ability to create multiple-choice polls in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10603))
- Add `GITHUB_REPOSITORY` and `SOURCE_BASE_URL` environment variables ([rosylilly](https://github.com/tootsuite/mastodon/pull/10600))
- Add `/interact/` paths to `robots.txt` ([ThibG](https://github.com/tootsuite/mastodon/pull/10666))
- Add `blurhash` to the Attachment entity in the REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/10630))

### Changed

- Change hidden media to be shown as a blurhash-based colorful gradient instead of a black box in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10630))
- Change rejected media to be shown as a blurhash-based gradient instead of a list of filenames in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10630))
- Change e-mail whitelist/blacklist to not be checked when invited ([Gargron](https://github.com/tootsuite/mastodon/pull/10683))
- Change cache header of REST API results to no-cache ([ThibG](https://github.com/tootsuite/mastodon/pull/10655))
- Change the "mark media as sensitive" button to be more obvious in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10673), [Gargron](https://github.com/tootsuite/mastodon/pull/10682))
- Change account gallery in web UI to display 3 columns, open media modal ([Gargron](https://github.com/tootsuite/mastodon/pull/10667), [Gargron](https://github.com/tootsuite/mastodon/pull/10674))

### Fixed

- Fix LDAP/PAM/SAML/CAS users not being pre-approved ([Gargron](https://github.com/tootsuite/mastodon/pull/10621))
- Fix accounts created through tootctl not being always pre-approved ([Gargron](https://github.com/tootsuite/mastodon/pull/10684))
- Fix Sidekiq retrying ActivityPub processing jobs that fail validation ([ThibG](https://github.com/tootsuite/mastodon/pull/10614))
- Fix toots not being scrolled into view sometimes through keyboard selection ([ThibG](https://github.com/tootsuite/mastodon/pull/10593))
- Fix expired invite links being usable to bypass approval mode ([ThibG](https://github.com/tootsuite/mastodon/pull/10657))
- Fix not being able to save e-mail preference for new pending accounts ([Gargron](https://github.com/tootsuite/mastodon/pull/10622))
- Fix upload progressbar when image resizing is involved ([ThibG](https://github.com/tootsuite/mastodon/pull/10632))
- Fix block action not automatically cancelling pending follow request ([ThibG](https://github.com/tootsuite/mastodon/pull/10633))
- Fix stoplight logging to stderr separate from Rails logger ([Gargron](https://github.com/tootsuite/mastodon/pull/10624))
- Fix sign up button not saying sign up when invite is used ([Gargron](https://github.com/tootsuite/mastodon/pull/10623))
- Fix health checks in Docker Compose configuration ([fabianonline](https://github.com/tootsuite/mastodon/pull/10553))
- Fix modal items not being scrollable on touch devices ([kedamaDQ](https://github.com/tootsuite/mastodon/pull/10605))
- Fix Keybase configuration using wrong domain when a web domain is used ([BenLubar](https://github.com/tootsuite/mastodon/pull/10565))
- Fix avatar GIFs not being animated on-hover on public profiles ([hyenagirl64](https://github.com/tootsuite/mastodon/pull/10549))
- Fix OpenGraph parser not understanding some valid property meta tags ([da2x](https://github.com/tootsuite/mastodon/pull/10604))
- Fix wrong fonts being displayed when Roboto is installed on user's machine ([ThibG](https://github.com/tootsuite/mastodon/pull/10594))
- Fix confirmation modals being too narrow for a secondary action button ([ThibG](https://github.com/tootsuite/mastodon/pull/10586))

## [2.8.0] - 2019-04-10
### Added

- Add polls ([Gargron](https://github.com/tootsuite/mastodon/pull/10111), [ThibG](https://github.com/tootsuite/mastodon/pull/10155), [Gargron](https://github.com/tootsuite/mastodon/pull/10184), [ThibG](https://github.com/tootsuite/mastodon/pull/10196), [Gargron](https://github.com/tootsuite/mastodon/pull/10248), [ThibG](https://github.com/tootsuite/mastodon/pull/10255), [ThibG](https://github.com/tootsuite/mastodon/pull/10322), [Gargron](https://github.com/tootsuite/mastodon/pull/10138), [Gargron](https://github.com/tootsuite/mastodon/pull/10139), [Gargron](https://github.com/tootsuite/mastodon/pull/10144), [Gargron](https://github.com/tootsuite/mastodon/pull/10145),[Gargron](https://github.com/tootsuite/mastodon/pull/10146), [Gargron](https://github.com/tootsuite/mastodon/pull/10148), [Gargron](https://github.com/tootsuite/mastodon/pull/10151), [ThibG](https://github.com/tootsuite/mastodon/pull/10150), [Gargron](https://github.com/tootsuite/mastodon/pull/10168), [Gargron](https://github.com/tootsuite/mastodon/pull/10165), [Gargron](https://github.com/tootsuite/mastodon/pull/10172), [Gargron](https://github.com/tootsuite/mastodon/pull/10170), [Gargron](https://github.com/tootsuite/mastodon/pull/10171), [Gargron](https://github.com/tootsuite/mastodon/pull/10186), [Gargron](https://github.com/tootsuite/mastodon/pull/10189), [ThibG](https://github.com/tootsuite/mastodon/pull/10200), [rinsuki](https://github.com/tootsuite/mastodon/pull/10203), [Gargron](https://github.com/tootsuite/mastodon/pull/10213), [Gargron](https://github.com/tootsuite/mastodon/pull/10246), [Gargron](https://github.com/tootsuite/mastodon/pull/10265), [Gargron](https://github.com/tootsuite/mastodon/pull/10261), [ThibG](https://github.com/tootsuite/mastodon/pull/10333), [Gargron](https://github.com/tootsuite/mastodon/pull/10352), [ThibG](https://github.com/tootsuite/mastodon/pull/10140), [ThibG](https://github.com/tootsuite/mastodon/pull/10142), [ThibG](https://github.com/tootsuite/mastodon/pull/10141), [ThibG](https://github.com/tootsuite/mastodon/pull/10162), [ThibG](https://github.com/tootsuite/mastodon/pull/10161), [ThibG](https://github.com/tootsuite/mastodon/pull/10158), [ThibG](https://github.com/tootsuite/mastodon/pull/10156), [ThibG](https://github.com/tootsuite/mastodon/pull/10160), [Gargron](https://github.com/tootsuite/mastodon/pull/10185), [Gargron](https://github.com/tootsuite/mastodon/pull/10188), [ThibG](https://github.com/tootsuite/mastodon/pull/10195), [ThibG](https://github.com/tootsuite/mastodon/pull/10208), [Gargron](https://github.com/tootsuite/mastodon/pull/10187), [ThibG](https://github.com/tootsuite/mastodon/pull/10214), [ThibG](https://github.com/tootsuite/mastodon/pull/10209))
- Add follows & followers managing UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10268), [Gargron](https://github.com/tootsuite/mastodon/pull/10308), [Gargron](https://github.com/tootsuite/mastodon/pull/10404), [Gargron](https://github.com/tootsuite/mastodon/pull/10293))
- Add identity proof integration with Keybase ([Gargron](https://github.com/tootsuite/mastodon/pull/10297), [xgess](https://github.com/tootsuite/mastodon/pull/10375), [Gargron](https://github.com/tootsuite/mastodon/pull/10338), [Gargron](https://github.com/tootsuite/mastodon/pull/10350), [Gargron](https://github.com/tootsuite/mastodon/pull/10414))
- Add option to overwrite imported data instead of merging ([Gargron](https://github.com/tootsuite/mastodon/pull/9962))
- Add featured hashtags to profiles ([Gargron](https://github.com/tootsuite/mastodon/pull/9755), [Gargron](https://github.com/tootsuite/mastodon/pull/10167), [Gargron](https://github.com/tootsuite/mastodon/pull/10249), [ThibG](https://github.com/tootsuite/mastodon/pull/10034))
- Add admission-based registrations mode ([Gargron](https://github.com/tootsuite/mastodon/pull/10250), [ThibG](https://github.com/tootsuite/mastodon/pull/10269), [Gargron](https://github.com/tootsuite/mastodon/pull/10264), [ThibG](https://github.com/tootsuite/mastodon/pull/10321), [Gargron](https://github.com/tootsuite/mastodon/pull/10349), [Gargron](https://github.com/tootsuite/mastodon/pull/10469))
- Add support for WebP uploads ([acid-chicken](https://github.com/tootsuite/mastodon/pull/9879))
- Add "copy link" item to status action bars in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/9983))
- Add list title editing in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/9748))
- Add a "Block & Report" button to the block confirmation dialog in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10360))
- Add disappointed elephant when the page crashes in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10275))
- Add ability to upload multiple files at once in web UI ([tmm576](https://github.com/tootsuite/mastodon/pull/9856))
- Add indication when you are not allowed to follow an account in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10420), [Gargron](https://github.com/tootsuite/mastodon/pull/10491))
- Add validations to admin settings to catch common mistakes ([Gargron](https://github.com/tootsuite/mastodon/pull/10348), [ThibG](https://github.com/tootsuite/mastodon/pull/10354))
- Add `type`, `limit`, `offset`, `min_id`, `max_id`, `account_id` to search API ([Gargron](https://github.com/tootsuite/mastodon/pull/10091))
- Add a preferences API so apps can share basic behaviours ([Gargron](https://github.com/tootsuite/mastodon/pull/10109))
- Add `visibility` param to reblog REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/9851), [ThibG](https://github.com/tootsuite/mastodon/pull/10302))
- Add `allowfullscreen` attribute to OEmbed iframe ([rinsuki](https://github.com/tootsuite/mastodon/pull/10370))
- Add `blocked_by` relationship to the REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/10373))
- Add `tootctl statuses remove` to sweep unreferenced statuses ([Gargron](https://github.com/tootsuite/mastodon/pull/10063))
- Add `tootctl search deploy` to avoid ugly rake task syntax ([Gargron](https://github.com/tootsuite/mastodon/pull/10403))
- Add `tootctl self-destruct` to shut down server gracefully ([Gargron](https://github.com/tootsuite/mastodon/pull/10367))
- Add option to hide application used to toot ([ThibG](https://github.com/tootsuite/mastodon/pull/9897), [rinsuki](https://github.com/tootsuite/mastodon/pull/9994), [hinaloe](https://github.com/tootsuite/mastodon/pull/10086))
- Add `DB_SSLMODE` configuration variable ([sascha-sl](https://github.com/tootsuite/mastodon/pull/10210))
- Add click-to-copy UI to invites page ([Gargron](https://github.com/tootsuite/mastodon/pull/10259))
- Add self-replies fetching ([ThibG](https://github.com/tootsuite/mastodon/pull/10106), [ThibG](https://github.com/tootsuite/mastodon/pull/10128), [ThibG](https://github.com/tootsuite/mastodon/pull/10175), [ThibG](https://github.com/tootsuite/mastodon/pull/10201))
- Add rate limit for media proxy requests ([Gargron](https://github.com/tootsuite/mastodon/pull/10490))
- Add `tootctl emoji purge` ([Gargron](https://github.com/tootsuite/mastodon/pull/10481))
- Add `tootctl accounts approve` ([Gargron](https://github.com/tootsuite/mastodon/pull/10480))
- Add `tootctl accounts reset-relationships` ([noellabo](https://github.com/tootsuite/mastodon/pull/10483))

### Changed

- Change design of landing page ([Gargron](https://github.com/tootsuite/mastodon/pull/10232), [Gargron](https://github.com/tootsuite/mastodon/pull/10260), [ThibG](https://github.com/tootsuite/mastodon/pull/10284), [ThibG](https://github.com/tootsuite/mastodon/pull/10291), [koyuawsmbrtn](https://github.com/tootsuite/mastodon/pull/10356), [Gargron](https://github.com/tootsuite/mastodon/pull/10245))
- Change design of profile column in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10337), [Aditoo17](https://github.com/tootsuite/mastodon/pull/10387), [ThibG](https://github.com/tootsuite/mastodon/pull/10390), [mayaeh](https://github.com/tootsuite/mastodon/pull/10379), [ThibG](https://github.com/tootsuite/mastodon/pull/10411))
- Change language detector threshold from 140 characters to 4 words ([Gargron](https://github.com/tootsuite/mastodon/pull/10376))
- Change language detector to always kick in for non-latin alphabets ([Gargron](https://github.com/tootsuite/mastodon/pull/10276))
- Change icons of features on admin dashboard ([Gargron](https://github.com/tootsuite/mastodon/pull/10366))
- Change DNS timeouts from 1s to 5s ([ThibG](https://github.com/tootsuite/mastodon/pull/10238))
- Change Docker image to use Ubuntu with jemalloc ([Sir-Boops](https://github.com/tootsuite/mastodon/pull/10100), [BenLubar](https://github.com/tootsuite/mastodon/pull/10212))
- Change public pages to be cacheable by proxies ([BenLubar](https://github.com/tootsuite/mastodon/pull/9059))
- Change the 410 gone response for suspended accounts to be cacheable by proxies ([ThibG](https://github.com/tootsuite/mastodon/pull/10339))
- Change web UI to not not empty timeline of blocked users on block ([ThibG](https://github.com/tootsuite/mastodon/pull/10359))
- Change JSON serializer to remove unused `@context` values ([Gargron](https://github.com/tootsuite/mastodon/pull/10378))
- Change GIFV file size limit to be the same as for other videos ([rinsuki](https://github.com/tootsuite/mastodon/pull/9924))
- Change Webpack to not use @babel/preset-env to compile node_modules ([ykzts](https://github.com/tootsuite/mastodon/pull/10289))
- Change web UI to use new Web Share Target API ([gol-cha](https://github.com/tootsuite/mastodon/pull/9963))
- Change ActivityPub reports to have persistent URIs ([ThibG](https://github.com/tootsuite/mastodon/pull/10303))
- Change `tootctl accounts cull --dry-run` to list accounts that would be deleted ([BenLubar](https://github.com/tootsuite/mastodon/pull/10460))
- Change format of CSV exports of follows and mutes to include extra settings ([ThibG](https://github.com/tootsuite/mastodon/pull/10495), [ThibG](https://github.com/tootsuite/mastodon/pull/10335))
- Change ActivityPub collections to be cacheable by proxies ([ThibG](https://github.com/tootsuite/mastodon/pull/10467))
- Change REST API and public profiles to not return follows/followers for users that have blocked you ([Gargron](https://github.com/tootsuite/mastodon/pull/10491))
- Change the groupings of menu items in settings navigation ([Gargron](https://github.com/tootsuite/mastodon/pull/10533))

### Removed

- Remove zopfli compression to speed up Webpack from 6min to 1min ([nolanlawson](https://github.com/tootsuite/mastodon/pull/10288))
- Remove stats.json generation to speed up Webpack ([nolanlawson](https://github.com/tootsuite/mastodon/pull/10290))

### Fixed

- Fix public timelines being broken by new toots when they are not mounted in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10131))
- Fix quick filter settings not being saved when selecting a different filter in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10296))
- Fix remote interaction dialogs being indexed by search engines ([Gargron](https://github.com/tootsuite/mastodon/pull/10240))
- Fix maxed-out invites not showing up as expired in UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10274))
- Fix scrollbar styles on compose textarea ([Gargron](https://github.com/tootsuite/mastodon/pull/10292))
- Fix timeline merge workers being queued for remote users ([Gargron](https://github.com/tootsuite/mastodon/pull/10355))
- Fix alternative relay support regression ([Gargron](https://github.com/tootsuite/mastodon/pull/10398))
- Fix trying to fetch keys of unknown accounts on a self-delete from them ([ThibG](https://github.com/tootsuite/mastodon/pull/10326))
- Fix CAS `:service_validate_url` option ([enewhuis](https://github.com/tootsuite/mastodon/pull/10328))
- Fix race conditions when creating backups ([ThibG](https://github.com/tootsuite/mastodon/pull/10234))
- Fix whitespace not being stripped out of username before validation ([aurelien-reeves](https://github.com/tootsuite/mastodon/pull/10239))
- Fix n+1 query when deleting status ([Gargron](https://github.com/tootsuite/mastodon/pull/10247))
- Fix exiting follows not being rejected when suspending a remote account ([ThibG](https://github.com/tootsuite/mastodon/pull/10230))
- Fix the underlying button element in a disabled icon button not being disabled ([ThibG](https://github.com/tootsuite/mastodon/pull/10194))
- Fix race condition when streaming out deleted statuses ([ThibG](https://github.com/tootsuite/mastodon/pull/10280))
- Fix performance of admin federation UI by caching account counts ([Gargron](https://github.com/tootsuite/mastodon/pull/10374))
- Fix JS error on pages that don't define a CSRF token ([hinaloe](https://github.com/tootsuite/mastodon/pull/10383))
- Fix `tootctl accounts cull` sometimes removing accounts that are temporarily unreachable ([BenLubar](https://github.com/tootsuite/mastodon/pull/10460))

## [2.7.4] - 2019-03-05
### Fixed

- Fix web UI not cleaning up notifications after block ([Gargron](https://github.com/tootsuite/mastodon/pull/10108))
- Fix redundant HTTP requests when resolving private statuses ([ThibG](https://github.com/tootsuite/mastodon/pull/10115))
- Fix performance of account media query ([abcang](https://github.com/tootsuite/mastodon/pull/10121))
- Fix mention processing for unknown accounts ([ThibG](https://github.com/tootsuite/mastodon/pull/10125))
- Fix getting started column not scrolling on short screens ([trwnh](https://github.com/tootsuite/mastodon/pull/10075))
- Fix direct messages pagination in the web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10126))
- Fix serialization of Announce activities ([ThibG](https://github.com/tootsuite/mastodon/pull/10129))
- Fix home timeline perpetually reloading when empty in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10130))
- Fix lists export ([ThibG](https://github.com/tootsuite/mastodon/pull/10136))
- Fix edit profile page crash for suspended-then-unsuspended users ([ThibG](https://github.com/tootsuite/mastodon/pull/10178))

## [2.7.3] - 2019-02-23
### Added

- Add domain filter to the admin federation page ([ThibG](https://github.com/tootsuite/mastodon/pull/10071))
- Add quick link from admin account view to block/unblock instance ([ThibG](https://github.com/tootsuite/mastodon/pull/10073))

### Fixed

- Fix video player width not being updated to fit container width ([ThibG](https://github.com/tootsuite/mastodon/pull/10069))
- Fix domain filter being shown in admin page when local filter is active ([ThibG](https://github.com/tootsuite/mastodon/pull/10074))
- Fix crash when conversations have no valid participants ([ThibG](https://github.com/tootsuite/mastodon/pull/10078))
- Fix error when performing admin actions on no statuses ([ThibG](https://github.com/tootsuite/mastodon/pull/10094))

### Changed

- Change custom emojis to randomize stored file name ([hinaloe](https://github.com/tootsuite/mastodon/pull/10090))

## [2.7.2] - 2019-02-17
### Added

- Add support for IPv6 in e-mail validation ([zoc](https://github.com/tootsuite/mastodon/pull/10009))
- Add record of IP address used for signing up ([ThibG](https://github.com/tootsuite/mastodon/pull/10026))
- Add tight rate-limit for API deletions (30 per 30 minutes) ([Gargron](https://github.com/tootsuite/mastodon/pull/10042))
- Add support for embedded `Announce` objects attributed to the same actor ([ThibG](https://github.com/tootsuite/mastodon/pull/9998), [Gargron](https://github.com/tootsuite/mastodon/pull/10065))
- Add spam filter for `Create` and `Announce` activities ([Gargron](https://github.com/tootsuite/mastodon/pull/10005), [Gargron](https://github.com/tootsuite/mastodon/pull/10041), [Gargron](https://github.com/tootsuite/mastodon/pull/10062))
- Add `registrations` attribute to `GET /api/v1/instance` ([Gargron](https://github.com/tootsuite/mastodon/pull/10060))
- Add `vapid_key` to `POST /api/v1/apps` and `GET /api/v1/apps/verify_credentials` ([Gargron](https://github.com/tootsuite/mastodon/pull/10058))

### Fixed

- Fix link color and add link underlines in high-contrast theme ([Gargron](https://github.com/tootsuite/mastodon/pull/9949), [Gargron](https://github.com/tootsuite/mastodon/pull/10028))
- Fix unicode characters in URLs not being linkified ([JMendyk](https://github.com/tootsuite/mastodon/pull/8447), [hinaloe](https://github.com/tootsuite/mastodon/pull/9991))
- Fix URLs linkifier grabbing ending quotation as part of the link ([Gargron](https://github.com/tootsuite/mastodon/pull/9997))
- Fix authorized applications page design ([rinsuki](https://github.com/tootsuite/mastodon/pull/9969))
- Fix custom emojis not showing up in share page emoji picker ([rinsuki](https://github.com/tootsuite/mastodon/pull/9970))
- Fix too liberal application of whitespace in toots ([trwnh](https://github.com/tootsuite/mastodon/pull/9968))
- Fix misleading e-mail hint being displayed in admin view ([ThibG](https://github.com/tootsuite/mastodon/pull/9973))
- Fix tombstones not being cleared out ([abcang](https://github.com/tootsuite/mastodon/pull/9978))
- Fix some timeline jumps ([ThibG](https://github.com/tootsuite/mastodon/pull/9982), [ThibG](https://github.com/tootsuite/mastodon/pull/10001), [rinsuki](https://github.com/tootsuite/mastodon/pull/10046))
- Fix content warning input taking keyboard focus even when hidden ([hinaloe](https://github.com/tootsuite/mastodon/pull/10017))
- Fix hashtags select styling in default and high-contrast themes ([Gargron](https://github.com/tootsuite/mastodon/pull/10029))
- Fix style regressions on landing page ([Gargron](https://github.com/tootsuite/mastodon/pull/10030))
- Fix hashtag column not subscribing to stream on mount ([Gargron](https://github.com/tootsuite/mastodon/pull/10040))
- Fix relay enabling/disabling not resetting inbox availability status ([Gargron](https://github.com/tootsuite/mastodon/pull/10048))
- Fix mutes, blocks, domain blocks and follow requests not paginating ([Gargron](https://github.com/tootsuite/mastodon/pull/10057))
- Fix crash on public hashtag pages when streaming fails ([ThibG](https://github.com/tootsuite/mastodon/pull/10061))

### Changed

- Change icon for unlisted visibility level ([clarcharr](https://github.com/tootsuite/mastodon/pull/9952))
- Change queue of actor deletes from push to pull for non-follower recipients ([ThibG](https://github.com/tootsuite/mastodon/pull/10016))
- Change robots.txt to exclude media proxy URLs ([nightpool](https://github.com/tootsuite/mastodon/pull/10038))
- Change upload description input to allow line breaks ([BenLubar](https://github.com/tootsuite/mastodon/pull/10036))
- Change `dist/mastodon-streaming.service` to recommend running node without intermediary npm command ([nolanlawson](https://github.com/tootsuite/mastodon/pull/10032))
- Change conversations to always show names of other participants ([Gargron](https://github.com/tootsuite/mastodon/pull/10047))
- Change buttons on timeline preview to open the interaction dialog ([Gargron](https://github.com/tootsuite/mastodon/pull/10054))
- Change error graphic to hover-to-play ([Gargron](https://github.com/tootsuite/mastodon/pull/10055))

## [2.7.1] - 2019-01-28
### Fixed

- Fix SSO authentication not working due to missing agreement boolean ([Gargron](https://github.com/tootsuite/mastodon/pull/9915))
- Fix slow fallback of CopyAccountStats migration setting stats to 0 ([Gargron](https://github.com/tootsuite/mastodon/pull/9930))
- Fix wrong command in migration error message ([angristan](https://github.com/tootsuite/mastodon/pull/9877))
- Fix initial value of volume slider in video player and handle volume changes ([ThibG](https://github.com/tootsuite/mastodon/pull/9929))
- Fix missing hotkeys for notifications ([ThibG](https://github.com/tootsuite/mastodon/pull/9927))
- Fix being able to attach unattached media created by other users ([ThibG](https://github.com/tootsuite/mastodon/pull/9921))
- Fix unrescued SSL error during link verification ([renatolond](https://github.com/tootsuite/mastodon/pull/9914))
- Fix Firefox scrollbar color regression ([trwnh](https://github.com/tootsuite/mastodon/pull/9908))
- Fix scheduled status with media immediately creating a status ([ThibG](https://github.com/tootsuite/mastodon/pull/9894))
- Fix missing strong style for landing page description ([Kjwon15](https://github.com/tootsuite/mastodon/pull/9892))

## [2.7.0] - 2019-01-20
### Added

- Add link for adding a user to a list from their profile ([namelessGonbai](https://github.com/tootsuite/mastodon/pull/9062))
- Add joining several hashtags in a single column ([gdpelican](https://github.com/tootsuite/mastodon/pull/8904))
- Add volume sliders for videos ([sumdog](https://github.com/tootsuite/mastodon/pull/9366))
- Add a tooltip explaining what a locked account is ([pawelngei](https://github.com/tootsuite/mastodon/pull/9403))
- Add preloaded cache for common JSON-LD contexts ([ThibG](https://github.com/tootsuite/mastodon/pull/9412))
- Add profile directory ([Gargron](https://github.com/tootsuite/mastodon/pull/9427))
- Add setting to not group reblogs in home feed ([ThibG](https://github.com/tootsuite/mastodon/pull/9248))
- Add admin ability to remove a user's header image ([ThibG](https://github.com/tootsuite/mastodon/pull/9495))
- Add account hashtags to ActivityPub actor JSON ([Gargron](https://github.com/tootsuite/mastodon/pull/9450))
- Add error message for avatar image that's too large ([sumdog](https://github.com/tootsuite/mastodon/pull/9518))
- Add notification quick-filter bar ([pawelngei](https://github.com/tootsuite/mastodon/pull/9399))
- Add new first-time tutorial ([Gargron](https://github.com/tootsuite/mastodon/pull/9531))
- Add moderation warnings ([Gargron](https://github.com/tootsuite/mastodon/pull/9519))
- Add emoji codepoint mappings for v11.0 ([Gargron](https://github.com/tootsuite/mastodon/pull/9618))
- Add REST API for creating an account ([Gargron](https://github.com/tootsuite/mastodon/pull/9572))
- Add support for Malayalam in language filter ([tachyons](https://github.com/tootsuite/mastodon/pull/9624))
- Add exclude_reblogs option to account statuses API ([Gargron](https://github.com/tootsuite/mastodon/pull/9640))
- Add local followers page to admin account UI ([chr-1x](https://github.com/tootsuite/mastodon/pull/9610))
- Add healthcheck commands to docker-compose.yml ([BenLubar](https://github.com/tootsuite/mastodon/pull/9143))
- Add handler for Move activity to migrate followers ([Gargron](https://github.com/tootsuite/mastodon/pull/9629))
- Add CSV export for lists and domain blocks ([Gargron](https://github.com/tootsuite/mastodon/pull/9677))
- Add `tootctl accounts follow ACCT` ([Gargron](https://github.com/tootsuite/mastodon/pull/9414))
- Add scheduled statuses ([Gargron](https://github.com/tootsuite/mastodon/pull/9706))
- Add immutable caching for S3 objects ([nolanlawson](https://github.com/tootsuite/mastodon/pull/9722))
- Add cache to custom emojis API ([Gargron](https://github.com/tootsuite/mastodon/pull/9732))
- Add preview cards to non-detailed statuses on public pages ([Gargron](https://github.com/tootsuite/mastodon/pull/9714))
- Add `mod` and `moderator` to list of default reserved usernames ([Gargron](https://github.com/tootsuite/mastodon/pull/9713))
- Add quick links to the admin interface in the web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/8545))
- Add `tootctl domains crawl` ([Gargron](https://github.com/tootsuite/mastodon/pull/9809))
- Add attachment list fallback to public pages ([ThibG](https://github.com/tootsuite/mastodon/pull/9780))
- Add `tootctl --version` ([Gargron](https://github.com/tootsuite/mastodon/pull/9835))
- Add information about how to opt-in to the directory on the directory ([Gargron](https://github.com/tootsuite/mastodon/pull/9834))
- Add timeouts for S3 ([Gargron](https://github.com/tootsuite/mastodon/pull/9842))
- Add support for non-public reblogs from ActivityPub ([Gargron](https://github.com/tootsuite/mastodon/pull/9841))
- Add sending of `Reject` activity when sending a `Block` activity ([ThibG](https://github.com/tootsuite/mastodon/pull/9811))

### Changed

- Temporarily pause timeline if mouse moved recently ([lmorchard](https://github.com/tootsuite/mastodon/pull/9200))
- Change the password form order ([mayaeh](https://github.com/tootsuite/mastodon/pull/9267))
- Redesign admin UI for accounts ([Gargron](https://github.com/tootsuite/mastodon/pull/9340), [Gargron](https://github.com/tootsuite/mastodon/pull/9643))
- Redesign admin UI for instances/domain blocks ([Gargron](https://github.com/tootsuite/mastodon/pull/9645))
- Swap avatar and header input fields in profile page ([ThibG](https://github.com/tootsuite/mastodon/pull/9271))
- When posting in mobile mode, go back to previous history location ([ThibG](https://github.com/tootsuite/mastodon/pull/9502))
- Split out is_changing_upload from is_submitting ([ThibG](https://github.com/tootsuite/mastodon/pull/9536))
- Back to the getting-started when pins the timeline. ([kedamaDQ](https://github.com/tootsuite/mastodon/pull/9561))
- Allow unauthenticated REST API access to GET /api/v1/accounts/:id/statuses ([Gargron](https://github.com/tootsuite/mastodon/pull/9573))
- Limit maximum visibility of local silenced users to unlisted ([ThibG](https://github.com/tootsuite/mastodon/pull/9583))
- Change API error message for unconfirmed accounts ([noellabo](https://github.com/tootsuite/mastodon/pull/9625))
- Change the icon to "reply-all" when it's a reply to other accounts ([mayaeh](https://github.com/tootsuite/mastodon/pull/9378))
- Do not ignore federated reports targetting already-reported accounts ([ThibG](https://github.com/tootsuite/mastodon/pull/9534))
- Upgrade default Ruby version to 2.6.0 ([Gargron](https://github.com/tootsuite/mastodon/pull/9688))
- Change e-mail digest frequency ([Gargron](https://github.com/tootsuite/mastodon/pull/9689))
- Change Docker images for Tor support in docker-compose.yml ([Sir-Boops](https://github.com/tootsuite/mastodon/pull/9438))
- Display fallback link card thumbnail when none is given ([Gargron](https://github.com/tootsuite/mastodon/pull/9715))
- Change account bio length validation to ignore mention domains and URLs ([Gargron](https://github.com/tootsuite/mastodon/pull/9717))
- Use configured contact user for "anonymous" federation activities ([yukimochi](https://github.com/tootsuite/mastodon/pull/9661))
- Change remote interaction dialog to use specific actions instead of generic "interact" ([Gargron](https://github.com/tootsuite/mastodon/pull/9743))
- Always re-fetch public key when signature verification fails to support blind key rotation ([ThibG](https://github.com/tootsuite/mastodon/pull/9667))
- Make replies to boosts impossible, connect reply to original status instead ([valerauko](https://github.com/tootsuite/mastodon/pull/9129))
- Change e-mail MX validation to check both A and MX records against blacklist ([Gargron](https://github.com/tootsuite/mastodon/pull/9489))
- Hide floating action button on search and getting started pages ([tmm576](https://github.com/tootsuite/mastodon/pull/9826))
- Redesign public hashtag page to use a masonry layout ([Gargron](https://github.com/tootsuite/mastodon/pull/9822))
- Use `summary` as summary instead of content warning for converted ActivityPub objects ([Gargron](https://github.com/tootsuite/mastodon/pull/9823))
- Display a double reply arrow on public pages for toots that are replies ([ThibG](https://github.com/tootsuite/mastodon/pull/9808))
- Change admin UI right panel size to be wider ([Kjwon15](https://github.com/tootsuite/mastodon/pull/9768))

### Removed

- Remove links to bridge.joinmastodon.org (non-functional) ([Gargron](https://github.com/tootsuite/mastodon/pull/9608))
- Remove LD-Signatures from activities that do not need them ([ThibG](https://github.com/tootsuite/mastodon/pull/9659))

### Fixed

- Remove unused computation of reblog references from updateTimeline ([ThibG](https://github.com/tootsuite/mastodon/pull/9244))
- Fix loaded embeds resetting if a status arrives from API again ([ThibG](https://github.com/tootsuite/mastodon/pull/9270))
- Fix race condition causing shallow status with only a "favourited" attribute ([ThibG](https://github.com/tootsuite/mastodon/pull/9272))
- Remove intermediary arrays when creating hash maps from results ([Gargron](https://github.com/tootsuite/mastodon/pull/9291))
- Extract counters from accounts table to account_stats table to improve performance ([Gargron](https://github.com/tootsuite/mastodon/pull/9295))
- Change identities id column to a bigint ([Gargron](https://github.com/tootsuite/mastodon/pull/9371))
- Fix conversations API pagination ([ThibG](https://github.com/tootsuite/mastodon/pull/9407))
- Improve account suspension speed and completeness ([Gargron](https://github.com/tootsuite/mastodon/pull/9290))
- Fix thread depth computation in statuses_controller ([ThibG](https://github.com/tootsuite/mastodon/pull/9426))
- Fix database deadlocks by moving account stats update outside transaction ([ThibG](https://github.com/tootsuite/mastodon/pull/9437))
- Escape HTML in profile name preview in profile settings ([pawelngei](https://github.com/tootsuite/mastodon/pull/9446))
- Use same CORS policy for /@:username and /users/:username ([ThibG](https://github.com/tootsuite/mastodon/pull/9485))
- Make custom emoji domains case insensitive ([Esteth](https://github.com/tootsuite/mastodon/pull/9474))
- Various fixes to scrollable lists and media gallery ([ThibG](https://github.com/tootsuite/mastodon/pull/9501))
- Fix bootsnap cache directory being declared relatively ([Gargron](https://github.com/tootsuite/mastodon/pull/9511))
- Fix timeline pagination in the web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/9516))
- Fix padding on dropdown elements in preferences ([ThibG](https://github.com/tootsuite/mastodon/pull/9517))
- Make avatar and headers respect GIF autoplay settings ([ThibG](https://github.com/tootsuite/mastodon/pull/9515))
- Do no retry Web Push workers if the server returns a 4xx response ([Gargron](https://github.com/tootsuite/mastodon/pull/9434))
- Minor scrollable list fixes ([ThibG](https://github.com/tootsuite/mastodon/pull/9551))
- Ignore low-confidence CharlockHolmes guesses when parsing link cards ([ThibG](https://github.com/tootsuite/mastodon/pull/9510))
- Fix `tootctl accounts rotate` not updating public keys ([Gargron](https://github.com/tootsuite/mastodon/pull/9556))
- Fix CSP / X-Frame-Options for media players ([jomo](https://github.com/tootsuite/mastodon/pull/9558))
- Fix unnecessary loadMore calls when the end of a timeline has been reached ([ThibG](https://github.com/tootsuite/mastodon/pull/9581))
- Skip mailer job retries when a record no longer exists ([Gargron](https://github.com/tootsuite/mastodon/pull/9590))
- Fix composer not getting focus after reply confirmation dialog ([ThibG](https://github.com/tootsuite/mastodon/pull/9602))
- Fix signature verification stoplight triggering on non-timeout errors ([Gargron](https://github.com/tootsuite/mastodon/pull/9617))
- Fix ThreadResolveWorker getting queued with invalid URLs ([Gargron](https://github.com/tootsuite/mastodon/pull/9628))
- Fix crash when clearing uninitialized timeline ([ThibG](https://github.com/tootsuite/mastodon/pull/9662))
- Avoid duplicate work by merging ReplyDistributionWorker into DistributionWorker ([ThibG](https://github.com/tootsuite/mastodon/pull/9660))
- Skip full text search if it fails, instead of erroring out completely ([Kjwon15](https://github.com/tootsuite/mastodon/pull/9654))
- Fix profile metadata links not verifying correctly sometimes ([shrft](https://github.com/tootsuite/mastodon/pull/9673))
- Ensure blocked user unfollows blocker if Block/Undo-Block activities are processed out of order ([ThibG](https://github.com/tootsuite/mastodon/pull/9687))
- Fix unreadable text color in report modal for some statuses ([Gargron](https://github.com/tootsuite/mastodon/pull/9716))
- Stop GIFV timeline preview explicitly when it's opened in modal ([kedamaDQ](https://github.com/tootsuite/mastodon/pull/9749))
- Fix scrollbar width compensation ([ThibG](https://github.com/tootsuite/mastodon/pull/9824))
- Fix race conditions when processing deleted toots ([ThibG](https://github.com/tootsuite/mastodon/pull/9815))
- Fix SSO issues on WebKit browsers by disabling Same-Site cookie again ([moritzheiber](https://github.com/tootsuite/mastodon/pull/9819))
- Fix empty OEmbed error ([renatolond](https://github.com/tootsuite/mastodon/pull/9807))
- Fix drag & drop modal not disappearing sometimes ([hinaloe](https://github.com/tootsuite/mastodon/pull/9797))
- Fix statuses with content warnings being displayed in web push notifications sometimes ([ThibG](https://github.com/tootsuite/mastodon/pull/9778))
- Fix scroll-to-detailed status not working on public pages ([ThibG](https://github.com/tootsuite/mastodon/pull/9773))
- Fix media modal loading indicator ([ThibG](https://github.com/tootsuite/mastodon/pull/9771))
- Fix hashtag search results not having a permalink fallback in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/9810))
- Fix slightly cropped font on settings page dropdowns when using system font ([ariasuni](https://github.com/tootsuite/mastodon/pull/9839))
- Fix not being able to drag & drop text into forms ([tmm576](https://github.com/tootsuite/mastodon/pull/9840))

### Security

- Sanitize and sandbox toot embeds in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/9552))
- Add tombstones for remote statuses to prevent replay attacks ([ThibG](https://github.com/tootsuite/mastodon/pull/9830))

## [2.6.5] - 2018-12-01
### Changed

- Change lists to display replies to others on the list and list owner ([ThibG](https://github.com/tootsuite/mastodon/pull/9324))

### Fixed

- Fix failures caused by commonly-used JSON-LD contexts being unavailable ([ThibG](https://github.com/tootsuite/mastodon/pull/9412))

## [2.6.4] - 2018-11-30
### Fixed

- Fix yarn dependencies not installing due to yanked event-stream package ([Gargron](https://github.com/tootsuite/mastodon/pull/9401))

## [2.6.3] - 2018-11-30
### Added

- Add hyphen to characters allowed in remote usernames ([ThibG](https://github.com/tootsuite/mastodon/pull/9345))

### Changed

- Change server user count to exclude suspended accounts ([Gargron](https://github.com/tootsuite/mastodon/pull/9380))

### Fixed

- Fix ffmpeg processing sometimes stalling due to overfilled stdout buffer ([hugogameiro](https://github.com/tootsuite/mastodon/pull/9368))
- Fix missing DNS records raising the wrong kind of exception ([Gargron](https://github.com/tootsuite/mastodon/pull/9379))
- Fix already queued deliveries still trying to reach inboxes marked as unavailable ([Gargron](https://github.com/tootsuite/mastodon/pull/9358))

### Security

- Fix TLS handshake timeout not being enforced ([Gargron](https://github.com/tootsuite/mastodon/pull/9381))

## [2.6.2] - 2018-11-23
### Added

- Add Page to whitelisted ActivityPub types ([mbajur](https://github.com/tootsuite/mastodon/pull/9188))
- Add 20px to column width in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/9227))
- Add amount of freed disk space in `tootctl media remove` ([Gargron](https://github.com/tootsuite/mastodon/pull/9229), [Gargron](https://github.com/tootsuite/mastodon/pull/9239), [mayaeh](https://github.com/tootsuite/mastodon/pull/9288))
- Add "Show thread" link to self-replies ([Gargron](https://github.com/tootsuite/mastodon/pull/9228))

### Changed

- Change order of Atom and RSS links so Atom is first ([Alkarex](https://github.com/tootsuite/mastodon/pull/9302))
- Change Nginx configuration for Nanobox apps ([danhunsaker](https://github.com/tootsuite/mastodon/pull/9310))
- Change the follow action to appear instant in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/9220))
- Change how the ActiveRecord connection is instantiated in on_worker_boot ([Gargron](https://github.com/tootsuite/mastodon/pull/9238))
- Change `tootctl accounts cull` to always touch accounts so they can be skipped ([renatolond](https://github.com/tootsuite/mastodon/pull/9293))
- Change mime type comparison to ignore JSON-LD profile ([valerauko](https://github.com/tootsuite/mastodon/pull/9179))

### Fixed

- Fix web UI crash when conversation has no last status ([sammy8806](https://github.com/tootsuite/mastodon/pull/9207))
- Fix follow limit validator reporting lower number past threshold ([Gargron](https://github.com/tootsuite/mastodon/pull/9230))
- Fix form validation flash message color and input borders ([Gargron](https://github.com/tootsuite/mastodon/pull/9235))
- Fix invalid twitter:player cards being displayed ([ThibG](https://github.com/tootsuite/mastodon/pull/9254))
- Fix emoji update date being processed incorrectly ([ThibG](https://github.com/tootsuite/mastodon/pull/9255))
- Fix playing embed resetting if status is reloaded in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/9270), [Gargron](https://github.com/tootsuite/mastodon/pull/9275))
- Fix web UI crash when favouriting a deleted status ([ThibG](https://github.com/tootsuite/mastodon/pull/9272))
- Fix intermediary arrays being created for hash maps ([Gargron](https://github.com/tootsuite/mastodon/pull/9291))
- Fix filter ID not being a string in REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/9303))

### Security

- Fix multiple remote account deletions being able to deadlock the database ([Gargron](https://github.com/tootsuite/mastodon/pull/9292))
- Fix HTTP connection timeout of 10s not being enforced ([Gargron](https://github.com/tootsuite/mastodon/pull/9329))

## [2.6.1] - 2018-10-30
### Fixed

- Fix resolving resources by URL not working due to a regression in [valerauko](https://github.com/tootsuite/mastodon/pull/9132) ([Gargron](https://github.com/tootsuite/mastodon/pull/9171))
- Fix reducer error in web UI when a conversation has no last status ([Gargron](https://github.com/tootsuite/mastodon/pull/9173))

## [2.6.0] - 2018-10-30
### Added

- Add link ownership verification ([Gargron](https://github.com/tootsuite/mastodon/pull/8703))
- Add conversations API ([Gargron](https://github.com/tootsuite/mastodon/pull/8832))
- Add limit for the number of people that can be followed from one account ([Gargron](https://github.com/tootsuite/mastodon/pull/8807))
- Add admin setting to customize mascot ([ashleyhull-versent](https://github.com/tootsuite/mastodon/pull/8766))
- Add support for more granular ActivityPub audiences from other software, i.e. circles ([Gargron](https://github.com/tootsuite/mastodon/pull/8950), [Gargron](https://github.com/tootsuite/mastodon/pull/9093), [Gargron](https://github.com/tootsuite/mastodon/pull/9150))
- Add option to block all reports from a domain ([Gargron](https://github.com/tootsuite/mastodon/pull/8830))
- Add user preference to always expand toots marked with content warnings ([webroo](https://github.com/tootsuite/mastodon/pull/8762))
- Add user preference to always hide all media ([fvh-P](https://github.com/tootsuite/mastodon/pull/8569))
- Add `force_login` param to OAuth authorize page ([Gargron](https://github.com/tootsuite/mastodon/pull/8655))
- Add `tootctl accounts backup` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl accounts create` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl accounts cull` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl accounts delete` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl accounts modify` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl accounts refresh` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl feeds build` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl feeds clear` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl settings registrations open` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `tootctl settings registrations close` ([Gargron](https://github.com/tootsuite/mastodon/pull/8642), [Gargron](https://github.com/tootsuite/mastodon/pull/8811))
- Add `min_id` param to REST API to support backwards pagination ([Gargron](https://github.com/tootsuite/mastodon/pull/8736))
- Add a confirmation dialog when hitting reply and the compose box isn't empty ([ThibG](https://github.com/tootsuite/mastodon/pull/8893))
- Add PostgreSQL disk space growth tracking in PGHero ([Gargron](https://github.com/tootsuite/mastodon/pull/8906))
- Add button for disabling local account to report quick actions bar ([Gargron](https://github.com/tootsuite/mastodon/pull/9024))
- Add Czech language ([Aditoo17](https://github.com/tootsuite/mastodon/pull/8594))
- Add `same-site` (`lax`) attribute to cookies ([sorin-davidoi](https://github.com/tootsuite/mastodon/pull/8626))
- Add support for styled scrollbars in Firefox Nightly ([sorin-davidoi](https://github.com/tootsuite/mastodon/pull/8653))
- Add highlight to the active tab in web UI profiles ([rhoio](https://github.com/tootsuite/mastodon/pull/8673))
- Add auto-focus for comment textarea in report modal ([ThibG](https://github.com/tootsuite/mastodon/pull/8689))
- Add auto-focus for emoji picker's search field ([ThibG](https://github.com/tootsuite/mastodon/pull/8688))
- Add nginx and systemd templates to `dist/` directory ([Gargron](https://github.com/tootsuite/mastodon/pull/8770))
- Add support for `/.well-known/change-password` ([Gargron](https://github.com/tootsuite/mastodon/pull/8828))
- Add option to override FFMPEG binary path ([sascha-sl](https://github.com/tootsuite/mastodon/pull/8855))
- Add `dns-prefetch` tag when using different host for assets or uploads ([Gargron](https://github.com/tootsuite/mastodon/pull/8942))
- Add `description` meta tag ([Gargron](https://github.com/tootsuite/mastodon/pull/8941))
- Add `Content-Security-Policy` header ([ThibG](https://github.com/tootsuite/mastodon/pull/8957))
- Add cache for the instance info API ([ykzts](https://github.com/tootsuite/mastodon/pull/8765))
- Add suggested follows to search screen in mobile layout ([Gargron](https://github.com/tootsuite/mastodon/pull/9010))
- Add CORS header to `/.well-known/*` routes ([BenLubar](https://github.com/tootsuite/mastodon/pull/9083))
- Add `card` attribute to statuses returned from REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/9120))
- Add in-stream link preview ([Gargron](https://github.com/tootsuite/mastodon/pull/9120))
- Add support for ActivityPub `Page` objects ([mbajur](https://github.com/tootsuite/mastodon/pull/9121))

### Changed

- Change forms design ([Gargron](https://github.com/tootsuite/mastodon/pull/8703))
- Change reports overview to group by target account ([Gargron](https://github.com/tootsuite/mastodon/pull/8674))
- Change web UI to show "read more" link on overly long in-stream statuses ([lanodan](https://github.com/tootsuite/mastodon/pull/8205))
- Change design of direct messages column ([Gargron](https://github.com/tootsuite/mastodon/pull/8832), [Gargron](https://github.com/tootsuite/mastodon/pull/9022))
- Change home timelines to exclude DMs ([Gargron](https://github.com/tootsuite/mastodon/pull/8940))
- Change list timelines to exclude all replies ([cbayerlein](https://github.com/tootsuite/mastodon/pull/8683))
- Change admin accounts UI default sort to most recent ([Gargron](https://github.com/tootsuite/mastodon/pull/8813))
- Change documentation URL in the UI ([Gargron](https://github.com/tootsuite/mastodon/pull/8898))
- Change style of success and failure messages ([Gargron](https://github.com/tootsuite/mastodon/pull/8973))
- Change DM filtering to always allow DMs from staff ([qguv](https://github.com/tootsuite/mastodon/pull/8993))
- Change recommended Ruby version to 2.5.3 ([zunda](https://github.com/tootsuite/mastodon/pull/9003))
- Change docker-compose default to persist volumes in current directory ([Gargron](https://github.com/tootsuite/mastodon/pull/9055))
- Change character counters on edit profile page to input length limit ([Gargron](https://github.com/tootsuite/mastodon/pull/9100))
- Change notification filtering to always let through messages from staff ([Gargron](https://github.com/tootsuite/mastodon/pull/9152))
- Change "hide boosts from user" function also hiding notifications about boosts ([ThibG](https://github.com/tootsuite/mastodon/pull/9147))
- Change CSS `detailed-status__wrapper` class actually wrap the detailed status ([trwnh](https://github.com/tootsuite/mastodon/pull/8547))

### Deprecated

- `GET /api/v1/timelines/direct` → `GET /api/v1/conversations` ([Gargron](https://github.com/tootsuite/mastodon/pull/8832))
- `POST /api/v1/notifications/dismiss` → `POST /api/v1/notifications/:id/dismiss` ([Gargron](https://github.com/tootsuite/mastodon/pull/8905))
- `GET /api/v1/statuses/:id/card` → `card` attributed included in status ([Gargron](https://github.com/tootsuite/mastodon/pull/9120))

### Removed

- Remove "on this device" label in column push settings ([rhoio](https://github.com/tootsuite/mastodon/pull/8704))
- Remove rake tasks in favour of tootctl commands ([Gargron](https://github.com/tootsuite/mastodon/pull/8675))

### Fixed

- Fix remote statuses using instance's default locale if no language given ([Kjwon15](https://github.com/tootsuite/mastodon/pull/8861))
- Fix streaming API not exiting when port or socket is unavailable ([Gargron](https://github.com/tootsuite/mastodon/pull/9023))
- Fix network calls being performed in database transaction in ActivityPub handler ([Gargron](https://github.com/tootsuite/mastodon/pull/8951))
- Fix dropdown arrow position ([ThibG](https://github.com/tootsuite/mastodon/pull/8637))
- Fix first element of dropdowns being focused even if not using keyboard ([ThibG](https://github.com/tootsuite/mastodon/pull/8679))
- Fix tootctl requiring `bundle exec` invocation ([abcang](https://github.com/tootsuite/mastodon/pull/8619))
- Fix public pages not using animation preference for avatars ([renatolond](https://github.com/tootsuite/mastodon/pull/8614))
- Fix OEmbed/OpenGraph cards not understanding relative URLs ([ThibG](https://github.com/tootsuite/mastodon/pull/8669))
- Fix some dark emojis not having a white outline ([ThibG](https://github.com/tootsuite/mastodon/pull/8597))
- Fix media description not being displayed in various media modals ([ThibG](https://github.com/tootsuite/mastodon/pull/8678))
- Fix generated URLs of desktop notifications missing base URL ([GenbuHase](https://github.com/tootsuite/mastodon/pull/8758))
- Fix RTL styles ([mabkenar](https://github.com/tootsuite/mastodon/pull/8764), [mabkenar](https://github.com/tootsuite/mastodon/pull/8767), [mabkenar](https://github.com/tootsuite/mastodon/pull/8823), [mabkenar](https://github.com/tootsuite/mastodon/pull/8897), [mabkenar](https://github.com/tootsuite/mastodon/pull/9005), [mabkenar](https://github.com/tootsuite/mastodon/pull/9007), [mabkenar](https://github.com/tootsuite/mastodon/pull/9018), [mabkenar](https://github.com/tootsuite/mastodon/pull/9021), [mabkenar](https://github.com/tootsuite/mastodon/pull/9145), [mabkenar](https://github.com/tootsuite/mastodon/pull/9146))
- Fix crash in streaming API when tag param missing ([Gargron](https://github.com/tootsuite/mastodon/pull/8955))
- Fix hotkeys not working when no element is focused ([ThibG](https://github.com/tootsuite/mastodon/pull/8998))
- Fix some hotkeys not working on detailed status view ([ThibG](https://github.com/tootsuite/mastodon/pull/9006))
- Fix og:url on status pages ([ThibG](https://github.com/tootsuite/mastodon/pull/9047))
- Fix upload option buttons only being visible on hover ([Gargron](https://github.com/tootsuite/mastodon/pull/9074))
- Fix tootctl not returning exit code 1 on wrong arguments ([sascha-sl](https://github.com/tootsuite/mastodon/pull/9094))
- Fix preview cards for appearing for profiles mentioned in toot ([ThibG](https://github.com/tootsuite/mastodon/pull/6934), [ThibG](https://github.com/tootsuite/mastodon/pull/9158))
- Fix local accounts sometimes being duplicated as faux-remote ([Gargron](https://github.com/tootsuite/mastodon/pull/9109))
- Fix emoji search when the shortcode has multiple separators ([ThibG](https://github.com/tootsuite/mastodon/pull/9124))
- Fix dropdowns sometimes being partially obscured by other elements ([kedamaDQ](https://github.com/tootsuite/mastodon/pull/9126))
- Fix cache not updating when reply/boost/favourite counters or media sensitivity update ([Gargron](https://github.com/tootsuite/mastodon/pull/9119))
- Fix empty display name precedence over username in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/9163))
- Fix td instead of th in sessions table header ([Gargron](https://github.com/tootsuite/mastodon/pull/9162))
- Fix handling of content types with profile ([valerauko](https://github.com/tootsuite/mastodon/pull/9132))

## [2.5.2] - 2018-10-12
### Security

- Fix XSS vulnerability ([Gargron](https://github.com/tootsuite/mastodon/pull/8959))

## [2.5.1] - 2018-10-07
### Fixed

- Fix database migrations for PostgreSQL below 9.5 ([Gargron](https://github.com/tootsuite/mastodon/pull/8903))
- Fix class autoloading issue in ActivityPub Create handler ([Gargron](https://github.com/tootsuite/mastodon/pull/8820))
- Fix cache statistics not being sent via statsd when statsd enabled ([ykzts](https://github.com/tootsuite/mastodon/pull/8831))
- Bump puma from 3.11.4 to 3.12.0 ([dependabot[bot]](https://github.com/tootsuite/mastodon/pull/8883))

### Security

- Fix some local images not having their EXIF metadata stripped on upload ([ThibG](https://github.com/tootsuite/mastodon/pull/8714))
- Fix being able to enable a disabled relay via ActivityPub Accept handler ([ThibG](https://github.com/tootsuite/mastodon/pull/8864))
- Bump nokogiri from 1.8.4 to 1.8.5 ([dependabot[bot]](https://github.com/tootsuite/mastodon/pull/8881))
- Fix being able to report statuses not belonging to the reported account ([ThibG](https://github.com/tootsuite/mastodon/pull/8916))
