require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class DerivativeTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Derivative agg" do
          subject { Derivative.new }

          should "be converted to a hash" do
            assert_equal({ derivative: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Derivative.new :foo

            subject.buckets_path 'bar'
            subject.gap_policy 'bar'
            subject.format 'bar'

            assert_equal %w[ buckets_path format gap_policy ],
              subject.to_hash[:derivative][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:derivative][:foo][:buckets_path]
          end

          should "take a block" do
            subject = Derivative.new :foo do
              format 'bar'
            end
            assert_equal({derivative: { foo: { format: 'bar' } } }, subject.to_hash)
          end

        end
      end
    end
  end
end
