require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class SpanFirstTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "SpanFirst query" do
          subject { SpanFirst.new }

          should "be converted to a Hash" do
            assert_equal({ span_first: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = SpanFirst.new

            subject.match 'bar'

            assert_equal %w[ match ],
                         subject.to_hash[:span_first].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:span_first][:match]
          end

          should "take a block" do
            subject = SpanFirst.new do
              match 'bar'
            end
            assert_equal({ span_first: { match: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
