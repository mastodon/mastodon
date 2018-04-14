require 'test_helper'

module Elasticsearch
  module Test
    class NodesShutdownTest < ::Test::Unit::TestCase

      context "Nodes: Shutdown" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_cluster/nodes/_shutdown', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.nodes.shutdown
        end

        should "send :node_id correctly" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_cluster/nodes/foo/_shutdown', url
            true
          end.returns(FakeResponse.new)

          subject.nodes.shutdown :node_id => 'foo'
        end

        should "send multiple :node_id-s correctly" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_cluster/nodes/A,B,C/_shutdown', url
            true
          end.returns(FakeResponse.new).twice

          subject.nodes.shutdown :node_id => 'A,B,C'
          subject.nodes.shutdown :node_id => ['A', 'B', 'C']
        end

      end

    end
  end
end
