require 'test_helper'

module Elasticsearch
  module Test
    class SnapshotRestoreTest < ::Test::Unit::TestCase

      context "Snapshot: Restore" do
        subject { FakeClient.new }

        should "require the :repository argument" do
          assert_raise ArgumentError do
            subject.snapshot.restore :snapshot => 'bar'
          end
        end

        should "require the :snapshot argument" do
          assert_raise ArgumentError do
            subject.snapshot.restore :repository => 'foo'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_snapshot/foo/bar/_restore', url
            assert_equal Hash.new, params
            assert_equal nil, body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.restore :repository => 'foo', :snapshot => 'bar'
        end

      end

    end
  end
end
