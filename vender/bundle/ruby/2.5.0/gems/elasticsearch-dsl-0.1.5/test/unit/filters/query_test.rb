require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class QueryTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Query filter" do
          subject { Query.new }

          should "be converted to a Hash" do
            assert_equal({ query: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = Query.new query_string: { query: 'foo' }

            assert_equal({ query: { query_string: { query: 'foo' } } }, subject.to_hash)
          end

          should "take a block" do
            subject = Query.new do
              match foo: 'bar'
            end

            assert_equal({ query: { match: { foo: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
