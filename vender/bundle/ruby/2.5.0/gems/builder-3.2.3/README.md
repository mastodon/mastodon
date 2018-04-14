# Project: Builder

## Goal

Provide a simple way to create XML markup and data structures.

## Classes

Builder::XmlMarkup:: Generate XML markup notation
Builder::XmlEvents:: Generate XML events (i.e. SAX-like)

**Notes:**

* An <tt>Builder::XmlTree</tt> class to generate XML tree
  (i.e. DOM-like) structures is also planned, but not yet implemented.
  Also, the events builder is currently lagging the markup builder in
  features.

## Usage

```ruby
  require 'rubygems'
  require_gem 'builder', '~> 2.0'

  builder = Builder::XmlMarkup.new
  xml = builder.person { |b| b.name("Jim"); b.phone("555-1234") }
  xml #=> <person><name>Jim</name><phone>555-1234</phone></person>
```

or

```ruby
  require 'rubygems'
  require_gem 'builder'

  builder = Builder::XmlMarkup.new(:target=>STDOUT, :indent=>2)
  builder.person { |b| b.name("Jim"); b.phone("555-1234") }
  #
  # Prints:
  # <person>
  #   <name>Jim</name>
  #   <phone>555-1234</phone>
  # </person>
```

## Compatibility

### Version 2.0.0 Compatibility Changes

Version 2.0.0 introduces automatically escaped attribute values for
the first time.  Versions prior to 2.0.0 did not insert escape
characters into attribute values in the XML markup.  This allowed
attribute values to explicitly reference entities, which was
occasionally used by a small number of developers.  Since strings
could always be explicitly escaped by hand, this was not a major
restriction in functionality.

However, it did surprise most users of builder.  Since the body text is
normally escaped, everybody expected the attribute values to be
escaped as well.  Escaped attribute values were the number one support
request on the 1.x Builder series.

Starting with Builder version 2.0.0, all attribute values expressed as
strings will be processed and the appropriate characters will be
escaped (e.g. "&" will be translated to "&amp;amp;").  Attribute values
that are expressed as Symbol values will not be processed for escaped
characters and will be unchanged in output. (Yes, this probably counts
as Symbol abuse, but the convention is convenient and flexible).

Example:

```ruby
  xml = Builder::XmlMarkup.new
  xml.sample(:escaped=>"This&That", :unescaped=>:"Here&amp;There")
  xml.target!  =>
    <sample escaped="This&amp;That" unescaped="Here&amp;There"/>
```

### Version 1.0.0 Compatibility Changes

Version 1.0.0 introduces some changes that are not backwards
compatible with earlier releases of builder.  The main areas of
incompatibility are:

* Keyword based arguments to +new+ (rather than positional based).  It
  was found that a developer would often like to specify indentation
  without providing an explicit target, or specify a target without
  indentation.  Keyword based arguments handle this situation nicely.

* Builder must now be an explicit target for markup tags.  Instead of
  writing

```ruby
    xml_markup = Builder::XmlMarkup.new
    xml_markup.div { strong("text") }
```

  you need to write

```ruby
    xml_markup = Builder::XmlMarkup.new
    xml_markup.div { xml_markup.strong("text") }
```

* The builder object is passed as a parameter to all nested markup
  blocks.  This allows you to create a short alias for the builder
  object that can be used within the block.  For example, the previous
  example can be written as:

```ruby
    xml_markup = Builder::XmlMarkup.new
    xml_markup.div { |xml| xml.strong("text") }
```

* If you have both a pre-1.0 and a post-1.0 gem of builder installed,
  you can choose which version to use through the RubyGems
  +require_gem+ facility.

```ruby
    require_gem 'builder', "~> 0.0"   # Gets the old version
    require_gem 'builder', "~> 1.0"   # Gets the new version
```

## Features

* XML Comments are supported ...

```ruby
    xml_markup.comment! "This is a comment"
      #=>  <!-- This is a comment -->
```

* XML processing instructions are supported ...

