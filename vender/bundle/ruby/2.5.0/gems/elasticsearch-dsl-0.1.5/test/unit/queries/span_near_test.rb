require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class SpanNearTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "SpanNear query" do
          subject { SpanNear.new }

          should "be converted to a Hash" do
            assert_equal({ span_near: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = SpanNear.new

            subject.span_near 'bar'
            subject.slop 'bar'
            subject.in_order 'bar'
            subject.collect_payloads 'bar'

            assert_equal %w[ collect_payloads in_order slop span_near ],
                         subject.to_hash[:span_near].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:span_near][:span_near]
          end

          should "take a block" do
            subject = SpanNear.new do
              span_near 'bar'
            end
            assert_equal({ span_near: { span_near: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
