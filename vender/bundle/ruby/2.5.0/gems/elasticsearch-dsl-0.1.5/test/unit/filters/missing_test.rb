require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class MissingTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Missing filter" do
          subject { Missing.new }

          should "be converted to a Hash" do
            assert_equal({ missing: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Missing.new

            subject.field 'bar'
            subject.existence 'bar'
            subject.null_value 'bar'

            assert_equal %w[ existence field null_value ],
                         subject.to_hash[:missing].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:missing][:field]
          end

          should "take a block" do
            subject = Missing.new do
              field 'bar'
            end
            assert_equal({missing: { field: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
