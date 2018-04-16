require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class GeoBoundsTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "GeoBounds agg" do
          subject { GeoBounds.new }

          should "be converted to a Hash" do
            assert_equal({ geo_bounds: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = GeoBounds.new

            subject.field 'bar'
            subject.wrap_longitude 'bar'

            assert_equal %w[ field wrap_longitude ],
                         subject.to_hash[:geo_bounds].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:geo_bounds][:field]
          end

          should "take a block" do
            subject = GeoBounds.new do
              field 'bar'
            end
            assert_equal({geo_bounds: { field: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
