require 'test_helper'

module Elasticsearch
  module Test
    class CatHelpTest < ::Test::Unit::TestCase

      context "Cat: Help" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.help
        end

      end

    end
  end
end
