require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class StatsBucketTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Stats Bucket agg" do
          subject { StatsBucket.new }

          should "be converted to a hash" do
            assert_equal({ stats_bucket: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = StatsBucket.new :foo

            subject.buckets_path 'bar'
            subject.gap_policy 'bar'
            subject.format 'bar'

            assert_equal %w[ buckets_path format gap_policy ],
              subject.to_hash[:stats_bucket][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:stats_bucket][:foo][:buckets_path]
          end

          should "take a block" do
            subject = StatsBucket.new :foo do
              format 'bar'
            end
            assert_equal({stats_bucket: { foo: { format: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
