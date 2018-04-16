require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class HasParentTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "HasParent query" do
          subject { HasParent.new }

          should "be converted to a Hash" do
            assert_equal({ has_parent: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = HasParent.new

            subject.parent_type 'bar'
            subject.query 'bar'
            subject.score_mode 'bar'

            assert_equal %w[ parent_type query score_mode ],
                         subject.to_hash[:has_parent].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:has_parent][:parent_type]
          end

          should "take a block" do
            subject = HasParent.new do
              parent_type 'bar'
              query match: { foo: 'bar' }
            end
            assert_equal({ has_parent: { parent_type: 'bar', query: { match: { foo: 'bar' } } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
