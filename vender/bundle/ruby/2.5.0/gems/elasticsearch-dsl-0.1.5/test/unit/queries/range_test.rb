require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class RangeTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Range Query" do

          should "take a Hash" do
            @subject = Range.new age: { gte: 10, lte: 20 }

            assert_equal({:range=>{:age=>{:gte=>10, :lte=>20}}}, @subject.to_hash)
          end

          should "take a block" do
            @subject = Range.new :age do
              gte   10
              lte   20
              boost 2
              format 'mm/dd/yyyy'
            end

            assert_equal({:range=>{:age=>{:gte=>10, :lte=>20, :boost=>2, :format=>'mm/dd/yyyy'}}}, @subject.to_hash)
          end

          should "take a method call" do
            @subject = Range.new :age
            @subject.gte 10
            @subject.lte 20
            @subject.format 'mm/dd/yyyy'

            assert_equal({:range=>{:age=>{:gte=>10, :lte=>20, :format=>'mm/dd/yyyy'}}}, @subject.to_hash)
          end

        end
      end
    end
  end
end
