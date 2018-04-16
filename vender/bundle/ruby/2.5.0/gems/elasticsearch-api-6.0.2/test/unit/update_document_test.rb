require 'test_helper'

module Elasticsearch
  module Test
    class UpdateTest < ::Test::Unit::TestCase

      context "Update document" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.update :type => 'bar', :id => '1'
          end
        end

        should "require the :type argument" do
          assert_raise ArgumentError do
            subject.update :index => 'foo', :id => '1'
          end
        end

        should "require the :id argument" do
          assert_raise ArgumentError do
            subject.update :index => 'foo', :type => 'bar'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/bar/1/_update', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body[:doc]
            true
          end.returns(FakeResponse.new)

          subject.update :index => 'foo', :type => 'bar', :id => '1', :body => { :doc => {} }
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/1/_update', url
            assert_equal 100, params[:version]
            true
          end.returns(FakeResponse.new)

          subject.update :index => 'foo', :type => 'bar', :id => '1', :version => 100, :body => {}
        end

        should "validate URL parameters" do
          assert_raise ArgumentError do
            subject.update :index => 'foo', :type => 'bar', :id => '1', :body => { :doc => {} }, :qwertypoiuy => 'asdflkjhg'
          end
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/bar%2Fbam/1/_update', url
            true
          end.returns(FakeResponse.new)

          subject.update :index => 'foo^bar', :type => 'bar/bam', :id => '1', :body => {}
        end

        should "raise a NotFound exception" do
          subject.expects(:perform_request).raises(NotFound)

          assert_raise NotFound do
            subject.update :index => 'foo', :type => 'bar', :id => 'XXX'
          end
        end

        should "catch a NotFound exception with the ignore parameter" do
          subject.expects(:perform_request).raises(NotFound)

          assert_nothing_raised do
            subject.update :index => 'foo', :type => 'bar', :id => 'XXX', :ignore => 404
          end
        end

      end

    end
  end
end
