require 'test_helper'

module Elasticsearch
  module Test
    class ListBenchmarksTest < ::Test::Unit::TestCase

      context "List benchmarks" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_bench', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.list_benchmarks
        end

      end

    end
  end
end
