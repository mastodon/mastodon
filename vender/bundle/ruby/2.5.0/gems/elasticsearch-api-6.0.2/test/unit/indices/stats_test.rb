require 'test_helper'

module Elasticsearch
  module Test
    class IndicesStatsTest < ::Test::Unit::TestCase

      context "Indices: Stats" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_stats', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.stats
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_stats', url
            true
          end.returns(FakeResponse.new)

          subject.indices.stats :index => 'foo'
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_stats', url
            true
          end.returns(FakeResponse.new).twice

          subject.indices.stats :index => ['foo','bar']
          subject.indices.stats :index => 'foo,bar'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_stats', url
            assert_equal true, params[:expand_wildcards]
            true
          end.returns(FakeResponse.new)

          subject.indices.stats :index => 'foo', :expand_wildcards => true
        end

        should "pass the fields parameter as a list" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_stats/fielddata', url
            assert_nil   params[:fielddata]
            assert_equal 'foo,bar', params[:fields]
            true
          end.returns(FakeResponse.new)

          subject.indices.stats :index => 'foo', :fielddata => true, :fields => ['foo', 'bar']
        end

        should "pass the groups parameter as a list" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_stats/search', url
            assert_equal 'groupA,groupB', params[:groups]
            true
          end.returns(FakeResponse.new)

          subject.indices.stats :search => true, :groups => ['groupA','groupB']
        end

      end

    end
  end
end
