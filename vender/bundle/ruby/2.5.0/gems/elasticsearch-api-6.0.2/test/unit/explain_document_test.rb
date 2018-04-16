require 'test_helper'

module Elasticsearch
  module Test
    class ExplainTest < ::Test::Unit::TestCase

      context "Explain document" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.explain :type => 'bar', :id => '1'
          end
        end

        should "require the :type argument" do
          assert_raise ArgumentError do
            subject.explain :index => 'foo', :id => '1'
          end
        end

        should "require the :id argument" do
          assert_raise ArgumentError do
            subject.explain :index => 'foo', :type => 'bar'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo/bar/1/_explain', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.explain :index => 'foo', :type => 'bar', :id => 1, :body => {}
        end

        should "pass the query in URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/1/_explain', url
            assert_equal 'foo', params[:q]
            true
          end.returns(FakeResponse.new)

          subject.explain :index => 'foo', :type => 'bar', :id => 1, :q => 'foo'
        end

        should "pass the request definition in the body" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/1/_explain', url
            assert_equal Hash.new, body[:query][:match]
            true
          end.returns(FakeResponse.new)

          subject.explain :index => 'foo', :type => 'bar', :id => 1, :body => { :query => { :match => {} } }
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/bar%2Fbam/1/_explain', url
            true
          end.returns(FakeResponse.new)

          subject.explain :index => 'foo^bar', :type => 'bar/bam', :id => '1', :body => {}
        end

      end

    end
  end
end
