require 'test_helper'

module Elasticsearch
  module Test
    class TasksCancelTest < ::Test::Unit::TestCase

      context "Tasks: Cancel" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_tasks/_cancel', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.tasks.cancel
        end

        should "perform correct request with a task_id" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_tasks/foo/_cancel', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.tasks.cancel :task_id => 'foo'
        end

      end

    end
  end
end
