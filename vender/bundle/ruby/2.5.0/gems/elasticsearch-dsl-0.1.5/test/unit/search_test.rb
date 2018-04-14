require 'test_helper'

module Elasticsearch
  module Test
    class SearchTest < ::Test::Unit::TestCase
      subject { Elasticsearch::DSL::Search::Search.new }

      context "The Search module" do
        should "have the search method on instance" do
          class DummySearchReceiver
            include Elasticsearch::DSL::Search
          end

          assert_instance_of Elasticsearch::DSL::Search::Search, DummySearchReceiver.new.search
        end

        should "have the search method on module" do
          class DummySearchReceiver
            include Elasticsearch::DSL::Search
          end

          assert_instance_of Elasticsearch::DSL::Search::Search, Elasticsearch::DSL::Search.search
        end

        should "have access to the calling context" do
          class DummySearchReceiver
            include Elasticsearch::DSL::Search

            def initialize
              @other_value = 'foo'
            end

            def value
              42
            end

            def search_definition
              search do |q|
                q.from value
                q.size @other_value

                q.filter do |q|
                  q._and do |q|
                    q.term thang: @other_value
                    q.term attributes: value
                  end
                end
              end
            end
          end

          assert_equal({from: 42,
                        size: 'foo',
                        filter: { and: [ { term:  { thang: 'foo' } },
                                         { term:  { attributes: 42 } }]}},
          DummySearchReceiver.new.search_definition.to_hash)
        end
      end

      context "The Search class" do

        context "with query" do
          should "take the query as a literal value" do
            subject.query foo: 'bar'
            assert_equal({query: { foo: 'bar' }}, subject.to_hash)
          end

          should "take the query as a block" do
            Elasticsearch::DSL::Search::Query.expects(:new).returns({foo: 'bar'})
            subject.query do; end
            assert_equal({query: { foo: 'bar' }}, subject.to_hash)
          end

          should "allow chaining" do
            assert_instance_of Elasticsearch::DSL::Search::Search, subject.query(:foo)
            assert_instance_of Elasticsearch::DSL::Search::Search, subject.query(:foo).query(:bar)
          end

          should "be converted to hash" do
            assert_equal({}, subject.to_hash)

            subject.query foo: 'bar'
            assert_equal({query: { foo: 'bar' }}, subject.to_hash)
          end

          should "have a getter/setter method" do
            assert_nil subject.query
            subject.query = Object.new
            assert_not_nil subject.query
          end
        end

        context "with filter" do
          should "take the filter as a literal value" do
            subject.filter foo: 'bar'
            assert_equal({filter: { foo: 'bar' }}, subject.to_hash)
          end

          should "take the filter as a block" do
            Elasticsearch::DSL::Search::Filter.expects(:new).returns({foo: 'bar'})
            subject.filter do; end
            assert_equal({filter: { foo: 'bar' }}, subject.to_hash)
          end

          should "allow chaining" do
            assert_instance_of Elasticsearch::DSL::Search::Search, subject.filter(:foo)
            assert_instance_of Elasticsearch::DSL::Search::Search, subject.filter(:foo).filter(:bar)
          end

          should "be converted to hash" do
            assert_equal({}, subject.to_hash)

            subject.filter foo: 'bar'
            assert_equal({filter: { foo: 'bar' }}, subject.to_hash)
          end

          should "have a getter/setter method" do
            assert_nil subject.filter
            subject.filter = Object.new
            assert_not_nil subject.filter
          end
        end

        context "with post_filter" do
          should "take the filter as a literal value" do
            subject.post_filter foo: 'bar'
            assert_equal({post_filter: { foo: 'bar' }}, subject.to_hash)
          end

          should "take the filter as a block" do
            Elasticsearch::DSL::Search::Filter.expects(:new).returns({foo: 'bar'})
            subject.post_filter do; end
            assert_equal({post_filter: { foo: 'bar' }}, subject.to_hash)
          end

          should "allow chaining" do
            assert_instance_of Elasticsearch::DSL::Search::Search, subject.post_filter(:foo)
            assert_instance_of Elasticsearch::DSL::Search::Search, subject.post_filter(:foo).post_filter(:bar)
          end

          should "be converted to hash" do
            assert_equal({}, subject.to_hash)

            subject.post_filter foo: 'bar'
            assert_equal({post_filter: { foo: 'bar' }}, subject.to_hash)
          end

          should "have a getter/setter method" do
            assert_nil subject.post_filter
            subject.post_filter = Object.new
            assert_not_nil subject.post_filter
          end
        end

        context "with aggregations" do
          should "take the aggregation as a literal value" do
            subject.aggregation :foo, terms: 'bar'
            assert_equal({aggregations: { foo: { terms: "bar" } } }, subject.to_hash)
          end

          should "take the aggregation as a block" do
            Elasticsearch::DSL::Search::Aggregation.expects(:new).returns({tam: 'tam'})
            subject.aggregation :foo do; end
            assert_equal({aggregations: { foo: { tam: 'tam' } } }, subject.to_hash)
          end

          should "allow chaining" do
            assert_instance_of Elasticsearch::DSL::Search::Search, subject.aggregation(:foo)
            assert_instance_of Elasticsearch::DSL::Search::Search, subject.aggregation(:foo).aggregation(:bar)
          end

          should "be converted to hash" do
            assert_equal({}, subject.to_hash)

            subject.post_filter foo: 'bar'
            assert_equal({post_filter: { foo: 'bar' }}, subject.to_hash)
          end

          should "have a getter/setter method" do
            assert_nil subject.aggregations
            subject.aggregations = { foo: Object.new }
            assert_not_nil subject.aggregations
          end
        end

        context "with sorting" do
          should "be converted to hash" do
            subject.sort :foo
            assert_equal( { sort: [ :foo ] }, subject.to_hash )
          end

          should "have a getter method" do
            assert_nil subject.sort
            subject.sort :foo
            assert_instance_of Elasticsearch::DSL::Search::Sort, subject.sort
          end
        end

        context "with suggest" do
          should "be converted to hash" do
            subject.suggest :foo, { bar: 'bam' }
            assert_equal( { suggest: { foo: { bar: 'bam' } } }, subject.to_hash )
          end

          should "have a getter/setter method" do
            assert_nil subject.suggest
            subject.suggest = Object.new
            assert_not_nil subject.suggest
          end
        end

        context "with highlighting" do
          should "be converted to a hash" do
            subject.highlight foo: 'bar'
            assert_not_nil subject.highlight
            assert_equal( { highlight: { foo: 'bar' } }, subject.to_hash )
          end
        end

        context "with options" do
          should "encode options" do
            subject.explain true
            subject.fields [:foo, :bar]
            assert_equal( { explain: true, fields: [:foo, :bar] }, subject.to_hash )
          end

          should "raise an exception for unknown method" do
            assert_raise(NoMethodError) { subject.foobar true }
          end
        end

      end
    end
  end
end
