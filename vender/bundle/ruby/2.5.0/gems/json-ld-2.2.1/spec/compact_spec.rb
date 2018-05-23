# coding: utf-8
require_relative 'spec_helper'

describe JSON::LD::API do
  let(:logger) {RDF::Spec.logger}

  describe ".compact" do
    {
      "prefix" => {
        input: %({
          "@id": "http://example.com/a",
          "http://example.com/b": {"@id": "http://example.com/c"}
        }),
        context: %({"ex": "http://example.com/"}),
        output: %({
          "@context": {"ex": "http://example.com/"},
          "@id": "ex:a",
          "ex:b": {"@id": "ex:c"}
        })
      },
      "term" => {
        input: %({
          "@id": "http://example.com/a",
          "http://example.com/b": {"@id": "http://example.com/c"}
        }),
        context: %({"b": "http://example.com/b"}),
        output: %({
          "@context": {"b": "http://example.com/b"},
          "@id": "http://example.com/a",
          "b": {"@id": "http://example.com/c"}
        })
      },
      "integer value" => {
        input: %({
          "@id": "http://example.com/a",
          "http://example.com/b": {"@value": 1}
        }),
        context: %({"b": "http://example.com/b"}),
        output: %({
          "@context": {"b": "http://example.com/b"},
          "@id": "http://example.com/a",
          "b": 1
        })
      },
      "boolean value" => {
        input: %({
          "@id": "http://example.com/a",
          "http://example.com/b": {"@value": true}
        }),
        context: %({"b": "http://example.com/b"}),
        output: %({
          "@context": {"b": "http://example.com/b"},
          "@id": "http://example.com/a",
          "b": true
        })
      },
      "@id" => {
        input: %({"@id": "http://example.org/test#example"}),
        context: {},
        output: {}
      },
      "@id coercion" => {
        input: %({
          "@id": "http://example.com/a",
          "http://example.com/b": {"@id": "http://example.com/c"}
        }),
        context: %({"b": {"@id": "http://example.com/b", "@type": "@id"}}),
        output: %({
          "@context": {"b": {"@id": "http://example.com/b", "@type": "@id"}},
          "@id": "http://example.com/a",
          "b": "http://example.com/c"
        })
      },
      "xsd:date coercion" => {
        input: %({
          "http://example.com/b": {"@value": "2012-01-04", "@type": "http://www.w3.org/2001/XMLSchema#date"}
        }),
        context: %({
          "xsd": "http://www.w3.org/2001/XMLSchema#",
          "b": {"@id": "http://example.com/b", "@type": "xsd:date"}
        }),
        output: %({
          "@context": {
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "b": {"@id": "http://example.com/b", "@type": "xsd:date"}
          },
          "b": "2012-01-04"
        })
      },
      "@list coercion": {
        input: %({
          "http://example.com/b": {"@list": ["c", "d"]}
        }),
        context: %({"b": {"@id": "http://example.com/b", "@container": "@list"}}),
        output: %({
          "@context": {"b": {"@id": "http://example.com/b", "@container": "@list"}},
          "b": ["c", "d"]
        })
      },
      "@list coercion (integer)" => {
        input: %({
          "http://example.com/term": [
            {"@list": [1]}
          ]
        }),
        context: %({
          "term4": {"@id": "http://example.com/term", "@container": "@list"},
          "@language": "de"
        }),
        output: %({
          "@context": {
            "term4": {"@id": "http://example.com/term", "@container": "@list"},
            "@language": "de"
          },
          "term4": [1]
        })
      },
      "@set coercion" => {
        input: %({
          "http://example.com/b": {"@set": ["c"]}
        }),
        context: %({"b": {"@id": "http://example.com/b", "@container": "@set"}}),
        output: %({
          "@context": {"b": {"@id": "http://example.com/b", "@container": "@set"}},
          "b": ["c"]
        })
      },
      "empty @set coercion" => {
        input: %({
          "http://example.com/b": []
        }),
        context: %({"b": {"@id": "http://example.com/b", "@container": "@set"}}),
        output: %({
          "@context": {"b": {"@id": "http://example.com/b", "@container": "@set"}},
          "b": []
        })
      },
      "@type with string @id" => {
        input: %({
          "@id": "http://example.com/",
          "@type": "#{RDF::RDFS.Resource}"
        }),
        context: {},
        output: %({
          "@id": "http://example.com/",
          "@type": "#{RDF::RDFS.Resource}"
        }),
      },
      "@type with array @id" => {
        input: %({
          "@id": "http://example.com/",
          "@type": ["#{RDF::RDFS.Resource}"]
        }),
        context: {},
        output: %({
          "@id": "http://example.com/",
          "@type": "#{RDF::RDFS.Resource}"
        }),
      },
      "default language" => {
        input: %({
          "http://example.com/term": [
            "v5",
            {"@value": "plain literal"}
          ]
        }),
        context: %({
          "term5": {"@id": "http://example.com/term", "@language": null},
          "@language": "de"
        }),
        output: %({
          "@context": {
            "term5": {"@id": "http://example.com/term", "@language": null},
            "@language": "de"
          },
          "term5": [ "v5", "plain literal" ]
        })
      },
    }.each_pair do |title, params|
      it(title) {run_compact(params)}
    end

    context "keyword aliasing" do
      {
        "@id" => {
          input: %({
            "@id": "",
            "@type": "#{RDF::RDFS.Resource}"
          }),
          context: %({"id": "@id"}),
          output: %({
            "@context": {"id": "@id"},
            "id": "",
            "@type": "#{RDF::RDFS.Resource}"
          })
        },
        "@type": {
          input: %({
            "@type": "http://www.w3.org/2000/01/rdf-schema#Resource",
            "http://example.org/foo": {"@value": "bar", "@type": "http://example.com/type"}
          }),
          context: %({"type": "@type"}),
          output: %({
            "@context": {"type": "@type"},
            "type": "http://www.w3.org/2000/01/rdf-schema#Resource",
            "http://example.org/foo": {"@value": "bar", "type": "http://example.com/type"}
          })
        },
        "@language" => {
          input: %({
            "http://example.org/foo": {"@value": "bar", "@language": "baz"}
          }),
          context: %({"language": "@language"}),
          output: %({
            "@context": {"language": "@language"},
            "http://example.org/foo": {"@value": "bar", "language": "baz"}
          })
        },
        "@value" => {
          input: %({
            "http://example.org/foo": {"@value": "bar", "@language": "baz"}
          }),
          context: %({"literal": "@value"}),
          output: %({
            "@context": {"literal": "@value"},
            "http://example.org/foo": {"literal": "bar", "@language": "baz"}
          })
        },
        "@list" => {
          input: %({
            "http://example.org/foo": {"@list": ["bar"]}
          }),
          context: %({"list": "@list"}),
          output: %({
            "@context": {"list": "@list"},
            "http://example.org/foo": {"list": ["bar"]}
          })
        },
      }.each do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "term selection" do
      {
        "Uses term with null language when two terms conflict on language" => {
          input: %([{
            "http://example.com/term": {"@value": "v1"}
          }]),
          context: %({
            "term5": {"@id": "http://example.com/term","@language": null},
            "@language": "de"
          }),
          output: %({
            "@context": {
              "term5": {"@id": "http://example.com/term","@language": null},
              "@language": "de"
            },
            "term5": "v1"
          })
        },
        "Uses subject alias" => {
          input: %([{
            "@id": "http://example.com/id1",
            "http://example.com/id1": {"@value": "foo", "@language": "de"}
          }]),
          context: %({
            "id1": "http://example.com/id1",
            "@language": "de"
          }),
          output: %({
            "@context": {
              "id1": "http://example.com/id1",
              "@language": "de"
            },
            "@id": "http://example.com/id1",
            "id1": "foo"
          })
        },
        "compact-0007" => {
          input: %(
            {"http://example.org/vocab#contains": "this-is-not-an-IRI"}
          ),
          context: %({
            "ex": "http://example.org/vocab#",
            "ex:contains": {"@type": "@id"}
          }),
          output: %({
            "@context": {
              "ex": "http://example.org/vocab#",
              "ex:contains": {"@type": "@id"}
            },
            "http://example.org/vocab#contains": "this-is-not-an-IRI"
          })
        }
      }.each_pair do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "IRI Compaction" do
      {
        "Expands and compacts to document base in 1.0" => {
          input: %({
            "@id": "a",
            "http://example.com/b": {"@id": "c"}
          }),
          context: %({"b": "http://example.com/b"}),
          output: %({
            "@context": {"b": "http://example.com/b"},
            "@id": "a",
            "b": {"@id": "c"}
          }),
          base: "http://example.org/"
        },
        "Expands and compacts to document base in 1.1 with compactToRelative true" => {
          input: %({
            "@id": "a",
            "http://example.com/b": {"@id": "c"}
          }),
          context: %({"b": "http://example.com/b"}),
          output: %({
            "@context": {"b": "http://example.com/b"},
            "@id": "a",
            "b": {"@id": "c"}
          }),
          base: "http://example.org/",
          compactToRelative: true,
          processingMode: 'json-ld-1.1'
        },
        "Expands but does not compact to document base in 1.1 with compactToRelative false" => {
          input: %({
            "@id": "http://example.org/a",
            "http://example.com/b": {"@id": "http://example.org/c"}
          }),
          context: %({"b": "http://example.com/b"}),
          output: %({
            "@context": {"b": "http://example.com/b"},
            "@id": "http://example.org/a",
            "b": {"@id": "http://example.org/c"}
          }),
          compactToRelative: false,
          processingMode: 'json-ld-1.1'
        },
        "Expands and compacts to document base in 1.1 by default" => {
          input: %({
            "@id": "a",
            "http://example.com/b": {"@id": "c"}
          }),
          context: %({"b": "http://example.com/b"}),
          output: %({
            "@context": {"b": "http://example.com/b"},
            "@id": "a",
            "b": {"@id": "c"}
          }),
          base: "http://example.org/",
          processingMode: 'json-ld-1.1'
        },
      }.each_pair do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "@container: @reverse" do
      {
        "@container: @reverse" => {
          input: %([{
            "@id": "http://example/one",
            "@reverse": {
              "http://example/forward": [
                {
                  "@id": "http://example/two"
                }
              ]
            }
          }]),
          context: %({
            "@vocab": "http://example/",
            "rev": { "@reverse": "forward", "@type": "@id"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "rev": { "@reverse": "forward", "@type": "@id"}
            },
            "@id": "http://example/one",
            "rev": "http://example/two"
          })
        },
        "compact-0033" => {
          input: %([
            {
              "@id": "http://example.com/people/markus",
              "@reverse": {
                "http://xmlns.com/foaf/0.1/knows": [
                  {
                    "@id": "http://example.com/people/dave",
                    "http://xmlns.com/foaf/0.1/name": [ { "@value": "Dave Longley" } ]
                  }
                ]
              },
              "http://xmlns.com/foaf/0.1/name": [ { "@value": "Markus Lanthaler" } ]
            }
          ]),
          context: %({
            "name": "http://xmlns.com/foaf/0.1/name",
            "isKnownBy": { "@reverse": "http://xmlns.com/foaf/0.1/knows" }
          }),
          output: %({
            "@context": {
              "name": "http://xmlns.com/foaf/0.1/name",
              "isKnownBy": {
                "@reverse": "http://xmlns.com/foaf/0.1/knows"
              }
            },
            "@id": "http://example.com/people/markus",
            "name": "Markus Lanthaler",
            "isKnownBy": {
              "@id": "http://example.com/people/dave",
              "name": "Dave Longley"
            }
          })
        }
      }.each_pair do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "context as value" do
      {
        "includes the context in the output document" => {
          input: %({
            "http://example.com/": "bar"
          }),
          context: %({
            "foo": "http://example.com/"
          }),
          output: %({
            "@context": {
              "foo": "http://example.com/"
            },
            "foo": "bar"
          })
        }
      }.each_pair do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "context as reference" do
      let(:remote_doc) do
        JSON::LD::API::RemoteDocument.new("http://example.com/context", %q({"@context": {"b": "http://example.com/b"}}))
      end
      it "uses referenced context" do
        input = ::JSON.parse %({
          "http://example.com/b": "c"
        })
        expected = ::JSON.parse %({
          "@context": "http://example.com/context",
          "b": "c"
        })
        allow(JSON::LD::API).to receive(:documentLoader).with("http://example.com/context", anything).and_yield(remote_doc)
        jld = JSON::LD::API.compact(input, "http://example.com/context", logger: logger, validate: true)
        expect(jld).to produce(expected, logger)
      end
    end

    context "@list" do
      {
        "1 term 2 lists 2 languages" => {
          input: %([{
            "http://example.com/foo": [
              {"@list": [{"@value": "en", "@language": "en"}]},
              {"@list": [{"@value": "de", "@language": "de"}]}
            ]
          }]),
          context: %({
            "foo_en": {"@id": "http://example.com/foo", "@container": "@list", "@language": "en"},
            "foo_de": {"@id": "http://example.com/foo", "@container": "@list", "@language": "de"}
          }),
          output: %({
            "@context": {
              "foo_en": {"@id": "http://example.com/foo", "@container": "@list", "@language": "en"},
              "foo_de": {"@id": "http://example.com/foo", "@container": "@list", "@language": "de"}
            },
            "foo_en": ["en"],
            "foo_de": ["de"]
          })
        },
      }.each_pair do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "@container: @index" do
      {
        "compact-0029" => {
          input: %([{
             "@id": "http://example.com/article",
             "http://example.com/vocab/author": [{
                "@id": "http://example.org/person/1",
                "@index": "regular"
             }, {
                "@id": "http://example.org/guest/cd24f329aa",
                "@index": "guest"
             }]
          }]),
          context: %({
            "author": {"@id": "http://example.com/vocab/author", "@container": "@index" }
          }),
          output: %({
            "@context": {
              "author": {
                "@id": "http://example.com/vocab/author",
                "@container": "@index"
              }
            },
            "@id": "http://example.com/article",
            "author": {
              "regular": {
                "@id": "http://example.org/person/1"
              },
              "guest": {
                "@id": "http://example.org/guest/cd24f329aa"
              }
            }
          })
        },
      }.each_pair do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "@container: @language" do
      {
        "compact-0024" => {
          input: %([
            {
              "@id": "http://example.com/queen",
              "http://example.com/vocab/label": [
                {"@value": "The Queen", "@language": "en"},
                {"@value": "Die Königin", "@language": "de"},
                {"@value": "Ihre Majestät", "@language": "de"}
              ]
            }
          ]),
          context: %({
            "vocab": "http://example.com/vocab/",
            "label": {"@id": "vocab:label", "@container": "@language"}
          }),
          output: %({
            "@context": {
              "vocab": "http://example.com/vocab/",
              "label": {"@id": "vocab:label", "@container": "@language"}
            },
            "@id": "http://example.com/queen",
            "label": {
              "en": "The Queen",
              "de": ["Die Königin", "Ihre Majestät"]
            }
          })
        },
      }.each_pair do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "@container: @id" do
      {
        "Indexes to object not having an @id" => {
          input: %([{
            "http://example/idmap": [
              {"http://example/label": [{"@value": "Object with @id _:bar"}], "@id": "_:bar"},
              {"http://example/label": [{"@value": "Object with @id <foo>"}], "@id": "http://example.org/foo"}
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "idmap": {"@container": "@id"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "idmap": {"@container": "@id"}
            },
            "idmap": {
              "http://example.org/foo": {"label": "Object with @id <foo>"},
              "_:bar": {"label": "Object with @id _:bar"}
            }
          }),
        },
        "Indexes to object already having an @id" => {
          input: %([{
            "http://example/idmap": [
              {"@id": "_:foo", "http://example/label": [{"@value": "Object with @id _:bar"}]},
              {"@id": "http://example.org/bar", "http://example/label": [{"@value": "Object with @id <foo>"}]}
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "idmap": {"@container": "@id"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "idmap": {"@container": "@id"}
            },
            "idmap": {
              "_:foo": {"label": "Object with @id _:bar"},
              "http://example.org/bar": {"label": "Object with @id <foo>"}
            }
          }),
        },
        "Indexes to object using compact IRI @id" => {
          input: %([{
            "http://example/idmap": [
              {"http://example/label": [{"@value": "Object with @id <foo>"}], "@id": "http://example.org/foo"}
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "ex": "http://example.org/",
            "idmap": {"@container": "@id"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "ex": "http://example.org/",
              "idmap": {"@container": "@id"}
            },
            "idmap": {
              "ex:foo": {"label": "Object with @id <foo>"}
            }
          })
        },
      }.each_pair do |title, params|
        it(title) {run_compact({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "@container: @type" do
      {
        "Indexes to object not having an @type" => {
          input: %([{
            "http://example/typemap": [
              {"http://example/label": [{"@value": "Object with @type _:bar"}], "@type": ["_:bar"]},
              {"http://example/label": [{"@value": "Object with @type <foo>"}], "@type": ["http://example.org/foo"]}
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "typemap": {"@container": "@type"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"}
            },
            "typemap": {
              "http://example.org/foo": {"label": "Object with @type <foo>"},
              "_:bar": {"label": "Object with @type _:bar"}
            }
          })
        },
        "Indexes to object already having an @type" => {
          input: %([{
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
          }]),
          context: %({
            "@vocab": "http://example/",
            "typemap": {"@container": "@type"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"}
            },
            "typemap": {
              "http://example.org/foo": {"@type": "http://example.org/bar", "label": "Object with @type <foo>"},
              "_:bar": {"@type": "_:foo", "label": "Object with @type _:bar"}
            }
          })
        },
        "Indexes to object already having multiple @type values" => {
          input: %([{
            "http://example/typemap": [
              {
                "@type": ["_:bar", "_:foo", "_:baz"],
                "http://example/label": [{"@value": "Object with @type _:bar"}]
              },
              {
                "@type": ["http://example.org/foo", "http://example.org/bar", "http://example.org/baz"],
                "http://example/label": [{"@value": "Object with @type <foo>"}]
              }
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "typemap": {"@container": "@type"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"}
            },
            "typemap": {
              "http://example.org/foo": {"@type": ["http://example.org/bar", "http://example.org/baz"], "label": "Object with @type <foo>"},
              "_:bar": {"@type": ["_:foo", "_:baz"], "label": "Object with @type _:bar"}
            }
          })
        },
        "Indexes using compacted @type" => {
          input: %([{
            "http://example/typemap": [
              {"http://example/label": [{"@value": "Object with @type <foo>"}], "@type": ["http://example/Foo"]}
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "typemap": {"@container": "@type"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"}
            },
            "typemap": {
              "Foo": {"label": "Object with @type <foo>"}
            }
          })
        },
      }.each_pair do |title, params|
        it(title) {run_compact({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "@container: @graph" do
      {
        "Compacts simple graph" => {
          input: %([{
            "http://example.org/input": [{
              "@graph": [{
                "http://example.org/value": [{"@value": "x"}]
              }]
            }]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "input": {"@container": "@graph"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "input": {"@container": "@graph"}
            },
            "input": {
              "value": "x"
            }
          })
        },
        "Compacts simple graph with @set" => {
          input: %([{
            "http://example.org/input": [{
              "@graph": [{
                "http://example.org/value": [{"@value": "x"}]
              }]
            }]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "input": {"@container": ["@graph", "@set"]}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@set"]}
            },
            "input": [{
              "value": "x"
            }]
          })
        },
        "Compacts simple graph with @index" => {
          input: %([{
            "http://example.org/input": [{
              "@graph": [{
                "http://example.org/value": [{"@value": "x"}]
              }],
              "@index": "ndx"
            }]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "input": {"@container": "@graph"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "input": {"@container": "@graph"}
            },
            "input": {
              "value": "x"
            }
          })
        },
        "Does not compact graph with @id" => {
          input: %([{
            "http://example.org/input": [{
              "@graph": [{
                "http://example.org/value": [{"@value": "x"}]
              }],
              "@id": "http://example.org/id"
            }]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "input": {"@container": "@graph"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "input": {"@container": "@graph"}
            },
            "input": {
              "@id": "http://example.org/id",
              "@graph": [{"value": "x"}]
            }
          })
        },
      }.each_pair do |title, params|
        it(title) {run_compact({processingMode: "json-ld-1.1"}.merge(params))}
      end

      context "+ @index" do
        {
          "Compacts simple graph" => {
            input: %([{
              "http://example.org/input": [{
                "@index": "g1",
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }]),
            context: %({
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@index"]}
            }),
            output: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@index"]}
              },
              "input": {
                "g1": {"value": "x"}
              }
            })
          },
          "Compacts simple graph with @set" => {
            input: %([{
              "http://example.org/input": [{
                "@index": "g1",
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }]),
            context: %({
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@index", "@set"]}
            }),
            output: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@index", "@set"]}
              },
              "input": {
                "g1": [{"value": "x"}]
              }
            })
          },
          "Does not compact graph with @id" => {
            input: %([{
              "http://example.org/input": [{
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }],
                "@index": "g1",
                "@id": "http://example.org/id"
              }]
            }]),
            context: %({
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@index"]}
            }),
            output: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@index"]}
              },
              "input": {
                "@id": "http://example.org/id",
                "@index": "g1",
                "@graph": [{"value": "x"}]
              }
            })
          },
        }.each_pair do |title, params|
          it(title) {run_compact({processingMode: "json-ld-1.1"}.merge(params))}
        end
      end

      context "+ @id" do
        {
          "Compacts simple graph" => {
            input: %([{
              "http://example.org/input": [{
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }]),
            context: %({
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@id"]}
            }),
            output: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@id"]}
              },
              "input": {
                "_:b0": {"value": "x"}
              }
            })
          },
          "Compacts simple graph with @set" => {
            input: %([{
              "http://example.org/input": [{
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }]
              }]
            }]),
            context: %({
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@id", "@set"]}
            }),
            output: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@id", "@set"]}
              },
              "input": {"_:b0": [{"value": "x"}]}
            })
          },
          "Compacts simple graph with @index" => {
            input: %([{
              "http://example.org/input": [{
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }],
                "@index": "ndx"
              }]
            }]),
            context: %({
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@id"]}
            }),
            output: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@id"]}
              },
              "input": {
                "_:b0": {"value": "x"}
              }
            })
          },
          "Compacts graph with @id" => {
            input: %([{
              "http://example.org/input": [{
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }],
                "@id": "http://example.org/id"
              }]
            }]),
            context: %({
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@id"]}
            }),
            output: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@id"]}
              },
              "input": {
                "http://example.org/id" : {"value": "x"}
              }
            })
          },
          "Compacts graph with @id and @set" => {
            input: %([{
              "http://example.org/input": [{
                "@graph": [{
                  "http://example.org/value": [{"@value": "x"}]
                }],
                "@id": "http://example.org/id"
              }]
            }]),
            context: %({
              "@vocab": "http://example.org/",
              "input": {"@container": ["@graph", "@id", "@set"]}
            }),
            output: %({
              "@context": {
                "@vocab": "http://example.org/",
                "input": {"@container": ["@graph", "@id", "@set"]}
              },
              "input": {
                "http://example.org/id" : [{"value": "x"}]
              }
            })
          },
        }.each_pair do |title, params|
          it(title) {run_compact({processingMode: "json-ld-1.1"}.merge(params))}
        end
      end
    end

    context "@nest" do
      {
        "Indexes to @nest for property with @container: @nest" => {
          input: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [{"@value": "v2"}]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "p2": {"@nest": "@nest"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "p2": {"@nest": "@nest"}
            },
            "p1": "v1",
            "@nest": {
              "p2": "v2"
            }
          })
        },
        "Indexes to @nest for all properties with @container: @nest" => {
          input: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [{"@value": "v2"}]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "p1": {"@nest": "@nest"},
            "p2": {"@nest": "@nest"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "p1": {"@nest": "@nest"},
              "p2": {"@nest": "@nest"}
            },
            "@nest": {
              "p1": "v1",
              "p2": "v2"
            }
          })
        },
        "Nests using alias of @nest" => {
          input: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [{"@value": "v2"}]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "nest": "@nest",
            "p2": {"@nest": "nest"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "nest": "@nest",
              "p2": {"@nest": "nest"}
            },
            "p1": "v1",
            "nest": {
              "p2": "v2"
            }
          })
        },
        "Arrays of nested values" => {
          input: %([{
            "http://example.org/p1": [{"@value": "v1"}],
            "http://example.org/p2": [{"@value": "v2"}, {"@value": "v3"}]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "p2": {"@nest": "@nest"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "p2": {"@nest": "@nest"}
            },
            "p1": "v1",
            "@nest": {
              "p2": ["v2", "v3"]
            }
          })
        },
        "Nested @container: @list" => {
          input: %([{
            "http://example.org/list": [{"@list": [
              {"@value": "a"},
              {"@value": "b"}
            ]}]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "list": {"@container": "@list", "@nest": "nestedlist"},
            "nestedlist": "@nest"
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "list": {"@container": "@list", "@nest": "nestedlist"},
              "nestedlist": "@nest"
            },
            "nestedlist": {
              "list": ["a", "b"]
            }
          }),
        },
        "Nested @container: @index" => {
          input: %([{
            "http://example.org/index": [
              {"@value": "a", "@index": "A"},
              {"@value": "b", "@index": "B"}
            ]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "index": {"@container": "@index", "@nest": "nestedindex"},
            "nestedindex": "@nest"
            }),
          output: %({
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
        },
        "Nested @container: @language" => {
          input: %([{
            "http://example.org/container": [
              {"@value": "Die Königin", "@language": "de"},
              {"@value": "The Queen", "@language": "en"}
            ]
          }]),
          context: %({
            "@vocab": "http://example.org/",
            "container": {"@container": "@language", "@nest": "nestedlanguage"},
            "nestedlanguage": "@nest"
          }),
          output: %({
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
          })
        },
        "Nested @container: @type" => {
          input: %([{
            "http://example/typemap": [
              {"http://example/label": [{"@value": "Object with @type _:bar"}], "@type": ["_:bar"]},
              {"http://example/label": [{"@value": "Object with @type <foo>"}], "@type": ["http://example.org/foo"]}
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "typemap": {"@container": "@type", "@nest": "nestedtypemap"},
            "nestedtypemap": "@nest"
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type", "@nest": "nestedtypemap"},
              "nestedtypemap": "@nest"
            },
            "nestedtypemap": {
              "typemap": {
                "_:bar": {"label": "Object with @type _:bar"},
                "http://example.org/foo": {"label": "Object with @type <foo>"}
              }
            }
          })
        },
        "Nested @container: @id" => {
          input: %([{
            "http://example/idmap": [
              {"http://example/label": [{"@value": "Object with @id _:bar"}], "@id": "_:bar"},
              {"http://example/label": [{"@value": "Object with @id <foo>"}], "@id": "http://example.org/foo"}
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "idmap": {"@container": "@id", "@nest": "nestedidmap"},
            "nestedidmap": "@nest"
          }),
          output: %({
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
          })
        },
        "Multiple nest aliases" => {
          input: %({
            "http://example.org/foo": "bar",
            "http://example.org/bar": "foo"
          }),
          context: %({
            "@vocab": "http://example.org/",
            "foonest": "@nest",
            "barnest": "@nest",
            "foo": {"@nest": "foonest"},
            "bar": {"@nest": "barnest"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example.org/",
              "foonest": "@nest",
              "barnest": "@nest",
              "foo": {"@nest": "foonest"},
              "bar": {"@nest": "barnest"}
            },
            "barnest": {"bar": "foo"},
            "foonest": {"foo": "bar"}
          })
        },
        "Nest term not defined" => {
          input: %({
            "http://example/foo": "bar"
          }),
          context: %({
            "term": {"@id": "http://example/foo", "@nest": "unknown"}
          }),
          exception: JSON::LD::JsonLdError::InvalidNestValue
        },
      }.each_pair do |title, params|
        it(title) {run_compact({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "@graph" do
      {
        "Uses @graph given mutliple inputs" => {
          input: %([
            {"http://example.com/foo": ["foo"]},
            {"http://example.com/bar": ["bar"]}
          ]),
          context: %({"ex": "http://example.com/"}),
          output: %({
            "@context": {"ex": "http://example.com/"},
            "@graph": [
              {"ex:foo": "foo"},
              {"ex:bar": "bar"}
            ]
          })
        },
      }.each_pair do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "scoped context" do
      {
        "adding new term" => {
          input: %([{
            "http://example/foo": [{"http://example.org/bar": [{"@value": "baz"}]}]
          }]),
          context: %({
            "@vocab": "http://example/",
            "foo": {"@context": {"bar": "http://example.org/bar"}}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "foo": {"@context": {"bar": "http://example.org/bar"}}
            },
            "foo": {
              "bar": "baz"
            }
          })
        },
        "overriding a term" => {
          input: %([
            {
              "http://example/foo": [{"http://example/bar": [{"@id": "http://example/baz"}]}]
            }
          ]),
          context: %({
            "@vocab": "http://example/",
            "foo": {"@context": {"bar": {"@type": "@id"}}},
            "bar": {"@type": "http://www.w3.org/2001/XMLSchema#string"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "foo": {"@context": {"bar": {"@type": "@id"}}},
              "bar": {"@type": "http://www.w3.org/2001/XMLSchema#string"}
            },
            "foo": {
              "bar": "http://example/baz"
            }
          }),
        },
        "property and value with different terms mapping to the same expanded property" => {
          input: %([
            {
              "http://example/foo": [{
                "http://example/bar": [
                  {"@value": "baz"}
                ]}
              ]
            }
          ]),
          context: %({
            "@vocab": "http://example/",
            "foo": {"@context": {"Bar": {"@id": "bar"}}}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "foo": {"@context": {"Bar": {"@id": "bar"}}}
            },
            "foo": {
              "Bar": "baz"
            }
          }),
        },
        "deep @context affects nested nodes" => {
          input: %([
            {
              "http://example/foo": [{
                "http://example/bar": [{
                  "http://example/baz": [{"@id": "http://example/buzz"}]
                }]
              }]
            }
          ]),
          context: %({
            "@vocab": "http://example/",
            "foo": {"@context": {"baz": {"@type": "@vocab"}}}
          }),
          output: %({
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
        },
        "scoped context layers on intemediate contexts" => {
          input: %([{
            "http://example/a": [{
              "http://example.com/c": [{"@value": "C in example.com"}],
              "http://example/b": [{
                "http://example.com/a": [{"@value": "A in example.com"}],
                "http://example.org/c": [{"@value": "C in example.org"}]
              }]
            }],
            "http://example/c": [{"@value": "C in example"}]
          }]),
          context: %({
            "@vocab": "http://example/",
            "b": {"@context": {"c": "http://example.org/c"}}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "b": {"@context": {"c": "http://example.org/c"}}
            },
            "a": {
              "b": {
                "c": "C in example.org",
                "http://example.com/a": "A in example.com"
              },
              "http://example.com/c": "C in example.com"
            },
            "c": "C in example"
          }),
        },
        "Raises InvalidTermDefinition if processingMode is not specified" => {
          input: %([{
            "http://example/foo": [{"http://example.org/bar": [{"@value": "baz"}]}]
          }]),
          context: %({
            "@vocab": "http://example/",
            "foo": {"@context": {"bar": "http://example.org/bar"}}
          }),
          processingMode: nil,
          validate: true,
          exception: JSON::LD::JsonLdError::InvalidTermDefinition
        },
      }.each_pair do |title, params|
        it(title) {run_compact({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "scoped context on @type" do
      {
        "adding new term" => {
          input: %([
            {
              "http://example/a": [{
                "@type": ["http://example/Foo"],
                "http://example.org/bar": [{"@value": "baz"}]
              }]
            }
          ]),
          context: %({
            "@vocab": "http://example/",
            "Foo": {"@context": {"bar": "http://example.org/bar"}}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "Foo": {"@context": {"bar": "http://example.org/bar"}}
            },
            "a": {"@type": "Foo", "bar": "baz"}
          })
        },
        "overriding a term" => {
          input: %([
            {
              "http://example/a": [{
                "@type": ["http://example/Foo"],
                "http://example/bar": [{"@id": "http://example/baz"}]
              }]
            }
          ]),
          context: %({
            "@vocab": "http://example/",
            "Foo": {"@context": {"bar": {"@type": "@id"}}},
            "bar": {"@type": "http://www.w3.org/2001/XMLSchema#string"}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "Foo": {"@context": {"bar": {"@type": "@id"}}},
              "bar": {"@type": "http://www.w3.org/2001/XMLSchema#string"}
            },
            "a": {"@type": "Foo", "bar": "http://example/baz"}
          }),
        },
        "alias of @type" => {
          input: %([
            {
              "http://example/a": [{
                "@type": ["http://example/Foo"],
                "http://example.org/bar": [{"@value": "baz"}]
              }]
            }
          ]),
          context: %({
            "@vocab": "http://example/",
            "type": "@type",
            "Foo": {"@context": {"bar": "http://example.org/bar"}}
            }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "type": "@type",
              "Foo": {"@context": {"bar": "http://example.org/bar"}}
            },
            "a": {"type": "Foo", "bar": "baz"}
          }),
        },
        "deep @context affects nested nodes" => {
          input: %([
            {
              "@type": ["http://example/Foo"],
              "http://example/bar": [{
                "http://example/baz": [{"@id": "http://example/buzz"}]
              }]
            }
          ]),
          context: %({
            "@vocab": "http://example/",
            "Foo": {"@context": {"baz": {"@type": "@vocab"}}}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "Foo": {"@context": {"baz": {"@type": "@vocab"}}}
            },
            "@type": "Foo",
            "bar": {"baz": "buzz"}
          }),
        },
        "scoped context layers on intemediate contexts" => {
          input: %([{
            "http://example/a": [{
              "@type": ["http://example/B"],
              "http://example.com/a": [{"@value": "A in example.com"}],
              "http://example.org/c": [{"@value": "C in example.org"}]
            }],
            "http://example/c": [{"@value": "C in example"}]
          }]),
          context: %({
            "@vocab": "http://example/",
            "B": {"@context": {"c": "http://example.org/c"}}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "B": {"@context": {"c": "http://example.org/c"}}
            },
            "a": {
              "@type": "B",
              "c": "C in example.org",
              "http://example.com/a": "A in example.com"
            },
            "c": "C in example"
          }),
        },
        "with @container: @type" => {
          input: %([{
            "http://example/typemap": [
              {"http://example.org/a": [{"@value": "Object with @type <Type>"}], "@type": ["http://example/Type"]}
            ]
          }]),
          context: %({
            "@vocab": "http://example/",
            "typemap": {"@container": "@type"},
            "Type": {"@context": {"a": "http://example.org/a"}}
          }),
          output: %({
            "@context": {
              "@vocab": "http://example/",
              "typemap": {"@container": "@type"},
              "Type": {"@context": {"a": "http://example.org/a"}}
            },
            "typemap": {
              "Type": {"a": "Object with @type <Type>"}
            }
          })
        },
        "Raises InvalidTermDefinition if processingMode is not specified" => {
          input: %([
            {
              "http://example/a": [{
                "@type": ["http://example/Foo"],
                "http://example.org/bar": [{"@value": "baz"}]
              }]
            }
          ]),
          context: %({
            "@vocab": "http://example/",
            "Foo": {"@context": {"bar": "http://example.org/bar"}}
          }),
          processingMode: nil,
          validate: true,
          exception: JSON::LD::JsonLdError::InvalidTermDefinition
        },
      }.each_pair do |title, params|
        it(title) {run_compact({processingMode: "json-ld-1.1"}.merge(params))}
      end
    end

    context "exceptions" do
      {
        "@list containing @list" => {
          input: %({
            "http://example.org/foo": {"@list": [{"@list": ["baz"]}]}
          }),
          context: {},
          exception: JSON::LD::JsonLdError::ListOfLists
        },
        "@list containing @list (with coercion)" => {
          input: %({
            "@context": {"http://example.org/foo": {"@container": "@list"}},
            "http://example.org/foo": [{"@list": ["baz"]}]
          }),
          context: {},
          exception: JSON::LD::JsonLdError::ListOfLists
        },
      }.each do |title, params|
        it(title) {run_compact(params)}
      end
    end

    context "compact IRI selection" do
      {
        "compacts using expanded term in 1.0" => {
          input: %({"http://example.org/foo": "term"}),
          context: %({"ex": {"@id": "http://example.org/"}}),
          output: %({
            "@context": {"ex": {"@id": "http://example.org/"}},
            "ex:foo": "term"
          }),
          processingMode: "json-ld-1.0"
        },
        "does not compact using expanded term in 1.1" => {
          input: %({"http://example.org/foo": "term"}),
          context: %({"ex": {"@id": "http://example.org/"}}),
          output: %({
            "@context": {"ex": {"@id": "http://example.org/"}},
            "http://example.org/foo": "term"
          }),
          processingMode: "json-ld-1.1"
        },
        "does not compact using simple term not ending in gen-delim" => {
          input: %({"http://example.org/foo": "term"}),
          context: %({"ex": "http://example.org/f"}),
          output: %({
            "@context": {"ex": "http://example.org/f"},
            "http://example.org/foo": "term"
          })
        },
        "compacts using simple term ending in gen-delim ('/')" => {
          input: %({"http://example.org/foo": "term"}),
          context: %({"ex": "http://example.org/"}),
          output: %({
            "@context": {"ex": "http://example.org/"},
            "ex:foo": "term"
          })
        },
        "compacts using simple term ending in gen-delim (':')" => {
          input: %({"http://example.org/foo:bar": "term"}),
          context: %({"ex": "http://example.org/foo:"}),
          output: %({
            "@context": {"ex": "http://example.org/foo:"},
            "ex:bar": "term"
          })
        },
        "compacts using simple term ending in gen-delim ('?')" => {
          input: %({"http://example.org/foo?bar": "term"}),
          context: %({"ex": "http://example.org/foo?"}),
          output: %({
            "@context": {"ex": "http://example.org/foo?"},
            "ex:bar": "term"
          })
        },
        "compacts using simple term ending in gen-delim ('#')" => {
          input: %({"http://example.org/foo#bar": "term"}),
          context: %({"ex": "http://example.org/foo#"}),
          output: %({
            "@context": {"ex": "http://example.org/foo#"},
            "ex:bar": "term"
          })
        },
        "compacts using simple term ending in gen-delim ('[')" => {
          input: %({"http://example.org/foo[bar": "term"}),
          context: %({"ex": "http://example.org/foo["}),
          output: %({
            "@context": {"ex": "http://example.org/foo["},
            "ex:bar": "term"
          })
        },
        "compacts using simple term ending in gen-delim (']')" => {
          input: %({"http://example.org/foo]bar": "term"}),
          context: %({"ex": "http://example.org/foo]"}),
          output: %({
            "@context": {"ex": "http://example.org/foo]"},
            "ex:bar": "term"
          })
        },
        "compacts using simple term ending in gen-delim ('@')" => {
          input: %({"http://example.org/foo@bar": "term"}),
          context: %({"ex": "http://example.org/foo@"}),
          output: %({
            "@context": {"ex": "http://example.org/foo@"},
            "ex:bar": "term"
          })
        },
      }.each do |title, params|
        it(title) {run_compact(params)}
      end
    end
  end

  def run_compact(params)
    input, output, context = params[:input], params[:output], params[:context]
    input = ::JSON.parse(input) if input.is_a?(String)
    output = ::JSON.parse(output) if output.is_a?(String)
    context = ::JSON.parse(context) if context.is_a?(String)
    pending params.fetch(:pending, "test implementation") unless input
    if params[:exception]
      expect {JSON::LD::API.compact(input, context, params.merge(logger: logger))}.to raise_error(params[:exception])
    else
      jld = JSON::LD::API.compact(input, context, params.merge(logger: logger))
      expect(jld).to produce(output, logger)
    end
  end
end