```ruby
    xml_markup.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      #=>  <?xml version="1.0" encoding="UTF-8"?>
```

  If the processing instruction is omitted, it defaults to "xml".
  When the processing instruction is "xml", the defaults attributes
  are:

  <b>version</b>: 1.0
  <b>encoding</b>: "UTF-8"

  (NOTE: if the encoding is set to "UTF-8" and $KCODE is set to
  "UTF8", then Builder will emit UTF-8 encoded strings rather than
  encoding non-ASCII characters as entities.)

* XML entity declarations are now supported to a small degree.

```ruby
    xml_markup.declare! :DOCTYPE, :chapter, :SYSTEM, "../dtds/chapter.dtd"
      #=>  <!DOCTYPE chapter SYSTEM "../dtds/chapter.dtd">
```

  The parameters to a declare! method must be either symbols or
  strings. Symbols are inserted without quotes, and strings are
  inserted with double quotes.  Attribute-like arguments in hashes are
  not allowed.

  If you need to have an argument to declare! be inserted without
  quotes, but the argument does not conform to the typical Ruby
  syntax for symbols, then use the :"string" form to specify a symbol.

  For example:

```ruby
    xml_markup.declare! :ELEMENT, :chapter, :"(title,para+)"
      #=>  <!ELEMENT chapter (title,para+)>
```

  Nested entity declarations are allowed.  For example:

```ruby
    @xml_markup.declare! :DOCTYPE, :chapter do |x|
      x.declare! :ELEMENT, :chapter, :"(title,para+)"
      x.declare! :ELEMENT, :title, :"(#PCDATA)"
      x.declare! :ELEMENT, :para, :"(#PCDATA)"
    end

    #=>

    <!DOCTYPE chapter [
      <!ELEMENT chapter (title,para+)>
      <!ELEMENT title (#PCDATA)>
      <!ELEMENT para (#PCDATA)>
    ]>
```

* Some support for XML namespaces is now available.  If the first
  argument to a tag call is a symbol, it will be joined to the tag to
  produce a namespace:tag combination.  It is easier to show this than
  describe it.

```ruby
   xml.SOAP :Envelope do ... end
```

  Just put a space before the colon in a namespace to produce the
  right form for builder (e.g. "<tt>SOAP:Envelope</tt>" =>
  "<tt>xml.SOAP :Envelope</tt>")

* String attribute values are <em>now</em> escaped by default by
  Builder (<b>NOTE:</b> this is _new_ behavior as of version 2.0).

  However, occasionally you need to use entities in attribute values.
  Using a symbol (rather than a string) for an attribute value will
  cause Builder to not run its quoting/escaping algorithm on that
  particular value.

  (<b>Note:</b> The +escape_attrs+ option for builder is now
  obsolete).

  Example:

```ruby
    xml = Builder::XmlMarkup.new
    xml.sample(:escaped=>"This&That", :unescaped=>:"Here&amp;There")
    xml.target!  =>
      <sample escaped="This&amp;That" unescaped="Here&amp;There"/>
```

* UTF-8 Support

  Builder correctly translates UTF-8 characters into valid XML.  (New
  in version 2.0.0).  Thanks to Sam Ruby for the translation code.

  You can get UTF-8 encoded output by making sure that the XML
  encoding is set to "UTF-8" and that the $KCODE variable is set to
  "UTF8".

```ruby
    $KCODE = 'UTF8'
    xml = Builder::Markup.new
    xml.instruct!(:xml, :encoding => "UTF-8")
    xml.sample("Iñtërnâtiônàl")
    xml.target!  =>
      "<sample>Iñtërnâtiônàl</sample>"
```

## Links

| Description | Link |
| :----: | :----: |
| Documents           | http://builder.rubyforge.org/ |
| Github Clone        | git://github.com/jimweirich/builder.git |
| Issue / Bug Reports | https://github.com/jimweirich/builder/issues?state=open |

## Contact

| Description | Value                  |
| :----:      | :----:                 |
| Author      | Jim Weirich            |
| Email       | jim.weirich@gmail.com  |
| Home Page   | http://onestepback.org |
| License     | MIT Licence (http://www.opensource.org/licenses/mit-license.html) |
