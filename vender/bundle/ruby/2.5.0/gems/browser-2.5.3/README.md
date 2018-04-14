# Browser

[![Travis-CI](https://travis-ci.org/fnando/browser.png)](https://travis-ci.org/fnando/browser)
[![Code Climate](https://codeclimate.com/github/fnando/browser/badges/gpa.svg)](https://codeclimate.com/github/fnando/browser)
[![Test Coverage](https://codeclimate.com/github/fnando/browser/badges/coverage.svg)](https://codeclimate.com/github/fnando/browser/coverage)
[![Gem](https://img.shields.io/gem/v/browser.svg)](https://rubygems.org/gems/browser)
[![Gem](https://img.shields.io/gem/dt/browser.svg)](https://rubygems.org/gems/browser)

Do some browser detection with Ruby. Includes ActionController integration.

## Installation

```bash
gem install browser
```

## Usage

```ruby
require "browser"

browser = Browser.new("Some User Agent", accept_language: "en-us")

# General info
browser.bot?
browser.chrome?
browser.core_media?
browser.edge?                # Newest MS browser
browser.electron?            # Electron Framework
browser.firefox?
browser.full_version
browser.ie?
browser.ie?(6)               # detect specific IE version
browser.ie?([">8", "<10"])   # detect specific IE (IE9).
browser.known?               # has the browser been successfully detected?
browser.meta                 # an array with several attributes
browser.modern?              # Webkit, Firefox 17+, IE 9+ and Opera 12+
browser.name                 # readable browser name
browser.nokia?
browser.opera?
browser.opera_mini?
browser.phantom_js?
browser.quicktime?
browser.safari?
browser.safari_webapp_mode?
browser.to_s            # the meta info joined by space
browser.uc_browser?
browser.version         # major version number
browser.webkit?
browser.webkit_full_version
browser.yandex?
browser.wechat?         # detect the MicroMessenger(WeChat)
browser.weibo?          # detect Weibo embedded browser (Sina Weibo)

# Get bot info
browser.bot.name
browser.bot.search_engine?
browser.bot?

# Get device info
browser.device
browser.device.id
browser.device.name
browser.device.blackberry_playbook?
browser.device.console?
browser.device.ipad?
browser.device.iphone?
browser.device.ipod_touch?
browser.device.kindle?
browser.device.kindle_fire?
browser.device.mobile?
browser.device.nintendo?
browser.device.playstation?
browser.device.ps3?
browser.device.ps4?
browser.device.psp?
browser.device.silk?
browser.device.surface?
browser.device.tablet?
browser.device.tv?
browser.device.vita?
browser.device.wii?
browser.device.wiiu?
browser.device.xbox?
browser.device.xbox_360?
browser.device.xbox_one?

# Get platform info
browser.platform
browser.platform.id
browser.platform.name
browser.platform.version  # e.g. 9 (for iOS9)
browser.platform.adobe_air?
browser.platform.android?
browser.platform.android?(4.2)   # detect Android Jelly Bean 4.2
browser.platform.android_app?     # detect webview in an Android app
browser.platform.android_webview? # alias for android_app?
browser.platform.blackberry?
browser.platform.blackberry?(10) # detect specific BlackBerry version
browser.platform.chrome_os?
browser.platform.firefox_os?
browser.platform.ios?     # detect iOS
browser.platform.ios?(9)  # detect specific iOS version
browser.platform.ios_app?     # detect webview in an iOS app
browser.platform.ios_webview? # alias for ios_app?
browser.platform.linux?
browser.platform.mac?
browser.platform.other?
browser.platform.windows10?
browser.platform.windows7?
browser.platform.windows8?
browser.platform.windows8_1?
browser.platform.windows?
browser.platform.windows_mobile?
browser.platform.windows_phone?
browser.platform.windows_rt?
browser.platform.windows_touchscreen_desktop?
browser.platform.windows_vista?
browser.platform.windows_wow64?
browser.platform.windows_x64?
browser.platform.windows_x64_inclusive?
browser.platform.windows_xp?
```

### Aliases

To add aliases like `mobile?` and `tablet?` to the base object (e.g `browser.mobile?`), require the `browser/aliases` file and extend the Browser::Base object like the following:

```ruby
require "browser/aliases"
Browser::Base.include(Browser::Aliases)

browser = Browser.new("Some user agent")
browser.mobile? #=> false
```

### What's being detected?

- For a list of platform detections, check [lib/browser/platform.rb](https://github.com/fnando/browser/blob/master/lib/browser/platform.rb)
- For a list of device detections, check [lib/browser/device.rb](https://github.com/fnando/browser/blob/master/lib/browser/device.rb)
- For a list of bot detections, check [bots.yml](https://github.com/fnando/browser/blob/master/bots.yml)

### What defines a modern browser?

The current rules that define a modern browser are pretty loose:

* Webkit
* IE9+
* Microsoft Edge
* Firefox 17+
* Firefox Tablet 14+
* Opera 12+

You can define your own rules. A rule must be a proc/lambda or any object that implements the method === and accepts the browser object. To redefine all rules, clear the existing rules before adding your own.

```ruby
# Only Chrome Canary is considered modern.
Browser.modern_rules.clear
Browser.modern_rules << -> b { b.chrome? && b.version.to_i >= 37 }
```

### Rails integration

Just add it to the Gemfile.

```ruby
gem "browser"
```

This adds a helper method called `browser`, that inspects your current user agent.

```erb
<% if browser.ie?(6) %>
  <p class="disclaimer">You're running an older IE version. Please update it!</p>
<% end %>
```

If you want to use Browser on your Rails app but don't want to taint your controller, use the following line on your Gemfile:

```ruby
gem "browser", require: "browser/browser"
```

### Accept Language

Parses the accept-language header from an HTTP request and produces an array of language objects sorted by quality.

```ruby
browser = Browser.new("Some User Agent", accept_language: "en-us")

browser.accept_language.class
#=> Array

language = browser.accept_language.first

language.code
#=> "en"

language.region
#=> "US"

language.full
#=> "en-US"

language.quality
#=> 1.0

language.name
#=> "English/United States"
```

Result is always sorted in quality order from highest -> lowest. As per the HTTP spec:

- omitting the quality value implies 1.0.
- quality value equal to zero means that is not accepted by the client.

### Internet Explorer

Internet Explorer has a compatibility view mode that allows newer versions (IE8+) to run as an older version. Browser will always return the navigator version, ignoring the compatibility view version, when defined. If you need to get the engine's version, you have to use `Browser#msie_version` and `Browser#msie_full_version`.

So, let's say an user activates compatibility view in a IE11 browser. This is what you'll get:

```ruby
browser.version
#=> 11

browser.full_version
#=> 11.0

browser.msie_version
#=> 7

browser.msie_full_version
#=> 7.0

browser.compatibility_view?
#=> true

browser.modern?
#=> false
```

This behavior changed in `v1.0.0`; previously there wasn't a way of getting the real browser version.

### Safari

iOS webviews and web apps aren't detect as Safari anymore, so be aware of that if that's your case. You can use a combination of platform and webkit detection to do whatever you want.

```ruby
# iPad's Safari running as web app mode.
browser = Browser.new("Mozilla/5.0 (iPad; U; CPU OS 3_2_1 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Mobile/7B405")

browser.safari?
#=> false

browser.webkit?
#=> true

browser.platform.ios?
#=> true
```

### Bots

Browser used to detect empty user agents as bots, but this behavior has changed. If you want to bring this detection back, you can activate it through the following call:

```ruby
Browser::Bot.detect_empty_ua!
```

### Middleware

You can use the `Browser::Middleware` to redirect user agents.

```ruby
use Browser::Middleware do
  redirect_to "/upgrade" unless browser.modern?
end
```

If you're using Rails, you can use the route helper methods. Just add something like the following to a initializer file (`config/initializers/browser.rb`).

```ruby
Rails.configuration.middleware.use Browser::Middleware do
  redirect_to upgrade_path unless browser.modern?
end
```

Notice that you can have multiple conditionals.

```ruby
Rails.configuration.middleware.use Browser::Middleware do
  next if browser.bot.search_engine?
  redirect_to upgrade_path(browser: "oldie") if browser.ie? && !browser.modern?
  redirect_to upgrade_path(browser: "oldfx") if browser.firefox? && !browser.modern?
end
```

If you need access to the `Rack::Request` object (e.g. to exclude a path), you can do so with `request`.

```ruby
Rails.configuration.middleware.use Browser::Middleware do
  redirect_to upgrade_path unless browser.modern? || request.env["PATH_INFO"] == "/exclude_me"
end
```

### Migrating to v2

#### Troubleshooting

##### `TypeError: no implicit conversion of Hash into String`

The class constructor now has a different signature. Change the instantiation from `Browser.new(options)` to `Browser.new(ua, options)`, where:

- `ua`: must be a string representing the user agent.
- `options`: must be a hash (for now it only accepts the `accept_language` option).

##### `NoMethodError: undefined method 'user_agent'`

`.ua` can now be used to retrieve the full User Agent string.

## Development

### Versioning

This library follows http://semver.org.

### Writing code

Once you've made your great commits (include tests, please):

1. [Fork](http://help.github.com/forking/) browser
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create a pull request
5. That's it!

Please respect the indentation rules and code style.
And use 2 spaces, not tabs. And don't touch the version thing.

## Configuring environment

To configure your environment, you must have Ruby and bundler installed. Then run `bundle install` to install all dependencies.

To run tests, execute `./bin/rake`.

### Adding new features

Before using your time to code a new feature, open a ticket asking if it makes sense and if it's on this project's scope.

Don't forget to add a new entry to `CHANGELOG.md`.

#### Adding a new bot

1. Add the user agent to `test/ua_bots.yml`.
2. Add the readable name to `bots.yml`. The key must be something that matches the user agent, in lowercased text.
3. Run tests.

Don't forget to add a new entry to `CHANGELOG.md`.

#### Adding a new search engine

1. Add the user agent to `test/ua_search_engines.yml`.
2. Add the same user agent to `test/ua_bots.yml`.
3. Add the readable name to `search_engines.yml`. The key must be something that matches the user agent, in lowercased text.
4. Run tests.

Don't forget to add a new entry to `CHANGELOG.md`.

#### Wrong browser/platform/device detection

If you know how to fix it, follow the "Writing code" above. Open an issue otherwise; make sure you fill in the issue template with all the required information.

## Maintainer

* Nando Vieira - http://nandovieira.com

## Contributors

* https://github.com/fnando/browser/contributors

## License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
