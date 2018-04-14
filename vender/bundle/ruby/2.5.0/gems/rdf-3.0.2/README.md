# RDF.rb: Linked Data for Ruby

This is a pure-Ruby library for working with [Resource Description Framework
(RDF)][RDF] data.

* <http://ruby-rdf.github.com/rdf>
* <http://blog.datagraph.org/2010/12/rdf-for-ruby>
* <http://blog.datagraph.org/2010/03/rdf-for-ruby>
* <http://blog.datagraph.org/2010/04/parsing-rdf-with-ruby>
* <http://blog.datagraph.org/2010/04/rdf-repository-howto>

[![Gem Version](https://badge.fury.io/rb/rdf.png)](http://badge.fury.io/rb/rdf)
[![Build Status](https://travis-ci.org/ruby-rdf/rdf.png?branch=master)](http://travis-ci.org/ruby-rdf/rdf)
[![Coverage Status](https://coveralls.io/repos/ruby-rdf/rdf/badge.svg)](https://coveralls.io/r/ruby-rdf/rdf)
[![Join the chat at https://gitter.im/ruby-rdf/rdf](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ruby-rdf/rdf?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Features

* 100% pure Ruby with minimal dependencies and no bloat.
* Fully compatible with [RDF 1.1][] specifications.
* 100% free and unencumbered [public domain](http://unlicense.org/) software.
* Provides a clean, well-designed RDF object model and related APIs.
* Supports parsing and serializing [N-Triples][] and [N-Quads][] out of the box, with more
  serialization format support available through add-on extensions.
* Includes in-memory graph and repository implementations, with more storage
  adapter support available through add-on extensions.
* Implements basic graph pattern (BGP) query evaluation.
* Plays nice with others: entirely contained in the `RDF` module, and does
  not modify any of Ruby's core classes or standard library.
* Based entirely on Ruby's autoloading, meaning that you can generally make
  use of any one part of the library without needing to load up the rest.
* Compatible with Ruby Ruby >= 2.2.2, Rubinius and JRuby 9.0+.
* Performs auto-detection of input to select appropriate Reader class if one
  cannot be determined from file characteristics.

### HTTP requests

RDF.rb uses `Net::HTTP` for retrieving HTTP and HTTPS resources. If the
[RestClient][] gem is included, that will be used instead to retrieve remote
resources. Clients may also consider using [RestClient Components][] to enable
client-side caching of HTTP results using [Rack::Cache][] or other Rack
middleware.

## Differences between RDF 1.0 and RDF 1.1

This version of RDF.rb is fully compatible with [RDF 1.1][], but it creates some
marginal incompatibilities with [RDF 1.0][], as implemented in versions prior to
the 1.1 release of RDF.rb:

* Introduces {RDF::IRI}, as a synonym for {RDF::URI} either {RDF::IRI} or {RDF::URI} can be used interchangeably. Versions of RDF.rb prior to the 1.1 release were already compatible with IRIs. Internationalized Resource Identifiers (see [RFC3987][]) are a super-set of URIs (see [RFC3986][]) which allow for characters other than standard US-ASCII.
* {RDF::URI} no longer uses the `Addressable` gem. As URIs typically don't need to be parsed, this provides a substantial performance improvement when enumerating or querying graphs and repositories.
* {RDF::List} no longer emits a `rdf:List` type. However, it will now recognize any subjects that are {RDF::Node} instances as being list elements, as long as they have both `rdf:first` and `rdf:rest` predicates.
* {RDF::Graph} adding a `graph_name` to a graph may only be done when the underlying storage model supports graph_names (the default {RDF::Repository} does). The notion of `graph_name` in RDF.rb is treated equivalently to [Named Graphs](http://www.w3.org/TR/rdf11-concepts/#dfn-named-graph) within an RDF Dataset, and graphs on their own are not named.
* {RDF::Graph}, {RDF::Statement} and {RDF::List} now include {RDF::Value}, and not {RDF::Resource}. Made it clear that using {RDF::Graph} does not mean that it may be used within an {RDF::Statement}, for this see {RDF::Term}.
* {RDF::Statement} now is stricter about checking that all elements are valid when validating.
* {RDF::NTriples::Writer} and {RDF::NQuads::Writer} now default to validate output, only allowing valid statements to be emitted. This may disabled by setting the `:validate` option to `false`.
* {RDF::Dataset} is introduced as a class alias of {RDF::Repository}. This allows closer alignment to the RDF concept of [Dataset](http://www.w3.org/TR/rdf11-concepts/#dfn-dataset).
* The `graph_name` of a graph within a Dataset or Repository may be either an {RDF::IRI} or {RDF::Node}. Implementations of repositories may restrict this to being only {RDF::IRI}.
* There are substantial and somewhat incompatible changes to {RDF::Literal}. In [RDF 1.1][], all literals are typed, including plain literals and language tagged literals. Internally, plain literals are given the `xsd:string` datatype and language tagged literals are given the `rdf:langString` datatype. Creating a plain literal, without a datatype or language, will automatically provide the `xsd:string` datatype; similar for language tagged literals. Note that most serialization formats will remove this datatype. Code which depends on a literal having the `xsd:string` datatype being different from a plain literal (formally, without a datatype) may break. However note that the `#has\_datatype?` will continue to return `false` for plain or language-tagged literals.
* {RDF::Query#execute} now accepts a block and returns {RDF::Query::Solutions}. This allows `enumerable.query(query)` to behave like `query.execute(enumerable)` and either return an enumerable or yield each solution.
* {RDF::Queryable#query} now returns {RDF::Query::Solutions} instead of an Enumerator if it's argument is an {RDF::Query}.
* {RDF::Util::File.open\_file} now performs redirects and manages `base_uri` based on W3C recommendations:
  * `base_uri` is set to the original URI if a status 303 is provided, otherwise any other redirect will set `base_uri` to the redirected location.
  * `base_uri` is set to the content of the `Location` header if status is _success_.
* Additionally, {RDF::Util::File.open\_file} sets the result encoding from `charset` if provided, defaulting to `UTF-8`. Other access methods include `last_modified` and `content_type`, 
* {RDF::StrictVocabulary} added with an easy way to keep vocabulary definitions up to date based on their OWL or RDFS definitions. Most vocabularies are now StrictVocabularies meaning that an attempt to resolve a particular term in that vocabulary will error if the term is not defined in the vocabulary.
* New vocabulary definitions have been added for [ICal](http://www.w3.org/2002/12/cal/icaltzd#), [Media Annotations (MA)](http://www.w3.org/ns/ma-ont#), [Facebook OpenGraph (OG)](http://ogp.me/ns#), [PROV](http://www.w3.org/ns/prov#), [SKOS-XL (SKOSXL)](http://www.w3.org/2008/05/skos-xl#), [Data Vocabulary (V)](http://rdf.data-vocabulary.org/), [VCard](http://www.w3.org/2006/vcard/ns#), [VOID](http://rdfs.org/ns/void#http://rdfs.org/ns/void#), [Powder-S (WDRS)](http://www.w3.org/2007/05/powder-s#), and [XHV](http://www.w3.org/1999/xhtml/vocab#).

Notably, {RDF::Queryable#query} and {RDF::Query#execute} are now completely symmetric; this allows an implementation of {RDF::Queryable} to optimize queries using implementation-specific logic, allowing for substantial performance improvements when executing BGP queries.

## Tutorials

* [Getting data from the Semantic Web using Ruby and RDF.rb](http://semanticweb.org/wiki/Getting_data_from_the_Semantic_Web_%28Ruby%29)
* [Using RDF.rb and Spira to process RDF data from the British Ordnance Survey](http://stephenpope.co.uk/?p=85)
* [Getting started with RDF and SPARQL using 4store and RDF.rb](http://www.jenitennison.com/blog/node/152)

## Command Line
When installed, RDF.rb includes a `rdf` shell script which acts as a wrapper to perform a number of different
operations on RDF files using available readers and writers.

* `count`: Parse and RDF input and count the number of statements.
* `predicates`: Returns unique objects from parsed input.
* `objects`: Returns unique objects from parsed input.
* `serialize`: Parse an RDF input and re-serializing to [N-Triples][] or another available format using `--output-format` option.
* `subjects`: Returns unique subjects from parsed input.

The `serialize` command can also be used to serialize as a vocabulary.

Different RDF gems will augment the `rdf` script with more capabilities, which may require specifying the appropriate `--input-format` option to revel.

## Examples

    require 'rdf'
    include RDF

### Writing RDF data using the [N-Triples][] format

    require 'rdf/ntriples'
    graph = RDF::Graph.new << [:hello, RDF::RDFS.label, "Hello, world!"]
    graph.dump(:ntriples)
    
or

    RDF::Writer.open("hello.nt") { |writer| writer << graph }

### Reading RDF data in the [N-Triples][] format

    require 'rdf/ntriples'
    graph = RDF::Graph.load("http://ruby-rdf.github.com/rdf/etc/doap.nt")
    
or

    RDF::Reader.open("http://ruby-rdf.github.com/rdf/etc/doap.nt") do |reader|
      reader.each_statement do |statement|
        puts statement.inspect
      end
    end

### Reading RDF data in other formats
{RDF::Reader.open} and {RDF::Repository.load} use a number of mechanisms to determine the appropriate reader
to use when loading a file. The specific format to use can be forced using, e.g. `format: :ntriples`
option where the specific format symbol is determined by the available readers. Both also use
MimeType or file extension, where available.

    require 'rdf/nquads'
    
    graph = RDF::Graph.load("http://ruby-rdf.github.com/rdf/etc/doap.nq", format: :nquads)

A specific sub-type of Reader can also be invoked directly:

    require 'rdf/nquads'
    
    RDF::NQuads::Reader.open("http://ruby-rdf.github.com/rdf/etc/doap.nq") do |reader|
      reader.each_statement do |statement|
        puts statement.inspect
      end
    end

Reader/Writer implementations may override {RDF::Format.detect}, which takes a small sample if input
and return a boolean indicating if it matches that specific format. In the case that a format cannot
be detected from filename or other options, or that more than one format is identified,
{RDF::Format.for} will query each loaded format by invoking it's `detect` method, and the first successful
match will be used to read the input.

### Writing RDF data using other formats
{RDF::Writer.open}, {RDF::Enumerable#dump}, {RDF::Writer.dump} take similar options to {RDF::Reader.open} to determine the
appropriate writer to use.

    require 'linkeddata'

    RDF::Writer.open("hello.nq", format: :nquads) do |writer|
      writer << RDF::Repository.new do |repo|
        repo << RDF::Statement.new(:hello, RDF::RDFS.label, "Hello, world!", graph_name: RDF::URI("http://example/graph_name"))
      end
    end

A specific sub-type of Writer can also be invoked directly:

    require 'rdf/nquads'

    repo = RDF::Repository.new << RDF::Statement.new(:hello, RDF::RDFS.label, "Hello, world!", graph_name: RDF::URI("http://example/graph_name"))
    File.open("hello.nq", "w") {|f| f << repo.dump(:nquads)}

## Reader/Writer convenience methods
{RDF::Enumerable} implements `to_{format}` for each available instance of {RDF::Reader}.
For example, if `rdf/turtle` is loaded, this allows the following:

    graph = RDF::Graph.new << [:hello, RDF::RDFS.label, "Hello, world!"]
    graph.to_ttl

Similarly, {RDF::Mutable} implements `from_{format}` for each available instance
of {RDF::Writer}. For example:

    graph = RDF::Graph.new
    graph.from_ttl("[ a <http://www.w3.org/1999/02/22-rdf-syntax-ns#Resource>]")

Note that no prefixes are loaded automatically, however they can be provided as arguments:

    graph.from_ttl("[ a rdf:Resource]", prefixes: {rdf: RDF.to_uri})

### Querying RDF data using basic graph patterns (BGPs)

    require 'rdf/ntriples'
    
    graph = RDF::Graph.load("http://ruby-rdf.github.com/rdf/etc/doap.nt")
    query = RDF::Query.new({
      person: {
        RDF.type  => FOAF.Person,
        FOAF.name => :name,
        FOAF.mbox => :email,
      }
    })
    
    query.execute(graph) do |solution|
      puts "name=#{solution.name} email=#{solution.email}"
    end

The same query may also be run from the graph:

    graph.query(query) do |solution|
      puts "name=#{solution.name} email=#{solution.email}"
    end

In general, querying from using the `queryable` instance allows a specific implementation of `queryable` to perform query optimizations specific to the datastore on which it is based.

A separate [SPARQL][SPARQL doc] gem builds on basic BGP support to provide full support for [SPARQL 1.0](http://www.w3.org/TR/rdf-sparql-query/) queries.

### Using pre-defined RDF vocabularies

    DC.title      #=> RDF::URI("http://purl.org/dc/terms/title")
    FOAF.knows    #=> RDF::URI("http://xmlns.com/foaf/0.1/knows")
    RDF.type      #=> RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
    RDFS.seeAlso  #=> RDF::URI("http://www.w3.org/2000/01/rdf-schema#seeAlso")
    RSS.title     #=> RDF::URI("http://purl.org/rss/1.0/title")
    OWL.sameAs    #=> RDF::URI("http://www.w3.org/2002/07/owl#sameAs")
    XSD.dateTime  #=> RDF::URI("http://www.w3.org/2001/XMLSchema#dateTime")

### Using ad-hoc RDF vocabularies

    foaf = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
    foaf.knows    #=> RDF::URI("http://xmlns.com/foaf/0.1/knows")
    foaf[:name]   #=> RDF::URI("http://xmlns.com/foaf/0.1/name")
    foaf['mbox']  #=> RDF::URI("http://xmlns.com/foaf/0.1/mbox")

## Documentation

<http://rubydoc.info/github/ruby-rdf/rdf/frames>

### RDF Object Model

<http://blog.datagraph.org/2010/03/rdf-for-ruby>

* {RDF::Value}
  * {RDF::Term}
    * {RDF::Literal}
      * {RDF::Literal::Boolean}
      * {RDF::Literal::Date}
      * {RDF::Literal::DateTime}
      * {RDF::Literal::Decimal}
      * {RDF::Literal::Double}
      * {RDF::Literal::Integer}
      * {RDF::Literal::Time}
      * [RDF::XSD](http://rubydoc.info/github/gkellogg/rdf-xsd/master/frames) (extension)
    * {RDF::Resource}
      * {RDF::Node}
      * {RDF::URI}
  * {RDF::List}
  * {RDF::Graph}
  * {RDF::Statement}

### RDF Serialization

<http://blog.datagraph.org/2010/04/parsing-rdf-with-ruby>

* {RDF::Format}
* {RDF::Reader}
* {RDF::Writer}

### RDF Serialization Formats

The following is a partial list of RDF formats implemented either natively, or through the inclusion of
other gems:

* {RDF::NTriples}
* {RDF::NQuads}
* [JSON::LD][] (extension)
* [RDF::JSON][] (extension)
* [RDF::Microdata][] (extension)
* [RDF::N3][] (extension)
* [RDF::Raptor::RDFXML](http://ruby-rdf.github.io/rdf-raptor) (extension)
* [RDF::Raptor::Turtle](http://ruby-rdf.github.io/rdf-raptor) (extension)
* [RDF::RDFa][] (extension)
* [RDF::RDFXML][] (extension)
* [RDF::TriG][] (extension)
* [RDF::TriX][] (extension)
* [RDF::Turtle][] (extension)

The meta-gem [LinkedData][LinkedData doc] includes many of these gems.

### RDF Datatypes

RDF.rb only implements core datatypes from the
[RDF Datatype Map](http://www.w3.org/TR/rdf11-concepts/#datatype-maps). Most other
XSD and RDF datatype implementations can be find in the following:

* {RDF::XSD}

### Graph Isomorphism

Two graphs may be compared with each other to determine if they are _isomorphic_.
As BNodes within two different graphs are no equal, graphs may not be directly compared.
The `RDF::Isomorphic` gem may be used to determine if they make the same statements, aside
from BNode identity (i.e., they each entail the other)

* `RDF::Isomorphic`

### RDF Storage

<http://blog.datagraph.org/2010/04/rdf-repository-howto>

* {RDF::Repository}
  * {RDF::Countable}
  * {RDF::Enumerable}
  * {RDF::Indexable}
  * {RDF::Queryable}
  * {RDF::Mutable}
  * {RDF::Durable}
* {RDF::Transaction}
* [RDF::AllegroGraph](http://rubydoc.info/github/ruby-rdf/rdf-agraph) (extension)
* [RDF::Mongo](http://rubydoc.info/github/ruby-rdf/rdf-mongo) (extension)
* [RDF::DataObjects](http://rubydoc.info/github/ruby-rdf/rdf-do) (extension)
* [RDF::Sesame](http://www.rubydoc.info/github/ruby-rdf/rdf-sesame) (extension)

### RDF Querying

* {RDF::Query}
  * {RDF::Query::HashPatternNormalizer}
  * {RDF::Query::Pattern}
  * {RDF::Query::Solution}
  * {RDF::Query::Solutions}
  * {RDF::Query::Variable}
* [SPARQL](http://rubydoc.info/github/ruby-rdf/sparql) (extension)


### RDF Vocabularies

* {RDF}         - Resource Description Framework (RDF)
* {RDF::OWL}    - Web Ontology Language (OWL)
* {RDF::RDFS}   - RDF Schema (RDFS)
* {RDF::RDFV}   - RDF Vocabulary (RDFV)
* {RDF::XSD}    - XML Schema (XSD)


## Dependencies

* [Ruby](http://ruby-lang.org/) (>= 2.2)
* [LinkHeader][] (>= 0.0.8)
* Soft dependency on [RestClient][] (>= 1.7)

## Installation

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of RDF.rb, do:

    % [sudo] gem install rdf             # Ruby 2+

## Download

To get a local working copy of the development repository, do:

    % git clone git://github.com/ruby-rdf/rdf.git

Alternatively, download the latest development version as a tarball as
follows:

    % wget http://github.com/ruby-rdf/rdf/tarball/master

## Resources

* <http://rubydoc.info/github/ruby-rdf/rdf/frames>
* <http://github.com/ruby-rdf/rdf>
* <http://rubygems.org/gems/rdf>
* <http://raa.ruby-lang.org/project/rdf/>
* <http://www.ohloh.net/p/rdf>

## Mailing List

* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

## Authors

* [Arto Bendiken](http://github.com/bendiken) - <http://ar.to/>
* [Ben Lavender](http://github.com/bhuga) - <http://bhuga.net/>
* [Gregg Kellogg](http://github.com/gkellogg) - <http://greggkellogg.net/>

## Contributors

* [Călin Ardelean](http://github.com/clnx) - <http://github.com/clnx>
* [Mark Borkum](http://github.com/markborkum) - <http://github.com/markborkum>
* [Danny Gagne](http://github.com/danny) - <http://www.dannygagne.com/>
* [Joey Geiger](http://github.com/jgeiger) - <http://github.com/jgeiger>
* [Fumihiro Kato](http://github.com/fumi) - <http://fumi.me/>
* [Naoki Kawamukai](http://github.com/kna) - <http://github.com/kna>
* [Tom Nixon](https://github.com/tomjnixon) - <https://github.com/tomjnixon>
* [Hellekin O. Wolf](http://github.com/hellekin) - <http://hellekin.cepheide.org/>
* [John Fieber](http://github.com/jfieber) - <http://github.com/jfieber>
* [Keita Urashima](http://github.com/ursm) - <http://ursm.jp/>
* [Pius Uzamere](http://github.com/pius) - <http://pius.me/>
* [Judson Lester](https://github.com/nyarly) - <https://github.com/nyarly>
* [Peter Vandenabeele](https://github.com/petervandenabeele) - <https://github.com/petervandenabeele>
* [Tom Johnson](https://github.com/no-reply) - <https://github.com/no-reply>

## Contributing

This repository uses [Git Flow](https://github.com/nvie/gitflow) to mange development and release activity. All submissions _must_ be on a feature branch based on the _develop_ branch to ease staging and integration.

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
  Before committing, run `git diff --check` to make sure of this.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec` or `VERSION` files. If you need to change them,
  do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the
  corresponding list in the the `README`. Alphabetical order applies.
* Don't touch the `AUTHORS` file. If your contributions are significant
  enough, be assured we will eventually add you in there.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

## License

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[RDF]:              http://www.w3.org/RDF/
[N-Triples]:        http://www.w3.org/TR/n-triples/
[N-Quads]:          http://www.w3.org/TR/n-quads/
[YARD]:             http://yardoc.org/
[YARD-GS]:          http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:              http://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
[JSONLD doc]:       http://rubydoc.info/github/ruby-rdf/json-ld/frames
[LinkedData doc]:   http://rubydoc.info/github/datagraph/linkeddata/master/frames
[Microdata doc]:    http://rubydoc.info/github/ruby-rdf/rdf-microdata/frames
[N3 doc]:           http://rubydoc.info/github/ruby-rdf/rdf-n3/master/frames
[RDFa doc]:         http://rubydoc.info/github/ruby-rdf/rdf-rdfa/master/frames
[RDFXML doc]:       http://rubydoc.info/github/ruby-rdf/rdf-rdfxml/master/frames
[Turtle doc]:       http://rubydoc.info/github/ruby-rdf/rdf-turtle/master/frames
[SPARQL doc]:       http://rubydoc.info/github/ruby-rdf/sparql/frames
[RDF 1.0]:          http://www.w3.org/TR/2004/REC-rdf-concepts-20040210/
[RDF 1.1]:          http://www.w3.org/TR/rdf11-concepts/
[SPARQL 1.0]:       http://www.w3.org/TR/rdf-sparql-query/
[RDF.rb]:           http://ruby-rdf.github.com/
[RDF::DO]:          http://ruby-rdf.github.com/rdf-do
[RDF::Mongo]:       http://ruby-rdf.github.com/rdf-mongo
[RDF::Sesame]:      http://ruby-rdf.github.com/rdf-sesame
[RDF::JSON]:        http://ruby-rdf.github.com/rdf-json
[RDF::Microdata]:   http://ruby-rdf.github.com/rdf-microdata
[RDF::N3]:          http://ruby-rdf.github.com/rdf-n3
[RDF::RDFa]:        http://ruby-rdf.github.com/rdf-rdfa
[RDF::RDFXML]:      http://ruby-rdf.github.com/rdf-rdfxml
[RDF::TriG]:        http://ruby-rdf.github.com/rdf-trig
[RDF::TriX]:        http://ruby-rdf.github.com/rdf-trix
[RDF::Turtle]:      http://ruby-rdf.github.com/rdf-turtle
[RDF::Raptor]:      http://ruby-rdf.github.com/rdf-raptor
[LinkedData]:       http://ruby-rdf.github.com/linkeddata
[JSON::LD]:         http://gkellogg.github.com/json-ld
[RestClient]:       https://rubygems.org/gems/rest-client
[RestClient Components]: https://rubygems.org/gems/rest-client-components
[Rack::Cache]:      http://rtomayko.github.io/rack-cache/