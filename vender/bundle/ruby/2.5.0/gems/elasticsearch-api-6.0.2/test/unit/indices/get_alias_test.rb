require 'test_helper'

module Elasticsearch
  module Test
    class IndicesGetAliasTest < ::Test::Unit::TestCase

      context "Indices: Get alias" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_alias/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.get_alias :name => 'foo'
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_alias/bam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_alias :index => ['foo','bar'], :name => 'bam'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_alias/bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_alias :index => 'foo^bar', :name => 'bar/bam'
        end

      end

    end
  end
end
