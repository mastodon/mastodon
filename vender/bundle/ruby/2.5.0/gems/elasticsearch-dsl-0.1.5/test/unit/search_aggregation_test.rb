require 'test_helper'

module Elasticsearch
  module Test
    class SearchAggregationTest < ::Test::Unit::TestCase
      subject { Elasticsearch::DSL::Search::Aggregation.new }

      context "Search Aggregation" do

        should "be serializable to a Hash" do
          assert_equal( {}, subject.to_hash )

          subject = Elasticsearch::DSL::Search::Aggregation.new
          subject.instance_variable_set(:@value, { foo: 'bar' })
          assert_equal( { foo: 'bar' }, subject.to_hash )
        end

        should "evaluate the block and return itself" do
          block   = Proc.new { 1+1 }
          subject = Elasticsearch::DSL::Search::Aggregation.new &block

          subject.expects(:instance_eval)
          assert_instance_of Elasticsearch::DSL::Search::Aggregation, subject.call
        end

        should "call the block and return itself" do
          block   = Proc.new { |s| 1+1 }
          subject = Elasticsearch::DSL::Search::Aggregation.new &block

          block.expects(:call)
          assert_instance_of Elasticsearch::DSL::Search::Aggregation, subject.call
        end

        should "define the value with DSL methods" do
          assert_nothing_raised do
            subject.terms field: 'foo'
            assert_instance_of Hash, subject.to_hash
            assert_equal( { terms: { field: 'foo' } }, subject.to_hash )
          end
        end

        should "raise an exception for unknown DSL method" do
          assert_raise(NoMethodError) { subject.foofoo }
        end

        should "return the aggregations" do
          subject.expects(:call)
          subject.instance_variable_set(:@value, mock(aggregations: { foo: 'bar' }))

          subject.aggregations
        end

        should "define a nested aggregation" do
          subject.instance_variable_set(:@value, mock(aggregation: true))

          subject.aggregation(:foo) { 1+1 }
        end

        should "return a non-hashy value directly" do
          subject.instance_variable_set(:@value, 'FOO')
          assert_equal 'FOO', subject.to_hash
        end

        should "return an empty Hash when it has no value set" do
          subject.instance_variable_set(:@value, nil)
          assert_equal({}, subject.to_hash)
        end
      end

    end
  end
end
