require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class PercentilesTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Percentiles agg" do
          subject { Percentiles.new }

          should "be converted to a Hash" do
            assert_equal({ percentiles: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Percentiles.new

            subject.field 'bar'
            subject.percents 'bar'
            subject.script 'bar'
            subject.params 'bar'
            subject.compression 'bar'

            assert_equal %w[ compression field params percents script ],
                         subject.to_hash[:percentiles].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:percentiles][:field]
          end

          should "take a block" do
            subject = Percentiles.new do
              field 'bar'
            end
            assert_equal({percentiles: { field: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
