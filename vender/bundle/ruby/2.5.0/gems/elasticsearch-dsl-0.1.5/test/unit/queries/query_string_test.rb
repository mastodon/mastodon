require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class QueryStringTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "QueryString query" do
          subject { QueryString.new }

          should "be converted to a Hash" do
            assert_equal({ query_string: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = QueryString.new :foo

            subject.query 'bar'
            subject.fields 'bar'
            subject.default_field 'bar'
            subject.default_operator 'bar'
            subject.analyzer 'bar'
            subject.allow_leading_wildcard 'bar'
            subject.lowercase_expanded_terms 'bar'
            subject.enable_position_increments 'bar'
            subject.fuzzy_max_expansions 'bar'
            subject.fuzziness 'bar'
            subject.fuzzy_prefix_length 'bar'
            subject.phrase_slop 'bar'
            subject.boost 'bar'
            subject.analyze_wildcard 'bar'
            subject.auto_generate_phrase_queries 'bar'
            subject.minimum_should_match 'bar'
            subject.lenient 'bar'
            subject.locale 'bar'
            subject.use_dis_max 'bar'
            subject.tie_breaker 'bar'
            subject.time_zone 'bar'

            assert_equal %w[ allow_leading_wildcard analyze_wildcard analyzer auto_generate_phrase_queries boost default_field default_operator enable_position_increments fields fuzziness fuzzy_max_expansions fuzzy_prefix_length lenient locale lowercase_expanded_terms minimum_should_match phrase_slop query tie_breaker time_zone use_dis_max ],
                         subject.to_hash[:query_string][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:query_string][:foo][:query]
          end

          should "take a block" do
            subject = QueryString.new :foo do
              query 'foo AND bar'
            end
            assert_equal({ query_string: { foo: { query: 'foo AND bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
