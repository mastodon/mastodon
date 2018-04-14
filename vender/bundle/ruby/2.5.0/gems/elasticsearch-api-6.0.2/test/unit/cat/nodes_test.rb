require 'test_helper'

module Elasticsearch
  module Test
    class CatNodesTest < ::Test::Unit::TestCase

      context "Cat: Nodes" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat/nodes', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.nodes
        end

      end

    end
  end
end
