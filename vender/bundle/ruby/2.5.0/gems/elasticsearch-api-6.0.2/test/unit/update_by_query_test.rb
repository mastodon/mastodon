require 'test_helper'

module Elasticsearch
  module Test
    class UpdateByQueryTest < ::Test::Unit::TestCase

      context "Update by query" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/_update_by_query', url
            assert_equal Hash.new, params
            assert_equal nil, body
            true
          end.returns(FakeResponse.new)

          subject.update_by_query :index => 'foo'
        end

      end

    end
  end
end
