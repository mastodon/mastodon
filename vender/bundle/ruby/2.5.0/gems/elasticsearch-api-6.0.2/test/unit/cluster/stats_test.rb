require 'test_helper'

module Elasticsearch
  module Test
    class ClusterStatsTest < ::Test::Unit::TestCase

      context "Cluster: Stats" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cluster/stats', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cluster.stats
        end

      end

    end
  end
end
