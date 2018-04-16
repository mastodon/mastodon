require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class SumBucketTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Sum Bucket agg" do
          subject { SumBucket.new }

          should "be converted to a hash" do
            assert_equal({ sum_bucket: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = SumBucket.new :foo

            subject.buckets_path 'bar'
            subject.gap_policy 'bar'
            subject.format 'bar'

            assert_equal %w[ buckets_path format gap_policy ],
              subject.to_hash[:sum_bucket][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:sum_bucket][:foo][:buckets_path]
          end

          should "take a block" do
            subject = SumBucket.new :foo do
              format 'bar'
            end
            assert_equal({sum_bucket: { foo: { format: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
