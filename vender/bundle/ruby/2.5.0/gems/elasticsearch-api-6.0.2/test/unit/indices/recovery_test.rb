require 'test_helper'

module Elasticsearch
  module Test
    class IndicesRecoveryTest < ::Test::Unit::TestCase

      context "Indices: Recovery" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo/_recovery', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.recovery :index => 'foo'
        end

      end

    end
  end
end
