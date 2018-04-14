require 'test_helper'

module Elasticsearch
  module Test
    class IndicesValidateQueryTest < ::Test::Unit::TestCase

      context "Indices: Validate query" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_validate/query', url
            assert_equal Hash.new, params
            assert_nil body
            true
          end.returns(FakeResponse.new)

          subject.indices.validate_query
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_validate/query', url
            true
          end.returns(FakeResponse.new)

          subject.indices.validate_query :index => 'foo'
        end

        should "perform request against an index and type" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/_validate/query', url
            true
          end.returns(FakeResponse.new)

          subject.indices.validate_query :index => 'foo', :type => 'bar'
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_validate/query', url
            true
          end.returns(FakeResponse.new).twice

          subject.indices.validate_query :index => ['foo', 'bar']
          subject.indices.validate_query :index => 'foo,bar'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_validate/query', url
            assert_equal true, params[:explain]
            assert_equal 'foo', params[:q]
            true
          end.returns(FakeResponse.new)

          subject.indices.validate_query :explain => true, :q => 'foo'
        end

        should "pass the query definition in body" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_validate/query', url
            assert_equal Hash.new, body[:filtered]
            true
          end.returns(FakeResponse.new)

          subject.indices.validate_query :body => { :filtered => {} }
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_validate/query', url
            true
          end.returns(FakeResponse.new)

          subject.indices.validate_query :index => 'foo^bar', :body => {}
        end

      end

    end
  end
end
