require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class ConstantScoreTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "ConstantScore query" do
          subject { ConstantScore.new }

          should "be converted to a Hash" do
            assert_equal({ constant_score: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = ConstantScore.new

            subject.query 'bar'
            subject.filter 'bar'
            subject.boost 'bar'

            assert_equal %w[ boost filter query ],
                         subject.to_hash[:constant_score].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:constant_score][:query]
          end

          should "take a block" do
            subject = ConstantScore.new do
              query term: { foo: 'bar' }
            end
            assert_equal 'bar', subject.to_hash[:constant_score][:query][:term][:foo]
          end

          should "evaluate a block passed to the option method" do
            subject = ConstantScore.new do
              query do
                term foo: 'bar'
              end
            end
            assert_equal 'bar', subject.to_hash[:constant_score][:query][:term][:foo]
          end
        end
      end
    end
  end
end
