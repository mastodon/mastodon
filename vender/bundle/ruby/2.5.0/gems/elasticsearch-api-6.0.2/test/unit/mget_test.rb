require 'test_helper'

module Elasticsearch
  module Test
    class MgetTest < ::Test::Unit::TestCase

      context "Mget" do
        subject { FakeClient.new }

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.mget
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_mget', url
            assert_equal Hash.new, params
            assert_equal [], body[:docs]
            true
          end.returns(FakeResponse.new)

          subject.mget :body => { :docs => [] }
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_mget', url
            true
          end.returns(FakeResponse.new)

          subject.mget :index => 'foo', :body => {}
        end

        should "perform request against an index and type" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/_mget', url
            assert_equal ['1', '2'], body[:ids]
            true
          end.returns(FakeResponse.new)

          subject.mget :index => 'foo', :type => 'bar', :body => { :ids => ['1','2'] }
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_mget', url
            assert_equal true, params[:refresh]
            true
          end.returns(FakeResponse.new)

          subject.mget :body => {}, :refresh => true
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/bar%2Fbam/_mget', url
            true
          end.returns(FakeResponse.new)

          subject.mget :index => 'foo^bar', :type => 'bar/bam', :body => { :ids => ['1','2'] }
        end

        should "pass the fields parameter as a list" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar', params[:fields]
            true
          end.returns(FakeResponse.new)

          subject.mget :body => {}, :fields => ['foo', 'bar']
        end

      end

    end
  end
end
