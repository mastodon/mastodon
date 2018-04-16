require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class MovingAvgTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Moving Average Bucket agg" do
          subject { MovingAvg.new }

          should "be converted to a hash" do
            assert_equal({ moving_avg: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = MovingAvg.new :foo

            subject.buckets_path 'bar'
            subject.gap_policy 'skip'
            subject.minimize false
            subject.model 'simple'
            subject.settings({ period: 7 })
            subject.window 5

            assert_equal %w[ buckets_path gap_policy minimize model settings window ],
              subject.to_hash[:moving_avg][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:moving_avg][:foo][:buckets_path]
          end

          should "take a block" do
            subject = MovingAvg.new :foo do
              format 'bar'
            end
            assert_equal({moving_avg: { foo: { format: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
