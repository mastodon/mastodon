require 'test_helper'

module Elasticsearch
  module Test
    class AbortBenchmarkTest < ::Test::Unit::TestCase

      context "Abort benchmark" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_bench/abort/foo', url
            assert_equal nil, params[:name]
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.abort_benchmark :name => 'foo'
        end

      end

    end
  end
end
