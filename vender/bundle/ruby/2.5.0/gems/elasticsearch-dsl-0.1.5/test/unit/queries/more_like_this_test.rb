require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class MoreLikeThisTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "MoreLikeThis query" do
          subject { MoreLikeThis.new }

          should "be converted to a Hash" do
            assert_equal({ more_like_this: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = MoreLikeThis.new

            subject.fields 'bar'
            subject.like_text 'bar'
            subject.min_term_freq 'bar'
            subject.max_query_terms 'bar'
            subject.docs 'bar'
            subject.ids 'bar'
            subject.include 'bar'
            subject.exclude 'bar'
            subject.percent_terms_to_match 'bar'
            subject.stop_words 'bar'
            subject.min_doc_freq 'bar'
            subject.max_doc_freq 'bar'
            subject.min_word_length 'bar'
            subject.max_word_length 'bar'
            subject.boost_terms 'bar'
            subject.boost 'bar'
            subject.analyzer 'bar'

            assert_equal %w[ analyzer boost boost_terms docs exclude fields ids include like_text max_doc_freq max_query_terms max_word_length min_doc_freq min_term_freq min_word_length percent_terms_to_match stop_words ],
                         subject.to_hash[:more_like_this].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:more_like_this][:fields]
          end

          should "take a block" do
            subject = MoreLikeThis.new do
              fields ['foo', 'bar']
              like_text 'abc'
            end
            assert_equal({more_like_this: { fields: ['foo','bar'], like_text: 'abc' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
