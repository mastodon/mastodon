require 'test_helper'

module Elasticsearch
  module Test
    class IndicesCreateTest < ::Test::Unit::TestCase

      context "Indices: Create" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.indices.create
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal 'foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.create :index => 'foo'
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo', url
            assert_equal '1s', params[:timeout]
            true
          end.returns(FakeResponse.new)

          subject.indices.create :index => 'foo', :timeout => '1s'
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar', url
            true
          end.returns(FakeResponse.new)

          subject.indices.create :index => 'foo^bar'
        end

      end

    end
  end
end
