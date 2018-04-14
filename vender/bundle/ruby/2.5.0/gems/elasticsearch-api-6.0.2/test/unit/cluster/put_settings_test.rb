require 'test_helper'

module Elasticsearch
  module Test
    class ClusterPutSettingsTest < ::Test::Unit::TestCase

      context "Cluster: Put settings" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal '_cluster/settings', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.cluster.put_settings
        end

      end

    end
  end
end
