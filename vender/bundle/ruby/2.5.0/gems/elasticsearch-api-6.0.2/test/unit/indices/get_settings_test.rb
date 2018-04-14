require 'test_helper'

module Elasticsearch
  module Test
    class IndicesGetSettingsTest < ::Test::Unit::TestCase

      context "Indices: Get settings" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_settings', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.get_settings
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_settings', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_settings :index => 'foo'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_settings', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_settings :index => 'foo^bar'
        end

        should "get specific settings" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_settings/foo.bar', url
            assert_equal Hash.new, params
            true
          end.returns(FakeResponse.new)

          subject.indices.get_settings :index => 'foo', :name => 'foo.bar'
        end

      end

    end
  end
end
