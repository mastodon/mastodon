require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class IpRangeTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "IpRange aggregation" do
          subject { IpRange.new }

          should "be converted to a Hash" do
            assert_equal({ ip_range: {} }, subject.to_hash)

            subject = IpRange.new field: 'test', ranges: [ {to: 'foo'}, {from: 'bar'} ]
            assert_equal({ ip_range: { field: 'test', ranges: [ {to: 'foo'}, {from: 'bar'} ] } }, subject.to_hash)
          end

          should "have option methods" do
            subject = IpRange.new

            subject.field 'bar'
            subject.ranges 'bar'

            assert_equal %w[ field ranges ],
                         subject.to_hash[:ip_range].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:ip_range][:field]
          end

          should "take a block" do
            subject = IpRange.new do
              field 'bar'
              ranges [ {to: 'foo'}, {from: 'bar'} ]
            end
            assert_equal({ip_range: { field: 'bar', ranges: [ {to: 'foo'}, {from: 'bar'} ] } }, subject.to_hash)
          end
        end
      end
    end
  end
end
