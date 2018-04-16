require 'test_helper'

module Elasticsearch
  module Test
    class IndexDocumentTest < ::Test::Unit::TestCase

      context "Indexing a document" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.index :type => 'foo'
          end
        end

        should "require the :type argument" do
          assert_raise ArgumentError do
            subject.index :index => 'foo'
          end
        end

        should "perform the index request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/bar', url
            assert_equal({:foo => 'bar'}, body)
            true
          end.returns(FakeResponse.new)

          subject.index :index => 'foo', :type => 'bar', :body => {:foo => 'bar'}
        end

        should "perform the index request with a specific ID" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal 'foo/bar/123', url
            assert_nil   params[:id]
            assert_equal({:foo => 'bar'}, body)
            true
          end.returns(FakeResponse.new)

          subject.index :index => 'foo', :type => 'bar', :id => '123', :body => {:foo => 'bar'}
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar%2Fbam/123', url
            true
          end.returns(FakeResponse.new)

          subject.index :index => 'foo', :type => 'bar/bam', :id => '123', :body => {}
        end

        should "validate URL parameters" do
          assert_raise ArgumentError do
            subject.index :index => 'foo', :type => 'bar/bam', :id => '123', :body => {}, :qwertypoiuy => 'asdflkjhg'
          end
        end
      end

      context "Creating a document" do
        subject { FakeClient.new }

        should "perform the create request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/bar', url
            assert_equal({:op_type => 'create'}, params)
            assert_equal({:foo => 'bar'}, body)
            true
          end.returns(FakeResponse.new)

          subject.index :index => 'foo', :type => 'bar', :op_type => 'create', :body => {:foo => 'bar'}
        end

        should "perform the create request with a specific ID" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal 'foo/bar/123', url
            assert_equal 'create', params[:op_type]
            assert_nil   params[:id]
            assert_equal({:foo => 'bar'}, body)
            true
          end.returns(FakeResponse.new)

          subject.index :index => 'foo', :type => 'bar', :id => '123', :op_type => 'create', :body => {:foo => 'bar'}
        end
      end

    end
  end
end
