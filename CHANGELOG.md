# Changelog

All notable changes to this project will be documented in this file.

## [4.6.2] - 2026-06-25

### Security

- Update FFMpeg version used in the container image to fix [CVE-2026-8461](https://github.com/advisories/GHSA-qff7-4q6c-m8h6) (critical severity)

## [4.6.1] - 2026-06-24

### Security

- Update dependencies

### Added

- Add `avatar_description` and `header_description` to `/api/v1/accounts/update_credentials` (#39547 and #39574 by @ClearlyClaire and @mkljczk)
  - This is available starting from Mastodon API version `11` and intended to provide an easier implementation path for clients implementing a similar feature in forks.
  - The new `/api/v1/profile` API remains the recommended API for setting avatar and header description as well as other profile values.

### Fixed

- Fix combobox menu not closing after a selection (#39595 by @diondiondion)
- Fix Emoji IndexedDB upgrades when multiple tabs are open (#39576 by @ChaosExAnima)
- Fix combobox listbox not scrolling up when new suggestions have loaded (#39588 by @diondiondion)
- Fix media modal navigation in RTL languages (#39587 by @diondiondion)
- Fix accounts not visible in collection editor in advanced web interface (#39586 by @diondiondion)
- Fix error on login with certain LDAP configurations (#39571 by @oneiros)
- Fix simplified layout applying to other pages in web UI (#39570 by @Gargron)
- Fix emoji database loading in web worker (#39558 and #39562 by @ChaosExAnima)
- Fix display name length limit being incorrectly enforced in web UI (#39499 by @shleeable)
- Fix advanced UI columns not using mobile styles (#39528 by @diondiondion)
- Fix "private mention" post heading overlapping thread line (#39521 and #39554 by @diondiondion)
- Fix misattribution of remote featured collections in some cases (#39523, #39525, and #39550 by @oneiros)
- Fix custom profile field overflow (#39513 by @diondiondion)
- Fix fetching unknown key when it's not the actor's first, and add error handling for unavailable keys (#39512 by @ClearlyClaire)

## [4.6.0] - 2026-06-17

### Added

- **Add collections** (#37992, #37005, #37049, #37020, #37053, #37110, #37117, #37122, #37154, #37157, #37176, #37192, #37222, #37225, #37254, #37277, #37298, #37322, #37434, #37468, #37514, #37512, #37549, #37556, #37560, #37580, #37591, #37552, #37618, #37643, #37658, #37731, #37678, #37741, #37762, #37790, #37805, #37823, #37837, #37842, #37850, #37848, #37812, #37950, #37898, #37916, #37920, #37927, #37928, #37961, #37967, #37974, #37989, #37986, #38004, #38026, #38027, #38030, #38038, #38065, #38081, #38082, #38096, #38106, #38113, #38124, #38133, #38144, #38153, #38166, #38167, #38169, #38170, #38177, #38193, #38213, #38251, #38255, #38256, #38282, #38298, #38292, #38307, #38306, #38316, #38115, #38329, #38334, #38337, #38351, #38368, #38370, #38356, #38383, #38386, #38385, #38394, #38393, #38399, #38402, #38409, #38414, #38413, #38424, #38425, #38450, #38508, #38528, #38534, #38536, #38540, #38543, #38491, #38586, #38611, #38588, #38612, #38628, #38626, #38630, #38633, #38629, #38638, #38645, #38644, #38636, #38660, #38657, #38688, #38690, #38672, #38698, #38697, #38708, #38712, #38713, #38709, #38719, #38728, #38730, #38732, #38739, #38749, #38751, #38750, #38767, #38769, #38783, #38785, #38959, #38786, #38794, #38776, #38817, #38792, #38822, #38827, #38831, #38830, #38844, #38843, #38852, #38850, #38847, #38865, #38897, #38900, #38919, #38933, #38934, #38935, #38942, #38941, #38954, #38961, #38957, #38962, #38991, #39009, #39062, #39029, #39069, #39020, #39073, #39082, #39096, #39080, #39182, #39143, #39127, #37929, #38029, #39194, #39198, #39210, #39211, #39202, #39214, #39215, #39220, #39234, #39260, #39251, #39361, #39357, #39349, #39287, #39376, #39289, #39342, #38711, #39379, #39282, #39286, #39296, #39047, #39346, #39373, #39372, #39429, and #39457 by @ChaosExAnima, @ClearlyClaire, @Gargron, @arte7, @diondiondion, @mjankowski, @oneiros, and @shleeable)
  - Create collections with up to 25 accounts each, then share them with others. You can read more about this feature [on our blog](https://blog.joinmastodon.org/2026/04/designing-collections/). This is based on FEP-7aa9 (Featured Collections) to be interoperable with the wider Fediverse. All the new API methods [are documented here](https://docs.joinmastodon.org/client/collections/).
- **Add email subscriptions** (#38163, #38507, #38502, #38487, #38527, #38582, #38741, #38907, #39162, #39271 by @ClearlyClaire and @Gargron)
  - Admins can allow specific roles to enable email subscriptions on their profile, allowing anonymous visitors to subscribe to their posts via email.
- **Add new overview landing page setting** (#39074, #39170, #39163, and #39138 by @Gargron, @diondiondion, and @zunda)
  - Admins can choose a new frontpage for anonymous visitors, which combines the about page and most recent posts from local profiles.
- **Add ability to require 2FA for specific roles** (including Everybody) (#37701, #37846, and #38906 by @ClearlyClaire and @mjankowski)
- Add import and export for custom filters (#39085, #39256, #39386 by @arte7)
- Add ability to search email blocks by domain in admin UI (#38923 by @arte7)
- Add new endpoints for profile editing in REST API (#37912, #37934, #37932, #38221, and #38339 by @ClearlyClaire)
  - Add `GET /api/v1/profile` and `PATCH /api/v1/profile` to replace the existing `update_credentials` endpoint. See [the documentation](https://docs.joinmastodon.org/methods/profile/) for more information.
- Add `missing_attribution` boolean to preview cards in REST API (#38043 by @ClearlyClaire)
  - Documentation: https://docs.joinmastodon.org/entities/PreviewCard/#missing_attribution
- Add `exclude_direct` flag to `/api/v1/accounts/:id/statuses` to exclude direct messages (#37763 by @ClearlyClaire)
- Add `max_note_length` and `max_display_name_length` attributes to `configuration.accounts` in `Instance` entity (#37991 by @ClearlyClaire)
- Add profile field limits to instance entity in REST API (#37535 by @mkljczk)
  - This adds attributes `configuration.accounts.max_profile_fields`, `configuration.accounts.profile_field_name_limit` and `configuration.accounts.profile_field_value_limit` to the [`Instance` entity](https://docs.joinmastodon.org/entities/Instance).
- Add `unresolved` flag to `/api/v1/admin/reports` to query both resolved and unresolved reports (#38323 by @mkljczk)
- Add fallback attributes to notifications for new and infrequent notifications in REST API (#38832 and #38860 by @ClearlyClaire)
  - This adds a [`supported_types`](https://docs.joinmastodon.org/methods/notifications/#query-parameters-1) parameter to `GET /api/v1/notifications`, `GET /api/v1/notifications/:id`, `GET /api/v2/notifications`, and `GET /api/v2/notifications/:group_key` along with a new `fallback` attribute for notifications and notification groups.
- Add support for posts in vertical languages in web UI (#37204, #38205, and #38797 by @shimon1024)
- Add `Alt` + `PageUp` and `Alt` + `PageDown` hotkeys for list navigation (#39252 and #39427 by @diondiondion)
- Add `g`+`e` keyboard shortcut to access the trending page in web UI (#38014 by @antoinecellerier)
- Add `Cmd`/`Ctrl`+`Enter` for form submissions in more text areas in web UI (#37821 by @diondiondion)
- Add support for quoting by dragging a link into the compose form in web UI (#36859 and #36896 by @ClearlyClaire and @tribela)
- Add `text-autospace` to posts to improve rendering of mixed script posts in web UI (#37694 by @ahxxm)
- Add Taiwanese (Minnan), Lazuri, Mingrelian and Ottoman Turkish to supported locales (#37650, #34923, #37822, #37721, #38648 by @ClearlyClaire and @Yoxem)
- Add ability to filter notifications from bots (#38809 and #39377 by @evanp and @shleeable)
- Add support for `hosts` resolver in request socket DNS lookup (#38699, #38866, and #39030 by @ClearlyClaire and @mjankowski)
- Add support for FEP-2c59 (Webfinger Backlink) (#38239, #38538, and #38639 by @ClearlyClaire and @shleeable)
- Add support for FEP-3b86 (Activity Intents) (#38120 and #38130 by @ClearlyClaire and @Gargron)
- Add support for alt text for profile pictures and headers (#37634, #37641, #38000, #39352 by @ClearlyClaire and @Doxterpepper)
- Add support for multiple keypairs for remote accounts (#38279, #38407, #38419, #38511, #38516, #38515, #38555 and #39235 by @ClearlyClaire)
- Add duration to ActivityPub representation of media attachments (#38061 by @ClearlyClaire)
- Add Stoplight circuit-breaker on Elasticsearch endpoints to better handle some Elasticsearch failures (#39323 and #39375 by @ClearlyClaire and @shleeable)
- Add support for the “require approval” feature for email domain blocks to `tootctl email_domain_blocks` (#34579 and #38107 by @ClearlyClaire and @e-nomem)
- Add `--keep-interacted` flag to `tootctl media remove` to preserve cached media on cleanup (#36200 by @northerner)
- Add systemd service file for prometheus exporter (#35130 by @ThisIsMissEm)

### Changed

- **Change design of profiles in web UI** (#37472, #37490, #37479, #37513, #37527, #37550, #37538, #37632, #37627, #37593, #37638, #37626, #37645, #37653, #37683, #37707, #37682, #37742, #37747, #37760, #37761, #37831, #37766, #37811, #37813, #37825, #37854, #37851, #37876, #37885, #37892, #37890, #37907, #37922, #37952, #37958, #37996, #37990, #37994, #38005, #38012, #38040, #38052, #38066, #38083, #38147, #38148, #38152, #38168, #38156, #38175, #38191, #38189, #38235, #38283, #38310, #38309, #38315, #38314, #38365, #38366, #38363, #38346, #38382, #38384, #38400, #38404, #38417, #38426, #38440, #38442, #38443, #38445, #38446, #38451, #38456, #38509, #38510, #38512, #38513, #38517, #38529, #38531, #38535, #38532, #38544, #38549, #38575, #38579, #38580, #38581, #38585, #38584, #38604, #38605, #38606, #38607, #38622, #38616, #38625, #38632, #38640, #38663, #38667, #38646, #38691, #38692, #38766, #38791, #38687, #38826, #38828, #38863, #38845, #38870, #38872, #38932, #38945, #38963, #38964, #39055, #39042, #38893, #39079, #39084, #39160, #39070, #39217, #39309, #39354, #39324, #39387, #39452, #39467 by @ChaosExAnima, @ClearlyClaire, @Coro365, @diondiondion, and @shleeable)
  - The profile screen has been entirely redesigned, has new features, and allows you to update your own profile directly without going into the preferences panel. You can read more about it [on our blog](https://blog.joinmastodon.org/2026/03/a-redesign-for-profiles/).
- **Change how #Wrapstodon reports are generated and displayed** (#37033, #37045, #37093, #37055, #37096, #37047, #37103, #37104, #37106, #37109, #37121, #37138, #37134, #37177, #37182, #37169, #37186, #37187, #37188, #37189, #37190, #37193, #37198, #37201, #37203, #37205, #37206, #37207, #37209, #37202, #37216, #37219, #37224, #37226, #37229, #37249, #37251, #37256, #37261, #37269, #37270, #37273, and #37289 by @ChaosExAnima, @ClearlyClaire, @channyeintun, and @diondiondion)
  - This finishes up work started in 2024 by completely revamping how Wrapstodon reports are generated and displayed, reducing the amount of data collected and generating reports when active users ask for them.
  - Instead of requiring manual generation from a server administrator, this is now offered between the 10th of December and the end of each year if enabled in the server settings.
  - The design of the Wrapstodon report has also been fully reworked to be more delightful and easier to share!
  - The relevant API endpoints are documented at https://docs.joinmastodon.org/methods/annual_reports/
- Change limitation to allow posts with both media and a poll to be created (#39203, #39368, #39388 by @ClearlyClaire and @Gargron)
- Change account display name length limit from 30 to 40 characters (#39458 by @mjankowski)
- Change alt text limit for media attachments to 10,000 characters (#39306 by @ClearlyClaire)
- Change pending user notification email to link directly to the pending account (#39206 by @vmstan)
- Changed emoji processing in web UI to make it less resource intensive and more robust (#39077, #39008, #39088, #38892, #38885, #38965, #38854, #38825, #38784, #38541, #37442, #37300, #37306, #37271, #37255, #37284, #37272, #37178, #37084, #37080, #37418, #39167, #39126, #39353, #39378, #39382, #39402, and #39421 by @ChaosExAnima, @ClearlyClaire, @diondiondion, @gomasy, and @Hanage999)
- Change composer textarea to have a limited height to prevent column scrolling (#39268 by @diondiondion)
- Change mentions of “Mastodon gGmbH” to “Mastodon GmbH” (#39261 by @renchap)
- Change the limited profile message to be less misleading (#39231 by @mortie)
- Change images/videos in posts in web UI to not have unlimited height (#36966, #37035, #37136, and #37032 by @diondiondion)
- Change search field and tabs to stick to the top on the search results page in web UI (#38968 by @diondiondion)
- Change “anyone can quote” label to “quotes allowed” in web UI (#37427 by @vmstan)
- Change navigation by `j`/`k` hotkeys to anchor navigated item to top of viewport in web UI (#38036 by @diondiondion)
- Change hotkeys to focus columns to not reset scroll, add hotkey `0` to scroll to top in web UI (#37052 by @diondiondion)
- Change media modal swipe animation in web UI (#36916, #37034, #37323, and #37464 by @ChaosExAnima and @heathdutton)
- Change “Hide”/“Show all” eye icon in thread view in web UI (#22301 by @tribela)
- Change order of onboarding steps (follow people, then fill out profile) in web UI (#38121 by @Gargron)
- Change “Why do you want to join” field on the sign-up page to have a label (#38936 by @diondiondion)
- Change date of birth field on the sign-up page to use locale-specific fields order (#36039 and #36895 by @mjankowski)
- Change how invalid-but-not-expired invites are shown in admin UI (#38736 by @ClearlyClaire)
- Change wording and ordering of media display settings (#38731 by @mjankowski)
- Change wording of server account recommendation setting description (#36771 by @mjankowski)
- Change wording and ordering of account migration warnings (#20387 by @jsoref)
- Change wording of “Automatic post deletion” settings (#37286 by @mjankowski)
- Change wording of language filter settings to clarify they do not impact home/lists (#38490 by @mjankowski)
- Change wording of `tootctl preview_cards remove` command description to clearly state it only removes media (#39348 by @mjankowski)
- Change invitations to only bypass sign-up approval setting when the issuer of the invitation has the `invite_bypass_approval` permission (#38278 by @ClearlyClaire)
  - This splits the “Invite Users” permission into a new “Invite Users without review” permission.
  - Existing roles will be updated to have the new permission if they have the old one, but default permissions will not include the new `invite_bypass_approval` permission.
- Change followers synchronization mechanism on followers-only posts to be skipped for accounts with 25k followers or more (#37302 by @ClearlyClaire)
- Change "Accept" link on sign-up page to a form to prevent some crawling behavior (#39283 and #39345 by @ClearlyClaire and @mjankowski)
- Change “dark”, “light” and “high contrast” themes to be separate “Color scheme” and “Contrast” settings handled by a single theme (#37095, #37120, #37288, #37459, #37470, #37477, #37519, #37520, #37523, #37524, #37526, #37612, #37824, #37807, #37810, #37819, #37906, and #38261 by @ClearlyClaire, @diondiondion, and @mjankowski)
  - Existing settings should be migrated automatically from user settings, and using browser defaults otherwise.
  - This also allows third-party theme authors to make use of the same browser defaults and user settings. Learn more about this in [our new Theming docs](https://docs.joinmastodon.org/dev/frontend/theming/).
- Change default theme to use CSS theme tokens (#36861, #36936, #37019, #37054, #37056, #37081, #37105, #37268, #37841, #37843, #38387, #38459, and #38621 by @diondiondion)
  - A [guide to using the new tokens](https://docs.joinmastodon.org/dev/frontend/design-tokens/) can be found in our docs.
- Change location blocks in default `nginx.conf` (#19644 and #37866 by @BedrockDigger and @Izorkin)
- Change `proxy_read_timeout` to 120 seconds in default `nginx.conf` (#30599 by @shleeable)
- Change JSON-LD collection handling (#34595 and #37806 by @ClearlyClaire and @sneakers-the-rat)

### Removed

- Remove support for EOL Node version 20 (#38926 by @mjankowski)
- Remove support for Ruby 3.2 (#37476 by @mjankowski)
- Remove support for `ENABLE_SIDEKIQ_UNIQUE_JOBS_UI` (#38340 by @ClearlyClaire)
- Remove support for ImageMagick (#37488 by @mjankowski)
- Remove outdated hint for "Use system scrollbar" preference (#39297 by @diondiondion)

### Fixed

- Fix accessibility issues in web UI (#37250, #38006, #38033, #38188, #38230, #38252, #38257, #38285, #38293, #38362, #38387, #38459, #38796, #38801, #39098, #39111, #39120, #39129, #39133, #39134, #39144, #39145, #39149, #39164, #39165, #39169, #39181, #39335, #39305, #39331, #39356, #39350, #39358, #39360, #39325, #39270, #39439, #39400, and #39408 by @ChaosExAnima and @diondiondion)
- Fix report modal heading being impossible to translate properly in some languages (#39457 by @diondiondion)
- Fix being unable to edit an attachment twice without submitting (#39453 by @ClearlyClaire)
- Fix error with audio player in Safari Lockdown Mode (#39397 by @Federicorao)
- Fix tiny checkboxes and radio buttons in Safari (#39332 by @diondiondion)
- Fix handling of offset in timezone list in settings (#39334 by @mjankowski)
- Fix being unable to unmark media as sensitive when "always mark media as sensitive" is enabled in web UI (#39339 by @matrix07012)
- Fix display of sensitive media cards in web UI according to settings (#39366 by @nshki)
- Fix some inputs incorrectly having resize handles in Firefox (#39274 by @diondiondion)
- Fix processing some link previews where text is language-tagged (#39190 by @zunda)
- Fix error when “New trends” email is sent at the same time trends are recomputed (#39122 by @arte7)
- Fix hovercard not showing in compose column (#39430 by @diondiondion)
- Fix hover card opening even when not preceded by mouse movement in web UI (#39166, #39381 by @diondiondion)
- Fix [ominous](https://mastodon.social/@mcc/116404362104299129) "Moments remaining" timestamp in web UI (#38488 and #38689 by @ChaosExAnima and @MitarashiDango)
- Fix filters not being applied to search results in web UI (#36346 by @ClearlyClaire)
- Fix error when visiting non-public hashtag timelines (#36961 by @diondiondion)
- Fix duplicate favourite/boost counters in some languages (#36844 by @ChaosExAnima)
- Fix unblocking domain from blocked domains column not updating the list in web UI (#38882 by @tribela)
- Fix "change thumbnail" button being visible when it shouldn't in web UI (#38467 by @dpbento)
- Fix profile dropdown menu sometimes ending with a separator in web UI (#38481 by @mkljczk)
- Fix short numbers rounding up instead of truncating in web UI (#38114 by @serranodfm)
- Fix directory showing load more button when no more profiles exist in web UI (#37465 by @heathdutton)
- Fix focus restoration after closing some modals in web UI (#37424 by @MegaManSec)
- Fix video modals being pushed down on mobile in web UI (#37421 by @ChaosExAnima)
- Fix outer page margins when viewport width equals content width in web UI (#36733 by @diondiondion)
- Fix announcement margin when in advanced web UI (#36714 by @ChaosExAnima)
- Fix navigation overflow issue in advanced web UI (#39178 by @diondiondion)
- Fix stale merging stale account from cached instance API response in web UI (#37666 by @ChaosExAnima)
- Fix HTML `lang` attribute being stripped out of remote posts (#39114 by @artemist)
- Fix remote posts with large media descriptions being rejected (#39135 by @ClearlyClaire)
- Fix some occurrence of PostgreSQL log pollution when processing new hashtags (#35792 by @oelison)
- Fix blocked domains not being removed from the Instance search index (#39109 by @shleeable)
- Fix Elasticsearch connections not being cleaned up properly in Sidekiq middleware (#39359 by @ClearlyClaire)
- Fix replica database not being used when `REPLICA_DB_HOST` is used but neither `REPLICA_DB_NAME` nor `REPLICA_DATABASE_URL` (#37240 by @smiba)
- Fix remote media attachment thumbnails not being stored in the `cache/` directory (#36911 by @shugo)
- Fix race condition when processing posts twice with the same idempotency key (#37879 by @ClearlyClaire)
- Fix `expire_at` instead of `expires_at` in muted words CSV exports (#39304 by @arte7)
- Fix various missing translation strings (#37671, #37838, #37078, #37371, #37827, #39328 by @ClearlyClaire, @mjankowski, and @valtlai)
- Fix last post time for remote accounts not being accurately tracked (#37619 by @ClearlyClaire)
- Fix filtering of mentions from filtered-on-their-origin-server accounts (#37583 by @ClearlyClaire)
- Fix irrelevant remote accounts being passed through to local fan-out worker (#37589 by @ClearlyClaire)
- Fix required field markers being displayed on fields that cannot be empty anyway in settings (#37291 by @diondiondion)
- Fix thumbnails for links from The Guardian (and possibly other CDNs that check URL hashes) not showing up (#36139 by @phocks)
- Fix `mastodon-async-refresh` response header not being exposed through CORS (#38914 by @mkljczk)
- Fix FASP availability being incorrectly updated (#38818 by @oneiros)
- Fix use of deprecated `vsync` FFmpeg option, using `fps_mode` instead (FFmpeg >= 5.1 now required) (#38198 by @mjankowski)
- Fix unnecessary downcasing of some words in admin UI (#37364 by @ClearlyClaire)
- Fix delivery worker counting unsalvageable HTTP errors as successes (#37235 by @shleeable)
- Fix streaming heartbeat comment not being its own event (#37389 by @ClearlyClaire)
- Fix posts with edited out media attachments being returned in `GET /api/v1/accounts/:id/statuses?only_media=true` (#37363 by @ClearlyClaire)
- Fix wrong media attachment URLs being returned from `DELETE /api/v1/statuses/:id` (#35880 by @dbarabashh)
- Fix hashtag matching by replacing negative look-behind with positive look-behind (#37684 and #38212 by @ClearlyClaire)
- Fix discovery of ActivityPub representation from HTML tags in presence of a non-ActivityPub alternate Link header (#37439 by @shleeable)
- Fix Webfinger endpoint not handling new ActivityPub ID scheme (#38391 by @ClearlyClaire)
- Fix error when admin-selected theme does not exist by falling back to `default` theme (#38703 by @shleeable)
- Fix wrong endonyms for Divehi and Latvian in languages list (#36254 and #36876 by @cuu508 and @shimon1024)
- Fix `Accept` headers when fetching ActivityPub resources not including JSON-LD profile (#30354 by @TheOneric)
- Fix wrong hover indicators on unclickable items in admin UI (#38782 by @diondiondion)
- Fix streaming server using deprecated `url.parse` instead of WHATWG URL API (#36973 by @Exagone313)

## [4.5.11] - 2026-06-03

### Security

- Fix allowed attribution domains spoofing ([GHSA-rwcw-vq68-g34p](https://github.com/mastodon/mastodon/security/advisories/GHSA-rwcw-vq68-g34p))
- Fix uncaught exception in message sanitization causing Denial of Service ([GHSA-qrgq-9fx2-vf2r](https://github.com/mastodon/mastodon/security/advisories/GHSA-qrgq-9fx2-vf2r))
- Update dependencies

### Fixed

- Fix remote statuses with large media descriptions being rejected (#39135 by @ClearlyClaire)

## [4.5.10] - 2026-05-20

### Security

- Fix SSRF protection bypass ([GHSA-crr4-7rm4-8gpw](https://github.com/mastodon/mastodon/security/advisories/GHSA-crr4-7rm4-8gpw), [GHSA-xx55-4rrg-8xg6](https://github.com/mastodon/mastodon/security/advisories/GHSA-xx55-4rrg-8xg6))
- Fix Linked-Data Signature bypass through JSON-LD graph restructuring features ([GHSA-53m7-2wrh-q839](https://github.com/mastodon/mastodon/security/advisories/GHSA-53m7-2wrh-q839), [GHSA-chgx-jx3p-rf73](https://github.com/mastodon/mastodon/security/advisories/GHSA-chgx-jx3p-rf73))
- Updated dependencies

### Fixed

- Fix type of `interactingObject`, `interactionTarget` and add missing `QuoteAuthorization` (#38940 by @ClearlyClaire)

### Removed

- Remove unused devise strategies (#38795 by @ClearlyClaire)

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

_For previous changes, review the [stable-4.3 branch](https://github.com/mastodon/mastodon/blob/stable-4.3/CHANGELOG.md)_
