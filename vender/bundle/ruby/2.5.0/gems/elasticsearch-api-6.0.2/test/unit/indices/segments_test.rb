require 'test_helper'

module Elasticsearch
  module Test
    class IndicesSegmentsTest < ::Test::Unit::TestCase

      context "Indices: Segments" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_segments', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.segments
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_segments', url
            true
          end.returns(FakeResponse.new)

          subject.indices.segments :index => 'foo'
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_segments', url
            true
          end.returns(FakeResponse.new).twice

          subject.indices.segments :index => ['foo','bar']
          subject.indices.segments :index => 'foo,bar'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_segments', url
            assert_equal 'missing', params[:ignore_indices]
            true
          end.returns(FakeResponse.new)

          subject.indices.segments :index => ['foo','bar'], :ignore_indices => 'missing'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/_segments', url
            true
          end.returns(FakeResponse.new)

          subject.indices.segments :index => 'foo^bar'
        end

      end

    end
  end
end
