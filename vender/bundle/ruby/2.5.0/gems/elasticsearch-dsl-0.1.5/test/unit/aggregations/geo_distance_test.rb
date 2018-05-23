require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class GeoDistanceTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "GeoDistance aggregation" do
          subject { GeoDistance.new }

          should "be converted to a Hash" do
            assert_equal({ geo_distance: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = GeoDistance.new

            subject.field 'bar'
            subject.origin 'bar'
            subject.ranges 'bar'
            subject.unit 'bar'
            subject.distance_type 'bar'

            assert_equal %w[ distance_type field origin ranges unit ],
                         subject.to_hash[:geo_distance].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:geo_distance][:field]
          end

          should "take a block" do
            subject = GeoDistance.new do
              field  'bar'
              origin lat: 50, lon: 5
              ranges [ { to: 50 }, { from: 50, to: 100 }, { from: 100 } ]
            end
            assert_equal(
              { geo_distance: { field: 'bar', origin: { lat: 50, lon: 5 }, ranges: [ { to: 50 }, { from: 50, to: 100 }, { from: 100 } ] } },
              subject.to_hash
            )
          end
        end
      end
    end
  end
end
