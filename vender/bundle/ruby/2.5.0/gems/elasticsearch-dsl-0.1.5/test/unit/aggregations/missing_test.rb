require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class MissingTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Missing aggregation" do
          subject { Missing.new }

          should "be converted to a Hash" do
            assert_equal({ missing: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = Missing.new( { field: 'foo' } )
            assert_equal({ missing: { field: "foo" } }, subject.to_hash)
          end

          should "have option methods" do
            subject.field 'foo'

            assert_equal %w[ field ], subject.to_hash[:missing].keys.map(&:to_s).sort
            assert_equal 'foo', subject.to_hash[:missing][:field]
          end

          should "take a block" do
            subject = Missing.new do
              field 'bar'
            end

            assert_equal({missing: { field: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
