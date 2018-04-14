require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class RangeTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Range filter" do
          subject { Range.new }

          should "be converted to a Hash" do
            assert_equal({ range: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Range.new :foo

            subject.gte 'bar'
            subject.lte 'bar'
            subject.time_zone 'bar'
            subject.format 'bar'

            assert_equal %w[ format gte lte time_zone ],
                         subject.to_hash[:range][:foo].keys.map(&:to_s).sort

            assert_equal 'bar', subject.to_hash[:range][:foo][:gte]
          end

          should "take a hash" do
            subject = Range.new age: { gte: 10, lte: 20 }

            assert_equal({ range: { age: { gte: 10, lte: 20 } } }, subject.to_hash)
          end

          should "take a block" do
            subject = Range.new :age do
              gte 10
              lte 20
            end

            assert_equal({ range: { age: { gte: 10, lte: 20 } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
