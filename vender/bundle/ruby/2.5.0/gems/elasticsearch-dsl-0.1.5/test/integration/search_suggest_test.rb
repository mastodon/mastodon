# encoding: UTF-8

require 'test_helper'

module Elasticsearch
  module Test
    class SuggestIntegrationTest < ::Elasticsearch::Test::IntegrationTestCase
      include Elasticsearch::DSL::Search

      context "Suggest integration" do
        startup do
          Elasticsearch::Extensions::Test::Cluster.start(nodes: 1) if ENV['SERVER'] and not Elasticsearch::Extensions::Test::Cluster.running?
        end

        setup do
          @client.indices.create index: 'test', body: {
            mappings: {
              d: {
                properties: {
                  title: { type: 'string' },
                  title_suggest: {
                    type: 'completion',
                    payloads: true
                  }
                }
              }
            }
          }

          @client.index index: 'test', type: 'd', id: '1', body: {
            title: 'One',
            title_suggest: { input: ['one', 'uno', 'jedna'] }, output: 'ONE', payload: { id: '1' } }
          @client.index index: 'test', type: 'd', id: '2', body: {
            title: 'Two',
            title_suggest: { input: ['two', 'due', 'dvě'] }, output: 'TWO', payload: { id: '2' } }
          @client.index index: 'test', type: 'd', id: '3', body: {
            title: 'Three',
            title_suggest: { input: ['three', 'tres', 'tři'] }, output: 'THREE', payload: { id: '3' } }
          @client.indices.refresh index: 'test'
        end

        should "return suggestions" do
          s = search do
            suggest :title, text: 't', completion: { field: 'title_suggest' }
          end

          response = @client.search index: 'test', body: s.to_hash
          assert_equal 4, response['suggest']['title'][0]['options'].size
        end

        should "return a single suggestion" do
          s = search do
            suggest :title, text: 'th', completion: { field: 'title_suggest' }
          end

          response = @client.search index: 'test', body: s.to_hash
          assert_equal 1, response['suggest']['title'][0]['options'].size
        end
      end
    end
  end
end
