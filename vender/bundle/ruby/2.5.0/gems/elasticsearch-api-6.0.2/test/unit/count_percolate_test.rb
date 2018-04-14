require 'test_helper'

module Elasticsearch
  module Test
    class CountPercolateTest < ::Test::Unit::TestCase

      context "Count percolate" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo/bar/_percolate/count', url
            assert_equal Hash.new, params
            assert_equal 'bar', body[:doc][:foo]
            true
          end.returns(FakeResponse.new)

          subject.count_percolate :index => 'foo', :type => 'bar', :body => { :doc => { :foo => 'bar' } }
        end

      end

    end
  end
end
