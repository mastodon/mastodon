require 'test_helper'

module Elasticsearch
  module Test
    class BenchmarkTest < ::Test::Unit::TestCase

      context "Benchmark" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal '_bench', url
            assert_equal Hash.new, params
            assert_equal 'foo', body[:name]
            true
          end.returns(FakeResponse.new)

          subject.benchmark :body => { :name => 'foo' }
        end

      end

    end
  end
end
