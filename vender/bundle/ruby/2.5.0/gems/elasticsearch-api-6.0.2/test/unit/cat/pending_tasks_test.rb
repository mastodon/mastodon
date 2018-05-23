require 'test_helper'

module Elasticsearch
  module Test
    class CatPendingTasksTest < ::Test::Unit::TestCase

      context "Cat: Pending tasks" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat/pending_tasks', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.pending_tasks
        end

      end

    end
  end
end
