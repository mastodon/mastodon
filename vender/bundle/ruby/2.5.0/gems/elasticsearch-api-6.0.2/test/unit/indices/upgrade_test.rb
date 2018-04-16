require 'test_helper'

module Elasticsearch
  module Test
    class IndicesUpgradeTest < ::Test::Unit::TestCase

      context "Indices: Upgrade" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_upgrade', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.upgrade
        end

      end

    end
  end
end
