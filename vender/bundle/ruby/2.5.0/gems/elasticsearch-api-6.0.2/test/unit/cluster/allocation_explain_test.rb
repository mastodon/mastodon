require 'test_helper'

module Elasticsearch
  module Test
    class ClusterAllocationExplainTest < ::Test::Unit::TestCase

      context "Cluster: Allocation explain" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cluster/allocation/explain', url
            assert_equal Hash.new, params
            assert_equal nil, body
            true
          end.returns(FakeResponse.new)

          subject.cluster.allocation_explain
        end

      end

    end
  end
end
