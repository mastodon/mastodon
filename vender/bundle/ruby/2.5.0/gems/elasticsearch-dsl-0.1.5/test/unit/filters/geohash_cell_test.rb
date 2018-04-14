require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class GeohashCellTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "GeohashCell filter" do
          subject { GeohashCell.new }

          should "be converted to a Hash" do
            assert_equal({ geohash_cell: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = GeohashCell.new :foo

            subject.precision 'bar'
            subject.neighbors 'bar'
            subject.lat 'bar'
            subject.lon 'bar'

            assert_equal %w[ foo neighbors precision ],
                         subject.to_hash[:geohash_cell].keys.map(&:to_s).sort
            assert_equal %w[ lat lon ],
                         subject.to_hash[:geohash_cell][:foo].keys.map(&:to_s).sort

            assert_equal 'bar', subject.to_hash[:geohash_cell][:precision]
            assert_equal 'bar', subject.to_hash[:geohash_cell][:foo][:lat]
          end

          should "take a block" do
            subject = GeohashCell.new :foo do
              lat 'bar'
            end
            assert_equal({geohash_cell: { foo: { lat: 'bar' } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
