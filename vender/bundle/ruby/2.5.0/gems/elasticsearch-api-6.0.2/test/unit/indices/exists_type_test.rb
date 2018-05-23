require 'test_helper'

module Elasticsearch
  module Test
    class IndicesExistsTypeTest < ::Test::Unit::TestCase

      context "Indices: Exists type" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'HEAD', method
            assert_equal 'foo/_mapping/bar', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.exists_type :index => 'foo', :type => 'bar'
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_mapping/bam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.exists_type :index => ['foo','bar'], :type => 'bam'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_mapping/bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.exists_type :index => 'foo^bar', :type => 'bar/bam'
        end

        should "return true for successful response" do
          subject.expects(:perform_request).returns(FakeResponse.new 200, 'OK')
          assert_equal true, subject.indices.exists_type(:index => 'foo', :type => 'bar')
        end

        should "return false for 404 response" do
          subject.expects(:perform_request).returns(FakeResponse.new 404, 'Not Found')
          assert_equal false, subject.indices.exists_type(:index => 'foo', :type => 'none')
        end

        should "return false on 'not found' exceptions" do
          subject.expects(:perform_request).raises(StandardError.new '404 NotFound')
          assert_nothing_raised do
            assert_equal false, subject.indices.exists_type(:index => 'foo', :type => 'none')
          end
        end

        should "re-raise generic exceptions" do
          subject.expects(:perform_request).raises(StandardError)
          assert_raise(StandardError) do
            assert_equal false, subject.indices.exists_type(:index => 'foo', :type => 'none')
          end
        end

        should "be aliased as predicate method" do
          assert_nothing_raised do
            subject.indices.exists_type?(:index => 'foo', :type => 'bar') == subject.indices.exists_type(:index => 'foo', :type => 'bar')
          end
        end
      end

    end
  end
end
