require 'test_helper'

module Elasticsearch
  module Test
    class SearchSortTest < ::Test::Unit::TestCase
      subject { Elasticsearch::DSL::Search::Sort.new }

      context "Search sort" do

        should "add a single field" do
          subject = Elasticsearch::DSL::Search::Sort.new :foo
          assert_equal( [:foo], subject.to_hash )
        end

        should "add multiple fields" do
          subject = Elasticsearch::DSL::Search::Sort.new [:foo, :bar]
          assert_equal( [:foo, :bar], subject.to_hash )
        end

        should "add a field with options" do
          subject = Elasticsearch::DSL::Search::Sort.new foo: { order: 'desc', mode: 'avg' }
          assert_equal( [ { foo: { order: 'desc', mode: 'avg' } } ], subject.to_hash )
        end

        should "add fields with the DSL method" do
          subject = Elasticsearch::DSL::Search::Sort.new do
            by :foo
            by :bar, order: 'desc'
          end

          assert_equal(
            [
              :foo,
              { bar: { order: 'desc' } },
            ], subject.to_hash )
        end

        should "be empty" do
          subject = Elasticsearch::DSL::Search::Sort.new
          assert_equal subject.empty?, true
        end

        should "not be empty" do
          subject = Elasticsearch::DSL::Search::Sort.new foo: { order: 'desc' }
          assert_equal subject.empty?, false
        end

        context "#to_hash" do
          should "not duplicate values when defined by arguments" do
            subject = Elasticsearch::DSL::Search::Sort.new foo: { order: 'desc' }
            assert_equal(subject.to_hash, subject.to_hash)
          end

          should "not duplicate values when defined by a block" do
            subject = Elasticsearch::DSL::Search::Sort.new do
              by :foo
            end

            assert_equal(subject.to_hash, subject.to_hash)
          end
        end
      end
    end
  end
end
