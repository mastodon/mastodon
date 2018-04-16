require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class CardinalityTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "Cardinality agg" do
          subject { Cardinality.new }

          should "be converted to a Hash" do
            assert_equal({ cardinality: {} }, subject.to_hash)
          end
                          
          should "have option methods" do
            subject = Cardinality.new :foo
            
            subject.field 'bar'
            subject.precision_threshold 'bar'
            subject.rehash 'bar'
            subject.script 'bar'
            subject.params 'bar'
          
            assert_equal %w[ field params precision_threshold rehash script ],
                         subject.to_hash[:cardinality][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:cardinality][:foo][:field]
          end
          
          should "take a block" do
            subject = Cardinality.new :foo do
              field 'bar'
            end
            assert_equal({cardinality: { foo: { field: 'bar' } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
