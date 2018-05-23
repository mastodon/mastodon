require 'test_helper'

module Elasticsearch
  module Test
    class SearchFilterTest < ::Test::Unit::TestCase
      subject { Elasticsearch::DSL::Search::Filter.new }

      context "Search Filter" do

        should "be serializable to a Hash" do
          assert_equal( {}, subject.to_hash )

          subject = Elasticsearch::DSL::Search::Filter.new
          subject.instance_variable_set(:@value, { foo: 'bar' })
          assert_equal( { foo: 'bar' }, subject.to_hash )
        end

        should "evaluate the block and return itself" do
          block   = Proc.new { 1+1 }
          subject = Elasticsearch::DSL::Search::Filter.new &block

          subject.expects(:instance_eval)
          assert_instance_of Elasticsearch::DSL::Search::Filter, subject.call
        end

        should "call the block and return itself" do
          block   = Proc.new { |s| 1+1 }
          subject = Elasticsearch::DSL::Search::Filter.new &block

          block.expects(:call)
          assert_instance_of Elasticsearch::DSL::Search::Filter, subject.call
        end

        should "define the value with filter methods" do
          assert_nothing_raised do
            subject.term foo: 'bar'
            assert_instance_of Hash, subject.to_hash
            assert_equal( { term: { foo: 'bar' } }, subject.to_hash )
          end
        end

        should "redefine the value with filter methods" do
          assert_nothing_raised do
            subject.term foo: 'bar'
            subject.term foo: 'bam'
            subject.to_hash
            subject.to_hash
            assert_instance_of Hash, subject.to_hash
            assert_equal({ term: { foo: 'bam' } }, subject.to_hash)
          end
        end

        should "raise an exception for unknown filter" do
          assert_raise(NoMethodError) { subject.foofoo }
        end

      end

    end
  end
end
