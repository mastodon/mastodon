require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class StatsTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Stats agg" do
          subject { Stats.new }

          should "be converted to a Hash" do
            assert_equal({ stats: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = Stats.new foo: 'bar'
            assert_equal({ stats: { foo: 'bar' } }, subject.to_hash)
          end

          should "take a block" do
            subject = Stats.new do
              field 'bar'
            end

            assert_equal({stats: { field: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
