require 'test_helper'

module Elasticsearch
  module Test
    class ExistsTest < ::Test::Unit::TestCase

      context "Exists document" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.exists :type => 'bar', :id => '1'
          end
        end

        should "NOT require the :type argument" do
          assert_nothing_raised do
            subject.exists :index => 'foo', :id => '1'
          end
        end

        should "require the :id argument" do
          assert_raise ArgumentError do
            subject.exists :index => 'foo', :type => 'bar'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'HEAD', method
            assert_equal 'foo/bar/1', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.exists :index => 'foo', :type => 'bar', :id => '1'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/1', url
            assert_equal 'abc123', params[:routing]
            true
          end.returns(FakeResponse.new)

          subject.exists :index => 'foo', :type => 'bar', :id => '1', :routing => 'abc123'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar%2Fbam/1', url
            true
          end.returns(FakeResponse.new)

          subject.exists :index => 'foo', :type => 'bar/bam', :id => '1'
        end

        should "return true for successful response" do
          subject.expects(:perform_request).returns(FakeResponse.new 200, 'OK')
          assert_equal true, subject.exists(:index => 'foo', :type => 'bar', :id => '1')
        end

        should "return false for 404 response" do
          subject.expects(:perform_request).returns(FakeResponse.new 404, 'Not Found')
          assert_equal false, subject.exists(:index => 'foo', :type => 'bar', :id => '1')
        end

        should "return false on 'not found' exceptions" do
          subject.expects(:perform_request).raises(StandardError.new '404 NotFound')
          assert_equal false, subject.exists(:index => 'foo', :type => 'bar', :id => '1')
        end

        should "re-raise generic exceptions" do
          subject.expects(:perform_request).raises(StandardError)
          assert_raise(StandardError) do
            assert_equal false, subject.exists(:index => 'foo', :type => 'bar', :id => '1')
          end
        end

        should "be aliased as predicate method" do
          assert_nothing_raised do
            subject.exists?(:index => 'foo', :type => 'bar', :id => '1') == subject.exists(:index => 'foo', :type => 'bar', :id => '1')
          end
        end
      end

    end
  end
end
