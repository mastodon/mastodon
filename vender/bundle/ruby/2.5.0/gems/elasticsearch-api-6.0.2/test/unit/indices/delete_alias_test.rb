require 'test_helper'

module Elasticsearch
  module Test
    class IndicesDeleteAliasTest < ::Test::Unit::TestCase

      context "Indices: Delete alias" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.indices.delete_alias :name => 'bar'
          end
        end

        should "require the :name argument" do
          assert_raise ArgumentError do
            subject.indices.delete_alias :index => 'foo'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'DELETE', method
            assert_equal 'foo/_alias/bar', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_alias :index => 'foo', :name => 'bar'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_alias/bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_alias :index => 'foo^bar', :name => 'bar/bam'
        end

      end

    end
  end
end
