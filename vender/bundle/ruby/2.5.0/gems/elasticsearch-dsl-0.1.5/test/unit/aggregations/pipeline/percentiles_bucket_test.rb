require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class PercentilesBucketTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Percentiles Bucket agg" do
          subject { PercentilesBucket.new }

          should "be converted to a hash" do
            assert_equal({ percentiles_bucket: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = PercentilesBucket.new :foo

            subject.buckets_path 'bar'
            subject.gap_policy 'skip'
            subject.format 'bar'
            subject.percents [ 1, 5, 25, 50, 75, 95, 99 ]

            assert_equal %w[ buckets_path format gap_policy percents ],
              subject.to_hash[:percentiles_bucket][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:percentiles_bucket][:foo][:buckets_path]
          end

          should "take a block" do
            subject = PercentilesBucket.new :foo do
              format 'bar'
            end
            assert_equal({percentiles_bucket: { foo: { format: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
