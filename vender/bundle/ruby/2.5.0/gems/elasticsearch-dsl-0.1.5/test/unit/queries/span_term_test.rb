require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class SpanTermTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "SpanTerm query" do
          subject { SpanTerm.new }

          should "be converted to a Hash" do
            assert_equal({ span_term: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = SpanTerm.new foo: 'bar'
            assert_equal({ span_term: { foo: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
