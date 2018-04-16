require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class TermsTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Terms query" do
          subject { Terms.new }

          should "be converted to a Hash" do
            assert_equal({ terms: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = Terms.new foo: ['abc', 'xyz']
            assert_equal({ terms: { foo: ['abc', 'xyz'] } }, subject.to_hash)
          end
        end
      end
    end
  end
end
