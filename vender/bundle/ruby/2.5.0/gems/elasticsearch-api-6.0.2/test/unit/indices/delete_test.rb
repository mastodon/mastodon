require 'test_helper'

module Elasticsearch
  module Test
    class IndicesDeleteTest < ::Test::Unit::TestCase

      context "Indices: Delete" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'DELETE', method
            assert_equal 'foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.delete :index => 'foo'
        end

        should "perform the request for more indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.delete :index => ['foo','bar']
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo', url
            assert_equal '1s', params[:timeout]
            true
          end.returns(FakeResponse.new)

          subject.indices.delete :index => 'foo', :timeout => '1s'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.delete :index => 'foo^bar'
        end

        should "raise a NotFound exception" do
          subject.expects(:perform_request).raises(NotFound)

          assert_raise NotFound do
            subject.indices.delete :index => 'foo'
          end
        end

        should "catch a NotFound exception with the ignore parameter" do
          subject.expects(:perform_request).raises(NotFound)

          assert_nothing_raised do
            subject.indices.delete :index => 'foo', :ignore => 404
          end
        end
      end

    end
  end
end
