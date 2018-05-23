require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class RegexpTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Regexp query" do
          subject { Regexp.new }

          should "be converted to a Hash" do
            assert_equal({ regexp: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Regexp.new :foo

            subject.value 'bar'
            subject.boost 'bar'
            subject.flags 'bar'

            assert_equal %w[ boost flags value ],
                         subject.to_hash[:regexp][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:regexp][:foo][:value]
          end

          should "take a Hash" do
            subject = Regexp.new foo: 'b.*r'
            assert_equal({regexp: { foo: 'b.*r' }}, subject.to_hash)
          end

          should "take a block" do
            subject = Regexp.new :foo do
              value 'bar'
            end
            assert_equal({regexp: { foo: { value: 'bar' } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
