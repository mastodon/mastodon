require 'test_helper'

module Elasticsearch
  module Test
    class IndicesPutSettingsTest < ::Test::Unit::TestCase

      context "Indices: Put settings" do
        subject { FakeClient.new }

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.indices.put_settings
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal '_settings', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.indices.put_settings :body => {}
        end

        should "perform request with parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal true, params[:flat_settings]
            true
          end.returns(FakeResponse.new)

          subject.indices.put_settings :index => 'foo', :flat_settings => true, :body => {}
        end

        should "perform request against a specific indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_settings', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_settings :index => 'foo', :body => {}
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_settings', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_settings :index => ['foo','bar'], :body => {}
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_settings', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_settings :index => 'foo^bar', :body => {}
        end

      end

    end
  end
end
