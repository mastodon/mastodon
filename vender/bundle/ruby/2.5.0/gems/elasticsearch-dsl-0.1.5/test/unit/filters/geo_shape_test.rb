require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class GeoShapeTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "GeoShape filter" do
          subject { GeoShape.new }

          should "be converted to a Hash" do
            assert_equal({ geo_shape: {} }, subject.to_hash)
          end
                          
          should "have option methods" do
            subject = GeoShape.new :foo
            
            subject.shape 'bar'
            subject.indexed_shape 'bar'
          
            assert_equal %w[ indexed_shape shape ],
                         subject.to_hash[:geo_shape][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:geo_shape][:foo][:shape]
          end
          
          should "take a block" do
            subject = GeoShape.new :foo do
              shape 'bar'
            end
            assert_equal({geo_shape: { foo: { shape: 'bar' } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
