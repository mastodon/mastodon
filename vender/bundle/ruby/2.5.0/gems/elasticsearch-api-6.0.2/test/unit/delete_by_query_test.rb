require 'test_helper'

module Elasticsearch
  module Test
    class DeleteByQueryTest < ::Test::Unit::TestCase

      context "Delete by query" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.delete_by_query :body => {}
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/_delete_by_query', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body[:term]
            true
          end.returns(FakeResponse.new)

          subject.delete_by_query :index => 'foo', :body => { :term => {} }
        end

        should "optionally take the :type argument" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/tweet,post/_delete_by_query', url
            true
          end.returns(FakeResponse.new)

          subject.delete_by_query :index => 'foo', :type => ['tweet', 'post'], :body => { :term => {} }
        end

        should "pass the query in URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_delete_by_query', url
            assert_equal 'foo:bar', params[:q]
            true
          end.returns(FakeResponse.new)

          subject.delete_by_query :index => 'foo', :q => 'foo:bar'
        end

      end

    end
  end
end
