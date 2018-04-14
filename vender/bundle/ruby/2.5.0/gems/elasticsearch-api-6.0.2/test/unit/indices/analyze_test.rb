require 'test_helper'

module Elasticsearch
  module Test
    class IndicesAnalyzeTest < ::Test::Unit::TestCase

      context "Indices: Analyze" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_analyze', url
            assert_equal Hash.new, params
            assert_nil body
            true
          end.returns(FakeResponse.new)

          subject.indices.analyze
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_analyze', url
            true
          end.returns(FakeResponse.new)

          subject.indices.analyze :index => 'foo'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_analyze', url
            assert_equal 'foo', params[:text]
            assert_equal 'bar', params[:analyzer]
            true
          end.returns(FakeResponse.new)

          subject.indices.analyze :text => 'foo', :analyzer => 'bar'
        end

        should "pass the text in body" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_analyze', url
            assert_equal Hash.new, params
            assert_equal 'foo', body
            true
          end.returns(FakeResponse.new)

          subject.indices.analyze :body => 'foo'
        end

        should "pass the filters parameter as a list" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_analyze', url
            assert_equal 'foo,bar', params[:filters]
            true
          end.returns(FakeResponse.new)

          subject.indices.analyze :text => 'Test', :tokenizer => 'whitespace', :filters => ['foo,bar']
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_analyze', url
            true
          end.returns(FakeResponse.new)

          subject.indices.analyze :index => 'foo^bar', :text => 'Test'
        end

      end

    end
  end
end
