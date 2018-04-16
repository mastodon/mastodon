require 'test_helper'

module Elasticsearch
  module Test
    class IndicesShrinkTest < ::Test::Unit::TestCase

      context "Indices: Shrink" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal 'foo/_shrink/bar', url
            assert_equal nil, body
            true
          end.returns(FakeResponse.new)

          subject.indices.shrink :index => 'foo', :target => 'bar'
        end

        should "not change the arguments" do
          arguments = { :index => 'foo', :target => 'bar', :body => { :settings => {} } }
          subject.indices.shrink arguments

          assert_not_nil arguments[:index]
          assert_not_nil arguments[:target]
        end

      end

    end
  end
end
