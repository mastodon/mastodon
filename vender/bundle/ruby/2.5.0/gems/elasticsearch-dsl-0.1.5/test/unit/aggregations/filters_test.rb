require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class FiltersTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Filters agg" do
          subject { Elasticsearch::DSL::Search::Aggregations::Filters.new }

          should "be converted to a Hash" do
            assert_equal({ filters: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Elasticsearch::DSL::Search::Aggregations::Filters.new
            subject.filters foo: 'bar'

            assert_equal 'bar', subject.to_hash[:filters][:filters][:foo]
          end

          should "define filters" do
            subject = Elasticsearch::DSL::Search::Aggregations::Filters.new filters: { foo: 'bar' }
            assert_equal({ filters: { filters: { foo: 'bar' } } }, subject.to_hash)
          end

          should "define filters with a block" do
            subject = Elasticsearch::DSL::Search::Aggregations::Filters.new do
              filters foo: 'bar'
            end
            assert_equal({ filters: { filters: { foo: 'bar' } } }, subject.to_hash)
          end

          should "define aggregations" do
            subject = Elasticsearch::DSL::Search::Aggregations::Filters.new do
              filters foo: { terms: { foo: 'bar' } }
              aggregation :sum_clicks do
                sum moo: 'bam'
              end
            end

            assert_equal(
              { filters: { filters: { foo: { terms: { foo: 'bar' } } } }, aggregations: { sum_clicks: { sum: { moo: 'bam' } } } },
              subject.to_hash)
          end

        end
      end
    end
  end
end
