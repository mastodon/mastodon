# coding: utf-8
require_relative 'spec_helper'

describe JSON::LD::API do
  let(:logger) {RDF::Spec.logger}

  context ".toRdf" do
    it "should implement RDF::Enumerable" do
      expect(JSON::LD::API.toRdf({})).to be_a(RDF::Enumerable)
    end

    context "unnamed nodes" do
      {
        "no @id" => [
          %q({
            "http://example.com/foo": "bar"
          }),
          %q([ <http://example.com/foo> "bar"^^xsd:string] .)
        ],
        "@id with _:a" => [
          %q({
            "@id": "_:a",
            "http://example.com/foo": "bar"
          }),
          %q([ <http://example.com/foo> "bar"^^xsd:string] .)
        ],
        "@id with _:a and reference" => [
          %q({
            "@id": "_:a",
            "http://example.com/foo": {"@id": "_:a"}
          }),
          %q(_:a <http://example.com/foo> _:a .)
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "nodes with @id" do
      {
        "with IRI" => [
          %q({
            "@id": "http://example.com/a",
            "http://example.com/foo": "bar"
          }),
          %q(<http://example.com/a> <http://example.com/foo> "bar" .)
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
      
      context "with relative IRIs" do
        {
          "base" => [
            %({
              "@id": "",
              "@type": "#{RDF::RDFS.Resource}"
            }),
            %(<http://example.org/> a <#{RDF::RDFS.Resource}> .)
          ],
          "relative" => [
            %({
              "@id": "a/b",
              "@type": "#{RDF::RDFS.Resource}"
            }),
            %(<http://example.org/a/b> a <#{RDF::RDFS.Resource}> .)
          ],
          "hash" => [
            %({
              "@id": "#a",
              "@type": "#{RDF::RDFS.Resource}"
            }),
            %(<http://example.org/#a> a <#{RDF::RDFS.Resource}> .)
          ],
        }.each do |title, (js, ttl)|
          it title do
            ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
            expect(parse(js, base: "http://example.org/")).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
          end
        end
      end
    end

    context "typed nodes" do
      {
        "one type" => [
          %q({
            "@type": "http://example.com/foo"
          }),
          %q([ a <http://example.com/foo> ] .)
        ],
        "two types" => [
          %q({
            "@type": ["http://example.com/foo", "http://example.com/baz"]
          }),
          %q([ a <http://example.com/foo>, <http://example.com/baz> ] .)
        ],
        "blank node type" => [
          %q({
            "@type": "_:foo"
          }),
          %q([ a _:foo ] .)
        ]
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "key/value" do
      {
        "string" => [
          %q({
            "http://example.com/foo": "bar"
          }),
          %q([ <http://example.com/foo> "bar"^^xsd:string ] .)
        ],
        "strings" => [
          %q({
            "http://example.com/foo": ["bar", "baz"]
          }),
          %q([ <http://example.com/foo> "bar"^^xsd:string, "baz"^^xsd:string ] .)
        ],
        "IRI" => [
          %q({
            "http://example.com/foo": {"@id": "http://example.com/bar"}
          }),
          %q([ <http://example.com/foo> <http://example.com/bar> ] .)
        ],
        "IRIs" => [
          %q({
            "http://example.com/foo": [{"@id": "http://example.com/bar"}, {"@id": "http://example.com/baz"}]
          }),
          %q([ <http://example.com/foo> <http://example.com/bar>, <http://example.com/baz> ] .)
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "literals" do
      {
        "plain literal" =>
        [
          %q({"@id": "http://greggkellogg.net/foaf#me", "http://xmlns.com/foaf/0.1/name": "Gregg Kellogg"}),
          %q(<http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/name> "Gregg Kellogg" .)
        ],
        "explicit plain literal" =>
        [
          %q({"http://xmlns.com/foaf/0.1/name": {"@value": "Gregg Kellogg"}}),
          %q(_:a <http://xmlns.com/foaf/0.1/name> "Gregg Kellogg"^^xsd:string .)
        ],
        "language tagged literal" =>
        [
          %q({"http://www.w3.org/2000/01/rdf-schema#label": {"@value": "A plain literal with a lang tag.", "@language": "en-us"}}),
          %q(_:a <http://www.w3.org/2000/01/rdf-schema#label> "A plain literal with a lang tag."@en-us .)
        ],
        "I18N literal with language" =>
        [
          %q([{
            "@id": "http://greggkellogg.net/foaf#me",
            "http://xmlns.com/foaf/0.1/knows": {"@id": "http://www.ivan-herman.net/foaf#me"}
          },{
            "@id": "http://www.ivan-herman.net/foaf#me",
            "http://xmlns.com/foaf/0.1/name": {"@value": "Herman Iván", "@language": "hu"}
          }]),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> <http://www.ivan-herman.net/foaf#me> .
            <http://www.ivan-herman.net/foaf#me> <http://xmlns.com/foaf/0.1/name> "Herman Iv\u00E1n"@hu .
          )
        ],
        "explicit datatyped literal" =>
        [
          %q({
            "@id":  "http://greggkellogg.net/foaf#me",
            "http://purl.org/dc/terms/created":  {"@value": "1957-02-27", "@type": "http://www.w3.org/2001/XMLSchema#date"}
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://purl.org/dc/terms/created> "1957-02-27"^^<http://www.w3.org/2001/XMLSchema#date> .
          )
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "prefixes" do
      {
        "empty prefix" => [
          %q({"@context": {"": "http://example.com/default#"}, ":foo": "bar"}),
          %q(_:a <http://example.com/default#foo> "bar"^^xsd:string .)
        ],
        "empty suffix" => [
          %q({"@context": {"prefix": "http://example.com/default#"}, "prefix:": "bar"}),
          %q(_:a <http://example.com/default#> "bar"^^xsd:string .)
        ],
        "prefix:suffix" => [
          %q({"@context": {"prefix": "http://example.com/default#"}, "prefix:foo": "bar"}),
          %q(_:a <http://example.com/default#foo> "bar"^^xsd:string .)
        ]
      }.each_pair do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "overriding keywords" do
      {
        "'url' for @id, 'a' for @type" => [
          %q({
            "@context": {"url": "@id", "a": "@type", "name": "http://schema.org/name"},
            "url": "http://example.com/about#gregg",
            "a": "http://schema.org/Person",
            "name": "Gregg Kellogg"
          }),
          %q(
            <http://example.com/about#gregg> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person> .
            <http://example.com/about#gregg> <http://schema.org/name> "Gregg Kellogg"^^xsd:string .
          )
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "chaining" do
      {
        "explicit subject" =>
        [
          %q({
            "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "http://greggkellogg.net/foaf#me",
            "foaf:knows": {
              "@id": "http://www.ivan-herman.net/foaf#me",
              "foaf:name": "Ivan Herman"
            }
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> <http://www.ivan-herman.net/foaf#me> .
            <http://www.ivan-herman.net/foaf#me> <http://xmlns.com/foaf/0.1/name> "Ivan Herman" .
          )
        ],
        "implicit subject" =>
        [
          %q({
            "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "http://greggkellogg.net/foaf#me",
            "foaf:knows": {
              "foaf:name": "Manu Sporny"
            }
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> _:a .
            _:a <http://xmlns.com/foaf/0.1/name> "Manu Sporny"^^xsd:string .
          )
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "multiple values" do
      {
        "literals" =>
        [
          %q({
            "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "http://greggkellogg.net/foaf#me",
            "foaf:knows": ["Manu Sporny", "Ivan Herman"]
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> "Manu Sporny" .
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> "Ivan Herman" .
          )
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "lists" do
      {
        "Empty" => [
          %q({
            "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "http://greggkellogg.net/foaf#me",
            "foaf:knows": {"@list": []}
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          )
        ],
        "single value" => [
          %q({
            "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "http://greggkellogg.net/foaf#me",
            "foaf:knows": {"@list": ["Manu Sporny"]}
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> _:a .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "Manu Sporny"^^xsd:string .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          )
        ],
        "single value (with coercion)" => [
          %q({
            "@context": {
              "foaf": "http://xmlns.com/foaf/0.1/",
              "foaf:knows": { "@container": "@list"}
            },
            "@id": "http://greggkellogg.net/foaf#me",
            "foaf:knows": ["Manu Sporny"]
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> _:a .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "Manu Sporny"^^xsd:string .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          )
        ],
        "multiple values" => [
          %q({
            "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "http://greggkellogg.net/foaf#me",
            "foaf:knows": {"@list": ["Manu Sporny", "Dave Longley"]}
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> _:a .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "Manu Sporny"^^xsd:string .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b .
            _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "Dave Longley"^^xsd:string .
            _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          )
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end

    context "context" do
      {
        "@id coersion" =>
        [
          %q({
            "@context": {
              "knows": {"@id": "http://xmlns.com/foaf/0.1/knows", "@type": "@id"}
            },
            "@id":  "http://greggkellogg.net/foaf#me",
            "knows":  "http://www.ivan-herman.net/foaf#me"
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://xmlns.com/foaf/0.1/knows> <http://www.ivan-herman.net/foaf#me> .
          )
        ],
        "datatype coersion" =>
        [
          %q({
            "@context": {
              "dcterms":  "http://purl.org/dc/terms/",
              "xsd":      "http://www.w3.org/2001/XMLSchema#",
              "created":  {"@id": "http://purl.org/dc/terms/created", "@type": "xsd:date"}
            },
            "@id":  "http://greggkellogg.net/foaf#me",
            "created":  "1957-02-27"
          }),
          %q(
            <http://greggkellogg.net/foaf#me> <http://purl.org/dc/terms/created> "1957-02-27"^^<http://www.w3.org/2001/XMLSchema#date> .
          )
        ],
        "sub-objects with context" => [
          %q({
            "@context": {"foo": "http://example.com/foo"},
            "foo":  {
              "@context": {"foo": "http://example.org/foo"},
              "foo": "bar"
            }
          }),
          %q(
            _:a <http://example.com/foo> _:b .
            _:b <http://example.org/foo> "bar"^^xsd:string .
          )
        ],
        "contexts with a list processed in order" => [
          %q({
            "@context": [
              {"foo": "http://example.com/foo"},
              {"foo": "http://example.org/foo"}
            ],
            "foo":  "bar"
          }),
          %q(
            _:b <http://example.org/foo> "bar"^^xsd:string .
          )
        ],
        "term definition resolves term as IRI" => [
          %q({
            "@context": [
              {"foo": "http://example.com/foo"},
              {"bar": "foo"}
            ],
            "bar":  "bar"
          }),
          %q(
            _:b <http://example.com/foo> "bar"^^xsd:string .
          )
        ],
        "term definition resolves prefix as IRI" => [
          %q({
            "@context": [
              {"foo": "http://example.com/foo#"},
              {"bar": "foo:bar"}
            ],
            "bar":  "bar"
          }),
          %q(
            _:b <http://example.com/foo#bar> "bar"^^xsd:string .
          )
        ],
        "@language" => [
          %q({
            "@context": {
              "foo": "http://example.com/foo#",
              "@language": "en"
            },
            "foo:bar":  "baz"
          }),
          %q(
            _:a <http://example.com/foo#bar> "baz"@en .
          )
        ],
        "@language with override" => [
          %q({
            "@context": {
              "foo": "http://example.com/foo#",
              "@language": "en"
            },
            "foo:bar":  {"@value": "baz", "@language": "fr"}
          }),
          %q(
            _:a <http://example.com/foo#bar> "baz"@fr .
          )
        ],
        "@language with plain" => [
          %q({
            "@context": {
              "foo": "http://example.com/foo#",
              "@language": "en"
            },
            "foo:bar":  {"@value": "baz"}
          }),
          %q(
            _:a <http://example.com/foo#bar> "baz"^^xsd:string .
          )
        ],
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, base: "http://example/", logger: logger, inputDocument: js)
        end
      end
      
      context "coercion" do
        context "term def with @id + @type" do
          {
            "dt with term" => [
              %q({
                "@context": [
                  {"date": "http://www.w3.org/2001/XMLSchema#date", "term": "http://example.org/foo#"},
                  {"foo": {"@id": "term", "@type": "date"}}
                ],
                "foo": "bar"
              }),
              %q(
                @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
                [ <http://example.org/foo#> "bar"^^xsd:date ] .
              )
            ],
            "@id with term" => [
              %q({
                "@context": [
                  {"foo": {"@id": "http://example.org/foo#bar", "@type": "@id"}}
                ],
                "foo": "http://example.org/foo#bar"
              }),
              %q(
                _:a <http://example.org/foo#bar> <http://example.org/foo#bar> .
              )
            ],
            "coercion without term definition" => [
              %q({
                "@context": [
                  {
                    "xsd": "http://www.w3.org/2001/XMLSchema#",
                    "dc": "http://purl.org/dc/terms/"
                  },
                  {
                    "dc:date": {"@type": "xsd:date"}
                  }
                ],
                "dc:date": "2011-11-23"
              }),
              %q(
                @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
                @prefix dc: <http://purl.org/dc/terms/> .
                [ dc:date "2011-11-23"^^xsd:date] .
              )
            ],
          }.each do |title, (js, ttl)|
            it title do
              ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
              expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
            end
          end
        end
      end

      context "lists" do
        context "term def with @id + @type + @container" do
          {
            "dt with term" => [
              %q({
                "@context": [
                  {"date": "http://www.w3.org/2001/XMLSchema#date", "term": "http://example.org/foo#"},
                  {"foo": {"@id": "term", "@type": "date", "@container": "@list"}}
                ],
                "foo": ["bar"]
              }),
              %q(
                @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
                [ <http://example.org/foo#> ("bar"^^xsd:date) ] .
              )
            ],
            "@id with term" => [
              %q({
                "@context": [
                  {"foo": {"@id": "http://example.org/foo#bar", "@type": "@id", "@container": "@list"}}
                ],
                "foo": ["http://example.org/foo#bar"]
              }),
              %q(
                _:a <http://example.org/foo#bar> (<http://example.org/foo#bar>) .
              )
            ],
          }.each do |title, (js, ttl)|
            it title do
              ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
              expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
            end
          end
        end
      end
    end

    context "blank node predicates" do
      subject {%q({"@id": "http://example/subj", "_:foo": "bar"})}

      it "outputs statements with blank node predicates if :produceGeneralizedRdf is true" do
        graph = parse(subject, produceGeneralizedRdf: true)
        expect(graph.count).to eq 1
      end

      it "rejects statements with blank node predicates if :produceGeneralizedRdf is false" do
        graph = parse(subject, produceGeneralizedRdf: false)
        expect(graph.count).to eq 0
      end
    end

    context "advanced features" do
      {
        "number syntax (decimal)" =>
        [
          %q({"@context": { "measure": "http://example/measure#"}, "measure:cups": 5.3}),
          %q(_:a <http://example/measure#cups> "5.3E0"^^<http://www.w3.org/2001/XMLSchema#double> .)
        ],
        "number syntax (double)" =>
        [
          %q({"@context": { "measure": "http://example/measure#"}, "measure:cups": 5.3e0}),
          %q(_:a <http://example/measure#cups> "5.3E0"^^<http://www.w3.org/2001/XMLSchema#double> .)
        ],
        "number syntax (integer)" =>
        [
          %q({"@context": { "chem": "http://example/chem#"}, "chem:protons": 12}),
          %q(_:a <http://example/chem#protons> "12"^^<http://www.w3.org/2001/XMLSchema#integer> .)
        ],
        "boolan syntax" =>
        [
          %q({"@context": { "sensor": "http://example/sensor#"}, "sensor:active": true}),
          %q(_:a <http://example/sensor#active> "true"^^<http://www.w3.org/2001/XMLSchema#boolean> .)
        ],
        "Array top element" =>
        [
          %q([
            {"@id":   "http://example.com/#me", "@type": "http://xmlns.com/foaf/0.1/Person"},
            {"@id":   "http://example.com/#you", "@type": "http://xmlns.com/foaf/0.1/Person"}
          ]),
          %q(
            <http://example.com/#me> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
            <http://example.com/#you> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
          )
        ],
        "@graph with array of objects value" =>
        [
          %q({
            "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@graph": [
              {"@id":   "http://example.com/#me", "@type": "foaf:Person"},
              {"@id":   "http://example.com/#you", "@type": "foaf:Person"}
            ]
          }),
          %q(
            <http://example.com/#me> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
            <http://example.com/#you> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
          )
        ],
        "XMLLiteral" => [
          %q({
            "http://rdfs.org/sioc/ns#content": {
              "@value": "foo",
              "@type": "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"
            }
          }),
          %q(
            [<http://rdfs.org/sioc/ns#content> "foo"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral>] .
          )
        ]
      }.each do |title, (js, ttl)|
        it title do
          ttl = "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{ttl}"
          expect(parse(js)).to be_equivalent_graph(ttl, logger: logger, inputDocument: js)
        end
      end
    end
  end

  def parse(input, options = {})
    graph = options[:graph] || RDF::Graph.new
    options = {logger: logger, validate: true, canonicalize: false}.merge(options)
    JSON::LD::API.toRdf(StringIO.new(input), options) {|st| graph << st}
    graph
  end
end
