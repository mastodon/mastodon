require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class MultiMatchTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "MultiMatch query" do
          subject { MultiMatch.new }

          should "be converted to a Hash" do
            assert_equal({ multi_match: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = MultiMatch.new

            subject.query 'bar'
            subject.fields 'bar'
            subject.type 'bar'
            subject.use_dis_max 'bar'

            assert_equal %w[ fields query type use_dis_max ],
                         subject.to_hash[:multi_match].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:multi_match][:query]
          end

          should "take a block" do
            subject = MultiMatch.new do
              query 'bar'
              fields ['a', 'b']
            end

            assert_equal 'bar', subject.to_hash[:multi_match][:query]
            assert_equal ['a', 'b'], subject.to_hash[:multi_match][:fields]
          end
        end
      end
    end
  end
end
