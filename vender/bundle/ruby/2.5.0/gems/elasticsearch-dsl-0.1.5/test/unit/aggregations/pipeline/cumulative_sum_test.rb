require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class CumulativeSumTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Cumulative Sum Bucket agg" do
          subject { CumulativeSum.new }

          should "be converted to a hash" do
            assert_equal({ cumulative_sum: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = CumulativeSum.new :foo

            subject.buckets_path 'bar'
            subject.format 'bar'

            assert_equal %w[ buckets_path format ],
              subject.to_hash[:cumulative_sum][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:cumulative_sum][:foo][:buckets_path]
          end

          should "take a block" do
            subject = CumulativeSum.new :foo do
              format 'bar'
            end
            assert_equal({cumulative_sum: { foo: { format: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
