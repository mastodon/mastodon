require 'test_helper'

module Elasticsearch
  module Test
    class IndicesPutMappingTest < ::Test::Unit::TestCase

      context "Indices: Put mapping" do
        subject { FakeClient.new }

        should "require the :type argument" do
          assert_raise ArgumentError do
            subject.indices.put_mapping :index => 'foo', :body => {}
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal 'foo/_mapping/bar', url
            assert_equal Hash.new, params
            assert_equal({ :foo => {} }, body)
            true
          end.returns(FakeResponse.new)

          subject.indices.put_mapping :index => 'foo', :type => 'bar', :body => { :foo => {} }
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_mapping/bam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_mapping :index => ['foo','bar'], :type => 'bam', :body => {}
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_mapping/bar', url
            assert_equal true, params[:ignore_conflicts]
            true
          end.returns(FakeResponse.new)

          subject.indices.put_mapping :index => 'foo', :type => 'bar', :body => {}, :ignore_conflicts => true
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_mapping/bar%2Fbam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_mapping :index => 'foo^bar', :type => 'bar/bam', :body => {}
        end

      end

    end
  end
end
