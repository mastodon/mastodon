require 'test_helper'

module Elasticsearch
  module Test
    class IndicesExistsTest < ::Test::Unit::TestCase

      context "Indices: Exists" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'HEAD', method
            assert_equal 'foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.exists(:index => 'foo')
        end

        should "perform the request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.exists(:index => ['foo', 'bar'])
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar,bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.exists :index => 'foo^bar,bar/bam'
        end

        should "return true for successful response" do
          subject.expects(:perform_request).returns(FakeResponse.new 200, 'OK')
          assert_equal true, subject.indices.exists(:index => 'foo')
        end

        should "return false for 404 response" do
          subject.expects(:perform_request).returns(FakeResponse.new 404, 'Not Found')
          assert_equal false, subject.indices.exists(:index => 'none')
        end

        should "return false on 'not found' exceptions" do
          subject.expects(:perform_request).raises(StandardError.new '404 NotFound')
          assert_equal false, subject.indices.exists(:index => 'none')
        end

        should "re-raise generic exceptions" do
          subject.expects(:perform_request).raises(StandardError)
          assert_raise(StandardError) do
            assert_equal false, subject.indices.exists(:index => 'none')
          end
        end

        should "be aliased as predicate method" do
          assert_nothing_raised do
            subject.indices.exists?(:index => 'foo') == subject.indices.exists(:index => 'foo')
          end
        end
      end

    end
  end
end
