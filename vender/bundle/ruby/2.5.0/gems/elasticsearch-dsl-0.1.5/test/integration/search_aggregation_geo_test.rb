require 'test_helper'

module Elasticsearch
  module Test
    class GeoAggregationIntegrationTest < ::Elasticsearch::Test::IntegrationTestCase
      include Elasticsearch::DSL::Search

      context "A geo aggregation" do
        startup do
          Elasticsearch::Extensions::Test::Cluster.start(nodes: 1) if ENV['SERVER'] and not Elasticsearch::Extensions::Test::Cluster.running?
        end

        setup do
          @client.indices.create index: 'venues-test', body: {
            mappings: {
              venue: {
                properties: {
                  location: { type: 'geo_point' }
                }
              }
            }
          }
          @client.index index: 'venues-test', type: 'venue',
                        body: { name: 'Space', location: "38.886214,1.403889" }
          @client.index index: 'venues-test', type: 'venue',
                        body: { name: 'Pacha', location: "38.9184427,1.4433646" }
          @client.index index: 'venues-test', type: 'venue',
                        body: { name: 'Amnesia', location: "38.948045,1.408341" }
          @client.index index: 'venues-test', type: 'venue',
                        body: { name: 'Privilege', location: "38.958082,1.408288" }
          @client.index index: 'venues-test', type: 'venue',
                        body: { name: 'Es Paradis', location: "38.979071,1.307394" }
          @client.indices.refresh index: 'venues-test'
        end

        should "return the geo distances from a location" do
          response = @client.search index: 'venues-test', size: 0, body: search {
            aggregation :venue_distances do
              geo_distance do
                field  :location
                origin '38.9126352,1.4350621'
                unit   'km'
                ranges [ { to: 1 }, { from: 1, to: 5 }, { from: 5, to: 10 }, { from: 10 } ]

                aggregation :top_venues do
                  top_hits _source: { include: 'name' }
                end
              end
            end
          }.to_hash

          result = response['aggregations']['venue_distances']

          assert_equal 4,       result['buckets'].size
          assert_equal 1,       result['buckets'][0]['doc_count']
          assert_equal 'Pacha', result['buckets'][0]['top_venues']['hits']['hits'][0]['_source']['name']

          assert_equal 2,       result['buckets'][1]['top_venues']['hits']['total']
        end

        should "return the geohash grid distribution" do
          #
          # See the geohash plot eg. at http://openlocation.org/geohash/geohash-js/
          # See the locations visually eg. at http://geohash.org/sncj8h17r2
          #
          response = @client.search index: 'venues-test', size: 0, body: search {
            aggregation :venue_distributions do
              geohash_grid do
                field     :location
                precision 5

                aggregation :top_venues do
                  top_hits _source: { include: 'name' }
                end
              end
            end
          }.to_hash

          result = response['aggregations']['venue_distributions']

          assert_equal 4,       result['buckets'].size
          assert_equal 'sncj8', result['buckets'][0]['key']
          assert_equal 2,       result['buckets'][0]['doc_count']

          assert_same_elements %w[ Privilege Amnesia ], result['buckets'][0]['top_venues']['hits']['hits'].map { |h| h['_source']['name'] }
        end
      end
    end
  end
end
