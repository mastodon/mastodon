require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class BucketSelectorTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Bucket Selector agg" do
          subject { BucketSelector.new }

          should "be converted to a hash" do
            assert_equal({ bucket_selector: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = BucketSelector.new :foo

            subject.buckets_path foo: 'foo', bar: 'bar'
            subject.script 'bar'
            subject.gap_policy 'skip'

            assert_equal %w[ buckets_path gap_policy script ],
              subject.to_hash[:bucket_selector][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:bucket_selector][:foo][:buckets_path][:bar]
          end

          should "take a block" do
            subject = BucketSelector.new :foo do
              gap_policy 'skip'
            end
            assert_equal({bucket_selector: { foo: { gap_policy: 'skip' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
