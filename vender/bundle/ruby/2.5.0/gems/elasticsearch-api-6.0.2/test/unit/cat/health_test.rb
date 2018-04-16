require 'test_helper'

module Elasticsearch
  module Test
    class CatHealthTest < ::Test::Unit::TestCase

      context "Cat: Health" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat/health', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.health
        end

      end

    end
  end
end
