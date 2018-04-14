require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class DisMaxTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "DisMax query" do
          subject { DisMax.new }

          should "be converted to a Hash" do
            assert_equal({ dis_max: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = DisMax.new

            subject.tie_breaker 'bar'
            subject.boost 'bar'
            subject.queries 'bar'

            assert_equal %w[ boost queries tie_breaker ],
                         subject.to_hash[:dis_max].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:dis_max][:tie_breaker]
          end

          should "take a block" do
            subject = DisMax.new do
              tie_breaker 'bar'
            end
            assert_equal 'bar', subject.to_hash[:dis_max][:tie_breaker]
          end
        end
      end
    end
  end
end
