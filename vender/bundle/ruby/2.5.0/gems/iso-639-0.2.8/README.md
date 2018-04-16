# ISO 639

A Ruby gem that provides the ISO 639-2 and ISO 639-1 data sets along with some convenience methods for accessing different entries and entry fields. The data comes from the [LOC ISO 639-2 UTF-8 data set](http://www.loc.gov/standards/iso639-2/ascii_8bits.html).

To install:

```bash
gem install iso-639
```

The [ISO 639-1](http://en.wikipedia.org/wiki/ISO_639-1) specification uses a two-letter code to identify a language and is often the recommended way to identify languages in computer applications. The ISO 639-1 specification covers most developed and widely used languages.

The [ISO 639-2](http://www.loc.gov/standards/iso639-2/) ([Wikipedia](http://en.wikipedia.org/wiki/ISO_639-2)) specification uses a three-letter code, is used primarily in bibliography and terminology and covers many more languages than the ISO 639-1 specification.

## Usage

```ruby
require 'iso-639'
```

To find a language entry:

```ruby
# by alpha-2 or alpha-3 code
ISO_639.find_by_code("en")
# or
ISO_639.find("en")
# by English name
ISO_639.find_by_english_name("Russian")
# by French name
ISO_639.find_by_french_name("français")
```

The `ISO_639.search` class method searches across all fields and will
match names in cases where a record has multiple names. This method
always returns an array of 0 or more results. For example:

```ruby
ISO_639.search("spanish")
# => [["spa", "", "es", "Spanish; Castilian", "espagnol; castillan"]]
```

Entries are arrays with convenience methods for accessing fields:

```ruby
@entry = ISO_639.find("slo")
# => ["slo", "slk", "sk", "Slovak", "slovaque"]
@entry.alpha3_bibliographic
# => "slo"
@entry.alpha3 # shortcut for #alpha3_bibliographic
# => "slo"
@entry.alpha3_terminologic
# => "slk"
@entry.alpha2
# => "sk"
@entry.english_name
# => "Slovak"
@entry.french_name
# => "slovaque"
```

The full data set is available through the `ISO_639::ISO_639_1` and `ISO_639::ISO_639_2` constants.

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 William Melody. See LICENSE for details.
