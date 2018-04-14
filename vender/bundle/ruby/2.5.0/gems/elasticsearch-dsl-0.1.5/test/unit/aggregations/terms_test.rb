require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class TermsTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Terms aggregation" do
          subject { Terms.new }

          should "be converted to a Hash" do
            assert_equal({ terms: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Terms.new

            subject.field 'bar'
            subject.size 'bar'
            subject.shard_size 'bar'
            subject.order 'bar'
            subject.min_doc_count 'bar'
            subject.shard_min_doc_count 'bar'
            subject.script 'bar'
            subject.include 'bar'
            subject.exclude 'bar'

            assert_equal %w[ exclude field include min_doc_count order script shard_min_doc_count shard_size size ],
                         subject.to_hash[:terms].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:terms][:field]
          end

          should "take a Hash" do
            subject = Terms.new field: 'test'

            assert_equal({:terms=>{:field=>"test"}}, subject.to_hash)
          end

          should "take a block" do
            subject = Terms.new do
              field 'bar'
            end

            assert_equal({terms: { field: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
