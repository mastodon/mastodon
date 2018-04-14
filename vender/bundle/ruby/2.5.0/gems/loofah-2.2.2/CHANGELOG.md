# Changelog

## 2.2.2 / 2018-03-22

Make public `Loofah::HTML5::Scrub.force_correct_attribute_escaping!`,
which was previously a private method. This is so that downstream gems
(like rails-html-sanitizer) can use this logic directly for their own
attribute scrubbers should they need to address CVE-2018-8048.


## 2.2.1 / 2018-03-19

Addresses CVE-2018-8048. Loofah allowed non-whitelisted attributes to be present in sanitized output when input with specially-crafted HTML fragments.

This CVE's public notice is at https://github.com/flavorjones/loofah/issues/144


## 2.2.0 / 2018-02-11

Features:

* Support HTML5 `<main>` tag. #133 (Thanks, @MothOnMars!)
* Recognize HTML5 block elements. #136 (Thanks, @MothOnMars!)
* Support SVG `<symbol>` tag. #131 (Thanks, @baopham!)
* Support for whitelisting CSS functions, initially just `calc` and `rgb`. #122/#123/#129 (Thanks, @NikoRoberts!)
* Whitelist CSS property `list-style-type`. #68/#137/#142 (Thanks, @andela-ysanni and @NikoRoberts!)

Bugfixes:

* Properly handle nested `script` tags. #127.


## 2.1.1 / 2017-09-24

Bugfixes:

* Removed warning for unused variable. #124 (Thanks, @y-yagi!)


## 2.1.0 / 2017-09-24

Notes:

