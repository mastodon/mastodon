require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class FuzzyLikeThisTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "FuzzyLikeThis query" do
          subject { FuzzyLikeThis.new }

          should "be converted to a Hash" do
            assert_equal({ fuzzy_like_this: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = FuzzyLikeThis.new

            subject.fields 'bar'
            subject.like_text 'bar'
            subject.fuzziness 'bar'
            subject.analyzer 'bar'
            subject.max_query_terms 'bar'
            subject.prefix_length 'bar'
            subject.boost 'bar'

            assert_equal %w[ analyzer boost fields fuzziness like_text max_query_terms prefix_length ],
                         subject.to_hash[:fuzzy_like_this].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:fuzzy_like_this][:fields]
          end

          should "take a block" do
            subject = FuzzyLikeThis.new do
              fields ['foo']
              like_text 'bar'
            end

            assert_equal({ fuzzy_like_this: { fields: ['foo'], like_text: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
