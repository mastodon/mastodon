require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class BoostingTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Boosting query" do
          subject { Boosting.new }

          should "be converted to a Hash" do
            assert_equal({ boosting: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Boosting.new

            subject.positive 'bar'
            subject.negative 'bar'
            subject.negative_boost 'bar'

            assert_equal %w[ negative negative_boost positive ],
                         subject.to_hash[:boosting].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:boosting][:positive]
          end

          should "take a block" do
            subject = Boosting.new do
              positive foo: 'bar'
              negative moo: 'xoo'
            end

            assert_equal 'bar', subject.to_hash[:boosting][:positive][:foo]
            assert_equal 'xoo', subject.to_hash[:boosting][:negative][:moo]
          end
        end
      end
    end
  end
end
