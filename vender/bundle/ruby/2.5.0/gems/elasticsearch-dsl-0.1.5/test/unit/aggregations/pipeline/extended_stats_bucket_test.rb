require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class ExtendedStatsBucketTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Extended Stats Bucket agg" do
          subject { ExtendedStatsBucket.new }

          should "be converted to a hash" do
            assert_equal({ extended_stats_bucket: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = ExtendedStatsBucket.new :foo

            subject.buckets_path 'bar'
            subject.gap_policy 'skip'
            subject.format 'bar'

            assert_equal %w[ buckets_path format gap_policy ],
              subject.to_hash[:extended_stats_bucket][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:extended_stats_bucket][:foo][:buckets_path]
          end

          should "take a block" do
            subject = ExtendedStatsBucket.new :foo do
              format 'bar'
            end
            assert_equal({extended_stats_bucket: { foo: { format: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
