# coding: utf-8
require_relative 'spec_helper'

describe JSON::LD::API do
  let(:logger) {RDF::Spec.logger}

  describe ".expand" do
    {
      "empty doc": {
        input: {},
        output: []
      },
      "@list coercion": {
        input: %({
          "@context": {
            "foo": {"@id": "http://example.com/foo", "@container": "@list"}
          },
          "foo": [{"@value": "bar"}]
        }),
        output: %([{
          "http://example.com/foo": [{"@list": [{"@value": "bar"}]}]
        }])
      },
      "native values in list": {
        input: %({
          "http://example.com/foo": {"@list": [1, 2]}
        }),
        output: %([{
          "http://example.com/foo": [{"@list": [{"@value": 1}, {"@value": 2}]}]
        }])
      },
      "@graph": {
        input: %({
          "@context": {"ex": "http://example.com/"},
          "@graph": [
            {"ex:foo": {"@value": "foo"}},
            {"ex:bar": {"@value": "bar"}}
          ]
        }),
        output: %([
          {"http://example.com/foo": [{"@value": "foo"}]},
          {"http://example.com/bar": [{"@value": "bar"}]}
        ])
      },
      "@graph value (expands to array form)": {
        input: %({
          "@context": {"ex": "http://example.com/"},
          "ex:p": {
            "@id": "ex:Sub1",
            "@graph": {
              "ex:q": "foo"
            }
          }
        }),
        output: %([{
          "http://example.com/p": [{
            "@id": "http://example.com/Sub1",
            "@graph": [{
              "http://example.com/q": [{"@value": "foo"}]
            }]
          }]
        }])
      },
      "@type with CURIE": {
        input: %({
          "@context": {"ex": "http://example.com/"},
          "@type": "ex:type"
        }),
        output: %([
          {"@type": ["http://example.com/type"]}
        ])
      },
      "@type with CURIE and muliple values": {
        input: %({
          "@context": {"ex": "http://example.com/"},
          "@type": ["ex:type1", "ex:type2"]
        }),
        output: %([
          {"@type": ["http://example.com/type1", "http://example.com/type2"]}
        ])
      },
      "@value with false": {
        input: %({"http://example.com/ex": {"@value": false}}),
        output: %([{"http://example.com/ex": [{"@value": false}]}])
      },
      "compact IRI": {
        input: %({
          "@context": {"ex": "http://example.com/"},
          "ex:p": {"@id": "ex:Sub1"}
        }),
        output: %([{
          "http://example.com/p": [{"@id": "http://example.com/Sub1"}]
        }])
      },
    }.each_pair do |title, params|
      it(title) {run_expand params}
    end

    context "with relative IRIs" do
      {
        "base": {
          input: %({
            "@id": "",
            "@type": "http://www.w3.org/2000/01/rdf-schema#Resource"
          }),
          output: %([{
            "@id": "http://example.org/",
            "@type": ["http://www.w3.org/2000/01/rdf-schema#Resource"]
          }])
        },
        "relative": {
          input: %({
            "@id": "a/b",
            "@type": "http://www.w3.org/2000/01/rdf-schema#Resource"
          }),
          output: %([{
            "@id": "http://example.org/a/b",
            "@type": ["http://www.w3.org/2000/01/rdf-schema#Resource"]
          }])
        },
        "hash": {
          input: %({
            "@id": "#a",
            "@type": "http://www.w3.org/2000/01/rdf-schema#Resource"
          }),
          output: %([{
            "@id": "http://example.org/#a",
            "@type": ["http://www.w3.org/2000/01/rdf-schema#Resource"]
          }])
        },
        "unmapped @id": {
          input: %({
            "http://example.com/foo": {"@id": "bar"}
          }),
          output: %([{
            "http://example.com/foo": [{"@id": "http://example.org/bar"}]
          }])
        },
      }.each do |title, params|
        it(title) {run_expand params.merge(base: "http://example.org/")}
      end
    end

    context "keyword aliasing" do
      {
        "@id": {
          input: %({
            "@context": {"id": "@id"},
            "id": "",
            "@type": "http://www.w3.org/2000/01/rdf-schema#Resource"
          }),
          output: %([{
            "@id": "",
            "@type":[ "http://www.w3.org/2000/01/rdf-schema#Resource"]
          }])
        },
        "@type": {
          input: %({
            "@context": {"type": "@type"},
            "type": "http://www.w3.org/2000/01/rdf-schema#Resource",
            "http://example.com/foo": {"@value": "bar", "type": "http://example.com/baz"}
          }),
          output: %([{
            "@type": ["http://www.w3.org/2000/01/rdf-schema#Resource"],
            "http://example.com/foo": [{"@value": "bar", "@type": "http://example.com/baz"}]
          }])
        },
        "@language": {
          input: %({
            "@context": {"language": "@language"},
            "http://example.com/foo": {"@value": "bar", "language": "baz"}
          }),
          output: %([{
            "http://example.com/foo": [{"@value": "bar", "@language": "baz"}]
          }])
        },
        "@value": {
          input: %({
            "@context": {"literal": "@value"},
            "http://example.com/foo": {"literal": "bar"}
          }),
          output: %([{
            "http://example.com/foo": [{"@value": "bar"}]
          }])
        },
        "@list": {
          input: %({
            "@context": {"list": "@list"},
            "http://example.com/foo": {"list": ["bar"]}
          }),
          output: %([{
            "http://example.com/foo": [{"@list": [{"@value": "bar"}]}]
          }])
        },
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "native types" do
      {
        "true": {
          input: %({
            "@context": {"e": "http://example.org/vocab#"},
            "e:bool": true
          }),
          output: %([{
            "http://example.org/vocab#bool": [{"@value": true}]
          }])
        },
        "false": {
          input: %({
            "@context": {"e": "http://example.org/vocab#"},
            "e:bool": false
          }),
          output: %([{
            "http://example.org/vocab#bool": [{"@value": false}]
          }])
        },
        "double": {
          input: %({
            "@context": {"e": "http://example.org/vocab#"},
            "e:double": 1.23
          }),
          output: %([{
            "http://example.org/vocab#double": [{"@value": 1.23}]
          }])
        },
        "double-zero": {
          input: %({
            "@context": {"e": "http://example.org/vocab#"},
            "e:double-zero": 0.0e0
          }),
          output: %([{
            "http://example.org/vocab#double-zero": [{"@value": 0.0e0}]
          }])
        },
        "integer": {
          input: %({
            "@context": {"e": "http://example.org/vocab#"},
            "e:integer": 123
          }),
          output: %([{
            "http://example.org/vocab#integer": [{"@value": 123}]
          }])
        },
      }.each do |title, params|
        it(title) {run_expand params}
      end

      context "with @type: @id" do
        {
          "true": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#bool", "@type": "@id"}},
              "e": true
            }),
            output:%( [{
              "http://example.org/vocab#bool": [{"@value": true}]
            }])
          },
          "false": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#bool", "@type": "@id"}},
              "e": false
            }),
            output: %([{
              "http://example.org/vocab#bool": [{"@value": false}]
            }])
          },
          "double": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#double", "@type": "@id"}},
              "e": 1.23
            }),
            output: %([{
              "http://example.org/vocab#double": [{"@value": 1.23}]
            }])
          },
          "double-zero": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#double", "@type": "@id"}},
              "e": 0.0e0
            }),
            output: %([{
              "http://example.org/vocab#double": [{"@value": 0.0e0}]
            }])
          },
          "integer": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#integer", "@type": "@id"}},
              "e": 123
            }),
            output: %([{
              "http://example.org/vocab#integer": [{"@value": 123}]
            }])
          },
        }.each do |title, params|
          it(title) {run_expand params}
        end
      end

      context "with @type: @vocab" do
        {
          "true": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#bool", "@type": "@vocab"}},
              "e": true
            }),
            output:%( [{
              "http://example.org/vocab#bool": [{"@value": true}]
            }])
          },
          "false": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#bool", "@type": "@vocab"}},
              "e": false
            }),
            output: %([{
              "http://example.org/vocab#bool": [{"@value": false}]
            }])
          },
          "double": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#double", "@type": "@vocab"}},
              "e": 1.23
            }),
            output: %([{
              "http://example.org/vocab#double": [{"@value": 1.23}]
            }])
          },
          "double-zero": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#double", "@type": "@vocab"}},
              "e": 0.0e0
            }),
            output: %([{
              "http://example.org/vocab#double": [{"@value": 0.0e0}]
            }])
          },
          "integer": {
            input: %({
              "@context": {"e": {"@id": "http://example.org/vocab#integer", "@type": "@vocab"}},
              "e": 123
            }),
            output: %([{
              "http://example.org/vocab#integer": [{"@value": 123}]
            }])
          },
        }.each do |title, params|
          it(title) {run_expand params}
        end
      end
    end

    context "coerced typed values" do
      {
        "boolean" => {
          input: {
            "@context" => {"foo" => {"@id" => "http://example.org/foo", "@type" => "http://www.w3.org/2001/XMLSchema#boolean"}},
            "foo" => "true"
          },
          output: [{
            "http://example.org/foo" => [{"@value" => "true", "@type" => "http://www.w3.org/2001/XMLSchema#boolean"}]
          }]
        },
        "date" => {
          input: {
            "@context" => {"foo" => {"@id" => "http://example.org/foo", "@type" => "http://www.w3.org/2001/XMLSchema#date"}},
            "foo" => "2011-03-26"
          },
          output: [{
            "http://example.org/foo" => [{"@value" => "2011-03-26", "@type" => "http://www.w3.org/2001/XMLSchema#date"}]
          }]
        },
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "null" do
      {
        "value" => {
          input: {"http://example.com/foo" => nil},
          output: []
        },
        "@value" => {
          input: {"http://example.com/foo" => {"@value" => nil}},
          output: []
        },
        "@value and non-null @type" => {
          input: {"http://example.com/foo" => {"@value" => nil, "@type" => "http://type"}},
          output: []
        },
        "@value and non-null @language" => {
          input: {"http://example.com/foo" => {"@value" => nil, "@language" => "en"}},
          output: []
        },
        "array with null elements" => {
          input: {
            "http://example.com/foo" => [nil]
          },
          output: [{
            "http://example.com/foo" => []
          }]
        },
        "@set with null @value" => {
          input: {
            "http://example.com/foo" => [
              {"@value" => nil, "@type" => "http://example.org/Type"}
            ]
          },
          output: [{
            "http://example.com/foo" => []
          }]
        }
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "default language" do
      {
        "value with coerced null language" => {
          input: {
            "@context" => {
              "@language" => "en",
              "ex" => "http://example.org/vocab#",
              "ex:german" => { "@language" => "de" },
              "ex:nolang" => { "@language" => nil }
            },
            "ex:german" => "german",
            "ex:nolang" => "no language"
          },
          output: [
            {
              "http://example.org/vocab#german" => [{"@value" => "german", "@language" => "de"}],
              "http://example.org/vocab#nolang" => [{"@value" => "no language"}]
            }
          ]
        },
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "default vocabulary" do
      {
        "property" => {
          input: {
            "@context" => {"@vocab" => "http://example.com/"},
            "verb" => {"@value" => "foo"}
          },
          output: [{
            "http://example.com/verb" => [{"@value" => "foo"}]
          }]
        },
        "datatype" => {
          input: {
            "@context" => {"@vocab" => "http://example.com/"},
            "http://example.org/verb" => {"@value" => "foo", "@type" => "string"}
          },
          output: [
            "http://example.org/verb" => [{"@value" => "foo", "@type" => "http://example.com/string"}]
          ]
        },
        "expand-0028" => {
          input: {
            "@context" => {
              "@vocab" => "http://example.org/vocab#",
              "date" => { "@type" => "dateTime" }
            },
            "@id" => "example1",
            "@type" => "test",
            "date" => "2011-01-25T00:00:00Z",
            "embed" => {
              "@id" => "example2",
              "expandedDate" => { "@value" => "2012-08-01T00:00:00Z", "@type" => "dateTime" }
            }
          },
          output: [
            {
              "@id" => "http://foo/bar/example1",
              "@type" => ["http://example.org/vocab#test"],
              "http://example.org/vocab#date" => [
                {
                  "@value" => "2011-01-25T00:00:00Z",
                  "@type" => "http://example.org/vocab#dateTime"
                }
              ],
              "http://example.org/vocab#embed" => [
                {
                  "@id" => "http://foo/bar/example2",
                  "http://example.org/vocab#expandedDate" => [
                    {
                      "@value" => "2012-08-01T00:00:00Z",
                      "@type" => "http://example.org/vocab#dateTime"
                    }
                  ]
                }
              ]
            }
          ]
        }
      }.each do |title, params|
        it(title) {run_expand params.merge(base: "http://foo/bar/")}
      end
    end

    context "unmapped properties" do
      {
        "unmapped key" => {
          input: {
            "foo" => "bar"
          },
          output: []
        },
        "unmapped @type as datatype" => {
          input: {
            "http://example.com/foo" => {"@value" => "bar", "@type" => "baz"}
          },
          output: [{
            "http://example.com/foo" => [{"@value" => "bar", "@type" => "http://example/baz"}]
          }]
        },
        "unknown keyword" => {
          input: {
            "@foo" => "bar"
          },
          output: []
        },
        "value" => {
          input: {
            "@context" => {"ex" => {"@id" => "http://example.org/idrange", "@type" => "@id"}},
            "@id" => "http://example.org/Subj",
            "idrange" => "unmapped"
          },
          output: []
        },
        "context reset" => {
          input: {
            "@context" => {"ex" => "http://example.org/", "prop" => "ex:prop"},
            "@id" => "http://example.org/id1",
            "prop" => "prop",
            "ex:chain" => {
              "@context" => nil,
              "@id" => "http://example.org/id2",
              "prop" => "prop"
            }
          },
          output: [{
            "@id" => "http://example.org/id1",
            "http://example.org/prop" => [{"@value" => "prop"}],
            "http://example.org/chain" => [{"@id" => "http://example.org/id2"}]
          }
        ]}
      }.each do |title, params|
        it(title) {run_expand params.merge(base: "http://example/")}
      end
    end

    context "@container: @index" do
      {
        "string annotation" => {
          input: {
            "@context" => {
              "container" => {
                "@id" => "http://example.com/container",
                "@container" => "@index"
              }
            },
            "@id" => "http://example.com/annotationsTest",
            "container" => {
              "en" => "The Queen",
              "de" => [ "Die Königin", "Ihre Majestät" ]
            }
          },
          output: [
            {
              "@id" => "http://example.com/annotationsTest",
              "http://example.com/container" => [
                {"@value" => "Die Königin", "@index" => "de"},
                {"@value" => "Ihre Majestät", "@index" => "de"},
                {"@value" => "The Queen", "@index" => "en"}
              ]
            }
          ]
        },
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "@container: @list" do
      {
        "empty" => {
          input: {"http://example.com/foo" => {"@list" => []}},
          output: [{"http://example.com/foo" => [{"@list" => []}]}]
        },
        "coerced empty" => {
          input: {
            "@context" => {"http://example.com/foo" => {"@container" => "@list"}},
            "http://example.com/foo" => []
          },
          output: [{"http://example.com/foo" => [{"@list" => []}]}]
        },
        "coerced single element" => {
          input: {
            "@context" => {"http://example.com/foo" => {"@container" => "@list"}},
            "http://example.com/foo" => [ "foo" ]
          },
          output: [{"http://example.com/foo" => [{"@list" => [{"@value" => "foo"}]}]}]
        },
        "coerced multiple elements" => {
          input: {
            "@context" => {"http://example.com/foo" => {"@container" => "@list"}},
            "http://example.com/foo" => [ "foo", "bar" ]
          },
          output: [{
            "http://example.com/foo" => [{"@list" => [ {"@value" => "foo"}, {"@value" => "bar"} ]}]
          }]
        },
        "native values in list" => {
          input: {
            "http://example.com/foo" => {"@list" => [1, 2]}
          },
          output: [{
            "http://example.com/foo" => [{"@list" => [{"@value" => 1}, {"@value" => 2}]}]
          }]
        },
        "explicit list with coerced @id values" => {
          input: {
            "@context" => {"http://example.com/foo" => {"@type" => "@id"}},
            "http://example.com/foo" => {"@list" => ["http://foo", "http://bar"]}
          },
          output: [{
            "http://example.com/foo" => [{"@list" => [{"@id" => "http://foo"}, {"@id" => "http://bar"}]}]
          }]
        },
        "explicit list with coerced datatype values" => {
          input: {
            "@context" => {"http://example.com/foo" => {"@type" => RDF::XSD.date.to_s}},
            "http://example.com/foo" => {"@list" => ["2012-04-12"]}
          },
          output: [{
            "http://example.com/foo" => [{"@list" => [{"@value" => "2012-04-12", "@type" => RDF::XSD.date.to_s}]}]
          }]
        },
        "expand-0004" => {
          input: %({
            "@context": {
              "mylist1": {"@id": "http://example.com/mylist1", "@container": "@list"},
              "mylist2": {"@id": "http://example.com/mylist2", "@container": "@list"},
              "myset2": {"@id": "http://example.com/myset2", "@container": "@set"},
              "myset3": {"@id": "http://example.com/myset3", "@container": "@set"}
            },
            "http://example.org/property": { "@list": "one item" }
          }),
          output: %([
            {
              "http://example.org/property": [
                {
                  "@list": [
                    {
                      "@value": "one item"
                    }
                  ]
                }
              ]
            }
          ])
        },
        "@list containing @list" => {
          input: {
            "http://example.com/foo" => {"@list" => [{"@list" => ["baz"]}]}
          },
          exception: JSON::LD::JsonLdError::ListOfLists
        },
        "@list containing @list (with coercion)" => {
          input: {
            "@context" => {"foo" => {"@id" => "http://example.com/foo", "@container" => "@list"}},
            "foo" => [{"@list" => ["baz"]}]
          },
          exception: JSON::LD::JsonLdError::ListOfLists
        },
        "coerced @list containing an array" => {
          input: {
            "@context" => {"foo" => {"@id" => "http://example.com/foo", "@container" => "@list"}},
            "foo" => [["baz"]]
          },
          exception: JSON::LD::JsonLdError::ListOfLists
        },
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "@container: @set" do
      {
        "empty" => {
          input: {
            "http://example.com/foo" => {"@set" => []}
          },
          output: [{
            "http://example.com/foo" => []
          }]
        },
        "coerced empty" => {
          input: {
            "@context" => {"http://example.com/foo" => {"@container" => "@set"}},
            "http://example.com/foo" => []
          },
          output: [{
            "http://example.com/foo" => []
          }]
        },
        "coerced single element" => {
          input: {
            "@context" => {"http://example.com/foo" => {"@container" => "@set"}},
            "http://example.com/foo" => [ "foo" ]
          },
          output: [{
            "http://example.com/foo" => [ {"@value" => "foo"} ]
          }]
        },
        "coerced multiple elements" => {
          input: {
            "@context" => {"http://example.com/foo" => {"@container" => "@set"}},
            "http://example.com/foo" => [ "foo", "bar" ]
          },
          output: [{
            "http://example.com/foo" => [ {"@value" => "foo"}, {"@value" => "bar"} ]
          }]
        },
        "array containing set" => {
          input: {
            "http://example.com/foo" => [{"@set" => []}]
          },
          output: [{
            "http://example.com/foo" => []
          }]
        },
        "Free-floating values in sets" => {
          input: %({
            "@context": {"property": "http://example.com/property"},
            "@graph": [{
                "@set": [
                    "free-floating strings in set objects are removed",
                    {"@id": "http://example.com/free-floating-node"},
                    {
                        "@id": "http://example.com/node",
                        "property": "nodes with properties are not removed"
                    }
                ]
            }]
          }),
          output: %([{
            "@id": "http://example.com/node",
            "http://example.com/property": [
              {
                "@value": "nodes with properties are not removed"
              }
            ]
          }])
        }
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "@container: @language" do
      {
        "simple map" => {
          input: {
            "@context" => {
              "vocab" => "http://example.com/vocab/",
              "label" => {
                "@id" => "vocab:label",
                "@container" => "@language"
              }
            },
            "@id" => "http://example.com/queen",
            "label" => {
              "en" => "The Queen",
              "de" => [ "Die Königin", "Ihre Majestät" ]
            }
          },
          output: [
            {
              "@id" => "http://example.com/queen",
              "http://example.com/vocab/label" => [
                {"@value" => "Die Königin", "@language" => "de"},
                {"@value" => "Ihre Majestät", "@language" => "de"},
                {"@value" => "The Queen", "@language" => "en"}
              ]
            }
          ]
        },
        "expand-0035" => {
          input: {
            "@context" => {
              "@vocab" => "http://example.com/vocab/",
              "@language" => "it",
              "label" => {
                "@container" => "@language"
              }
            },
            "@id" => "http://example.com/queen",
            "label" => {
              "en" => "The Queen",
              "de" => [ "Die Königin", "Ihre Majestät" ]
            },
            "http://example.com/vocab/label" => [
              "Il re",
              { "@value" => "The king", "@language" => "en" }
            ]
          },
          output: [
            {
              "@id" => "http://example.com/queen",
              "http://example.com/vocab/label" => [
                {"@value" => "Il re", "@language" => "it"},
                {"@value" => "The king", "@language" => "en"},
                {"@value" => "Die Königin", "@language" => "de"},
                {"@value" => "Ihre Majestät", "@language" => "de"},
                {"@value" => "The Queen", "@language" => "en"},
              ]
            }
          ]
        }
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "@container: @id" do
      {
        "Adds @id to object not having an @id" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "idmap": {"@container": "@id"}
            },
            "idmap": {
              "http://example.org/foo": {"label": "Object with @id <foo>"},
              "_:bar": {"label": "Object with @id _:bar"}
            }
          }),
          output: %([{
            "http://example/idmap": [
              {"http://example/label": [{"@value": "Object with @id _:bar"}], "@id": "_:bar"},
              {"http://example/label": [{"@value": "Object with @id <foo>"}], "@id": "http://example.org/foo"}
            ]
          }])
        },
        "Retains @id in object already having an @id" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "idmap": {"@container": "@id"}
            },
            "idmap": {
              "http://example.org/foo": {"@id": "http://example.org/bar", "label": "Object with @id <foo>"},
              "_:bar": {"@id": "_:foo", "label": "Object with @id _:bar"}
            }
          }),
          output: %([{
            "http://example/idmap": [
              {"@id": "_:foo", "http://example/label": [{"@value": "Object with @id _:bar"}]},
              {"@id": "http://example.org/bar", "http://example/label": [{"@value": "Object with @id <foo>"}]}
            ]
          }])
        },
        "Adds expanded @id to object" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "idmap": {"@container": "@id"}
            },
            "idmap": {
              "foo": {"label": "Object with @id <foo>"}
            }
          }),
          output: %([{
            "http://example/idmap": [
              {"http://example/label": [{"@value": "Object with @id <foo>"}], "@id": "http://example.org/foo"}
            ]
          }]),
          base: "http://example.org/"
        },
        "Raises InvalidContainerMapping if processingMode is not specified" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "idmap": {"@container": "@id"}
            },
            "idmap": {
              "http://example.org/foo": {"label": "Object with @id <foo>"},
              "_:bar": {"label": "Object with @id _:bar"}
            }
          }),
          processingMode: nil,
          exception: JSON::LD::JsonLdError::InvalidContainerMapping
        },
      }.each do |title, params|
        it(title) {run_expand({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "@container: @type" do
      {
        "Adds @type to object not having an @type" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"}
            },
            "typemap": {
              "http://example.org/foo": {"label": "Object with @type <foo>"},
              "_:bar": {"label": "Object with @type _:bar"}
            }
          }),
          output: %([{
            "http://example/typemap": [
              {"http://example/label": [{"@value": "Object with @type _:bar"}], "@type": ["_:bar"]},
              {"http://example/label": [{"@value": "Object with @type <foo>"}], "@type": ["http://example.org/foo"]}
            ]
          }])
        },
        "Prepends @type in object already having an @type" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"}
            },
            "typemap": {
              "http://example.org/foo": {"@type": "http://example.org/bar", "label": "Object with @type <foo>"},
              "_:bar": {"@type": "_:foo", "label": "Object with @type _:bar"}
            }
          }),
          output: %([{
            "http://example/typemap": [
              {
                "@type": ["_:bar", "_:foo"],
                "http://example/label": [{"@value": "Object with @type _:bar"}]
              },
              {
                "@type": ["http://example.org/foo", "http://example.org/bar"],
                "http://example/label": [{"@value": "Object with @type <foo>"}]
              }
            ]
          }])
        },
        "Adds vocabulary expanded @type to object" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"}
            },
            "typemap": {
              "Foo": {"label": "Object with @type <foo>"}
            }
          }),
          output: %([{
            "http://example/typemap": [
              {"http://example/label": [{"@value": "Object with @type <foo>"}], "@type": ["http://example/Foo"]}
            ]
          }])
        },
        "Adds document expanded @type to object" => {
          input: %({
            "@context": {
              "typemap": {"@id": "http://example/typemap", "@container": "@type"},
              "label": "http://example/label"
            },
            "typemap": {
              "Foo": {"label": "Object with @type <foo>"}
            }
          }),
          output: %([{
            "http://example/typemap": [
              {"http://example/label": [{"@value": "Object with @type <foo>"}], "@type": ["http://example.org/Foo"]}
            ]
          }]),
          base: "http://example.org/"
        },
        "Raises InvalidContainerMapping if processingMode is not specified" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"}
            },
            "typemap": {
              "http://example.org/foo": {"label": "Object with @type <foo>"},
              "_:bar": {"label": "Object with @type _:bar"}
            }
          }),
          processingMode: nil,
          exception: JSON::LD::JsonLdError::InvalidContainerMapping
        },
      }.each do |title, params|
        it(title) {run_expand({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "@container: @graph" do
      {
        "Creates a graph object given a value" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "input": {"@container": "@graph"}
            },
            "input": {
              "value": "x"
            }
          }),
          output: %([{
            "http://example.org/input": [{
              "@graph": [{
                "http://example.org/value": [{"@value": "x"}]
              }]
            }]
          }])
        },
        "Creates a graph object within an array given a value" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@set"]}
            },
            "input": {
              "value": "x"
            }
          }),
          output: %([{
            "http://example.org/input": [{
              "@graph": [{
                "http://example.org/value": [{"@value": "x"}]
              }]
            }]
          }])
        },
        "Does not create an graph object if value is a graph" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "input": {"@container": "@graph"}
            },
            "input": {
              "@graph": {
                "value": "x"
              }
            }
          }),
          output: %([{
            "http://example.org/input": [{
              "@graph": [{
                "http://example.org/value": [{"@value": "x"}]
              }]
            }]
          }])
        },
      }.each do |title, params|
        it(title) {run_expand({processingMode: "json-ld-1.1"}.merge(params))}
      end

      context "+ @index" do
        {
          "Creates a graph object given an indexed value" => {
            input: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@index"]}
              },
              "input": {
                "g1": {"value": "x"}
              }
            }),
            output: %([{
              "http://example.org/input": [{
                "@index": "g1",
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }])
          },
          "Creates a graph object given an indexed value with @set" => {
            input: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@index", "@set"]}
              },
              "input": {
                "g1": {"value": "x"}
              }
            }),
            output: %([{
              "http://example.org/input": [{
                "@index": "g1",
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }])
          },
          "Does not create a new graph object if indexed value is already a graph object" => {
            input: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@index"]}
              },
              "input": {
                "g1": {
                  "@graph": {
                    "value": "x"
                  }
                }
              }
            }),
            output: %([{
              "http://example.org/input": [{
                "@index": "g1",
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }])
          },
        }.each do |title, params|
          it(title) {run_expand({processingMode: "json-ld-1.1"}.merge(params))}
        end
      end

      context "+ @id" do
        {
          "Creates a graph object given an indexed value" => {
            input: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@id"]}
              },
              "input": {
                "http://example.com/g1": {"value": "x"}
              }
            }),
            output: %([{
              "http://example.org/input": [{
                "@id": "http://example.com/g1",
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }])
          },
          "Creates a graph object given an indexed value with @set" => {
            input: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@id", "@set"]}
              },
              "input": {
                "http://example.com/g1": {"value": "x"}
              }
            }),
            output: %([{
              "http://example.org/input": [{
                "@id": "http://example.com/g1",
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }])
          },
          "Does not create a new graph object if indexed value is already a graph object" => {
            input: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@id"]}
              },
              "input": {
                "http://example.com/g1": {
                  "@graph": {
                    "value": "x"
                  }
                }
              }
            }),
            output: %([{
              "http://example.org/input": [{
                "@id": "http://example.com/g1",
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }])
          },
        }.each do |title, params|
          it(title) {run_expand({processingMode: "json-ld-1.1"}.merge(params))}
        end
      end
    end

    context "@nest" do
      {
        "Expands input using @nest" => {
          input: %({
            "@context": {"@vocab": "http://example.org/"},
            "p1": "v1",
            "@nest": {
              "p2": "v2"
            }
          }),
          output: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [{"@value": "v2"}]
          }])
        },
        "Expands input using aliased @nest" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest": "@nest"
            },
            "p1": "v1",
            "nest": {
              "p2": "v2"
            }
          }),
          output: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [{"@value": "v2"}]
          }])
        },
        "Appends nested values when property at base and nested" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest": "@nest"
            },
            "p1": "v1",
            "nest": {
              "p2": "v3"
            },
            "p2": "v2"
          }),
          output: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [
              {"@value": "v2"},
              {"@value": "v3"}
            ]
          }])
        },
        "Appends nested values from all @nest aliases in term order" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest1": "@nest",
              "nest2": "@nest"
            },
            "p1": "v1",
            "nest2": {
              "p2": "v4"
            },
            "p2": "v2",
            "nest1": {
              "p2": "v3"
            }
          }),
          output: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [
              {"@value": "v2"},
              {"@value": "v3"},
              {"@value": "v4"}
            ]
          }])
        },
        "Nested nested containers" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/"
            },
            "p1": "v1",
            "@nest": {
              "p2": "v3",
              "@nest": {
                "p2": "v4"
              }
            },
            "p2": "v2"
          }),
          output: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [
              {"@value": "v2"},
              {"@value": "v3"},
              {"@value": "v4"}
            ]
          }])
        },
        "Arrays of nested values" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest": "@nest"
            },
            "p1": "v1",
            "nest": {
              "p2": ["v4", "v5"]
            },
            "p2": ["v2", "v3"]
          }),
          output: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [
              {"@value": "v2"},
              {"@value": "v3"},
              {"@value": "v4"},
              {"@value": "v5"}
            ]
          }])
        },
        "A nest of arrays" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest": "@nest"
            },
            "p1": "v1",
            "nest": [{
              "p2": "v4"
            }, {
              "p2": "v5"
            }],
            "p2": ["v2", "v3"]
          }),
          output: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [
              {"@value": "v2"},
              {"@value": "v3"},
              {"@value": "v4"},
              {"@value": "v5"}
            ]
          }])
        },
        "@nest MUST NOT have a string value" => {
          input: %({
            "@context": {"@vocab": "http://example.org/"},
            "@nest": "This should generate an error"
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
        "@nest MUST NOT have a boolen value" => {
          input: %({
            "@context": {"@vocab": "http://example.org/"},
            "@nest": true
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
        "@nest MUST NOT have a numeric value" => {
          input: %({
            "@context": {"@vocab": "http://example.org/"},
            "@nest": 1
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
        "@nest MUST NOT have a value object value" => {
          input: %({
            "@context": {"@vocab": "http://example.org/"},
            "@nest": {"@value": "This should generate an error"}
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
        "@nest in term definition MUST NOT be a non-@nest keyword" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest": {"@nest": "@id"}
            },
            "nest": "This should generate an error"
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
        "@nest in term definition MUST NOT have a boolen value" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest": {"@nest": true}
            },
            "nest": "This should generate an error"
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
        "@nest in term definition MUST NOT have a numeric value" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest": {"@nest": 123}
            },
            "nest": "This should generate an error"
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
        "Nested @container: @list" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "list": {"@container": "@list", "@nest": "nestedlist"},
              "nestedlist": "@nest"
            },
            "nestedlist": {
              "list": ["a", "b"]
            }
          }),
          output: %([{
            "http://example.org/list": [{"@list": [
              {"@value": "a"},
              {"@value": "b"}
            ]}]
          }])
        },
        "Nested @container: @index" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "index": {"@container": "@index", "@nest": "nestedindex"},
              "nestedindex": "@nest"
            },
            "nestedindex": {
              "index": {
                "A": "a",
                "B": "b"
              }
            }
          }),
          output: %([{
            "http://example.org/index": [
              {"@value": "a", "@index": "A"},
              {"@value": "b", "@index": "B"}
            ]
          }])
        },
        "Nested @container: @language" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "container": {"@container": "@language", "@nest": "nestedlanguage"},
              "nestedlanguage": "@nest"
            },
            "nestedlanguage": {
              "container": {
                "en": "The Queen",
                "de": "Die Königin"
              }
            }
          }),
          output: %([{
            "http://example.org/container": [
              {"@value": "Die Königin", "@language": "de"},
              {"@value": "The Queen", "@language": "en"}
            ]
          }])
        },
        "Nested @container: @type" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type", "@nest": "nestedtypemap"},
              "nestedtypemap": "@nest"
            },
            "nestedtypemap": {
              "typemap": {
                "http://example.org/foo": {"label": "Object with @type <foo>"},
                "_:bar": {"label": "Object with @type _:bar"}
              }
            }
          }),
          output: %([{
            "http://example/typemap": [
              {"http://example/label": [{"@value": "Object with @type _:bar"}], "@type": ["_:bar"]},
              {"http://example/label": [{"@value": "Object with @type <foo>"}], "@type": ["http://example.org/foo"]}
            ]
          }])
        },
        "Nested @container: @id" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "idmap": {"@container": "@id", "@nest": "nestedidmap"},
              "nestedidmap": "@nest"
            },
            "nestedidmap": {
              "idmap": {
                "http://example.org/foo": {"label": "Object with @id <foo>"},
                "_:bar": {"label": "Object with @id _:bar"}
              }
            }
          }),
          output: %([{
            "http://example/idmap": [
              {"http://example/label": [{"@value": "Object with @id _:bar"}], "@id": "_:bar"},
              {"http://example/label": [{"@value": "Object with @id <foo>"}], "@id": "http://example.org/foo"}
            ]
          }])
        },
        "Nest term an invalid keyword" => {
          input: %({
            "@context": {
              "term": {"@id": "http://example/term", "@nest": "@id"}
            }
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
        "Nest in @reverse" => {
          input: %({
            "@context": {
              "term": {"@reverse": "http://example/term", "@nest": "@nest"}
            }
          }),
          exception: JSON::LD::JsonLdError::InvalidReverseProperty
        },
        "Raises InvalidTermDefinition if processingMode is not specified" => {
          input: %({
            "@context": {
              "@vocab": "http://example.org/",
              "list": {"@container": "@list", "@nest": "nestedlist"},
              "nestedlist": "@nest"
            },
            "nestedlist": {
              "list": ["a", "b"]
            }
          }),
          processingMode: nil,
          validate: true,
          exception: JSON::LD::JsonLdError::InvalidTermDefinition
        },
      }.each do |title, params|
        it(title) {run_expand({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "scoped context" do
      {
        "adding new term" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "foo": {"@context": {"bar": "http://example.org/bar"}}
            },
            "foo": {
              "bar": "baz"
            }
          }),
          output: %([
            {
              "http://example/foo": [{"http://example.org/bar": [{"@value": "baz"}]}]
            }
          ])
        },
        "overriding a term" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "foo": {"@context": {"bar": {"@type": "@id"}}},
              "bar": {"@type": "http://www.w3.org/2001/XMLSchema#string"}
            },
            "foo": {
              "bar": "http://example/baz"
            }
          }),
          output: %([
            {
              "http://example/foo": [{"http://example/bar": [{"@id": "http://example/baz"}]}]
            }
          ])
        },
        "property and value with different terms mapping to the same expanded property" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "foo": {"@context": {"Bar": {"@id": "bar"}}}
            },
            "foo": {
              "Bar": "baz"
            }
          }),
          output: %([
            {
              "http://example/foo": [{
                "http://example/bar": [
                  {"@value": "baz"}
                ]}
              ]
            }
          ])
        },
        "deep @context affects nested nodes" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "foo": {"@context": {"baz": {"@type": "@vocab"}}}
            },
            "foo": {
              "bar": {
                "baz": "buzz"
              }
            }
          }),
          output: %([
            {
              "http://example/foo": [{
                "http://example/bar": [{
                  "http://example/baz": [{"@id": "http://example/buzz"}]
                }]
              }]
            }
          ])
        },
        "scoped context layers on intemediate contexts" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "b": {"@context": {"c": "http://example.org/c"}}
            },
            "a": {
              "@context": {"@vocab": "http://example.com/"},
              "b": {
                "a": "A in example.com",
                "c": "C in example.org"
              },
              "c": "C in example.com"
            },
            "c": "C in example"
          }),
          output: %([{
            "http://example/a": [{
              "http://example.com/c": [{"@value": "C in example.com"}],
              "http://example/b": [{
                "http://example.com/a": [{"@value": "A in example.com"}],
                "http://example.org/c": [{"@value": "C in example.org"}]
              }]
            }],
            "http://example/c": [{"@value": "C in example"}]
          }])
        },
        "Raises InvalidTermDefinition if processingMode is not specified" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "foo": {"@context": {"bar": "http://example.org/bar"}}
            },
            "foo": {
              "bar": "baz"
            }
          }),
          processingMode: nil,
          validate: true,
          exception: JSON::LD::JsonLdError::InvalidTermDefinition
        },
      }.each do |title, params|
        it(title) {run_expand({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "scoped context on @type" do
      {
        "adding new term" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "Foo": {"@context": {"bar": "http://example.org/bar"}}
            },
            "a": {"@type": "Foo", "bar": "baz"}
          }),
          output: %([
            {
              "http://example/a": [{
                "@type": ["http://example/Foo"],
                "http://example.org/bar": [{"@value": "baz"}]
              }]
            }
          ])
        },
        "overriding a term" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "Foo": {"@context": {"bar": {"@type": "@id"}}},
              "bar": {"@type": "http://www.w3.org/2001/XMLSchema#string"}
            },
            "a": {"@type": "Foo", "bar": "http://example/baz"}
          }),
          output: %([
            {
              "http://example/a": [{
                "@type": ["http://example/Foo"],
                "http://example/bar": [{"@id": "http://example/baz"}]
              }]
            }
          ])
        },
        "alias of @type" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "type": "@type",
              "Foo": {"@context": {"bar": "http://example.org/bar"}}
            },
            "a": {"type": "Foo", "bar": "baz"}
          }),
          output: %([
            {
              "http://example/a": [{
                "@type": ["http://example/Foo"],
                "http://example.org/bar": [{"@value": "baz"}]
              }]
            }
          ])
        },
        "deep @context affects nested nodes" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "Foo": {"@context": {"baz": {"@type": "@vocab"}}}
            },
            "@type": "Foo",
            "bar": {"baz": "buzz"}
          }),
          output: %([
            {
              "@type": ["http://example/Foo"],
              "http://example/bar": [{
                "http://example/baz": [{"@id": "http://example/buzz"}]
              }]
            }
          ])
        },
        "scoped context layers on intemediate contexts" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "B": {"@context": {"c": "http://example.org/c"}}
            },
            "a": {
              "@context": {"@vocab": "http://example.com/"},
              "@type": "B",
              "a": "A in example.com",
              "c": "C in example.org"
            },
            "c": "C in example"
          }),
          output: %([{
            "http://example/a": [{
              "@type": ["http://example/B"],
              "http://example.com/a": [{"@value": "A in example.com"}],
              "http://example.org/c": [{"@value": "C in example.org"}]
            }],
            "http://example/c": [{"@value": "C in example"}]
          }])
        },
        "with @container: @type" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"},
              "Type": {"@context": {"a": "http://example.org/a"}}
            },
            "typemap": {
              "Type": {"a": "Object with @type <Type>"}
            }
          }),
          output: %([{
            "http://example/typemap": [
              {"http://example.org/a": [{"@value": "Object with @type <Type>"}], "@type": ["http://example/Type"]}
            ]
          }])
        },
        "Raises InvalidTermDefinition if processingMode is not specified" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "Foo": {"@context": {"bar": "http://example.org/bar"}}
            },
            "a": {"@type": "Foo", "bar": "baz"}
          }),
          processingMode: nil,
          validate: true,
          exception: JSON::LD::JsonLdError::InvalidTermDefinition
        },
      }.each do |title, params|
        it(title) {run_expand({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "@reverse" do
      {
        "@container: @reverse" => {
          input: %({
            "@context": {
              "@vocab": "http://example/",
              "rev": { "@reverse": "forward", "@type": "@id"}
            },
            "@id": "http://example/one",
            "rev": "http://example/two"
          }),
          output: %([{
            "@id": "http://example/one",
            "@reverse": {
              "http://example/forward": [
                {
                  "@id": "http://example/two"
                }
              ]
            }
          }])
        },
        "expand-0037" => {
          input: %({
            "@context": {
              "name": "http://xmlns.com/foaf/0.1/name"
            },
            "@id": "http://example.com/people/markus",
            "name": "Markus Lanthaler",
            "@reverse": {
              "http://xmlns.com/foaf/0.1/knows": {
                "@id": "http://example.com/people/dave",
                "name": "Dave Longley"
              }
            }
          }),
          output: %([
            {
              "@id": "http://example.com/people/markus",
              "@reverse": {
                "http://xmlns.com/foaf/0.1/knows": [
                  {
                    "@id": "http://example.com/people/dave",
                    "http://xmlns.com/foaf/0.1/name": [
                      {
                        "@value": "Dave Longley"
                      }
                    ]
                  }
                ]
              },
              "http://xmlns.com/foaf/0.1/name": [
                {
                  "@value": "Markus Lanthaler"
                }
              ]
            }
          ])
        },
        "expand-0043" => {
          input: %({
            "@context": {
              "name": "http://xmlns.com/foaf/0.1/name",
              "isKnownBy": { "@reverse": "http://xmlns.com/foaf/0.1/knows" }
            },
            "@id": "http://example.com/people/markus",
            "name": "Markus Lanthaler",
            "@reverse": {
              "isKnownBy": [
                {
                  "@id": "http://example.com/people/dave",
                  "name": "Dave Longley"
                },
                {
                  "@id": "http://example.com/people/gregg",
                  "name": "Gregg Kellogg"
                }
              ]
            }
          }),
          output: %([
            {
              "@id": "http://example.com/people/markus",
              "http://xmlns.com/foaf/0.1/knows": [
                {
                  "@id": "http://example.com/people/dave",
                  "http://xmlns.com/foaf/0.1/name": [
                    {
                      "@value": "Dave Longley"
                    }
                  ]
                },
                {
                  "@id": "http://example.com/people/gregg",
                  "http://xmlns.com/foaf/0.1/name": [
                    {
                      "@value": "Gregg Kellogg"
                    }
                  ]
                }
              ],
              "http://xmlns.com/foaf/0.1/name": [
                {
                  "@value": "Markus Lanthaler"
                }
              ]
            }
          ])
        },
        "@reverse object with an @id property" => {
          input: %({
            "@id": "http://example/foo",
            "@reverse": {
              "@id": "http://example/bar"
            }
          }),
          exception: JSON::LD::JsonLdError::InvalidReversePropertyMap,
        },
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end

    context "exceptions" do
      {
        "non-null @value and null @type" => {
          input: {"http://example.com/foo" => {"@value" => "foo", "@type" => nil}},
          exception: JSON::LD::JsonLdError::InvalidTypeValue
        },
        "non-null @value and null @language" => {
          input: {"http://example.com/foo" => {"@value" => "foo", "@language" => nil}},
          exception: JSON::LD::JsonLdError::InvalidLanguageTaggedString
        },
        "value with null language" => {
          input: {
            "@context" => {"@language" => "en"},
            "http://example.org/nolang" => {"@value" => "no language", "@language" => nil}
          },
          exception: JSON::LD::JsonLdError::InvalidLanguageTaggedString
        },
        "colliding keywords" => {
          input: %({
            "@context": {
              "id": "@id",
              "ID": "@id"
            },
            "id": "http://example/foo",
            "ID": "http://example/bar"
          }),
          exception: JSON::LD::JsonLdError::CollidingKeywords,
        }
      }.each do |title, params|
        it(title) {run_expand params}
      end
    end
  end

  def run_expand(params)
    input, output, processingMode = params[:input], params[:output], params[:processingMode]
    input = ::JSON.parse(input) if input.is_a?(String)
    output = ::JSON.parse(output) if output.is_a?(String)
    pending params.fetch(:pending, "test implementation") unless input
    if params[:exception]
      expect {JSON::LD::API.expand(input, {processingMode: processingMode}.merge(params))}.to raise_error(params[:exception])
    else
      jld = JSON::LD::API.expand(input, base: params[:base], logger: logger, processingMode: processingMode)
      expect(jld).to produce(output, logger)
    end
  end
end
