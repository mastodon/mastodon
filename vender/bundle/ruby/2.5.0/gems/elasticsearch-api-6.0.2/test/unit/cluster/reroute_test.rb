require 'test_helper'

module Elasticsearch
  module Test
    class ClusterRerouteTest < ::Test::Unit::TestCase

      context "Cluster: Reroute" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_cluster/reroute', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.cluster.reroute
        end

        should "send the body" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_cluster/reroute', url
            assert_equal Hash.new, params
            assert_equal({:commands => [ :move => { :index => 'myindex', :shard => 0 } ]}, body)
            true
          end.returns(FakeResponse.new)

          subject.cluster.reroute :body => { :commands => [ :move => { :index => 'myindex', :shard => 0 } ] }
        end

      end

    end
  end
end
