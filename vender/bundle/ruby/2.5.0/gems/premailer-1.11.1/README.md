# Premailer README [![Build Status](https://travis-ci.org/premailer/premailer.png?branch=master)](https://travis-ci.org/premailer/premailer) [![Gem Version](https://badge.fury.io/rb/premailer.svg)](https://badge.fury.io/rb/premailer)

## What is this?

For the best HTML e-mail delivery results, CSS should be inline. This is a
huge pain and a simple newsletter becomes un-managable very quickly. This
script is my solution.

* CSS styles are converted to inline style attributes
  - Checks `style` and `link[rel=stylesheet]` tags and preserves existing inline attributes
* Relative paths are converted to absolute paths
  - Checks links in `href`, `src` and CSS `url('')`
* CSS properties are checked against e-mail client capabilities
  - Based on the Email Standards Project's guides
* A plain text version is created (optional)

## Installation

Install the Premailer gem from RubyGems.

```bash
gem install premailer
```

or add it to your `Gemfile` and run `bundle`.

## Example

```ruby
require 'premailer'

premailer = Premailer.new('http://example.com/myfile.html', :warn_level => Premailer::Warnings::SAFE)

# Write the plain-text output
# This must come before to_inline_css (https://github.com/premailer/premailer/issues/201)
File.open("output.txt", "w") do |fout|
  fout.puts premailer.to_plain_text
end

# Write the HTML output
File.open("output.html", "w") do |fout|
  fout.puts premailer.to_inline_css
end

# Output any CSS warnings
premailer.warnings.each do |w|
  puts "#{w[:message]} (#{w[:level]}) may not render properly in #{w[:clients]}"
end
```

## Adapters

Premailer's default adapter is nokogiri if both nokogiri and nokogumbo are included in the Gemfile list. However, if you want to use a different adapter, you can choose to.

There are three adapters in total (as of premailer 1.10.0)

1. nokogiri (default)
2. nokogiri_fast
3. nokogumbo

hpricot adapter removed due to its EOL, please use `~>1.9.0` version if You still need it..

`NokogiriFast` adapter improves the Algorithmic complexity of the running time by 20x with a slight compensation on memory. To switch to any of these adapters, add the following line. For example, if you want to include the `NokogiriFast` adapter,

```ruby
Premailer::Adapter.use = :nokogiri_fast
```

## Ruby Compatibility

Premailer is tested on Ruby 2.1 and above. JRuby support is close; contributors are welcome.  Checkout the latest build status on the [Travis CI dashboard](https://travis-ci.org/#!/premailer/premailer).

## Premailer-specific CSS

Premailer looks for a few CSS attributes that make working with tables a bit easier.

| CSS Attribute | Availability |
| ------------- | ------------ |
| -premailer-width | Available on `table`, `th` and `td` elements |
| -premailer-height | Available on `table`, `tr`, `th` and `td` elements |
| -premailer-cellpadding | Available on `table` elements |
| -premailer-cellspacing | Available on `table` elements |
| data-premailer="ignore" | Available on `link` and `style` elements. Premailer will ignore these elements entirely. |

Each of these CSS declarations will be copied to appropriate element's attribute.

For example

```css
table { -premailer-cellspacing: 5; -premailer-width: 500; }
```

will result in

```html
<table cellspacing='5' width='500'>
```

## Contributions

Contributions are most welcome.  Premailer was rotting away in a private SVN repository for too long and could use some TLC.  Fork and patch to your heart's content.  Please don't increment the version numbers, though.

A few areas that are particularly in need of love:

* Improved test coverage
* Move un-repeated background images defined in CSS for Outlook

## Credits and code

Thanks to [all the wonderful contributors](https://github.com/premailer/premailer/contributors) for their updates.

Thanks to [Greenhood + Company](http://www.greenhood.com/) for sponsoring some of the 1.5.6 updates,
and to [Campaign Monitor](https://www.campaignmonitor.com/) for supporting the web interface.

The source code can be found on [GitHub](https://github.com/premailer/premailer).

Copyright by Alex Dunae (dunae.ca, e-mail 'code' at the same domain), 2007-2017.  See [LICENSE.md](https://github.com/premailer/premailer/blob/master/LICENSE.md) for license details.

