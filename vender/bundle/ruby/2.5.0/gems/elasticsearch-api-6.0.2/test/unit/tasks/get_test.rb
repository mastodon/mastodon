require 'test_helper'

module Elasticsearch
  module Test
    class TasksGetTest < ::Test::Unit::TestCase

      context "Tasks: Get" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_tasks/foo1', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.tasks.get :task_id => 'foo1'
        end

      end

    end
  end
end
