# Changelog

## v2.5.3

- Add Google Site Verification to the bot list.
- Handle invalid quality values that look like numbers.
- Add Barkrowler bot.
- Add AlwaysOnline bot: CloudFlare.
- Add News aggregator crawler: AndersPink, BuzzBot.
- Add Domain crawler: CipaCrawler.
- Add Job bot: JobSeeker's.
- Add Apparel crawler: TeeRaid.
- Add Search engine crawler: SemanticBot, Mappy.
- Add Copyright crawler: Copypants' BotPants.
- Add SEO bots: SEOdiver, SeoAudit, WebCeo.
- Add Woriobot from Zite.
- Add BUbiNG bot.
- Add Paessler bot.

## v2.5.2

- Add COMODO SSL Checker bot.
- Add Swiftype bot.
- Add WhatsApp detection.

## v2.5.1

- Add Android Oreo detection.

## v2.5.0

- Add support for QQ Browser Mac & Mac Lite.
- Add support for Electron Framework.
- Add support for Facebook in-app browser.
- Add support for Otter Browser.
- Add Android webview detection.

## v2.4.0

- Add Google Drive API, Proximic Spider, NewRelic pinger and SocialRank bots.
- Add Pinboard in-app browser to the bot exception list.
- All browser detection methods can now compare versions.
- All platform detection methods can now compare versions (except `#linux?` and `#firefox_os?`).
- Add `browser/aliases`, so you can have methods on the base object (e.g. `browser.mobile?`). See README for instructions.
- Remove official support for Rails 3 and Ruby 2.1.

## v2.3.0

- Add AWS ELB bot.
- Add CommonCrawl and Yahoo Ad Monitoring bots.
- Add Google Stackdriver Uptime Check bot.
- Add Microsoft Bing bots (adldxbot, bingpreview, and msnbot-media).
- Add Stripe and Netcraft bots.
- Add support for loading browser without extending Rails' helpers.
- Add Watchsumo bot.
- Match Alipay.

## v2.2.0

- `Browser::Platform#windows?` can now compare versions.
- `Browser::Platform#mac?` can now compare versions.
- Detect QQ Browser.
- Fix issue with Mac user agents that didn't include the version.

## v2.1.0

- Add PrivacyAwareBot, ltx71, Squider and Traackr to bots.
- Match Google Structured Data alternative bot.
- Match MicroMessenger (WeChat).
- Match Weibo.
- Detect Windows & Mac OS versions.

## v2.0.3

- Fix issue with version detection when no actual version is provided (i.e. the user agent doesn't have any version information).

## v2.0.2

- Fix issue when user agent is set to `nil`.
- Fix issue with user agent without version information.

## v2.0.1

- Fix Rails integration.

## v2.0.0

- `Browser#platform` now returns instance of `Browser::Platform`, instead of a `String`. It contains information about the platform (software).
- `Browser#device` was added. It returns information about the device (hardware).
- `Browser#accept_language` now returns a list of `Browser::AcceptLanguage` objects.
- `Browser#bot` now returns a `Browser::Bot` instance.
- Safari running as web app mode is not recognized as Safari anymore.
- ruby-2.3+ will always activate frozen strings.
- [List of all commits since last release](https://github.com/fnando/browser/compare/v1.1.0...v2.0.0).
