require 'test_helper'

module Elasticsearch
  module Test
    class IndicesExistsTemplateTest < ::Test::Unit::TestCase

      context "Indices: Exists template" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'HEAD', method
            assert_equal '_template/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.exists_template :name => 'foo'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_template/bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.exists_template :name => 'bar/bam'
        end

        should "return true for successful response" do
          subject.expects(:perform_request).returns(FakeResponse.new 200, 'OK')
          assert_equal true, subject.indices.exists_template(:name => 'bar')
        end

        should "return false for 404 response" do
          subject.expects(:perform_request).returns(FakeResponse.new 404, 'Not Found')
          assert_equal false, subject.indices.exists_template(:name => 'none')
        end

        should "return false on 'not found' exceptions" do
          subject.expects(:perform_request).raises(StandardError.new '404 NotFound')
          assert_nothing_raised do
            assert_equal false, subject.indices.exists_template(:name => 'none')
          end
        end

        should "re-raise generic exceptions" do
          subject.expects(:perform_request).raises(StandardError)
          assert_raise(StandardError) do
            assert_equal false, subject.indices.exists_template(:name => 'none')
          end
        end

      end

    end
  end
end
