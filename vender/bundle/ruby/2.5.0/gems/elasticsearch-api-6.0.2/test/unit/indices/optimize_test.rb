require 'test_helper'

module Elasticsearch
  module Test
    class IndicesOptimizeTest < ::Test::Unit::TestCase

      context "Indices: Optimize" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_optimize', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.optimize
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_optimize', url
            true
          end.returns(FakeResponse.new)

          subject.indices.optimize :index => ['foo','bar']
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_optimize', url
            assert_equal 1, params[:max_num_segments]
            true
          end.returns(FakeResponse.new)

          subject.indices.optimize :index => 'foo', :max_num_segments => 1
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_optimize', url
            true
          end.returns(FakeResponse.new)

          subject.indices.optimize :index => 'foo^bar'
        end

      end

    end
  end
end
