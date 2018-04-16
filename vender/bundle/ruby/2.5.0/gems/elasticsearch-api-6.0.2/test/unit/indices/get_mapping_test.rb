require 'test_helper'

module Elasticsearch
  module Test
    class IndicesGetMappingTest < ::Test::Unit::TestCase

      context "Indices: Get mapping" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_mapping', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.get_mapping
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_mapping', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_mapping :index => 'foo'
        end

        should "perform request against an index and type" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_mapping/bar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_mapping :index => 'foo', :type => 'bar'
        end

        should "perform request against multiple indices and types" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_mapping/bam,baz', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_mapping :index => ['foo', 'bar'], :type => ['bam', 'baz']
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_mapping/bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_mapping :index => 'foo^bar', :type => 'bar/bam'
        end

      end

    end
  end
end
