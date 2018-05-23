require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class DateRangeTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "DateRange aggregation" do
          subject { DateRange.new }

          should "be converted to a Hash" do
            assert_equal({ date_range: {} }, subject.to_hash)

            subject = DateRange.new field: 'test', ranges: [ {to: 'foo'}, {from: 'bar'} ]
            assert_equal({ date_range: { field: 'test', ranges: [ {to: 'foo'}, {from: 'bar'} ] } }, subject.to_hash)
          end

          should "have option methods" do
            subject = DateRange.new

            subject.field 'bar'
            subject.format 'bar'
            subject.ranges 'bar'

            assert_equal %w[ field format ranges ],
                         subject.to_hash[:date_range].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:date_range][:field]
          end

          should "take a block" do
            subject = DateRange.new do
              field 'bar'
              ranges [ {to: 'foo'}, {from: 'bar'} ]
            end
            assert_equal({date_range: { field: 'bar', ranges: [ {to: 'foo'}, {from: 'bar'} ] } }, subject.to_hash)
          end
        end
      end
    end
  end
end
