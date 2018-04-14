require 'test_helper'

module Elasticsearch
  module Test
    class IndicesDeleteTemplateTest < ::Test::Unit::TestCase

      context "Indices: Delete template" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'DELETE', method
            assert_equal '_template/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_template :name => 'foo'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_template/foo%5Ebar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.delete_template :name => 'foo^bar'
        end

        should "raise a NotFound exception" do
          subject.expects(:perform_request).raises(NotFound)

          assert_raise NotFound do
            assert ! subject.indices.delete_template(:name => 'foo')
          end
        end

        should "catch a NotFound exception with the ignore parameter" do
          subject.expects(:perform_request).raises(NotFound)

          assert_nothing_raised do
            assert ! subject.indices.delete_template(:name => 'foo', :ignore => 404)
          end
        end

      end

    end
  end
end
