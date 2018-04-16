require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class OrTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Or filter" do
          subject { Or.new }

          should "be converted to a Hash" do
            assert_equal({ or: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = Or.new filters: [ { term: { foo: 'bar' } } ]
            assert_equal({ or: { filters: [ { term: { foo: 'bar' } } ] } }, subject.to_hash)
          end

          should "take a block" do
            subject = Or.new do
              term foo: 'bar'
              term moo: 'mam'
            end
            assert_equal({or: [ {term: { foo: 'bar'}}, {term: { moo: 'mam'}} ]}, subject.to_hash)
          end

          should "behave like an Enumerable" do
            subject = Or.new
            subject << { term: { foo: 'bar' } }

            assert_equal 1, subject.size
            assert subject.any? { |d| d[:term] == { foo: 'bar' } }
          end

          should "behave like an Array" do
            subject = Or.new

            assert subject.empty?

            subject << { term: { foo: 'bar' } }
            subject << { term: { moo: 'xam' } }

            assert ! subject.empty?

            assert_equal({ or: [ { term: { foo: 'bar' } }, { term: { moo: 'xam' } } ] }, subject.to_hash)
          end
        end
      end
    end
  end
end
