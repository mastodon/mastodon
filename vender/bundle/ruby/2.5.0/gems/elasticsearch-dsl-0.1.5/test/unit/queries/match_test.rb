require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class MatchTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Match Query" do
          subject { Match.new }

          should "be converted to a Hash" do
            assert_equal({ match: {} }, subject.to_hash)
          end

          should "take a concrete value" do
            subject = Match.new message: 'test'

            assert_equal({match: {message: "test"}}, subject.to_hash)
          end

          should "have option methods" do
            subject = Match.new

            subject.query    'bar'
            subject.operator 'bar'
            subject.type     'bar'

            assert_equal %w[ operator query type ],
                         subject.to_hash[:match].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:match][:query]
          end

          should "take a Hash" do
            subject = Match.new message: { query: 'test', operator: 'and' }

            assert_equal({match: {message: {query: "test", operator: "and"}}}, subject.to_hash)
          end

          should "take a block" do
            subject = Match.new :message do
              query     'test'
              operator  'and'
              type      'phrase_prefix'
              boost     2
              fuzziness 'AUTO'
            end

            assert_equal({match: {message: {query: "test", operator: "and", type: 'phrase_prefix', boost: 2, fuzziness: 'AUTO'}}},
                         subject.to_hash)
          end

          should "take a method call" do
            subject = Match.new :message
            subject.query    'test'
            subject.operator 'and'

            assert_equal({match: {message: {query: "test", operator: "and"}}}, subject.to_hash)
          end

        end
      end
    end
  end
end
