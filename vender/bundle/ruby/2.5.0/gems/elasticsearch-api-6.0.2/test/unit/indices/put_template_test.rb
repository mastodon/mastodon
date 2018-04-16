require 'test_helper'

module Elasticsearch
  module Test
    class IndicesPutTemplateTest < ::Test::Unit::TestCase

      context "Indices: Put template" do
        subject { FakeClient.new }

        should "require the :name argument" do
          assert_raise ArgumentError do
            subject.indices.put_template :body => {}
          end
        end

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.indices.put_template :name => 'foo'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal '_template/foo', url
            assert_equal Hash.new, params
            assert_equal 'bar', body[:template]
            true
          end.returns(FakeResponse.new)

          subject.indices.put_template :name => 'foo', :body => { :template => 'bar' }
        end

         should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_template/foo', url
            assert_equal 3, params[:order]
            true
          end.returns(FakeResponse.new)

          subject.indices.put_template :name => 'foo', :body => {}, :order => 3
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_template/foo%5Ebar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_template :name => 'foo^bar', :body => {}
        end

      end

    end
  end
end
