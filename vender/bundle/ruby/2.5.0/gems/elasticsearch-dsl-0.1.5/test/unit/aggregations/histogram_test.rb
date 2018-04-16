require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class HistogramTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Histogram aggregation" do
          subject { Histogram.new }

          should "be converted to a Hash" do
            assert_equal({ histogram: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Histogram.new

            subject.field 'bar'
            subject.interval 'bar'
            subject.min_doc_count 'bar'
            subject.extended_bounds 'bar'
            subject.order 'bar'
            subject.keyed 'bar'

            assert_equal %w[ extended_bounds field interval keyed min_doc_count order ],
                         subject.to_hash[:histogram].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:histogram][:field]
          end

          should "take a block" do
            subject = Histogram.new do
              field    'bar'
              interval 5
            end
            assert_equal({histogram: { field: 'bar', interval: 5 } }, subject.to_hash)
          end
        end
      end
    end
  end
end
