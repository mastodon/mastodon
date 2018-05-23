require 'test_helper'

module Elasticsearch
  module Test
    class IndexDocumentTest < ::Test::Unit::TestCase

      context "Creating a document with the #create method" do
        subject { FakeClient.new }

        should "perform the create request with a specific ID" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal 'foo/bar/123', url
            assert_equal 'create', params[:op_type]
            assert_nil   params[:id]
            assert_equal({:foo => 'bar'}, body)
            true
          end.returns(FakeResponse.new)

          subject.create :index => 'foo', :type => 'bar', :id => '123', :body => {:foo => 'bar'}
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar%2Fbam/123', url
            true
          end.returns(FakeResponse.new)

          subject.create :index => 'foo', :type => 'bar/bam', :id => '123', :body => {}
        end

        should "update the arguments with `op_type` when the `:id` argument is present" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/1', url
            assert_not_nil params[:op_type]
            true
          end.returns(FakeResponse.new)

          subject.create :index => 'foo', :type => 'bar', :id => 1, :body => { :foo => 'bar' }
        end

        should "pass the arguments when the `:id` argument is missing" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar', url
            assert_nil params[:op_type]
            assert_nil params[:id]
            true
          end.returns(FakeResponse.new)

          subject.create :index => 'foo', :type => 'bar', :body => { :foo => 'bar' }
        end
      end

    end
  end
end
