require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class CommonTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Common query" do
          subject { Common.new }

          should "be converted to a Hash" do
            assert_equal({ common: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Common.new :foo

            subject.query 'bar'
            subject.cutoff_frequency 'bar'
            subject.low_freq_operator 'bar'
            subject.minimum_should_match 'bar'
            subject.boost 'bar'
            subject.analyzer 'bar'
            subject.disable_coord 'bar'

            assert_equal %w[ analyzer boost cutoff_frequency disable_coord low_freq_operator minimum_should_match query ],
                         subject.to_hash[:common][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:common][:foo][:query]
          end

          should "take a block" do
            subject = Common.new :foo do
              query 'bar'
            end
            assert_equal 'bar', subject.to_hash[:common][:foo][:query]
          end
        end
      end
    end
  end
end
