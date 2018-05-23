require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class PercentileRanksTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "PercentileRanks agg" do
          subject { PercentileRanks.new }

          should "be converted to a Hash" do
            assert_equal({ percentile_ranks: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = PercentileRanks.new

            subject.field 'bar'
            subject.values 'bar'
            subject.script 'bar'
            subject.params 'bar'
            subject.compression 'bar'

            assert_equal %w[ compression field params script values ],
                         subject.to_hash[:percentile_ranks].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:percentile_ranks][:field]
          end

          should "take a block" do
            subject = PercentileRanks.new do
              field 'bar'
              values [5, 10]
            end
            assert_equal({percentile_ranks: { field: 'bar', values: [5, 10] } }, subject.to_hash)
          end
        end
      end
    end
  end
end
