require 'test_helper'

module Elasticsearch
  module Test
    class ClusterRemoteInfoTest < ::Test::Unit::TestCase

      context "Cluster: Remote info" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_remote/info', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cluster.remote_info
        end

      end

    end
  end
end
