require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class GeoBoundingBoxTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "GeoBoundingBox filter" do
          subject { GeoBoundingBox.new }

          should "be converted to a Hash" do
            assert_equal({ geo_bounding_box: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = GeoBoundingBox.new :foo

            subject.top_left     'bar'
            subject.bottom_right 'bar'
            subject.top_right    'bar'
            subject.bottom_left  'bar'
            subject.top          'bar'
            subject.left         'bar'
            subject.bottom       'bar'
            subject.right        'bar'

            assert_equal %w[ bottom bottom_left bottom_right left right top top_left top_right ],
                         subject.to_hash[:geo_bounding_box][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:geo_bounding_box][:foo][:top_left]
          end

          should "take a block" do
            subject = GeoBoundingBox.new :foo do
              top_left     [0,1]
              bottom_right [3,2]
            end

            assert_equal({geo_bounding_box: { foo: { top_left: [0,1], bottom_right: [3,2] } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
