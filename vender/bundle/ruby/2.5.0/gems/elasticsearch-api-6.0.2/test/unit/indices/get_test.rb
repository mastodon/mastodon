require 'test_helper'

module Elasticsearch
  module Test
    class IndicesGetTest < ::Test::Unit::TestCase

      context "Indices: Get" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.get :index => 'foo'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo', url
            assert_equal 1, params[:ignore_unavailable]
            true
          end.returns(FakeResponse.new)

          subject.indices.get :index => 'foo', :ignore_unavailable => 1
        end

        should "encode features in URL" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_settings', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get :index => 'foo', :feature => '_settings'
        end

      end

    end
  end
end
