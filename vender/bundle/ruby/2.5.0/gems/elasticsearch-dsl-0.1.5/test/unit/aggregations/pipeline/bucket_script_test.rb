require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class BucketScriptTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Bucket Script agg" do
          subject { BucketScript.new }

          should "be converted to a hash" do
            assert_equal({ bucket_script: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = BucketScript.new :foo

            subject.buckets_path foo: 'foo', bar: 'bar'
            subject.script 'bar'
            subject.gap_policy 'skip'
            subject.format 'bar'

            assert_equal %w[ buckets_path format gap_policy script ],
              subject.to_hash[:bucket_script][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:bucket_script][:foo][:buckets_path][:bar]
          end

          should "take a block" do
            subject = BucketScript.new :foo do
              format 'bar'
            end
            assert_equal({bucket_script: { foo: { format: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
