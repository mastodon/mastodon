require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class SimpleQueryStringTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "SimpleQueryString query" do
          subject { SimpleQueryString.new }

          should "be converted to a Hash" do
            assert_equal({ simple_query_string: {} }, subject.to_hash)
          end
                          
          should "have option methods" do
            subject = SimpleQueryString.new :foo
            
            subject.query 'bar'
            subject.fields 'bar'
            subject.default_operator 'bar'
            subject.analyzer 'bar'
            subject.flags 'bar'
            subject.lowercase_expanded_terms 'bar'
            subject.locale 'bar'
            subject.lenient 'bar'
          
            assert_equal %w[ analyzer default_operator fields flags lenient locale lowercase_expanded_terms query ],
                         subject.to_hash[:simple_query_string][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:simple_query_string][:foo][:query]
          end
          
          should "take a block" do
            subject = SimpleQueryString.new :foo do
              query 'bar'
            end
            assert_equal({simple_query_string: { foo: { query: 'bar' } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
