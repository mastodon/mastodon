require 'test_helper'

module Elasticsearch
  module Test
    class Cluster_Test < ::Test::Unit::TestCase

      context "Health" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cluster/health', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cluster.health
        end

        should "encode URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cluster/health', url
            assert_equal({:level => 'indices'}, params)
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cluster.health :level => 'indices'
        end

        should "return health for a specific index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_cluster/health/foo', url
            true
          end.returns(FakeResponse.new)

          subject.cluster.health :index => 'foo'
        end

      end

    end
  end
end
