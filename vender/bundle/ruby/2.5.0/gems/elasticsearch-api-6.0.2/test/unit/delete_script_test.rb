require 'test_helper'

module Elasticsearch
  module Test
    class DeleteScriptTest < ::Test::Unit::TestCase

      context "Delete script" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'DELETE', method
            assert_equal '_scripts/groovy/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.delete_script :lang => "groovy", :id => "foo"
        end

      end

    end
  end
end
