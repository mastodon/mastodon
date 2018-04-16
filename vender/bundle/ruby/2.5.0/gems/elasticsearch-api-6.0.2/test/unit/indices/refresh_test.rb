require 'test_helper'

module Elasticsearch
  module Test
    class IndicesRefreshTest < ::Test::Unit::TestCase

      context "Indices: Refresh" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_refresh', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.refresh
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_refresh', url
            true
          end.returns(FakeResponse.new)

          subject.indices.refresh :index => 'foo'
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_refresh', url
            true
          end.returns(FakeResponse.new).twice

          subject.indices.refresh :index => ['foo','bar']
          subject.indices.refresh :index => 'foo,bar'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_refresh', url
            assert_equal 'missing', params[:ignore_indices]
            true
          end.returns(FakeResponse.new)

          subject.indices.refresh :index => ['foo','bar'], :ignore_indices => 'missing'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_refresh', url
            true
          end.returns(FakeResponse.new)

          subject.indices.refresh :index => 'foo^bar'
        end

      end

    end
  end
end
