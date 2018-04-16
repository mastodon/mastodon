require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class MatchAllTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "MatchAll query" do
          subject { MatchAll.new }

          should "be converted to a Hash" do
            assert_equal({ match_all: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = MatchAll.new

            subject.boost 'bar'

            assert_equal %w[ boost ],
                         subject.to_hash[:match_all].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:match_all][:boost]
          end

          should "take a block" do
            subject = MatchAll.new do
              boost 'bar'
            end
            assert_equal({match_all: { boost: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
