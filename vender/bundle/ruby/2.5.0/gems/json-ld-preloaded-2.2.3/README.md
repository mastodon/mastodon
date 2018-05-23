# JSON-LD Preloaded
JSON-LD with preloaded contexts.

[![Gem Version](https://badge.fury.io/rb/json-ld-preloaded.png)](http://badge.fury.io/rb/json-ld-preloaded)
[![Build Status](https://secure.travis-ci.org/ruby-rdf/json-ld-preloaded.png?branch=master)](http://travis-ci.org/ruby-rdf/json-ld-preloaded)

## Features

This gem uses the preloading capabilities in `JSON::LD::Context` to create ruby context definitions for common JSON-LD contexts to dramatically reduce processing time when any preloaded context is used in a JSON-LD document. As a consequence, changes made to these contexts after the gem release will not be loaded.

Contexts are taken from https://github.com/json-ld/json-ld.org/wiki/existing-contexts:

* [Linked Open Vocabularies (LOV)](http://lov.okfn.org/dataset/lov/)
 * http://lov.okfn.org/dataset/lov/context
* [Schema.org](http://schema.org)
 * http://schema.org (needs content negotiation)
* [Hydra](http://www.hydra-cg.com/spec/latest/core/)
 * http://www.w3.org/ns/hydra/core
* [LDP](http://www.w3.org/2012/ldp/wiki/Main_Page)
 * [work in progress](http://lists.w3.org/Archives/Public/public-linked-json/2014Jul/0050.html)
* [ActivityStreams 2.0](http://activitystrea.ms)
 *  http://asjsonld.mybluemix.net/
* Open Badges (OBI)
 * https://openbadgespec.org/v1/context.json
 * issues: https://github.com/openbadges/openbadges-specification/issues
* [vCard Ontology](http://www.w3.org/TR/vcard-rdf/)
 * http://www.w3.org/2006/vcard/ns (needs content negotiation)
* [FOAF](http://xmlns.com/foaf/spec/)
 * http://xmlns.com/foaf/context
* [GeoJSON-LD](https://github.com/geojson/geojson-ld)
 * https://raw.githubusercontent.com/geojson/geojson-ld/master/contexts/geojson-base.jsonld
* [IIIF Image API](http://iiif.io/api/image/2/)
 * http://iiif.io/api/image/2/context.json
* [IIIF Presentation API](http://iiif.io/api/presentation/2/)
 * http://iiif.io/api/presentation/2/context.json
* [RDFa Core Initial Context](http://www.w3.org/2011/rdfa-context/rdfa-1.1)
 * http://www.w3.org/2013/json-ld-context/rdfa11
* [Web Payments](https://web-payments.org/)
 * multiple, see specs
* [package.json](https://github.com/digitalbazaar/jsonld.js/issues/39)
* [Research Object Bundle](https://w3id.org/bundle)
 * https://w3id.org/bundle/context
* [prefix.cc](http://prefix.cc)
 * http://prefix.cc/context (and subsets using URLs of the form http://prefix.cc/foaf,rdf,rdfs.file.jsonld)
* CultureGraph EntityFacts
 * http://hub.culturegraph.org/entityfacts/context/v1/entityfacts.jsonld
* [RDF Data Cube](http://purl.org/linked-data/cube#)
 * http://pebbie.org/context/qb
* [CSVW Namespace Vocabulary Terms](https://www.w3.org/TR/tabular-data-model/)
 * https://www.w3.org/ns/csvw

## Examples

    require 'rubygems'
    require 'json/ld/preloaded'
    require 'rdf/turtle'
    require 'rdf/vocab'

    input = JSON.parse %({
      "@context": "http://schema.org/",
      "@id": "https://github.com/ruby-rdf/json-ld-preloaded",
      "@type": "SoftwareApplication",
      "name": "JSON-LD Preloaded",
      "description": "A meta-release of the json-ld gem including preloaded vocabularies.",
      "author": {
        "@id": "http://greggkellogg.net/foaf#me",
        "@type": "Person",
        "name": "Gregg Kellogg"
      }
    })

    RDF::Turtle::Writer.new(STDOUT, standard_prefixes: true) do |w|
      w << JSON::LD::API.toRdf(input)
    end

## Dependencies
* [Ruby](http://ruby-lang.org/) (>= 2.2.2)
* [JSON::LD](http://rubygems.org/gems/json-ld) (>= 2.0.3)

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
