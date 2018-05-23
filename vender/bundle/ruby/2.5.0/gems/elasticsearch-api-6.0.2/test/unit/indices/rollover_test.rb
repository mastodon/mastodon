require 'test_helper'

module Elasticsearch
  module Test
    class IndicesRolloverTest < ::Test::Unit::TestCase

      context "Indices: Rollover" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/_rollover', url
            assert_equal Hash.new, params
            assert_equal nil, body
            true
          end.returns(FakeResponse.new)

          subject.indices.rollover :alias => 'foo'
        end

        should "customize the index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/_rollover/bar', url
            assert_equal Hash.new, params
            assert_equal nil, body
            true
          end.returns(FakeResponse.new)

          subject.indices.rollover :alias => 'foo', :new_index => 'bar'
        end

      end

    end
  end
end
