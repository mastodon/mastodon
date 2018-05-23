require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class TopChildrenTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "TopChildren query" do
          subject { TopChildren.new }

          should "be converted to a Hash" do
            assert_equal({ top_children: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = TopChildren.new

            subject.type 'bar'
            subject.query 'bar'
            subject.score 'bar'
            subject.factor 'bar'
            subject.incremental_factor 'bar'
            subject._scope 'bar'

            assert_equal %w[ _scope factor incremental_factor query score type ],
                         subject.to_hash[:top_children].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:top_children][:type]
          end

          should "take a block" do
            subject = TopChildren.new do
              type 'bar'
              query 'foo'
            end
            assert_equal({ top_children: { type: 'bar', query: 'foo' } }, subject.to_hash)
          end

          should "evaluate a block passed to the query method" do
            subject = TopChildren.new do
              type 'bar'
              query do
                match foo: 'BLAM'
              end
            end

            assert_equal({ top_children: { type: 'bar', query: { match: { foo: 'BLAM' } } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
