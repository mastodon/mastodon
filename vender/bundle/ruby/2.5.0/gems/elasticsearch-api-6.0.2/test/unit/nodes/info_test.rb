require 'test_helper'

module Elasticsearch
  module Test
    class NodesInfoTest < ::Test::Unit::TestCase

      context "Nodes: Info" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_nodes', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.nodes.info
        end

        should "send :node_id correctly" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_nodes/foo', url
            true
          end.returns(FakeResponse.new)

          subject.nodes.info :node_id => 'foo'
        end

        should "send multiple :node_id-s correctly" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_nodes/A,B,C', url
            true
          end.returns(FakeResponse.new).twice

          subject.nodes.info :node_id => 'A,B,C'
          subject.nodes.info :node_id => ['A', 'B', 'C']
        end

        should "properly pass URL parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_same_elements ['http','jvm'], url.split('/').last.split(',')
            assert_nil   params[:jvm]
            assert_nil   params[:http]
            true
          end.returns(FakeResponse.new)

          subject.nodes.info :jvm => true, :http => true
        end

        should "properly pass URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_nodes', url
            assert_equal 'yaml',   params[:format]
            true
          end.returns(FakeResponse.new)

          subject.nodes.info :format => 'yaml'
        end

        should "encode metrics" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_nodes/http,network', url
            assert_nil   params[:metric]
            true
          end.returns(FakeResponse.new)

          subject.nodes.info :metric => ['http', 'network']
        end
      end

    end
  end
end
