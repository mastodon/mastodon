require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class ExtendedStatsTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "ExtendedStats agg" do
          subject { ExtendedStats.new }

          should "be converted to a Hash" do
            assert_equal({ extended_stats: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = ExtendedStats.new foo: 'bar'
            assert_equal({ extended_stats: { foo: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
