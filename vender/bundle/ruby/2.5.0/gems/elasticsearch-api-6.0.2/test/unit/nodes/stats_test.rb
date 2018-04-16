require 'test_helper'

module Elasticsearch
  module Test
    class NodesStatsTest < ::Test::Unit::TestCase

      context "Nodes: Stats" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_nodes/stats', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.nodes.stats
        end

        should "send :node_id correctly" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_nodes/foo/stats', url
            true
          end.returns(FakeResponse.new)

          subject.nodes.stats :node_id => 'foo'
        end

        should "get specific metric families" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_nodes/stats/http,fs', url
            assert_equal( {}, params )
            true
          end.returns(FakeResponse.new)

          subject.nodes.stats :metric => [:http, :fs]
        end

        should "get specific metric for the indices family" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_nodes/stats/indices/filter_cache', url
            true
          end.returns(FakeResponse.new)

          subject.nodes.stats :metric => :indices, :index_metric => 'filter_cache'
        end

        should "get fielddata statistics for the indices family" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_nodes/stats/indices/fielddata', url
            assert_equal( {:fields => 'foo,bar'}, params )
            true
          end.returns(FakeResponse.new).twice

          subject.nodes.stats :metric => 'indices', :index_metric => 'fielddata', :fields => 'foo,bar'
          subject.nodes.stats :metric => 'indices', :index_metric => 'fielddata', :fields => ['foo','bar']
        end

      end

    end
  end
end
