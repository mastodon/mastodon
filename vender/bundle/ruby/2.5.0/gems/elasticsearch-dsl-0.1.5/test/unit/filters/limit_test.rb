require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class LimitTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Limit filter" do
          subject { Limit.new }

          should "be converted to a Hash" do
            assert_equal({ limit: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Limit.new

            subject.value 'bar'

            assert_equal %w[ value ],
                         subject.to_hash[:limit].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:limit][:value]
          end

          should "take a block" do
            subject = Limit.new do
              value 'bar'
            end
            assert_equal({limit: { value: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
