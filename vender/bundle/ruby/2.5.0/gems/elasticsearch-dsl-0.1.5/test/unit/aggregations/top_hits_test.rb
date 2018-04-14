require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class TopHitsTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "TopHits agg" do
          subject { TopHits.new }

          should "be converted to a Hash" do
            assert_equal({ top_hits: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = TopHits.new

            subject.from 'bar'
            subject.size 'bar'
            subject.sort 'bar'

            assert_equal %w[ from size sort ],
                         subject.to_hash[:top_hits].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:top_hits][:from]
          end

          should "take a block" do
            subject = TopHits.new do
              from 'bar'
            end
            assert_equal({top_hits: { from: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
