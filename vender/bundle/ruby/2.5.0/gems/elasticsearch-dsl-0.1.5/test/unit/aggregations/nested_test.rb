require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class NestedTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Nested aggregation" do
          subject { Nested.new }

          should "be converted to a Hash" do
            assert_equal({ nested: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Nested.new

            subject.path 'bar'

            assert_equal %w[ path ],
                         subject.to_hash[:nested].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:nested][:path]
          end

          should "take a block" do
            subject = Nested.new do
              path 'bar'
            end
            assert_equal({nested: { path: 'bar' } }, subject.to_hash)
          end

          should "define aggregations" do
            subject = Nested.new do
              path 'bar'

              aggregation :min_price do
                min field: 'bam'
              end
            end

            assert_equal({nested: { path: 'bar' }, aggregations: { min_price: { min: { field: 'bam' } } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
