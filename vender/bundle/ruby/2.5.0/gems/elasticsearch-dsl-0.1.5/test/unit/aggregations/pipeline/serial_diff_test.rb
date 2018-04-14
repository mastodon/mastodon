require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class SerialDiffTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Serial Defferencing agg" do
          subject { SerialDiff.new }

          should "be converted to a hash" do
            assert_equal({ serial_diff: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = SerialDiff.new :foo

            subject.buckets_path 'bar'
            subject.lag 1
            subject.gap_policy 'skip'
            subject.format 'foo'

            assert_equal %w[ buckets_path format gap_policy lag ],
              subject.to_hash[:serial_diff][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:serial_diff][:foo][:buckets_path]
          end

          should "take a block" do
            subject = SerialDiff.new :foo do
              gap_policy 'skip'
            end
            assert_equal({serial_diff: { foo: { gap_policy: 'skip' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
