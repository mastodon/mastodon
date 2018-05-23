require 'test_helper'

module Elasticsearch
  module Test
    class SearchOptionsIntegrationTest < ::Elasticsearch::Test::IntegrationTestCase
      include Elasticsearch::DSL::Search

      context "Search options" do
        setup do
          @client.indices.create index: 'test'
          @client.index index: 'test', type: 'd', id: '1', body: { title: 'Test' }
          @client.index index: 'test', type: 'd', id: '2', body: { title: 'Rest' }
          @client.indices.refresh index: 'test'
        end

        should "explain the match" do
          response = @client.search index: 'test', body: search {
            query   { match title: 'test' }
            explain true
          }.to_hash

          assert_equal 1, response['hits']['total']
          assert_not_nil  response['hits']['hits'][0]['_explanation']
        end
      end
    end
  end
end
