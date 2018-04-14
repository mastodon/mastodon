# Loofah

* https://github.com/flavorjones/loofah
* http://rubydoc.info/github/flavorjones/loofah/master/frames
* http://librelist.com/browser/loofah

## Status

|System|Status|
|--|--|
| Concourse | [![Concourse CI](https://ci.nokogiri.org/api/v1/teams/nokogiri-core/pipelines/loofah/jobs/ruby-2.5/badge)](https://ci.nokogiri.org/teams/nokogiri-core/pipelines/loofah?groups=master) |
| Code Climate | [![Code Climate](https://codeclimate.com/github/flavorjones/loofah.svg)](https://codeclimate.com/github/flavorjones/loofah) |
| Version Eye | [![Version Eye](https://www.versioneye.com/ruby/loofah/badge.png)](https://www.versioneye.com/ruby/loofah) |


## Description

Loofah is a general library for manipulating and transforming HTML/XML
documents and fragments. It's built on top of Nokogiri and libxml2, so
it's fast and has a nice API.

Loofah excels at HTML sanitization (XSS prevention). It includes some
nice HTML sanitizers, which are based on HTML5lib's whitelist, so it
most likely won't make your codes less secure. (These statements have
not been evaluated by Netexperts.)

ActiveRecord extensions for sanitization are available in the
[`loofah-activerecord` gem](https://github.com/flavorjones/loofah-activerecord).


## Features

* Easily write custom scrubbers for HTML/XML leveraging the sweetness of Nokogiri (and HTML5lib's whitelists).
* Common HTML sanitizing tasks are built-in:
  * _Strip_ unsafe tags, leaving behind only the inner text.
  * _Prune_ unsafe tags and their subtrees, removing all traces that they ever existed.
  * _Escape_ unsafe tags and their subtrees, leaving behind lots of <tt>&lt;</tt> and <tt>&gt;</tt> entities.
  * _Whitewash_ the markup, removing all attributes and namespaced nodes.
* Common HTML transformation tasks are built-in:
  * Add the _nofollow_ attribute to all hyperlinks.
* Format markup as plain text, with or without sensible whitespace handling around block elements.
* Replace Rails's `strip_tags` and `sanitize` view helper methods.


## Compare and Contrast

Loofah is one of two known Ruby XSS/sanitization solutions that
guarantees well-formed and valid markup (the other is Sanitize, which
also uses Nokogiri).

Loofah works on XML, XHTML and HTML documents.

Also, it's pretty fast. Here is a benchmark comparing Loofah to other
commonly-used libraries (ActionView, Sanitize, HTML5lib and HTMLfilter):

* https://gist.github.com/170193

Lastly, Loofah is extensible. It's super-easy to write your own custom
scrubbers for whatever document manipulation you need. You don't like
the built-in scrubbers? Build your own, like a boss.


## The Basics

Loofah wraps [Nokogiri](http://nokogiri.org) in a loving
embrace. Nokogiri is an excellent HTML/XML parser. If you don't know
how Nokogiri works, you might want to pause for a moment and go check
it out. I'll wait.

Loofah presents the following classes:

* `Loofah::HTML::Document` and `Loofah::HTML::DocumentFragment`
* `Loofah::XML::Document` and `Loofah::XML::DocumentFragment`
* `Loofah::Scrubber`

The documents and fragments are subclasses of the similar Nokogiri classes.

The Scrubber represents the document manipulation, either by wrapping
a block,

``` ruby
span2div = Loofah::Scrubber.new do |node|
  node.name = "div" if node.name == "span"
end
```

or by implementing a method.


### Side Note: Fragments vs Documents

Generally speaking, unless you expect to have a DOCTYPE and a single
root node, you don't have a *document*, you have a *fragment*. For
HTML, another rule of thumb is that *documents* have `html` and `body`
tags, and *fragments* usually do not.

HTML fragments should be parsed with Loofah.fragment. The result won't
be wrapped in `html` or `body` tags, won't have a DOCTYPE declaration,
`head` elements will be silently ignored, and multiple root nodes are
allowed.

XML fragments should be parsed with Loofah.xml_fragment. The result
won't have a DOCTYPE declaration, and multiple root nodes are allowed.

HTML documents should be parsed with Loofah.document. The result will
have a DOCTYPE declaration, along with `html`, `head` and `body` tags.

XML documents should be parsed with Loofah.xml_document. The result
will have a DOCTYPE declaration and a single root node.


### Loofah::HTML::Document and Loofah::HTML::DocumentFragment

These classes are subclasses of Nokogiri::HTML::Document and
Nokogiri::HTML::DocumentFragment, so you get all the markup
fixer-uppery and API goodness of Nokogiri.

The module methods Loofah.document and Loofah.fragment will parse an
HTML document and an HTML fragment, respectively.

``` ruby
Loofah.document(unsafe_html).is_a?(Nokogiri::HTML::Document)         # => true
Loofah.fragment(unsafe_html).is_a?(Nokogiri::HTML::DocumentFragment) # => true
```

Loofah injects a `scrub!` method, which takes either a symbol (for
built-in scrubbers) or a Loofah::Scrubber object (for custom
scrubbers), and modifies the document in-place.

Loofah overrides `to_s` to return HTML:

``` ruby
unsafe_html = "ohai! <div>div is safe</div> <script>but script is not</script>"

doc = Loofah.fragment(unsafe_html).scrub!(:prune)
doc.to_s    # => "ohai! <div>div is safe</div> "
```

and `text` to return plain text:

``` ruby
doc.text    # => "ohai! div is safe "
```

Also, `to_text` is available, which does the right thing with
whitespace around block-level elements.

``` ruby
doc = Loofah.fragment("<h1>Title</h1><div>Content</div>")
doc.text    # => "TitleContent"           # probably not what you want
doc.to_text # => "\nTitle\n\nContent\n"   # better
```

### Loofah::XML::Document and Loofah::XML::DocumentFragment

These classes are subclasses of Nokogiri::XML::Document and
Nokogiri::XML::DocumentFragment, so you get all the markup
fixer-uppery and API goodness of Nokogiri.

The module methods Loofah.xml_document and Loofah.xml_fragment will
parse an XML document and an XML fragment, respectively.

``` ruby
Loofah.xml_document(bad_xml).is_a?(Nokogiri::XML::Document)         # => true
Loofah.xml_fragment(bad_xml).is_a?(Nokogiri::XML::DocumentFragment) # => true
```

### Nodes and NodeSets

Nokogiri::XML::Node and Nokogiri::XML::NodeSet also get a `scrub!`
method, which makes it easy to scrub subtrees.

The following code will apply the `employee_scrubber` only to the
`employee` nodes (and their subtrees) in the document:

``` ruby
Loofah.xml_document(bad_xml).xpath("//employee").scrub!(employee_scrubber)
```

And this code will only scrub the first `employee` node and its subtree:

``` ruby
Loofah.xml_document(bad_xml).at_xpath("//employee").scrub!(employee_scrubber)
```

### Loofah::Scrubber

A Scrubber wraps up a block (or method) that is run on a document node:

``` ruby
# change all <span> tags to <div> tags
span2div = Loofah::Scrubber.new do |node|
  node.name = "div" if node.name == "span"
end
```

This can then be run on a document:

``` ruby
Loofah.fragment("<span>foo</span><p>bar</p>").scrub!(span2div).to_s
# => "<div>foo</div><p>bar</p>"
```

Scrubbers can be run on a document in either a top-down traversal (the
default) or bottom-up. Top-down scrubbers can optionally return
Scrubber::STOP to terminate the traversal of a subtree. Read below and
in the Loofah::Scrubber class for more detailed usage.

Here's an XML example:

``` ruby
# remove all <employee> tags that have a "deceased" attribute set to true
bring_out_your_dead = Loofah::Scrubber.new do |node|
  if node.name == "employee" and node["deceased"] == "true"
    node.remove
    Loofah::Scrubber::STOP # don't bother with the rest of the subtree
  end
end
Loofah.xml_document(File.read('plague.xml')).scrub!(bring_out_your_dead)
```

=== Built-In HTML Scrubbers

Loofah comes with a set of sanitizing scrubbers that use HTML5lib's
whitelist algorithm:

``` ruby
doc.scrub!(:strip)       # replaces unknown/unsafe tags with their inner text
doc.scrub!(:prune)       #  removes unknown/unsafe tags and their children
doc.scrub!(:escape)      #  escapes unknown/unsafe tags, like this: &lt;script&gt;
doc.scrub!(:whitewash)   #  removes unknown/unsafe/namespaced tags and their children,
                         #          and strips all node attributes
```

Loofah also comes with some common transformation tasks: 

``` ruby
doc.scrub!(:nofollow)    #     adds rel="nofollow" attribute to links
doc.scrub!(:unprintable) #  removes unprintable characters from text nodes
```

See Loofah::Scrubbers for more details and example usage.


### Chaining Scrubbers

You can chain scrubbers:

``` ruby
Loofah.fragment("<span>hello</span> <script>alert('OHAI')</script>") \
      .scrub!(:prune) \
      .scrub!(span2div).to_s
# => "<div>hello</div> "
```

### Shorthand

The class methods Loofah.scrub_fragment and Loofah.scrub_document are
shorthand.

``` ruby
Loofah.scrub_fragment(unsafe_html, :prune)
Loofah.scrub_document(unsafe_html, :prune)
Loofah.scrub_xml_fragment(bad_xml, custom_scrubber)
Loofah.scrub_xml_document(bad_xml, custom_scrubber)
```

are the same thing as (and arguably semantically clearer than):

``` ruby
Loofah.fragment(unsafe_html).scrub!(:prune)
Loofah.document(unsafe_html).scrub!(:prune)
Loofah.xml_fragment(bad_xml).scrub!(custom_scrubber)
Loofah.xml_document(bad_xml).scrub!(custom_scrubber)
```


### View Helpers

Loofah has two "view helpers": Loofah::Helpers.sanitize and
Loofah::Helpers.strip_tags, both of which are drop-in replacements for
the Rails ActionView helpers of the same name.
These are no longer required automatically. You must require `loofah/helpers`. 


## Requirements

* Nokogiri >= 1.5.9


## Installation

Unsurprisingly:

* gem install loofah


## Support

The bug tracker is available here:

* https://github.com/flavorjones/loofah/issues

And the mailing list is on librelist:

* loofah@librelist.com / http://librelist.com

And the IRC channel is \#loofah on freenode.


## Security

See [`SECURITY.md`](SECURITY.md) for vulnerability reporting details.


### "Secure by Default"

Some tools may incorrectly report Loofah as a potential security
vulnerability.

Loofah depends on Nokogiri, and it's _possible_ to use Nokogiri in a
dangerous way (by enabling its DTDLOAD option and disabling its NONET
option). This specifically allows the opportunity for an XML External
Entity (XXE) vulnerability if the XML data is untrusted.

However, Loofah __never enables this Nokogiri configuration__; Loofah
never enables DTDLOAD, and it never disables NONET, thereby protecting
you by default from this XXE vulnerability.


## Related Links

* Nokogiri: http://nokogiri.org
* libxml2: http://xmlsoft.org
* html5lib: https://code.google.com/p/html5lib


## Authors

* [Mike Dalessio](http://mike.daless.io) ([@flavorjones](https://twitter.com/flavorjones))
* Bryan Helmkamp

Featuring code contributed by:

* Aaron Patterson
* John Barnette
* Josh Owens
* Paul Dix
* Luke Melia

And a big shout-out to Corey Innis for the name, and feedback on the API.


## Thank You

The following people have generously donated via the [Pledgie](http://pledgie.com) badge on the [Loofah github page](https://github.com/flavorjones/loofah):

* Bill Harding


## Historical Note

This library was formerly known as Dryopteris, which was a very bad
name that nobody could spell properly.


## License

Distributed under the MIT License. See `MIT-LICENSE.txt` for details.
