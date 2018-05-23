# coding: utf-8
require_relative 'spec_helper'
require 'rdf/spec/writer'

describe JSON::LD::API do
  let(:logger) {RDF::Spec.logger}

  describe ".fromRdf" do
    context "simple tests" do
      it "One subject IRI object" do
        input = %(<http://a/b> <http://a/c> <http://a/d> .)
        expect(serialize(input)).to produce([
        {
          '@id'         => "http://a/b",
          "http://a/c"  => [{"@id" => "http://a/d"}]
        }
        ], logger)
      end

      it "should generate object list" do
        input = %(@prefix : <http://example.com/> . :b :c :d, :e .)
        expect(serialize(input)).
        to produce([{
          '@id'                         => "http://example.com/b",
          "http://example.com/c" => [
            {"@id" => "http://example.com/d"},
            {"@id" => "http://example.com/e"}
          ]
        }
        ], logger)
      end
    
      it "should generate property list" do
        input = %(@prefix : <http://example.com/> . :b :c :d; :e :f .)
        expect(serialize(input)).
        to produce([{
          '@id'   => "http://example.com/b",
          "http://example.com/c"      => [{"@id" => "http://example.com/d"}],
          "http://example.com/e"      => [{"@id" => "http://example.com/f"}]
        }
        ], logger)
      end
    
      it "serializes multiple subjects" do
        input = %q(
          @prefix : <http://www.w3.org/2006/03/test-description#> .
          @prefix dc: <http://purl.org/dc/elements/1.1/> .
          <test-cases/0001> a :TestCase .
          <test-cases/0002> a :TestCase .
        )
        expect(serialize(input)).
        to produce([
          {'@id'  => "test-cases/0001", '@type' => ["http://www.w3.org/2006/03/test-description#TestCase"]},
          {'@id'  => "test-cases/0002", '@type' => ["http://www.w3.org/2006/03/test-description#TestCase"]},
        ], logger)
      end
    end
  
    context "literals" do
      context "coercion" do
        it "typed literal" do
          input = %(@prefix ex: <http://example.com/> . ex:a ex:b "foo"^^ex:d .)
          expect(serialize(input)).to produce([
            {
              '@id'   => "http://example.com/a",
              "http://example.com/b"    => [{"@value" => "foo", "@type" => "http://example.com/d"}]
            }
          ], logger)
        end

        it "integer" do
          input = %(@prefix ex: <http://example.com/> . ex:a ex:b 1 .)
          expect(serialize(input, useNativeTypes: true)).to produce([{
            '@id'   => "http://example.com/a",
            "http://example.com/b"    => [{"@value" => 1}]
          }], logger)
        end

        it "integer (non-native)" do
          input = %(@prefix ex: <http://example.com/> . ex:a ex:b 1 .)
          expect(serialize(input, useNativeTypes: false)).to produce([{
            '@id'   => "http://example.com/a",
            "http://example.com/b"    => [{"@value" => "1","@type" => "http://www.w3.org/2001/XMLSchema#integer"}]
          }], logger)
        end

        it "boolean" do
          input = %(@prefix ex: <http://example.com/> . ex:a ex:b true .)
          expect(serialize(input, useNativeTypes: true)).to produce([{
            '@id'   => "http://example.com/a",
            "http://example.com/b"    => [{"@value" => true}]
          }], logger)
        end

        it "boolean (non-native)" do
          input = %(@prefix ex: <http://example.com/> . ex:a ex:b true .)
          expect(serialize(input, useNativeTypes: false)).to produce([{
            '@id'   => "http://example.com/a",
            "http://example.com/b"    => [{"@value" => "true","@type" => "http://www.w3.org/2001/XMLSchema#boolean"}]
          }], logger)
        end

        it "decmal" do
          input = %(@prefix ex: <http://example.com/> . ex:a ex:b 1.0 .)
          expect(serialize(input, useNativeTypes: true)).to produce([{
            '@id'   => "http://example.com/a",
            "http://example.com/b"    => [{"@value" => "1.0", "@type" => "http://www.w3.org/2001/XMLSchema#decimal"}]
          }], logger)
        end

        it "double" do
          input = %(@prefix ex: <http://example.com/> . ex:a ex:b 1.0e0 .)
          expect(serialize(input, useNativeTypes: true)).to produce([{
            '@id'   => "http://example.com/a",
            "http://example.com/b"    => [{"@value" => 1.0E0}]
          }], logger)
        end

        it "double (non-native)" do
          input = %(@prefix ex: <http://example.com/> . ex:a ex:b 1.0e0 .)
          expect(serialize(input, useNativeTypes: false)).to produce([{
            '@id'   => "http://example.com/a",
            "http://example.com/b"    => [{"@value" => "1.0E0","@type" => "http://www.w3.org/2001/XMLSchema#double"}]
          }], logger)
        end
      end

      context "datatyped (non-native)" do
        {
          integer:            1,
          unsignedInteger:    1,
          nonNegativeInteger: 1,
          float:              1,
          nonPositiveInteger: -1,
          negativeInteger:    -1,
        }.each do |t, v|
          it "#{t}" do
            input = %(
              @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
              @prefix ex: <http://example.com/> .
              ex:a ex:b "#{v}"^^xsd:#{t} .
            )
            expect(serialize(input, useNativeTypes: false)).to produce([{
              '@id'   => "http://example.com/a",
              "http://example.com/b"    => [{"@value" => "#{v}","@type" => "http://www.w3.org/2001/XMLSchema##{t}"}]
            }], logger)
          end
        end
      end

      it "encodes language literal" do
        input = %(@prefix ex: <http://example.com/> . ex:a ex:b "foo"@en-us .)
        expect(serialize(input)).to produce([{
          '@id'   => "http://example.com/a",
          "http://example.com/b"    => [{"@value" => "foo", "@language" => "en-us"}]
        }], logger)
      end
    end

    context "anons" do
      it "should generate bare anon" do
        input = %(@prefix : <http://example.com/> . _:a :a :b .)
        expect(serialize(input)).to produce([
        {
          "@id" => "_:a",
          "http://example.com/a"  => [{"@id" => "http://example.com/b"}]
        }
        ], logger)
      end
    
      it "should generate anon as object" do
        input = %(@prefix : <http://example.com/> . :a :b _:a . _:a :c :d .)
        expect(serialize(input)).to produce([
          {
            "@id" => "_:a",
            "http://example.com/c"  => [{"@id" => "http://example.com/d"}]
          },
          {
            "@id" => "http://example.com/a",
            "http://example.com/b"  => [{"@id" => "_:a"}]
          }
        ], logger)
      end
    end

    context "lists" do
      {
        "literal list" => [
          %q(
            @prefix : <http://example.com/> .
            @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
            :a :b ("apple" "banana")  .
          ),
          [{
            '@id'   => "http://example.com/a",
            "http://example.com/b"  => [{
              "@list" => [
                {"@value" => "apple"},
                {"@value" => "banana"}
              ]
            }]
          }]
        ],
        "iri list" => [
          %q(@prefix : <http://example.com/> . :a :b (:c) .),
          [{
            '@id'   => "http://example.com/a",
            "http://example.com/b"  => [{
              "@list" => [
                {"@id" => "http://example.com/c"}
              ]
            }]
          }]
        ],
        "empty list" => [
          %q(@prefix : <http://example.com/> . :a :b () .),
          [{
            '@id'   => "http://example.com/a",
            "http://example.com/b"  => [{"@list" => []}]
          }]
        ],
        "single element list" => [
          %q(@prefix : <http://example.com/> . :a :b ( "apple" ) .),
          [{
            '@id'   => "http://example.com/a",
            "http://example.com/b"  => [{"@list" => [{"@value" => "apple"}]}]
          }]
        ],
        "single element list without @type" => [
          %q(@prefix : <http://example.com/> . :a :b ( _:a ) . _:a :b "foo" .),
          [
            {
              '@id'   => "_:a",
              "http://example.com/b"  => [{"@value" => "foo"}]
            },
            {
              '@id'   => "http://example.com/a",
              "http://example.com/b"  => [{"@list" => [{"@id" => "_:a"}]}]
            },
          ]
        ],
        "multiple graphs with shared BNode" => [
          %q(
            <http://www.example.com/z> <http://www.example.com/q> _:z0 <http://www.example.com/G> .
            _:z0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "cell-A" <http://www.example.com/G> .
            _:z0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:z1 <http://www.example.com/G> .
            _:z1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "cell-B" <http://www.example.com/G> .
            _:z1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://www.example.com/G> .
            <http://www.example.com/x> <http://www.example.com/p> _:z1 <http://www.example.com/G1> .
          ),
          [{
            "@id" => "http://www.example.com/G",
            "@graph" => [{
              "@id" => "_:z0",
              "http://www.w3.org/1999/02/22-rdf-syntax-ns#first" => [{"@value" => "cell-A"}],
              "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest" => [{"@id" => "_:z1"}]
            }, {
              "@id" => "_:z1",
              "http://www.w3.org/1999/02/22-rdf-syntax-ns#first" => [{"@value" => "cell-B"}],
              "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest" => [{"@list" => []}]
            }, {
              "@id" => "http://www.example.com/z",
              "http://www.example.com/q" => [{"@id" => "_:z0"}]
            }]
          },
          {
            "@id" => "http://www.example.com/G1",
            "@graph" => [{
              "@id" => "http://www.example.com/x",
              "http://www.example.com/p" => [{"@id" => "_:z1"}]
            }]
          }],
          RDF::NQuads::Reader
        ],
      }.each do |name, (input, output, reader)|
        it name do
          r = serialize(input, reader: reader)
          expect(r).to produce(output, logger)
        end
      end
    end
    
    context "quads" do
      {
        "simple named graph" => {
          input: %(
            <http://example.com/a> <http://example.com/b> <http://example.com/c> <http://example.com/U> .
          ),
          output: [
            {
              "@id" => "http://example.com/U",
              "@graph" => [{
                "@id" => "http://example.com/a",
                "http://example.com/b" => [{"@id" => "http://example.com/c"}]
              }]
            },
          ]
        },
        "with properties" => {
          input: %(
            <http://example.com/a> <http://example.com/b> <http://example.com/c> <http://example.com/U> .
            <http://example.com/U> <http://example.com/d> <http://example.com/e> .
          ),
          output: [
            {
              "@id" => "http://example.com/U",
              "@graph" => [{
                "@id" => "http://example.com/a",
                "http://example.com/b" => [{"@id" => "http://example.com/c"}]
              }],
              "http://example.com/d" => [{"@id" => "http://example.com/e"}]
            }
          ]
        },
        "with lists" => {
          input: %(
            <http://example.com/a> <http://example.com/b> _:a <http://example.com/U> .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> <http://example.com/c> <http://example.com/U> .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://example.com/U> .
            <http://example.com/U> <http://example.com/d> _:b .
            _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> <http://example.com/e> .
            _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          ),
          output: [
            {
              "@id" => "http://example.com/U",
              "@graph" => [{
                "@id" => "http://example.com/a",
                "http://example.com/b" => [{"@list" => [{"@id" => "http://example.com/c"}]}]
              }],
              "http://example.com/d" => [{"@list" => [{"@id" => "http://example.com/e"}]}]
            }
          ]
        },
        "Two Graphs with same subject and lists" => {
          input: %(
            <http://example.com/a> <http://example.com/b> _:a <http://example.com/U> .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> <http://example.com/c> <http://example.com/U> .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://example.com/U> .
            <http://example.com/a> <http://example.com/b> _:b <http://example.com/V> .
            _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> <http://example.com/e> <http://example.com/V> .
            _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://example.com/V> .
          ),
          output: [
            {
              "@id" => "http://example.com/U",
              "@graph" => [
                {
                  "@id" => "http://example.com/a",
                  "http://example.com/b" => [{
                    "@list" => [{"@id" => "http://example.com/c"}]
                  }]
                }
              ]
            },
            {
              "@id" => "http://example.com/V",
              "@graph" => [
                {
                  "@id" => "http://example.com/a",
                  "http://example.com/b" => [{
                    "@list" => [{"@id" => "http://example.com/e"}]
                  }]
                }
              ]
            }
          ]
        },
      }.each_pair do |name, properties|
        it name do
          r = serialize(properties[:input], reader: RDF::NQuads::Reader)
          expect(r).to produce(properties[:output], logger)
        end
      end
    end
  
    context "problems" do
      {
        "xsd:boolean as value" => [
          %(
            @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
            @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

            <http://data.wikia.com/terms#playable> rdfs:range xsd:boolean .
          ),
          [{
            "@id" => "http://data.wikia.com/terms#playable",
            "http://www.w3.org/2000/01/rdf-schema#range" => [
              { "@id" => "http://www.w3.org/2001/XMLSchema#boolean" }
            ]
          }]
        ],
      }.each do |t, (input, output)|
        it "#{t}" do
          expect(serialize(input)).to produce(output, logger)
        end
      end
    end
  end

  def parse(input, options = {})
    reader = options[:reader] || RDF::TriG::Reader
    reader.new(input, options, &:each_statement).to_a.extend(RDF::Enumerable)
  end

  # Serialize ntstr to a string and compare against regexps
  def serialize(ntstr, options = {})
    logger.info ntstr if ntstr.is_a?(String)
    g = ntstr.is_a?(String) ? parse(ntstr, options) : ntstr
    logger.info g.dump(:trig)
    statements = g.each_statement.to_a
    JSON::LD::API.fromRdf(statements, options.merge(logger: logger))
  end
end
