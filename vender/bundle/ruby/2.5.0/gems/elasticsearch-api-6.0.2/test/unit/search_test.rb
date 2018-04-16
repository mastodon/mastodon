require 'test_helper'

module Elasticsearch
  module Test
    class SearchTest < ::Test::Unit::TestCase

      context "Search" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_search', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.search
        end

        should "have default value for index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_all/foo/_search', url
            true
          end.returns(FakeResponse.new)

          subject.search :type => 'foo'
        end

        should "post a request definition in body" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal :match, body[:query].keys.first
            true
          end.returns(FakeResponse.new)

          subject.search :body => { :query => { :match => {} } }
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_search', url
            true
          end.returns(FakeResponse.new)

          subject.search :index => 'foo'
        end

        should "perform request against an index and type" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/_search', url
            true
          end.returns(FakeResponse.new)

          subject.search :index => 'foo', :type => 'bar'
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_search', url
            true
          end.returns(FakeResponse.new).twice

          subject.search :index => ['foo', 'bar']
          subject.search :index => 'foo,bar'
        end

        should "perform request against multiple indices and types" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/lam,bam/_search', url
            true
          end.returns(FakeResponse.new).twice

          subject.search :index => ['foo', 'bar'], :type => ['lam', 'bam']
          subject.search :index => 'foo,bar', :type => 'lam,bam'
        end

        should "encode URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_search', url
            assert_equal 'count', params[:search_type]
            true
          end.returns(FakeResponse.new)

          subject.search :search_type => 'count'
        end

        should "validate URL parameters" do
          assert_raise ArgumentError do
            subject.search :search_type => 'count', :qwertypoiuy => 'asdflkjhg'
          end
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/bar%2Fbam/_search', url
            true
          end.returns(FakeResponse.new)

          subject.search :index => 'foo^bar', :type => 'bar/bam'
        end

        should "not URL-escape the fields parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo^bar', params[:fields]
            true
          end.returns(FakeResponse.new)

          subject.search :index => 'foo', :type => 'bar', :fields => 'foo^bar'
        end
      end

    end
  end
end
