# Changelog

All notable changes to this project will be documented in this file.

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
  This adds the `severed_relationships` notification type to the REST API and streaming, with a new [`relationship_severance_event` attribute](https://docs.joinmastodon.org/entities/Notification/#relationship_severance_event).
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

## |4.2.11] - 2024-08-16

### Added

- Add support for incoming `<s>` tag ([mediaformat](https://github.com/mastodon/mastodon/pull/31375))

### Changed

- Change logic of block/mute bypass for mentions from moderators to only apply to visible roles with moderation powers ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/31271))

### Fixed

- Fix incorrect rate limit on PUT requests ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/31356))
- Fix presence of `ß` in adjacent word preventing mention and hashtag matching ([adamniedzielski](https://github.com/mastodon/mastodon/pull/31122))
- Fix processing of webfinger responses with multiple `self` links ([adamniedzielski](https://github.com/mastodon/mastodon/pull/31110))
- Fix duplicate `orderedItems` in user archive's `outbox.json` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/31099))
- Fix click event handling when clicking outside of an open dropdown menu ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/31251))
- Fix status processing failing halfway when a remote post has a malformed `replies` attribute ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/31246))
- Fix `--verbose` option of `tootctl media remove`, which was previously erroneously removed ([mjankowski](https://github.com/mastodon/mastodon/pull/30536))
- Fix division by zero on some video/GIF files ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30600))
- Fix Web UI trying to save user settings despite being logged out ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30324))
- Fix hashtag regexp matching some link anchors ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30190))
- Fix local account search on LDAP login being case-sensitive ([raucao](https://github.com/mastodon/mastodon/pull/30113))
- Fix development environment admin account not being auto-approved ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29958))
- Fix report reason selector in moderation interface not unselecting rules when changing category ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29026))
- Fix already-invalid reports failing to resolve ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29027))
- Fix OCR when using S3/CDN for assets ([vmstan](https://github.com/mastodon/mastodon/pull/28551))
- Fix error when encountering malformed `Tag` objects from Kbin ([ShadowJonathan](https://github.com/mastodon/mastodon/pull/28235))
- Fix not all allowed image formats showing in file picker when uploading custom emoji ([june128](https://github.com/mastodon/mastodon/pull/28076))
- Fix search popout listing unusable search options when logged out ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27918))
- Fix processing of featured collections lacking an `items` attribute ([tribela](https://github.com/mastodon/mastodon/pull/27581))
- Fix `mastodon:stats` decoration of stats rake task ([mjankowski](https://github.com/mastodon/mastodon/pull/31104))

## [4.2.10] - 2024-07-04

### Security

- Fix incorrect permission checking on multiple API endpoints ([GHSA-58x8-3qxw-6hm7](https://github.com/mastodon/mastodon/security/advisories/GHSA-58x8-3qxw-6hm7))
- Fix incorrect authorship checking when processing some activities (CVE-2024-37903, [GHSA-xjvf-fm67-4qc3](https://github.com/mastodon/mastodon/security/advisories/GHSA-xjvf-fm67-4qc3))
- Fix ongoing streaming sessions not being invalidated when application tokens get revoked ([GHSA-vp5r-5pgw-jwqx](https://github.com/mastodon/mastodon/security/advisories/GHSA-vp5r-5pgw-jwqx))
- Update dependencies

### Added

- Add yarn version specification to avoid confusion with Yarn 3 and Yarn 4

### Changed

- Change preview cards generation to skip unusually long URLs ([oneiros](https://github.com/mastodon/mastodon/pull/30854))
- Change search modifiers to be case-insensitive ([Gargron](https://github.com/mastodon/mastodon/pull/30865))
- Change `STATSD_ADDR` handling to emit a warning rather than crashing if the address is unreachable ([timothyjrogers](https://github.com/mastodon/mastodon/pull/30691))
- Change PWA start URL from `/home` to `/` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/27377))

### Removed

- Removed dependency on `posix-spawn` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/18559))

### Fixed

- Fix scheduled statuses scheduled in less than 5 minutes being immediately published ([danielmbrasil](https://github.com/mastodon/mastodon/pull/30584))
- Fix encoding detection for link cards ([oneiros](https://github.com/mastodon/mastodon/pull/30780))
- Fix `/admin/accounts/:account_id/statuses/:id` for edited posts with media attachments ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30819))
- Fix duplicate `@context` attribute in user archive export ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30653))

## [4.2.9] - 2024-05-30

### Security

- Update dependencies
- Fix private mention filtering ([GHSA-5fq7-3p3j-9vrf](https://github.com/mastodon/mastodon/security/advisories/GHSA-5fq7-3p3j-9vrf))
- Fix password change endpoint not being rate-limited ([GHSA-q3rg-xx5v-4mxh](https://github.com/mastodon/mastodon/security/advisories/GHSA-q3rg-xx5v-4mxh))
- Add hardening around rate-limit bypass ([GHSA-c2r5-cfqr-c553](https://github.com/mastodon/mastodon/security/advisories/GHSA-c2r5-cfqr-c553))

### Added

- Add rate-limit on OAuth application registration ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/30316))
- Add fallback redirection when getting a webfinger query `WEB_DOMAIN@WEB_DOMAIN` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/28592))
- Add `digest` attribute to `Admin::DomainBlock` entity in REST API ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/29092))

### Removed

- Remove superfluous application-level caching in some controllers ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29862))
- Remove aggressive OAuth application vacuuming ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/30316))

### Fixed

- Fix leaking Elasticsearch connections in Sidekiq processes ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30450))
- Fix language of remote posts not being recognized when using unusual casing ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30403))
- Fix off-by-one in `tootctl media` commands ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30306))
- Fix removal of allowed domains (in `LIMITED_FEDERATION_MODE`) not being recorded in the audit log ([ThisIsMissEm](https://github.com/mastodon/mastodon/pull/30125))
- Fix not being able to block a subdomain of an already-blocked domain through the API ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30119))
- Fix `Idempotency-Key` being ignored when scheduling a post ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/30084))
- Fix crash when supplying the `FFMPEG_BINARY` environment variable ([timothyjrogers](https://github.com/mastodon/mastodon/pull/30022))
- Fix improper email address validation ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29838))
- Fix results/query in `api/v1/featured_tags/suggestions` ([mjankowski](https://github.com/mastodon/mastodon/pull/29597))
- Fix unblocking internationalized domain names under certain conditions ([tribela](https://github.com/mastodon/mastodon/pull/29530))
- Fix admin account created by `mastodon:setup` not being auto-approved ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29379))
- Fix reference to non-existent var in CLI maintenance command ([mjankowski](https://github.com/mastodon/mastodon/pull/28363))

## [4.2.8] - 2024-02-23

### Added

- Add hourly task to automatically require approval for new registrations in the absence of moderators ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29318), [ClearlyClaire](https://github.com/mastodon/mastodon/pull/29355))
  In order to prevent future abandoned Mastodon servers from being used for spam, harassment and other malicious activity, Mastodon will now automatically switch new user registrations to require moderator approval whenever they are left open and no activity (including non-moderation actions from apps) from any logged-in user with permission to access moderation reports has been detected in a full week.
  When this happens, users with the permission to change server settings will receive an email notification.
  This feature is disabled when `EMAIL_DOMAIN_ALLOWLIST` is used, and can also be disabled with `DISABLE_AUTOMATIC_SWITCHING_TO_APPROVED_REGISTRATIONS=true`.

### Changed

- Change registrations to be closed by default on new installations ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29280))
  If you are running a server and never changed your registrations mode from the default, updating will automatically close your registrations.
  Simply re-enable them through the administration interface or using `tootctl settings registrations open` if you want to enable them again.

### Fixed

- Fix processing of remote ActivityPub actors making use of `Link` objects as `Image` `url` ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29335))
- Fix link verifications when page size exceeds 1MB ([ClearlyClaire](https://github.com/mastodon/mastodon/pull/29358))

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
