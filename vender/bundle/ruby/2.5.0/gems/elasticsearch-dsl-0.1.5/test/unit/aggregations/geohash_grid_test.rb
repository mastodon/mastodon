require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class GeohashGridTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "GeohashGrid aggregation" do
          subject { GeohashGrid.new }

          should "be converted to a Hash" do
            assert_equal({ geohash_grid: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = GeohashGrid.new

            subject.field 'bar'
            subject.precision 'bar'
            subject.size 'bar'
            subject.shard_size 'bar'

            assert_equal %w[ field precision shard_size size ],
                         subject.to_hash[:geohash_grid].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:geohash_grid][:field]
          end

          should "take a block" do
            subject = GeohashGrid.new do
              field     'bar'
              precision 5
            end
            assert_equal({geohash_grid: { field: 'bar', precision: 5 } }, subject.to_hash)
          end
        end
      end
    end
  end
end
