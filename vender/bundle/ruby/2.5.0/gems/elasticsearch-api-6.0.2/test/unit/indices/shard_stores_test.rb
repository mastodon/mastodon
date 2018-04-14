require 'test_helper'

module Elasticsearch
  module Test
    class IndicesShardStoresTest < ::Test::Unit::TestCase

      context "Indices: Shard stores" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_shard_stores', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.shard_stores
        end

      end

    end
  end
end
