require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class FunctionScoreTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "FunctionScore query" do
          subject { FunctionScore.new }

          should "be converted to a Hash" do
            assert_equal({ function_score: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = FunctionScore.new

            subject.query 'bar'
            subject.filter 'bar'
            subject.functions ['bar']
            subject.script_score 'bar'
            subject.boost 'bar'
            subject.max_boost 'bar'
            subject.score_mode 'bar'
            subject.boost_mode 'bar'

            assert_equal %w[ boost boost_mode filter functions max_boost query score_mode script_score ],
                         subject.to_hash[:function_score].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:function_score][:query]
          end

          should "take a block" do
            subject = FunctionScore.new do
              query 'bar'
            end
            assert_equal 'bar', subject.to_hash[:function_score][:query]
          end

          should "evaluate a block passed to the option method" do
            subject = FunctionScore.new do
              query do
                match foo: 'BLAM'
              end
              filter do
                term bar: 'slam'
              end
              functions << { foo: { abc: '123' } }
              functions << { foo: { xyz: '456' } }
            end

            assert_equal({
              function_score: {
                query: { match: { foo: 'BLAM' } },
                filter: { term: { bar: 'slam' } },
                functions: [ { foo: { abc: '123' } }, { foo: { xyz: '456' } } ] } },
              subject.to_hash)
          end

          should "set the functions directly" do
            subject = FunctionScore.new
            subject.functions = [ {foo: { abc: '123' }} ]

            assert_equal({function_score: { functions: [ {foo: { abc: '123' }} ] }}, subject.to_hash)
          end
        end
      end
    end
  end
end
