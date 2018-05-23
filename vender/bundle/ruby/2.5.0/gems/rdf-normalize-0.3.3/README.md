# RDF::Normalize
RDF Graph normalizer for [RDF.rb][RDF.rb].

[![Gem Version](https://badge.fury.io/rb/rdf-normalize.png)](http://badge.fury.io/rb/rdf-normalize)
[![Build Status](https://secure.travis-ci.org/ruby-rdf/rdf-normalize.png?branch=master)](http://travis-ci.org/ruby-rdf/rdf-normalize)

## Description
This is a [Ruby][] implementation of a [RDF Normalize][] for [RDF.rb][].

## Features
RDF::Normalize generates normalized [N-Quads][] output for an RDF Dataset using the algorithm
defined in [RDF Normalize][]. It also implements an RDF Writer interface, which can be used
to serialize normalized statements.

Algorithms implemented:

* [URGNA2012](http://json-ld.github.io/normalization/spec/index.html#dfn-urgna2012)
* [URDNA2015](http://json-ld.github.io/normalization/spec/index.html#dfn-urdna2015)

Install with `gem install rdf-normalize`

* 100% free and unencumbered [public domain](http://unlicense.org/) software.
* Compatible with  Ruby >= 2.2.2.

## Usage

## Documentation
Full documentation available on [Rubydoc.info][Normalize doc]

### Principle Classes
* {RDF::Normalize}
  * {RDF::Normalize::Base}
  * {RDF::Normalize::Format}
  * {RDF::Normalize::Writer}
  * {RDF::Normalize::URGNA2012}
  * {RDF::Normalize::URDNA2015}


## Dependencies

* [Ruby](http://ruby-lang.org/) (>= 2.0)
* [RDF.rb](http://rubygems.org/gems/rdf) (~> 2.0)

## Installation

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `RDF::Normalize` gem, do:

    % [sudo] gem install rdf-normalize

## Mailing List
* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

## Author
* [Gregg Kellogg](http://github.com/gkellogg) - <http://greggkellogg.net/>

## Contributing
* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

## License
This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:LICENSE} file.

[Ruby]:         http://ruby-lang.org/
[RDF]:          http://www.w3.org/RDF/
[YARD]:         http://yardoc.org/
[YARD-GS]:      http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:          http://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
[RDF.rb]:       http://rubydoc.info/github/ruby-rdf/rdf-normalize
[N-Triples]:    http://www.w3.org/TR/rdf-testcases/#ntriples
[RDF Normalize]:http://json-ld.github.io/normalization/spec/
[Normalize doc]:http://rubydoc.info/github/ruby-rdf/rdf-normalize/master
