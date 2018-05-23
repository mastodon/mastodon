require 'test_helper'

module Elasticsearch
  module Test
    class PutTemplateTest < ::Test::Unit::TestCase

      context "Put template" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal '_search/template/foo', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.put_template :id => 'foo', :body => {}
        end

      end

    end
  end
end
