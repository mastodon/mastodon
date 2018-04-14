require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class GeoDistanceRangeTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "GeoDistanceRange filter" do
          subject { GeoDistanceRange.new }

          should "be converted to a Hash" do
            assert_equal({ geo_distance_range: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = GeoDistanceRange.new :foo

            subject.lat 'bar'
            subject.lon 'bar'

            assert_equal %w[ lat lon ],
                         subject.to_hash[:geo_distance_range][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:geo_distance_range][:foo][:lat]
          end

          should "take a block" do
            subject = GeoDistanceRange.new :foo do
              lat 40
              lon -70
            end
            assert_equal({geo_distance_range: { foo: { lat: 40, lon: -70 } } }, subject.to_hash)
          end

          should "take a Hash" do
            subject = GeoDistanceRange.new from: '10km', to: '20km', foo: { lat: 40, lon: -70 }
            assert_equal({geo_distance_range: { foo: { lat: 40, lon: -70 }, from: '10km', to: '20km' }}, subject.to_hash)
          end

          should "take options" do
            subject = GeoDistanceRange.new :foo, from: '10km', to: '20km' do
              lat 40
              lon -70
            end
            assert_equal({geo_distance_range: { foo: { lat: 40, lon: -70 }, from: '10km', to: '20km' }}, subject.to_hash)
          end
        end
      end
    end
  end
end
