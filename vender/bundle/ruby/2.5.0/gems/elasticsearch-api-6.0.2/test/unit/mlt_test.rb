require 'test_helper'

module Elasticsearch
  module Test
    class MltTest < ::Test::Unit::TestCase

      context "More Like This" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.mlt :type => 'bar', :id => '1'
          end
        end

        should "require the :type argument" do
          assert_raise ArgumentError do
            subject.mlt :index => 'foo', :id => '1'
          end
        end

        should "require the :id argument" do
          assert_raise ArgumentError do
            subject.mlt :index => 'foo', :type => 'bar'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo/bar/1/_mlt', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.mlt :index => 'foo', :type => 'bar', :id => '1'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/1/_mlt', url
            assert_equal 1, params[:max_doc_freq]
            true
          end.returns(FakeResponse.new)

          subject.mlt :index => 'foo', :type => 'bar', :id => '1', :max_doc_freq => 1
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/bar%2Fbam/1/_mlt', url
            true
          end.returns(FakeResponse.new)

          subject.mlt :index => 'foo^bar', :type => 'bar/bam', :id => '1'
        end

        should "pass the specific parameters as a list" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar', params[:mlt_fields]
            assert_equal 'A,B',     params[:search_indices]
            assert_equal 'X,Y',     params[:search_types]
            assert_equal 'lam,bam', params[:stop_words]
            true
          end.returns(FakeResponse.new)

          subject.mlt :index => 'foo', :type => 'bar', :id => '1',
                      :mlt_fields     => ['foo', 'bar'],
                      :search_indices => ['A', 'B'],
                      :search_types   => ['X', 'Y'],
                      :stop_words     => ['lam','bam']
        end

        should "pass a specific search definition in body" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/1/_mlt', url
            assert_equal Hash.new, body[:query]
            true
          end.returns(FakeResponse.new)

          subject.mlt :index => 'foo', :type => 'bar', :id => '1', :body => { :query => {} }
        end

      end

    end
  end
end
