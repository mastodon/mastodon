require 'test_helper'

module Elasticsearch
  module Test
    class InfoTest < ::Test::Unit::TestCase

      context "Info" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.info
        end

      end

    end
  end
end
