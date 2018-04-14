require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class NestedTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Nested filter" do
          subject { Nested.new }

          should "be converted to a Hash" do
            assert_equal({ nested: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Nested.new

            subject.path 'bar'
            subject.filter 'bar'

            assert_equal %w[ filter path ],
                         subject.to_hash[:nested].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:nested][:path]
          end

          should "take a block" do
            subject = Nested.new do
              path 'bar'
              filter do
                term foo: 'bar'
              end
            end
            assert_equal({nested: { path: 'bar', filter: { term: { foo: 'bar' } } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
