require 'test_helper'

module Elasticsearch
  module Test
    class SizeIntegrationTest < ::Elasticsearch::Test::IntegrationTestCase
      include Elasticsearch::DSL::Search

        context "Search results pagination" do
          setup do
            25.times { |i| @client.index index: 'test', type: 'd', id: i, body: { title: "Test #{sprintf('%03d', i)}" } }
            @client.indices.refresh index: 'test'
          end

          should "find the correct number of documents" do
            response = @client.search index: 'test', body: search {
              query { match title: 'test' }
              size 15
            }.to_hash

            assert_equal 25, response['hits']['total']
            assert_equal 15, response['hits']['hits'].size
          end

          should "move the offset" do
            response = @client.search index: 'test', body: search {
              query { match(:title) { query 'test' and type 'phrase_prefix' } }
              size 5
              from 5
              sort { by :title }
            }.to_hash

            assert_equal 25, response['hits']['total']
            assert_equal 5,  response['hits']['hits'].size
            assert_equal 'Test 005', response['hits']['hits'][0]['_source']['title']
            assert_equal 'Test 009', response['hits']['hits'][4]['_source']['title']
          end
        end

    end
  end
end
