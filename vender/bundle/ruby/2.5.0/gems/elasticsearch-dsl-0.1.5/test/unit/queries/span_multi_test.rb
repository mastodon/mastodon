require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class SpanMultiTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "SpanMulti query" do
          subject { SpanMulti.new }

          should "be converted to a Hash" do
            assert_equal({ span_multi: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = SpanMulti.new

            subject.match 'bar'

            assert_equal %w[ match ],
                         subject.to_hash[:span_multi].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:span_multi][:match]
          end

          should "take a block" do
            subject = SpanMulti.new do
              match 'bar'
            end
            assert_equal({span_multi: { match: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
