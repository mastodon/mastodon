require 'test_helper'

module Elasticsearch
  module Test
    class SearchQueryTest < ::Test::Unit::TestCase
      subject { Elasticsearch::DSL::Search::Query.new }

      context "Search Query" do

        should "be serializable to a Hash" do
          assert_equal( {}, subject.to_hash )

          subject = Elasticsearch::DSL::Search::Query.new
          subject.instance_variable_set(:@value, {})
          assert_equal( {}, subject.to_hash )
        end

        should "evaluate the block and return itself" do
          block   = Proc.new { 1+1 }
          subject = Elasticsearch::DSL::Search::Query.new &block

          subject.expects(:instance_eval)
          assert_instance_of Elasticsearch::DSL::Search::Query, subject.call
        end

        should "call the block and return itself" do
          block   = Proc.new { |s| 1+1 }
          subject = Elasticsearch::DSL::Search::Query.new &block

          block.expects(:call)
          assert_instance_of Elasticsearch::DSL::Search::Query, subject.call
        end

        should "define the value with query methods" do
          assert_nothing_raised do
            subject.match foo: 'bar'
            assert_instance_of Hash, subject.to_hash
            assert_equal( { match: { foo: 'bar' } }, subject.to_hash )
          end
        end

        should "redefine the value with query methods" do
          assert_nothing_raised do
            subject.match foo: 'bar'
            subject.match foo: 'bam'
            subject.to_hash
            subject.to_hash
            assert_instance_of Hash, subject.to_hash
            assert_equal({ match: { foo: 'bam' } }, subject.to_hash)
          end
        end

        should "have the query methods" do
          assert_nothing_raised { subject.match foo: 'bar' }
        end

        should "raise an exception for unknown query" do
          assert_raise(NoMethodError) { subject.foofoo }
        end

      end

    end
  end
end
