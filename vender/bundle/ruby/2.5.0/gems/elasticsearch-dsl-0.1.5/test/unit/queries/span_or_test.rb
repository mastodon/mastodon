require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class SpanOrTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "SpanOr query" do
          subject { SpanOr.new }

          should "be converted to a Hash" do
            assert_equal({ span_or: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = SpanOr.new

            subject.clauses 'bar'

            assert_equal %w[ clauses ],
                         subject.to_hash[:span_or].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:span_or][:clauses]
          end

          should "take a block" do
            subject = SpanOr.new do
              clauses 'bar'
            end
            assert_equal({span_or: { clauses: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
