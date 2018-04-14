require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class DateHistogramTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "DateHistogram aggregation" do
          subject { DateHistogram.new }

          should "be converted to a Hash" do
            assert_equal({ date_histogram: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = DateHistogram.new

            subject.field 'bar'
            subject.interval 'bar'
            subject.pre_zone 'bar'
            subject.post_zone 'bar'
            subject.time_zone 'bar'
            subject.pre_zone_adjust_large_interval 'bar'
            subject.pre_offset 'bar'
            subject.post_offset 'bar'
            subject.format 'bar'
            subject.min_doc_count 'bar'
            subject.extended_bounds 'bar'
            subject.order 'bar'

            assert_equal %w[ extended_bounds field format interval min_doc_count order post_offset post_zone pre_offset pre_zone pre_zone_adjust_large_interval time_zone ],
                         subject.to_hash[:date_histogram].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:date_histogram][:field]
          end

          should "take a block" do
            subject = DateHistogram.new do
              field    'bar'
              interval 'day'
              format   'yyyy-MM-dd'
            end
            assert_equal({date_histogram: { field: 'bar', interval: 'day', format: 'yyyy-MM-dd' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
