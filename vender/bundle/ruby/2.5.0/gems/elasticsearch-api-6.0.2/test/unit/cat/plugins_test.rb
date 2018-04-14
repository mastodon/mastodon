require 'test_helper'

module Elasticsearch
  module Test
    class CatPluginsTest < ::Test::Unit::TestCase

      context "Cat: Plugins" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat/plugins', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.plugins
        end

      end

    end
  end
end
