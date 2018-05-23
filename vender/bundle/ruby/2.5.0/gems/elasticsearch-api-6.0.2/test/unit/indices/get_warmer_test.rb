require 'test_helper'

module Elasticsearch
  module Test
    class IndicesGetWarmerTest < ::Test::Unit::TestCase

      context "Indices: Get warmer" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_all/_warmer', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.get_warmer :index => '_all'
        end

        should "return single warmer" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_warmer/bar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_warmer :index => 'foo', :name => 'bar'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_warmer/bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_warmer :index => 'foo^bar', :name => 'bar/bam'
        end

      end

    end
  end
end
