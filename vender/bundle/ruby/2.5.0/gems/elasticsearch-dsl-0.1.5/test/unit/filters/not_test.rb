require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class NotTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Not filter" do
          subject { Not.new }

          should "be converted to a Hash" do
            assert_equal({ not: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = Not.new filters: [ { term: { foo: 'bar' } } ]
            assert_equal({ not: { filters: [ { term: { foo: 'bar' } } ] } }, subject.to_hash)
          end

          should "take a block" do
            subject = Not.new do
              term foo: 'bar'
            end
            assert_equal({not: {term: { foo: 'bar'}} }, subject.to_hash)
          end

          should "raise an exception for unknown DSL method" do
            assert_raise(NoMethodError) { subject.foofoo }
          end
        end
      end
    end
  end
end
