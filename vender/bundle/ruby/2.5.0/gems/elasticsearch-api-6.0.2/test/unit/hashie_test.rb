require 'test_helper'

require 'hashie'

module Elasticsearch
  module Test
    class HashieTest < ::Test::Unit::TestCase

      context "Hashie" do
        subject { FakeClient.new }

        should "wrap the response" do
          json =<<-JSON
            {
              "took": 14,
              "timed_out": false,
              "_shards": {
                "total": 1,
                "successful": 1,
                "failed": 0
              },
              "hits": {
                "total": 5,
                "max_score": 0.51104903,
                "hits": [
                  {
                    "_index": "myindex",
                    "_type": "mytype",
                    "_id": "1",
                    "_score": 0.51104903,
                    "_source": {
                      "title": "Test 1",
                      "tags": [
                        "y",
                        "z"
                      ],
                      "published": true,
                      "published_at": "2013-06-22T21:13:00Z",
                      "counter": 1
                    }
                  }
                ]
              },
              "facets": {
                "tags": {
                  "_type": "terms",
                  "missing": 0,
                  "total": 10,
                  "other": 0,
                  "terms": [
                    {
                      "term": "z",
                      "count": 4
                    },
                    {
                      "term": "y",
                      "count": 3
                    },
                    {
                      "term": "x",
                      "count": 3
                    }
                  ]
                }
              }
            }
          JSON

          response = Hashie::Mash.new MultiJson.load(json)

          assert_equal 'Test 1', response.hits.hits.first._source.title
          assert_equal 'z',      response.facets.tags.terms.first.term
        end
      end

    end
  end
end
