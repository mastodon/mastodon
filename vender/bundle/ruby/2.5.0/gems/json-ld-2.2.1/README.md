# JSON-LD reader/writer

[JSON-LD][] reader/writer for [RDF.rb][RDF.rb] and fully conforming [JSON-LD API][] processor. Additionally this gem implements [JSON-LD Framing][].

[![Gem Version](https://badge.fury.io/rb/json-ld.png)](http://badge.fury.io/rb/json-ld)
[![Build Status](https://secure.travis-ci.org/ruby-rdf/json-ld.png?branch=master)](http://travis-ci.org/ruby-rdf/json-ld)
[![Coverage Status](https://coveralls.io/repos/ruby-rdf/json-ld/badge.svg)](https://coveralls.io/r/ruby-rdf/json-ld)

## Features

JSON::LD parses and serializes [JSON-LD][] into [RDF][] and implements expansion, compaction and framing API interfaces.

JSON::LD can now be used to create a _context_ from an RDFS/OWL definition, and optionally include a JSON-LD representation of the ontology itself. This is currently accessed through the `script/gen_context` script.

If the [jsonlint][] gem is installed, it will be used when validating an input document.

[Implementation Report](file.earl.html)

Install with `gem install json-ld`

### MultiJson parser
The [MultiJson](https://rubygems.org/gems/multi_json) gem is used for parsing JSON; this defaults to the native JSON parser, but will use a more performant parser if one is available. A specific parser can be specified by adding the `:adapter` option to any API call. See [MultiJson](https://rubygems.org/gems/multi_json) for more information.

### JSON-LD Streaming Profile
This gem implements an optimized streaming writer used for generating JSON-LD from large repositories. Such documents result in the JSON-LD Streaming Profile:

* Each statement written as a separate node in expanded/flattened form.
* RDF Lists are written as separate nodes using `rdf:first` and `rdf:rest` properties.

## Examples

    require 'rubygems'
    require 'json/ld'

### Expand a Document

    input = JSON.parse %({
      "@context": {
        "name": "http://xmlns.com/foaf/0.1/name",
        "homepage": "http://xmlns.com/foaf/0.1/homepage",
        "avatar": "http://xmlns.com/foaf/0.1/avatar"
      },
      "name": "Manu Sporny",
      "homepage": "http://manu.sporny.org/",
      "avatar": "http://twitter.com/account/profile_image/manusporny"
    })
    JSON::LD::API.expand(input) =>
    
    [{
        "http://xmlns.com/foaf/0.1/name": [{"@value"=>"Manu Sporny"}],
        "http://xmlns.com/foaf/0.1/homepage": [{"@value"=>"http://manu.sporny.org/"}], 
        "http://xmlns.com/foaf/0.1/avatar": [{"@value": "http://twitter.com/account/profile_image/manusporny"}]
    }]

### Compact a Document

    input = JSON.parse %([{
        "http://xmlns.com/foaf/0.1/name": ["Manu Sporny"],
        "http://xmlns.com/foaf/0.1/homepage": [{"@id": "http://manu.sporny.org/"}],
        "http://xmlns.com/foaf/0.1/avatar": [{"@id": "http://twitter.com/account/profile_image/manusporny"}]
    }])
    
    context = JSON.parse(%({
      "@context": {
        "name": "http://xmlns.com/foaf/0.1/name",
        "homepage": {"@id": "http://xmlns.com/foaf/0.1/homepage", "@type": "@id"},
        "avatar": {"@id": "http://xmlns.com/foaf/0.1/avatar", "@type": "@id"}
      }
    }))['@context']
    
    JSON::LD::API.compact(input, context) =>
    {
        "@context": {
          "name": "http://xmlns.com/foaf/0.1/name",
          "homepage": {"@id": "http://xmlns.com/foaf/0.1/homepage", "@type": "@id"},
          "avatar": {"@id": "http://xmlns.com/foaf/0.1/avatar", "@type": "@id"}
        },
        "avatar": "http://twitter.com/account/profile_image/manusporny",
        "homepage": "http://manu.sporny.org/",
        "name": "Manu Sporny"
    }

### Frame a Document

    input = JSON.parse %({
      "@context": {
        "Book":         "http://example.org/vocab#Book",
        "Chapter":      "http://example.org/vocab#Chapter",
        "contains":     {"@id": "http://example.org/vocab#contains", "@type": "@id"},
        "creator":      "http://purl.org/dc/terms/creator",
        "description":  "http://purl.org/dc/terms/description",
        "Library":      "http://example.org/vocab#Library",
        "title":        "http://purl.org/dc/terms/title"
      },
      "@graph":
      [{
        "@id": "http://example.com/library",
        "@type": "Library",
        "contains": "http://example.org/library/the-republic"
      },
      {
        "@id": "http://example.org/library/the-republic",
        "@type": "Book",
        "creator": "Plato",
        "title": "The Republic",
        "contains": "http://example.org/library/the-republic#introduction"
      },
      {
        "@id": "http://example.org/library/the-republic#introduction",
        "@type": "Chapter",
        "description": "An introductory chapter on The Republic.",
        "title": "The Introduction"
      }]
    })
    
    frame = JSON.parse %({
      "@context": {
        "Book":         "http://example.org/vocab#Book",
        "Chapter":      "http://example.org/vocab#Chapter",
        "contains":     "http://example.org/vocab#contains",
        "creator":      "http://purl.org/dc/terms/creator",
        "description":  "http://purl.org/dc/terms/description",
        "Library":      "http://example.org/vocab#Library",
        "title":        "http://purl.org/dc/terms/title"
      },
      "@type": "Library",
      "contains": {
        "@type": "Book",
        "contains": {
          "@type": "Chapter"
        }
      }
    })

    JSON::LD::API.frame(input, frame) =>
    {
      "@context": {
        "Book": "http://example.org/vocab#Book",
        "Chapter": "http://example.org/vocab#Chapter",
        "contains": "http://example.org/vocab#contains",
        "creator": "http://purl.org/dc/terms/creator",
        "description": "http://purl.org/dc/terms/description",
        "Library": "http://example.org/vocab#Library",
        "title": "http://purl.org/dc/terms/title"
      },
      "@graph": [
        {
          "@id": "http://example.com/library",
          "@type": "Library",
          "contains": {
            "@id": "http://example.org/library/the-republic",
            "@type": "Book",
            "contains": {
              "@id": "http://example.org/library/the-republic#introduction",
              "@type": "Chapter",
              "description": "An introductory chapter on The Republic.",
              "title": "The Introduction"
            },
            "creator": "Plato",
            "title": "The Republic"
          }
        }
      ]
    }

### Turn JSON-LD into RDF (Turtle)

    input = JSON.parse %({
      "@context": {
        "":       "http://manu.sporny.org/",
        "foaf":   "http://xmlns.com/foaf/0.1/"
      },
      "@id":       "http://example.org/people#joebob",
      "@type":          "foaf:Person",
      "foaf:name":      "Joe Bob",
      "foaf:nick":      { "@list": [ "joe", "bob", "jaybe" ] }
    })
    
    graph = RDF::Graph.new << JSON::LD::API.toRdf(input)

    require 'rdf/turtle'
    graph.dump(:ttl, prefixes: {foaf: "http://xmlns.com/foaf/0.1/"})
    @prefix foaf: <http://xmlns.com/foaf/0.1/> .

    <http://example.org/people#joebob> a foaf:Person;
       foaf:name "Joe Bob";
       foaf:nick ("joe" "bob" "jaybe") .

### Turn RDF into JSON-LD

    require 'rdf/turtle'
    input = RDF::Graph.new << RDF::Turtle::Reader.new(%(
      @prefix foaf: <http://xmlns.com/foaf/0.1/> .

      <http://manu.sporny.org/#me> a foaf:Person;
         foaf:knows [ a foaf:Person;
           foaf:name "Gregg Kellogg"];
         foaf:name "Manu Sporny" .
    ))
    
    context = JSON.parse %({
      "@context": {
        "":       "http://manu.sporny.org/",
        "foaf":   "http://xmlns.com/foaf/0.1/"
      }
    })

    compacted = nil
    JSON::LD::API::fromRdf(input) do |expanded|
      compacted = JSON::LD::API.compact(expanded, context['@context'])
    end
    compacted =>
      [
        {
          "@id": "_:g70265766605380",
          "@type": ["http://xmlns.com/foaf/0.1/Person"],
          "http://xmlns.com/foaf/0.1/name": [{"@value": "Gregg Kellogg"}]
        },
        {
          "@id": "http://manu.sporny.org/#me",
          "@type": ["http://xmlns.com/foaf/0.1/Person"],
          "http://xmlns.com/foaf/0.1/knows": [{"@id": "_:g70265766605380"}],
          "http://xmlns.com/foaf/0.1/name": [{"@value": "Manu Sporny"}]
        }
      ]

## Use a custom Document Loader
In some cases, the built-in document loader {JSON::LD::API.documentLoader} is inadequate; for example, when using `http://schema.org` as a remote context, it will be re-loaded every time.

All entries into the {JSON::LD::API} accept a `:documentLoader` option, which can be used to provide an alternative method to use when loading remote documents. For example:

    def load_document_local(url, options={}, &block)
      if RDF::URI(url, canonicalize: true) == RDF::URI('http://schema.org/')
        remote_document = JSON::LD::API::RemoteDocument.new(url, File.read("etc/schema.org.jsonld"))
        return block_given? ? yield(remote_document) : remote_document
      else
        JSON::LD::API.documentLoader(url, options, &block)
      end
    end

Then, when performing something like expansion:

    JSON::LD::API.expand(input, documentLoader: load_document_local)


## Preloading contexts
In many cases, for small documents, processing time can be dominated by loading and parsing remote contexts. In particular, a small schema.org example may need to download a large context and turn it into an internal representation, before the actual document can be expanded for processing. Using {JSON::LD::Context.add_preloaded}, an implementation can perform this loading up-front, and make it available to the processor.

    ctx = JSON::LD::Context.new().parse('http://schema.org/')
    JSON::LD::Context.add_preloaded('http://schema.org/', ctx)

On lookup, URIs with an `https` prefix are normalized to `http`.

A context may be serialized to Ruby to speed this process using `Context#to_rb`. When loaded, this generated file will add entries to the {JSON::LD::Context::PRELOADED}.

## RDF Reader and Writer
{JSON::LD} also acts as a normal RDF reader and writer, using the standard RDF.rb reader/writer interfaces:

    graph = RDF::Graph.load("etc/doap.jsonld", format: :jsonld)
    graph.dump(:jsonld, standard_prefixes: true)

`RDF::GRAPH#dump` can also take a `:context` option to use a separately defined context

As JSON-LD may come from many different sources, included as an embedded script tag within an HTML document, the RDF Reader will strip input before the leading `{` or `[` and after the trailing `}` or `]`.

## Extensions from JSON-LD 1.0
This implementation is being used as a test-bed for features planned for an upcoming JSON-LD 1.1 Community release.

### Scoped Contexts
A term definition can include `@context`, which is applied to values of that object. This is also used when compacting. Taken together, this allows framing to effectively include context definitions more deeply within the framed structure.

    {
      "@context": {
        "ex": "http://example.com/",
        "foo": {
          "@id": "ex:foo",
          "@type": "@vocab"
          "@context": {
            "Bar": "ex:Bar",
            "Baz": "ex:Baz"
          }
        }
      },
      "foo": "Bar"
    }

### @id and @type maps
The value of `@container` in a term definition can include `@id` or `@type`, in addition to `@set`, `@list`, `@language`, and `@index`. This allows value indexing based on either the `@id` or `@type` of associated objects.

    {
      "@context": {
        "@vocab": "http://example/",
        "idmap": {"@container": "@id"}
      },
      "idmap": {
        "http://example.org/foo": {"label": "Object with @id <foo>"},
        "_:bar": {"label": "Object with @id _:bar"}
      }
    }

### @graph containers and maps
A term can have `@container` set to include `@graph` optionally including `@id` or `@index` and `@set`. In the first form, with `@container` set to `@graph`, the value of a property is treated as a _simple graph object_, meaning that values treated as if they were contained in an object with `@graph`, creating _named graph_ with an anonymous name.

    {
      "@context": {
        "@vocab": "http://example.org/",
        "input": {"@container": "@graph"}
      },
      "input": {
        "value": "x"
      }
    }

which expands to the following:

    [{
      "http://example.org/input": [{
        "@graph": [{
          "http://example.org/value": [{"@value": "x"}]
        }]
      }]
    }]

Compaction reverses this process, optionally ensuring that a single value is contained within an array of `@container` also includes `@set`:

    {
      "@context": {
        "@vocab": "http://example.org/",
        "input": {"@container": ["@graph", "@set"]}
      }
    }

A graph map uses the map form already existing for `@index`, `@language`, `@type`, and `@id` where the index is either an index value or an id.

    {
      "@context": {
        "@vocab": "http://example.org/",
        "input": {"@container": ["@graph", "@index"]}
      },
      "input": {
        "g1": {"value": "x"}
      }
    }

treats "g1" as an index, and expands to the following:

    [{
      "http://example.org/input": [{
        "@index": "g1",
        "@graph": [{
          "http://example.org/value": [{"@value": "x"}]
        }]
      }]
    }])

This can also include `@set` to ensure that, when compacting, a single value of an index will be in array form.

The _id_ version is similar:

    {
      "@context": {
        "@vocab": "http://example.org/",
        "input": {"@container": ["@graph", "@id"]}
      },
      "input": {
        "http://example.com/g1": {"value": "x"}
      }
    }

which expands to:

    [{
      "http://example.org/input": [{
        "@id": "http://example.com/g1",
        "@graph": [{
          "http://example.org/value": [{"@value": "x"}]
        }]
      }]
    }])

### Transparent Nesting
Many JSON APIs separate properties from their entities using an intermediate object. For example, a set of possible labels may be grouped under a common property:

    {
      "@context": {
        "skos": "http://www.w3.org/2004/02/skos/core#",
        "labels": "@nest",
        "main_label": {"@id": "skos:prefLabel"},
        "other_label": {"@id": "skos:altLabel"},
        "homepage": {"@id":"http://schema.org/description", "@type":"@id"}
      },
      "@id":"http://example.org/myresource",
      "homepage": "http://example.org",
      "labels": {
         "main_label": "This is the main label for my resource",
         "other_label": "This is the other label"
      }
    }
 
 In this case, the `labels` property is semantically meaningless. Defining it as equivalent to `@nest` causes it to be ignored when expanding, making it equivalent to the following:

    {
      "@context": {
        "skos": "http://www.w3.org/2004/02/skos/core#",
        "labels": "@nest",
        "main_label": {"@id": "skos:prefLabel"},
        "other_label": {"@id": "skos:altLabel"},
        "homepage": {"@id":"http://schema.org/description", "@type":"@id"}
      },
      "@id":"http://example.org/myresource",
      "homepage": "http://example.org",
      "main_label": "This is the main label for my resource",
      "other_label": "This is the other label"
    }
 
 Similarly, properties may be marked with "@nest": "nest-term", to cause them to be nested. Note that the `@nest` keyword can also be aliased in the context.

     {
       "@context": {
         "skos": "http://www.w3.org/2004/02/skos/core#",
         "labels": "@nest",
         "main_label": {"@id": "skos:prefLabel", "@nest": "labels"},
         "other_label": {"@id": "skos:altLabel", "@nest": "labels"},
         "homepage": {"@id":"http://schema.org/description", "@type":"@id"}
       },
       "@id":"http://example.org/myresource",
       "homepage": "http://example.org",
       "labels": {
          "main_label": "This is the main label for my resource",
          "other_label": "This is the other label"
       }
     }

In this way, nesting survives round-tripping through expansion, and framed output can include nested properties.

### Framing Updates
The [JSON-LD Framing 1.1 Specification]() improves on previous un-released versions.

* [More Specific Frame matching](https://github.com/json-ld/json-ld.org/issues/110) – Allows framing to extend to elements of value objects, and objects are matched through recursive frame matching. `{}` is used as a wildcard, and `[]` as matching nothing.
* [Graph framing](https://github.com/json-ld/json-ld.org/issues/118) – previously, only the merged graph can be framed, this update allows arbitrary graphs to be framed.
  * Use `@graph` in frame, matches the default graph, not the merged graph.
  * Use `@graph` in property value, causes the apropriatly named graph to be used for filling in values.
* [Reverse properties](https://github.com/json-ld/json-ld.org/issues/311) – `@reverse` (or a property defined with `@reverse`) can cause matching values to be included, allowing a matched object to include reverse references to any objects referencing it.
* [@omitDefault behavior](https://github.com/json-ld/json-ld.org/issues/389) – In addition to `true` and `false`, `@omitDefault` can take `@last`, `@always`, `@never`, and `@link`.
* [multiple `@id` matching](https://github.com/json-ld/json-ld.org/issues/424) – A frame can match based on one or more specific object `@id` values.

## Documentation
Full documentation available on [RubyDoc](http://rubydoc.info/gems/json-ld/file/README.md)

## Differences from [JSON-LD API][]
The specified JSON-LD API is based on a WebIDL definition implementing [Promises][] intended for use within a browser.
This version implements a more Ruby-like variation of this API without the use
of promises or callback arguments, preferring Ruby blocks. All API methods
execute synchronously, so that the return from a method can typically be used as well as a block.

Note, the API method signatures differed in versions before 1.0, in that they also had a callback parameter. And 1.0.6 has some other minor method signature differences than previous versions. This should be the only exception to the use of semantic versioning.

### Principal Classes
* {JSON::LD}
  * {JSON::LD::API}
  * {JSON::LD::Compact}
  * {JSON::LD::Context}
  * {JSON::LD::Format}
  * {JSON::LD::Frame}
  * {JSON::LD::FromRDF}
  * {JSON::LD::Reader}
  * {JSON::LD::ToRDF}
  * {JSON::LD::Writer}

## Dependencies
* [Ruby](http://ruby-lang.org/) (>= 2.2.2)
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 2.2)
* [JSON](https://rubygems.org/gems/json) (>= 1.5)

## Installation
The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `JSON-LD` gem, do:

    % [sudo] gem install json-ld

## Download
To get a local working copy of the development repository, do:

    % git clone git://github.com/ruby-rdf/json-ld.git

## Mailing List
* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

## Author
* [Gregg Kellogg](http://github.com/gkellogg) - <http://kellogg-assoc.com/>

## Contributing
* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `json-ld.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Ruby]:             http://ruby-lang.org/
[RDF]:              http://www.w3.org/RDF/
[YARD]:             http://yardoc.org/
[YARD-GS]:          http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:              http://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
[RDF.rb]:           http://rubygems.org/gems/rdf
[Backports]:        http://rubygems.org/gems/backports
[JSON-LD]:          http://www.w3.org/TR/json-ld/ "JSON-LD 1.0"
[JSON-LD API]:      http://www.w3.org/TR/json-ld-api/ "JSON-LD 1.0 Processing Algorithms and API"
[JSON-LD Framing]:  http://json-ld.org/spec/latest/json-ld-framing/ "JSON-LD Framing 1.0"
[Promises]:         http://dom.spec.whatwg.org/#promises
[jsonlint]:         https://rubygems.org/gems/jsonlint
