require 'test_helper'

module Elasticsearch
  module Test
    class ClusterStateTest < ::Test::Unit::TestCase

      context "Cluster: State" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cluster/state', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cluster.state
        end

        should "build the correct path" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_cluster/state/foo,bar', url
            assert_equal({}, params)
            true
          end.returns(FakeResponse.new)

          subject.cluster.state :metric => ['foo', 'bar']
        end

        should "send the API parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_cluster/state', url
            assert_equal({:index_templates => 'foo,bar'}, params)
            true
          end.returns(FakeResponse.new)

          subject.cluster.state :index_templates => ['foo', 'bar']
        end

      end

    end
  end
end
