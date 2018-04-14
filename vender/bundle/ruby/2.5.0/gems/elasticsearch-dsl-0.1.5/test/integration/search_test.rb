require 'test_helper'

module Elasticsearch
  module Test
    class SearchIntegrationTest < ::Elasticsearch::Test::IntegrationTestCase
      include Elasticsearch::DSL::Search

      class MySearch
        include Elasticsearch::DSL::Search

        def initialize(q)
          @q = q
        end

        def tags
          %w[ one two ]
        end

        def search_definition
          search do |q|
            q.query do |q|
              q.bool do |q|
                q.must do |q|
                  q.match title: @q
                end
                q.must do |q|
                  q.terms tags: tags
                end
              end
            end
          end
        end
      end

      context "The Search class" do
        startup do
          Elasticsearch::Extensions::Test::Cluster.start(nodes: 1) if ENV['SERVER'] and not Elasticsearch::Extensions::Test::Cluster.running?
        end

        setup do
          @client.indices.create index: 'test'
          @client.index index: 'test', type: 'd', id: '1', body: { title: 'Test', tags: ['one'] }
          @client.index index: 'test', type: 'd', id: '2', body: { title: 'Test', tags: ['one', 'two'] }
          @client.index index: 'test', type: 'd', id: '3', body: { title: 'Test', tags: ['three'] }
          @client.indices.refresh index: 'test'
        end


        should "have access to the calling context" do
          s = MySearch.new('test')
          response = @client.search index: 'test', body: s.search_definition.to_hash

          assert_equal 2, response['hits']['total']
          assert_equal 'Test', response['hits']['hits'][0]['_source']['title']
          assert_same_elements ['1', '2'], response['hits']['hits'].map { |d| d['_id'] }
        end
      end
    end
  end
end
