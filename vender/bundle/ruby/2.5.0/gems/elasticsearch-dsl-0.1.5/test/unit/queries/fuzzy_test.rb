require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class FuzzyTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Fuzzy query" do
          subject { Fuzzy.new }

          should "be converted to a Hash" do
            assert_equal({ fuzzy: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Fuzzy.new :foo

            subject.value 'bar'
            subject.boost 'bar'
            subject.fuzziness 'bar'
            subject.prefix_length 'bar'
            subject.max_expansions 'bar'

            assert_equal %w[ boost fuzziness max_expansions prefix_length value ],
                         subject.to_hash[:fuzzy][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:fuzzy][:foo][:value]
          end

          should "take a block" do
            subject = Fuzzy.new :foo do
              value 'bar'
            end
            assert_equal({fuzzy: { foo: { value: 'bar' } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
