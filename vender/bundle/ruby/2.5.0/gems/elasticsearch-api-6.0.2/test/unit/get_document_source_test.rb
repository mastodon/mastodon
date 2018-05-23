require 'test_helper'

module Elasticsearch
  module Test
    class GetSourceTest < ::Test::Unit::TestCase

      context "Get document source" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.get_source :type => 'bar', :id => '1'
          end
        end

        should "NOT require the :type argument" do
          assert_nothing_raised do
            subject.get_source :index => 'foo', :id => '1'
          end
        end

        should "require the :id argument" do
          assert_raise ArgumentError do
            subject.get_source :index => 'foo', :type => 'bar'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo/bar/1/_source', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.get_source :index => 'foo', :type => 'bar', :id => '1'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/1/_source', url
            assert_equal 'abc123', params[:routing]
            true
          end.returns(FakeResponse.new)

          subject.get_source :index => 'foo', :type => 'bar', :id => '1', :routing => 'abc123'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/bar%2Fbam/1/_source', url
            true
          end.returns(FakeResponse.new)

          subject.get_source :index => 'foo^bar', :type => 'bar/bam', :id => '1'
        end

        should "catch a NotFound exception with the ignore parameter" do
          subject.expects(:perform_request).raises(NotFound)

          assert_nothing_raised do
            subject.get :index => 'foo', :type => 'bar', :id => 'XXX', :ignore => 404
          end
        end

      end

    end
  end
end
