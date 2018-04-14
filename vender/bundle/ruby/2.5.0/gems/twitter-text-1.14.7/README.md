# twitter-text

![hello](https://img.shields.io/gem/v/twitter-text.svg)

A gem that provides text processing routines for Twitter Tweets. The major
reason for this is to unify the various auto-linking and extraction of
usernames, lists, hashtags and URLs.

## Extraction Examples


# Extraction
```
class MyClass
  include Twitter::Extractor
  usernames = extract_mentioned_screen_names("Mentioning @twitter and @jack")
  # usernames = ["twitter", "jack"]
end
```

# Extraction with a block argument
```ruby

class MyClass
  include Twitter::Extractor
  extract_reply_screen_name("@twitter are you hiring?").do |username|
    # username = "twitter"
  end
end
```

## Auto-linking Examples

# Auto-link
```
class MyClass
  include Twitter::Autolink

  html = auto_link("link @user, please #request")
end
```

# For Ruby on Rails you want to add this to app/helpers/application_helper.rb
```
module ApplicationHelper
  include Twitter::Autolink
end
```

# Now the auto_link function is available in every view. So in index.html.erb:
```ruby
<%= auto_link("link @user, please #request") %>
```

### Usernames

Username extraction and linking matches all valid Twitter usernames but does
not verify that the username is a valid Twitter account.

### Lists

Auto-link and extract list names when they are written in @user/list-name
format.

### Hashtags

Auto-link and extract hashtags, where a hashtag can contain most letters or
numbers but cannot be solely numbers and cannot contain punctuation.

### URLs

Asian languages like Chinese, Japanese or Korean may not use a delimiter such
as a space to separate normal text from URLs making it difficult to identify
where the URL ends and the text starts.

For this reason twitter-text currently does not support extracting or
auto-linking of URLs immediately followed by non-Latin characters.

Example: "http://twitter.com/は素晴らしい" . The normal text is "は素晴らしい" and is not
part of the URL even though it isn't space separated.

### International

Special care has been taken to be sure that auto-linking and extraction work
in Tweets of all languages. This means that languages without spaces between
words should work equally well.

### Hit Highlighting

Use to provide emphasis around the "hits" returned from the Search API, built
to work against text that has been auto-linked already.

### Thanks

Thanks to everybody who has filed issues, provided feedback or contributed
patches. Patches courtesy of:

*   At Twitter …
    *   Matt Sanford - http://github.com/mzsanford
    *   Raffi Krikorian - http://github.com/r
    *   Ben Cherry - http://github.com/bcherry
    *   Patrick Ewing - http://github.com/hoverbird
    *   Jeff Smick - http://github.com/sprsquish
    *   Kenneth Kufluk - https://github.com/kennethkufluk
    *   Keita Fujii - https://github.com/keitaf
    *   Yoshimasa Niwa - https://github.com/niw


*   Patches from the community …
    *   Jean-Philippe Bougie - http://github.com/jpbougie
    *   Erik Michaels-Ober - https://github.com/sferik


*   Anyone who has filed an issue. It helps. Really.


### Copyright and License

**Copyright 2011 Twitter, Inc.**

Licensed under the Apache License, Version 2.0:
http://www.apache.org/licenses/LICENSE-2.0
