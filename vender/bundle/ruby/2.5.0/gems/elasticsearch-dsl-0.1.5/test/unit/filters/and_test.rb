require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class AndTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "And filter" do
          subject { And.new }

          should "be converted to a Hash" do
            assert_equal({ and: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = And.new filters: [ { term: { foo: 'bar' } } ]
            assert_equal({ and: { filters: [ { term: { foo: 'bar' } } ] } }, subject.to_hash)
          end

          should "take a block" do
            subject = And.new do
              term foo: 'bar'
              term moo: 'mam'
            end
            assert_equal({and: [ {term: { foo: 'bar'}}, {term: { moo: 'mam'}} ]}, subject.to_hash)
          end

          should "behave like an Enumerable" do
            subject = And.new
            subject << { term: { foo: 'bar' } }
            subject << { term: { moo: 'mam' } }

            assert_equal 2,    subject.size
            assert_equal 'bar', subject[0][:term][:foo]
            assert subject.any? { |d| d[:term] == { foo: 'bar' } }
          end

          should "behave like an Enumerable with a block" do
            subject = And.new do
              term foo: 'bar'
              term moo: 'mam'
            end

            subject.call
            assert_equal 2,     subject.size

            hash = subject.to_hash
            assert_equal 'bar', hash[:and][0][:term][:foo]
            assert hash[:and].any? { |d| d[:term] == { foo: 'bar' } }
          end

          should "behave like an Array" do
            subject = And.new

            assert subject.empty?

            subject << { term: { foo: 'bar' } }
            subject << { term: { moo: 'xam' } }

            assert ! subject.empty?

            assert_equal({ and: [ { term: { foo: 'bar' } }, { term: { moo: 'xam' } } ] }, subject.to_hash)
          end
        end
      end
    end
  end
end
