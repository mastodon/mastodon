require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class FilteredTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Filtered query" do
          subject { Filtered.new }

          should "be converted to a Hash" do
            assert_equal({ filtered: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Filtered.new

            subject.query 'bar'
            subject.filter 'bar'
            subject.strategy 'bar'

            assert_equal %w[ filter query strategy ],
                         subject.to_hash[:filtered].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:filtered][:query]
          end

          should "take a block" do
            subject = Filtered.new do
              query 'bar'
            end
            assert_equal 'bar', subject.to_hash[:filtered][:query]
          end

          should "evaluate a block passed to the option method" do
            subject = Filtered.new do
              query do
                match foo: 'BLAM'
              end
              filter do
                term bar: 'slam'
              end
            end

            assert_equal({filtered: { query: { match: { foo: 'BLAM' } }, filter: { term: { bar: 'slam' } } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
