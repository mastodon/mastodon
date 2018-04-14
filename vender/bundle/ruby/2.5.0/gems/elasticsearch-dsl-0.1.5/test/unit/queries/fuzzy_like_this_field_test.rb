require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class FuzzyLikeThisFieldTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "FuzzyLikeThisField query" do
          subject { FuzzyLikeThisField.new }

          should "be converted to a Hash" do
            assert_equal({ fuzzy_like_this_field: {} }, subject.to_hash)
          end
                          
          should "have option methods" do
            subject = FuzzyLikeThisField.new :foo
            
            subject.like_text 'bar'
            subject.fuzziness 'bar'
            subject.analyzer 'bar'
            subject.max_query_terms 'bar'
            subject.prefix_length 'bar'
            subject.boost 'bar'
            subject.ignore_tf 'bar'
          
            assert_equal %w[ analyzer boost fuzziness ignore_tf like_text max_query_terms prefix_length ],
                         subject.to_hash[:fuzzy_like_this_field][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:fuzzy_like_this_field][:foo][:like_text]
          end
          
          should "take a block" do
            subject = FuzzyLikeThisField.new :foo do
              like_text 'bar'
            end
            assert_equal 'bar', subject.to_hash[:fuzzy_like_this_field][:foo][:like_text]
          end
        end
      end
    end
  end
end
