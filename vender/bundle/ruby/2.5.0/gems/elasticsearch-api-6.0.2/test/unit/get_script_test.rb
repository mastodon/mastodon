require 'test_helper'

module Elasticsearch
  module Test
    class GetScriptTest < ::Test::Unit::TestCase

      context "Get script" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_scripts/groovy/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.get_script :lang => "groovy", :id => 'foo'
        end

      end

    end
  end
end
