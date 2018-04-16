require 'test_helper'

module Elasticsearch
  module Test
    class IndicesDeleteWarmerTest < ::Test::Unit::TestCase

      context "Indices: Delete warmer" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.indices.delete_warmer
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'DELETE', method
            assert_equal 'foo/_warmer', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_warmer :index => 'foo'
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_warmer', url
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_warmer :index => ['foo','bar']
        end

        should "perform request against single warmer" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_warmer/bar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_warmer :index => 'foo', :name => 'bar'
        end

        should "perform request against multiple warmers" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_warmer/bar,baz', url
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_warmer :index => 'foo', :name => ['bar', 'baz']
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_warmer/bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_warmer :index => 'foo^bar', :name => 'bar/bam'
        end

      end

    end
  end
end
