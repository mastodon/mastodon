require 'test_helper'

module Elasticsearch
  module Test
    module Queries
      class TemplateTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Queries

        context "Template query" do
          subject { Template.new }

          should "be converted to a Hash" do
            assert_equal({ template: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Template.new

            subject.query 'bar'
            subject.params 'bar'

            assert_equal %w[ params query ],
                         subject.to_hash[:template].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:template][:query]
          end

          should "take a hash" do
            subject = Template.new query: 'bar', params: { foo: 'abc' }
            assert_equal({template: { query: 'bar', params: { foo: 'abc' } } }, subject.to_hash)
          end

          should "take a block" do
            subject = Template.new do
              query 'bar'
              params foo: 'abc'
            end
            assert_equal({template: { query: 'bar', params: { foo: 'abc' } } }, subject.to_hash)
          end
        end
      end
    end
  end
end
