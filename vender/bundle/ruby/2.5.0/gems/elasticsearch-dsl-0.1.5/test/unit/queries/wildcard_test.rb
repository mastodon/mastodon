require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class WildcardTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Wildcard query" do
          subject { Wildcard.new }

          should "be converted to a Hash" do
            assert_equal({ wildcard: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Wildcard.new :foo

            subject.value 'bar'
            subject.boost 'bar'

            assert_equal %w[ boost value ],
                         subject.to_hash[:wildcard][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:wildcard][:foo][:value]
          end

          should "take a hash" do
            subject = Wildcard.new foo: 'bar'

            assert_equal({ wildcard: { foo: 'bar' } }, subject.to_hash)
          end

          should "take a block" do
            subject = Wildcard.new :foo do
              value 'bar'
            end
            assert_equal({ wildcard: { foo: { value: 'bar' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
