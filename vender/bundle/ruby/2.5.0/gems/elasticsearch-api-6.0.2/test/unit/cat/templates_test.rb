require 'test_helper'

module Elasticsearch
  module Test
    class CatTemplatesTest < ::Test::Unit::TestCase

      context "Cat: Templates" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat/templates', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.templates
        end

      end

    end
  end
end
