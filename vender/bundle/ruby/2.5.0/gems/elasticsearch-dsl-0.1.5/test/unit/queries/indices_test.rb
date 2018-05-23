require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class IndicesTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Indices query" do
          subject { Indices.new }

          should "be converted to a Hash" do
            assert_equal({ indices: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Indices.new

            subject.indices 'bar'
            subject.query 'bar'
            subject.no_match_query 'bar'

            assert_equal %w[ indices no_match_query query ],
                         subject.to_hash[:indices].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:indices][:indices]
          end

          should "take a block" do
            subject = Indices.new do
              indices 'bar'
              query term: { foo: 'bar' }
            end
            assert_equal({indices: { indices: 'bar', query: { term: { foo: 'bar' } } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
