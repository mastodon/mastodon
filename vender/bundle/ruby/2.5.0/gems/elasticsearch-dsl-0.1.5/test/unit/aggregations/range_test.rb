require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class RangeTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Range aggregation" do

          should "take a Hash" do
            subject = Range.new( { field: 'test', ranges: [ { to: 50 } ] } )
            assert_equal({ range: { field: "test", ranges: [ {to: 50} ] } }, subject.to_hash)
          end

          should "have option methods" do
            subject = Range.new

            subject.field 'foo'
            subject.script 'bar*2'

            assert_equal %w[ field script ], subject.to_hash[:range].keys.map(&:to_s).sort
            assert_equal 'foo', subject.to_hash[:range][:field]
          end

          should "take a block with keyed ranges" do
            subject = Range.new field: 'test' do
              key 'foo', to: 10
              key 'bar', from: 10, to: 20
            end

            assert_equal({ range: { field: "test", keyed: true, ranges: [ {to: 10, key: 'foo'}, { from: 10, to: 20, key: 'bar'}]}}, subject.to_hash)
          end

          should "define field in the block" do
            subject = Range.new do
              field 'test'
              key   'foo', to: 10
              key   'bar', from: 10, to: 20
            end

            assert_equal({ range: { field: "test", keyed: true, ranges: [ {to: 10, key: 'foo'}, { from: 10, to: 20, key: 'bar'}]}}, subject.to_hash)
          end
        end
      end
    end
  end
end
