require 'test_helper'

module Elasticsearch
  module Test
    class TasksListTest < ::Test::Unit::TestCase

      context "Tasks: List" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_tasks', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.tasks.list
        end

        should "perform correct request with :task_id" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_tasks/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.tasks.list :task_id => 'foo'
        end

      end

    end
  end
end
