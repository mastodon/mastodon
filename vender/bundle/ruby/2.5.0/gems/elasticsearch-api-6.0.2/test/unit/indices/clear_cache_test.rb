require 'test_helper'

module Elasticsearch
  module Test
    class IndicesClearCacheTest < ::Test::Unit::TestCase

      context "Indices: Clear cache" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_cache/clear', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.clear_cache
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_cache/clear', url
            true
          end.returns(FakeResponse.new)

          subject.indices.clear_cache :index => 'foo'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_cache/clear', url
            assert_equal true, params[:field_data]
            true
          end.returns(FakeResponse.new)

          subject.indices.clear_cache :field_data => true
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_cache/clear', url
            true
          end.returns(FakeResponse.new)

          subject.indices.clear_cache :index => 'foo^bar'
        end

      end

    end
  end
end
