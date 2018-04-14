require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class GeoDistanceTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "GeoDistance filter" do
          subject { GeoDistance.new }

          should "be converted to a Hash" do
            assert_equal({ geo_distance: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = GeoDistance.new :foo

            subject.distance 'bar'
            subject.distance_type 'bar'
            subject.lat 'bar'
            subject.lon 'bar'

            assert_equal %w[ distance distance_type foo ],
                         subject.to_hash[:geo_distance].keys.map(&:to_s).sort
            assert_equal %w[ lat lon ],
                         subject.to_hash[:geo_distance][:foo].keys.map(&:to_s).sort

            assert_equal 'bar', subject.to_hash[:geo_distance][:distance]
            assert_equal 'bar', subject.to_hash[:geo_distance][:foo][:lat]
          end

          should "take a block" do
            subject = GeoDistance.new :foo do
              distance '1km'
              lat 40
              lon -70
            end
            assert_equal({geo_distance: { distance: '1km', foo: { lat: 40, lon: -70 } }}, subject.to_hash)
          end

          should "take a Hash" do
            subject = GeoDistance.new distance: '10km', foo: { lat: 40, lon: -70 }
            assert_equal({geo_distance: { foo: { lat: 40, lon: -70 }, distance: '10km' }}, subject.to_hash)
          end

          should "take options" do
            subject = GeoDistance.new :foo, distance: '10km' do
              lat 40
              lon -70
            end
            assert_equal({geo_distance: { foo: { lat: 40, lon: -70 }, distance: '10km' }}, subject.to_hash)
          end
        end
      end
    end
  end
end
