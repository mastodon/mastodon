require 'test_helper'

module Elasticsearch
  module Test
    class NestedAggregationIntegrationTest < ::Elasticsearch::Test::IntegrationTestCase
      include Elasticsearch::DSL::Search

      context "A nested aggregation" do
        startup do
          Elasticsearch::Extensions::Test::Cluster.start(nodes: 1) if ENV['SERVER'] and not Elasticsearch::Extensions::Test::Cluster.running?
        end

        setup do
          @client.indices.create index: 'products-test', body: {
            mappings: {
              product: {
                properties: {
                  offers: {
                    type: 'nested',
                    properties: {
                      name:  { type: 'string' },
                      price: { type: 'double' }
                    }
                  }
                }
              }
            }
          }
          @client.index index: 'products-test', type: 'product',
                        body: { title: 'A',
                                category: 'audio',
                                offers: [ { name: 'A1', price: 100 }, { name: 'A2', price: 120 } ] }
          @client.index index: 'products-test', type: 'product',
                        body: { title: 'B',
                                category: 'audio',
                                offers: [ { name: 'B1', price: 200 }, { name: 'B2', price: 180 } ] }
          @client.index index: 'products-test', type: 'product',
                        body: { title: 'C',
                                category: 'video',
                                offers: [ { name: 'C1', price: 300 }, { name: 'C2', price: 350 } ] }
          @client.indices.refresh index: 'products-test'
        end

        should "return the minimal price from offers" do
          response = @client.search index: 'products-test', body: search {
            query { match title: 'A' }

            aggregation :offers do
              nested do
                path 'offers'
                aggregation :min_price do
                  min field: 'offers.price'
                end
              end
            end
          }.to_hash

          assert_equal 100, response['aggregations']['offers']['min_price']['value'].to_i
        end

        should "return the top categories for offer price range" do
          response = @client.search index: 'products-test', body: search {
            query do
              filtered do
                filter do
                  nested do
                    path 'offers'
                    filter do
                      range 'offers.price' do
                        gte 100
                        lte 300
                      end
                    end
                  end
                end
              end
            end

            aggregation :offers do
              nested do
                path 'offers'
                aggregation :top_categories do
                  reverse_nested do
                    aggregation :top_category_per_offer do
                      terms field: 'category'
                    end
                  end
                end
              end
            end
          }.to_hash

          assert_equal 2, response['aggregations']['offers']['top_categories']['top_category_per_offer']['buckets'].size
          assert_equal 'audio', response['aggregations']['offers']['top_categories']['top_category_per_offer']['buckets'][0]['key']
          assert_equal 'video', response['aggregations']['offers']['top_categories']['top_category_per_offer']['buckets'][1]['key']
        end
      end
    end
  end
end
