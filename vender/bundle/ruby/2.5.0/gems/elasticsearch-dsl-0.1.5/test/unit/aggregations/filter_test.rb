require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class FilterTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Filter agg" do
          subject { Filter.new }

          should "be converted to a Hash" do
            assert_equal({ filter: {} }, subject.to_hash)
          end

          should "nest another aggregation" do
            subject = Filter.new terms: { foo: 'bar' } do
              aggregation :sum_clicks do
                sum moo: 'bam'
              end
            end

            assert_equal(
              { filter: { terms: { foo: 'bar' } }, aggregations: { sum_clicks: { sum: { moo: 'bam' } } } },
              subject.to_hash)
          end
        end
      end
    end
  end
end
