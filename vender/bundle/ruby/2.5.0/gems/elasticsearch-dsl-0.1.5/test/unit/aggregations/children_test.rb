require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class ChildrenTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Children aggregation" do
          subject { Children.new }

          should "be converted to a Hash" do
            assert_equal({ children: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Children.new

            subject.type 'bar'

            assert_equal %w[ type ],
                         subject.to_hash[:children].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:children][:type]
          end

          should "take a block" do
            subject = Children.new do
              type 'bar'
            end
            assert_equal({children: { type: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
