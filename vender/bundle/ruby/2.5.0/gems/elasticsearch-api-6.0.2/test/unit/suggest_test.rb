require 'test_helper'

module Elasticsearch
  module Test
    class SuggestTest < ::Test::Unit::TestCase

      context "Suggest" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_suggest', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.suggest :body => {}
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_suggest', url
            true
          end.returns(FakeResponse.new)

          subject.suggest :index => 'foo', :body => {}
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_suggest', url
            assert_equal 'abc123', params[:routing]
            true
          end.returns(FakeResponse.new)

          subject.suggest :index => 'foo', :routing => 'abc123', :body => {}
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_suggest', url
            true
          end.returns(FakeResponse.new)

          subject.suggest :index => 'foo^bar', :body => {}
        end

        should "pass the request definition in the body" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_suggest', url
            assert_equal 'tset', body[:my_suggest][:text]
            true
          end.returns(FakeResponse.new)

          subject.suggest :body => { :my_suggest => { :text => 'tset' } }
        end

      end

    end
  end
end
