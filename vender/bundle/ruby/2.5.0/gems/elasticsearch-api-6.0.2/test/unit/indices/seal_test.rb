require 'test_helper'

module Elasticsearch
  module Test
    class IndicesSealTest < ::Test::Unit::TestCase

      context "Indices: Seal" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/_seal', url
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.seal :index => 'foo'
        end

      end

    end
  end
end
