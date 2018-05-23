require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class SpanNotTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "SpanNot query" do
          subject { SpanNot.new }

          should "be converted to a Hash" do
            assert_equal({ span_not: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = SpanNot.new

            subject.include 'bar'
            subject.exclude 'bar'
            subject.pre 'bar'
            subject.post 'bar'
            subject.dist 'bar'

            assert_equal %w[ dist exclude include post pre ],
                         subject.to_hash[:span_not].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:span_not][:include]
          end

          should "take a block" do
            subject = SpanNot.new do
              include 'bar'
            end
            assert_equal({ span_not: { include: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
