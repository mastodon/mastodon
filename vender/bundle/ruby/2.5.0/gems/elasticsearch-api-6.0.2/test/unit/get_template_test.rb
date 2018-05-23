require 'test_helper'

module Elasticsearch
  module Test
    class GetTemplateTest < ::Test::Unit::TestCase

      context "Get template" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_search/template/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.get_template :id => "foo"
        end

        should "raise a NotFound exception" do
          subject.expects(:perform_request).raises(NotFound)

          assert_raise NotFound do
            subject.get_template :id => "foo"
          end
        end

        should "catch a NotFound exception with the ignore parameter" do
          subject.expects(:perform_request).raises(NotFound)

          assert_nothing_raised do
            subject.get_template :id => "foo", :ignore => 404
          end
        end
      end

    end
  end
end
