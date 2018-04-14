require 'test_helper'

module Elasticsearch
  module Test
    class IndicesFlushSyncedTest < ::Test::Unit::TestCase

      context "Indices: Flush synced" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'foo/_flush/synced', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.flush_synced :index => 'foo'
        end

        should "raise a NotFound exception" do
          subject.expects(:perform_request).raises(NotFound)

          assert_raise NotFound do
            subject.indices.flush_synced :index => 'foo'
          end
        end

        should "catch a NotFound exception with the ignore parameter" do
          subject.expects(:perform_request).raises(NotFound)

          assert_nothing_raised do
            subject.indices.flush_synced :index => 'foo', :ignore => 404
          end
        end
      end

    end
  end
end