* Re-implemented CSS parsing and sanitization using the [crass](https://github.com/rgrove/crass) library. #91


Features:

* Added :noopener HTML scrubber (Thanks, @tastycode!)
* Support `data` URIs with the following media types: text/plain, text/css, image/png, image/gif, image/jpeg, image/svg+xml. #101, #120. (Thanks, @mrpasquini!)


Bugfixes:

* The :unprintable scrubber now scrubs unprintable characters in CDATA nodes (like `<script>`). #124
* Allow negative values in CSS properties. Restores functionality that was reverted in v2.0.3. #91


## 2.0.3 / 2015-08-17

Bug fixes:

* Revert support for negative values in CSS properties due to slow performance. #90 (Related to #85.)


## 2.0.2 / 2015-05-05

Bug fixes:

* Fix error with `#to_text` when Loofah::Helpers hadn't been required. #75
* Allow multi-word data attributes. #84 (Thanks, @jstorimer!)
* Allow negative values in CSS properties. #85 (Thanks, @siddhartham!)


## 2.0.1 / 2014-08-21

Bug fixes:

* Load RR correctly when running test files directly. (Thanks, @ktdreyer!)


Notes:

* Extracted HTML5::Scrub#scrub_css_attribute to accommodate the Rails integration work. (Thanks, @kaspth!)


## 2.0.0 / 2014-05-09

Compatibility notes:

* ActionView helpers now must be required explicitly: `require "loofah/helpers"`
* Support for Ruby 1.8.7 and prior has been dropped

Enhancements:

* HTML5 whitelist allows the following ...
  * tags: `article`, `aside`, `bdi`, `bdo`, `canvas`, `command`, `datalist`, `details`, `figcaption`, `figure`, `footer`, `header`, `mark`, `meter`, `nav`, `output`, `section`, `summary`, `time`
  * attributes: `data-*` (Thanks, Rafael Franca!)
  * URI attributes: `poster` and `preload`
* Addition of the `:unprintable` scrubber to remove unprintable characters from text nodes. #65 (Thanks, Matt Swanson!)
* `Loofah.fragment` accepts an optional encoding argument, compatible with `Nokogiri::HTML::DocumentFragment.parse`. #62 (Thanks, Ben Atkins!)
* HTML5 sanitizers now remove attributes without values. (Thanks, Kasper Timm Hansen!)

Bug fixes:

* HTML5 sanitizers' CSS keyword check now actually works (broken in v2.0). Additional regression tests added. (Thanks, Kasper Timm Hansen!)
* HTML5 sanitizers now allow negative arguments to CSS. #64 (Thanks, Jon Calhoun!)


## 1.2.1 (2012-04-14)

* Declaring encoding in html5/scrub.rb. Without this, use of the ruby -KU option would cause havoc. (#32)


## 1.2.0 (2011-08-08)

Enhancements:

* Loofah::Helpers.sanitize_css is a replacement for Rails's built-in sanitize_css helper.
* Improving ActionView integration.


## 1.1.0 (2011-08-08)

Enhancements:

* Additional HTML5lib whitelist elements (from html5lib 1524:80b5efe26230).
  Up to date with HTML5lib ruby code as of 1723:7ee6a0331856.
* Whitelists (which are not part of the public API) are now Sets (were previously Arrays).
* Don't explode when encountering UTF-8 URIs. (#25, #29)


## 1.0.0 (2010-10-26)

Notes:

* Moved ActiveRecord functionality into `loofah-activerecord` gem.
* Removed DEPRECATIONS.rdoc documenting 0.3.0 API changes.


## 0.4.7 (2010-03-09)

Enhancements:

* New methods Loofah::HTML::Document#to_text and
  Loofah::HTML::DocumentFragment#to_text do the right thing with
  whitespace. Note that these methods are significantly slower than
  #text. GH #12
* Loofah::Elements::BLOCK_LEVEL contains a canonical list of HTML4 block-level4 elements.
* Loofah::HTML::Document#text and Loofah::HTML::DocumentFragment#text
  will return unescaped HTML entities by passing :encode_special_chars => false.


## 0.4.4, 0.4.5, 0.4.6 (2010-02-01)

Enhancements:

* Loofah::HTML::Document#text and Loofah::HTML::DocumentFragment#text now escape HTML entities.

Bug fixes:

* Loofah::XssFoliate was not properly escaping HTML entities when implicitly scrubbing a string attribute. GH #17


## 0.4.3 (2010-01-29)

Enhancements:

* All built-in scrubbers are accepted by ActiveRecord::Base.xss_foliate
* Loofah::XssFoliate.xss_foliate_all_models replaces use of the constant LOOFAH_XSS_FOLIATE_ALL_MODELS

Miscellaneous:

* Modified documentation for bootstrapping XssFoliate in a Rails app,
  since the use of Bundler breaks the previously-documented method. To
  be safe, always use an initializer file.


## 0.4.2 (2010-01-22)

Enhancements:

* Implemented Node#scrub! for scrubbing subtrees.
* Implemented NodeSet#scrub! for scrubbing a set of subtrees.
* Document.text now only serializes <body> contents (ignores <head>)
* <head>, <html> and <body> added to the HTML5lib whitelist.

Bug fixes:

* Supporting Rails apps that aren't loading ActiveRecord. GH #10

Miscellaneous:

* Mailing list is now loofah@librelist.com / http://librelist.com
* IRC channel is now \#loofah on freenode.


## 0.4.1 (2009-11-23)

Bugfix:

* Manifest fixed. Whoops.


## 0.4.0 (2009-11-21)

Enhancements:

* Scrubber class introduced, allowing development of custom scrubbers.
* Added support for XML documents and fragments.
* Added :nofollow HTML scrubber (thanks Luke Melia!)
* Built-in scrubbing methods refactored to use Scrubber.



## 0.3.1 (2009-10-12)

Bug fixes:

* Scrubbed Documents properly render html, head and body tags when serialized.


## 0.3.0 (2009-10-06)

Enhancements:

* New ActiveRecord extension `xss_foliate`, a drop-in replacement for xss_terminate[http://github.com/look/xss_terminate/tree/master].
* Replacement methods for Rails's helpers, Loofah::Rails.sanitize and Loofah::Rails.strip_tags.
* Official support (and test coverage) for Rails versions 2.3, 2.2, 2.1, 2.0 and 1.2.

Deprecations:

* The methods strip_tags, whitewash, whitewash_document, sanitize, and
  sanitize_document have been deprecated. See DEPRECATED.rdoc for
  details on the equivalent calls with the post-0.2 API.


## 0.2.2 (2009-09-30)

Enhancements:

* ActiveRecord extension scrubs fields in a before_validation callback
  (was previously in a before_save)


## 0.2.1 (2009-09-19)

Enhancements:

* when loaded in a Rails app, automatically extend ActiveRecord::Base
  with html_fragment and html_document. GH #6 (Thanks Josh Nichols!)

Bugfixes:

* ActiveRecord scrubbing should generate strings instead of Document or
  DocumentFragment objects. GH #5
* init.rb fixed to support installation as a Rails plugin. GH #6
  (Thanks Josh Nichols!)


## 0.2.0 (2009-09-11)

* Swank new API.
* ActiveRecord extension.
* Uses Nokogiri's Document and DocumentFragment for parsing.
* Updated html5lib codes and tests to revision 1384:b9d3153d7be7.
* Deprecated the Dryopteris sanitization methods. Will be removed in 0.3.0.
* Documentation! Hey!


## 0.1.2 (2009-04-30)

* Added whitewashing -- removal of all attributes and namespaced nodes. You know, for microsofty HTML.


## 0.1.0 (2009-02-10)

* Birthday!
