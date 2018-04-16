require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class GeoPolygonTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "GeoPolygon filter" do
          subject { GeoPolygon.new }

          should "be converted to a Hash" do
            assert_equal({ geo_polygon: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = GeoPolygon.new :foo

            subject.points 'bar'

            assert_equal %w[ points ],
                         subject.to_hash[:geo_polygon][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:geo_polygon][:foo][:points]
          end

          should "take a block" do
            subject = GeoPolygon.new :foo do
              points 'bar'
            end
            assert_equal({geo_polygon: { foo: { points: 'bar' } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
